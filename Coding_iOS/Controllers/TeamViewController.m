//
//  TeamViewController.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TeamViewController.h"
#import "ODRefreshControl.h"
#import "TeamTopCell.h"
#import "TitleDisclosureCell.h"
#import "Coding_NetAPIManager.h"

#import "TeamProjectsViewController.h"
#import "TeamMembersViewController.h"

@interface TeamViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@end

@implementation TeamViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"团队首页";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[TeamTopCell class] forCellReuseIdentifier:kCellIdentifier_TeamTopCell];
        [tableView registerClass:[TitleDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_TitleDisclosure];
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
    ESWeak(self, weakSelf);
    [[Coding_NetAPIManager sharedManager] request_DetailOfTeam:_curTeam andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.curTeam = data;
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0? 0: 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0? 1: 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TeamTopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TeamTopCell forIndexPath:indexPath];
        cell.curTeam = _curTeam;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        TitleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleDisclosure forIndexPath:indexPath];
        [cell setTitleStr:indexPath.row == 0? @"团队项目": @"团队成员"];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0? [TeamTopCell cellHeight]: 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            TeamProjectsViewController *vc = [TeamProjectsViewController new];
            vc.curTeam = _curTeam;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            TeamMembersViewController *vc = [TeamMembersViewController new];
            vc.curTeam = _curTeam;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
