//
//  TeamProjectsViewController.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TeamProjectsViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "ProjectListCell.h"
#import "NProjectViewController.h"
#import "Login.h"

@interface TeamProjectsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSArray *joinedList, *unjoinedList;
@end

@implementation TeamProjectsViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = _curTeam.name;
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
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)refresh{
    if (_joinedList.count + _unjoinedList.count <= 0) {
        [self.view beginLoading];
    }
    ESWeak(self, weakSelf);
    void (^requestFinishedBlock)(NSError *) = ^(NSError *error){
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.myTableView reloadData];
        [weakSelf.myTableView configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.joinedList.count + weakSelf.unjoinedList.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    };
    
    [[Coding_NetAPIManager sharedManager] request_ProjectsInTeam:_curTeam isJoined:YES andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.joinedList = data;
        }
        if ([weakSelf needToShowUnjoined]) {
            [[Coding_NetAPIManager sharedManager] request_ProjectsInTeam:weakSelf.curTeam isJoined:NO andBlock:^(id dataU, NSError *errorU) {
                if (dataU) {
                    weakSelf.unjoinedList = dataU;
                }
                requestFinishedBlock(errorU);
            }];
        }else{
            weakSelf.unjoinedList = nil;
            requestFinishedBlock(error);
        }
    }];
}

- (BOOL)needToShowUnjoined{
    return _curTeam.current_user_role_id.integerValue > 80;
}

#pragma mark Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self needToShowUnjoined]? 2: 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0? _joinedList.count > 0? 30: 0: _unjoinedList.count > 0? 30: 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [tableView getHeaderViewWithStr:section == 0? @"我参与的": @"我未参与的" andBlock:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0? _joinedList.count: _unjoinedList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectList forIndexPath:indexPath];
    Project *curPro = indexPath.section == 0? _joinedList[indexPath.row]: _unjoinedList[indexPath.row];
    [cell setProject:curPro hasSWButtons:NO hasBadgeTip:YES hasIndicator:YES];
    cell.backgroundColor = kColorTableBG;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Project *curPro = indexPath.section == 0? _joinedList[indexPath.row]: _unjoinedList[indexPath.row];
    NProjectViewController *vc = [NProjectViewController new];
    vc.myProject = curPro;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
