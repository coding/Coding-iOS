//
//  TeamListViewController.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TeamListViewController.h"
#import "ODRefreshControl.h"
#import "TeamListCell.h"
#import "Coding_NetAPIManager.h"
#import "TeamViewController.h"

@interface TeamListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSArray *teamList;
@end

@implementation TeamListViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"团队列表";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[TeamListCell class] forCellReuseIdentifier:kCellIdentifier_TeamListCell];
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
    if (_teamList.count <= 0) {
        [self.view beginLoading];
    }
    ESWeak(self, weakSelf);
    [[Coding_NetAPIManager sharedManager] request_JoinedTeamsBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.teamList = data;
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.myTableView configBlankPage:EaseBlankPageTypeTeam hasData:(weakSelf.teamList.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _teamList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TeamListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TeamListCell forIndexPath:indexPath];
    cell.curTeam = _teamList[indexPath.row];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [TeamListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TeamViewController *vc = [TeamViewController new];
    vc.curTeam = _teamList[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
