//
//  EditMemberTypeProjectListViewController.m
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/6/6.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "EditMemberTypeProjectListViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "ProjectListCell.h"
#import "ProjectRole.h"
#import "ValueListViewController.h"

@interface EditMemberTypeProjectListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSArray *dataList;
@end

@implementation EditMemberTypeProjectListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择项目";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ProjectListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectList];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)refresh{
    if (_dataList.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectRoleOfUser:_curMember.user.global_key andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.dataList = data;
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectList forIndexPath:indexPath];
    ProjectRole *curR = _dataList[indexPath.row];
    [cell setProjectRole:curR];
    cell.backgroundColor = kColorTableBG;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ProjectRole *curRole = _dataList[indexPath.row];
    __weak typeof(self) weakSelf = self;
    __weak typeof(curRole) weakRole = curRole;
    ValueListViewController *vc = [ValueListViewController new];
    NSMutableArray *valueList = @[@"受限成员", @"普通成员", @"管理员", @"无"].mutableCopy;
    NSArray *typeRawList = @[@75, @80, @90, @(-1)];
    
    [vc setTitle:@"设置项目权限" valueList:valueList defaultSelectIndex:[typeRawList indexOfObject:curRole.type] type:ValueListTypeProjectMemberType selectBlock:^(NSInteger index) {
        NSNumber *editType = typeRawList[index];
        if (![weakRole.type isEqualToNumber:editType]) {
            [[Coding_NetAPIManager sharedManager] request_EditTypeOfUser:weakSelf.curMember.user.global_key inProjects:@[weakRole.project_id] roles:@[editType] andBlock:^(id data, NSError *error) {
                if (data) {
                    weakRole.type = editType;
                    [weakSelf.myTableView reloadData];
                }
            }];
        }
    }];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
