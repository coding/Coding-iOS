//
//  RATaskBoardListListViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/28.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "RATaskBoardListListViewController.h"
#import "ValueListCell.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"

@interface RATaskBoardListListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;

@property (strong, nonatomic) NSArray<EABoardTaskList *> *myBoardTLs;
@end

@implementation RATaskBoardListListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"看板列表";
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ValueListCell class] forCellReuseIdentifier:kCellIdentifier_ValueList];
        tableView.backgroundColor = kColorTableSectionBg;
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
    if (_myBoardTLs.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;;
    [[Coding_NetAPIManager sharedManager] request_BoardTaskListsInPro:_curPro andBlock:^(NSArray<EABoardTaskList *> *data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.myBoardTLs = data;
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:weakSelf.myBoardTLs.count > 0 hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark TableM

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.myBoardTLs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ValueListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ValueList forIndexPath:indexPath];
    [cell setTitleStr:_myBoardTLs[indexPath.row].title imageStr:nil isSelected:[_selectedBoardTL.id isEqualToNumber:_myBoardTLs[indexPath.row].id]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (!_needToShowDoneBoardTL && _myBoardTLs[indexPath.row].type == EABoardTaskListDone)? 0: 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 30)];
    headerView.backgroundColor = kColorTableSectionBg;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedBoardTL = _myBoardTLs[indexPath.row];
    [self.myTableView reloadData];
    if (self.selectedBlock) {
        self.selectedBlock(_selectedBoardTL);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
