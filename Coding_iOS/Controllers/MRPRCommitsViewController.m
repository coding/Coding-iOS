//
//  MRPRCommitsViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPRCommitsViewController.h"
#import "CommitListCell.h"

#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"

#import "CommitFilesViewController.h"


@interface MRPRCommitsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray *listGroups;
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@end

@implementation MRPRCommitsViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"#%@", _curMRPR.iid.stringValue];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableBG;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[CommitListCell class] forCellReuseIdentifier:kCellIdentifier_CommitListCell];
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
    if (_curMRPR.isLoading) {
        return;
    }
    if (_listGroups.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_MRPRCommits_WithObj:_curMRPR andBlock:^(NSArray *data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            [weakSelf configListGroupsWithCommitList:data];
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(_listGroups.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

- (void)configListGroupsWithCommitList:(NSArray *)commitList{
    if (!_listGroups) {
        _listGroups = [NSMutableArray new];
    }
    [_listGroups removeAllObjects];
    
    NSMutableArray *valueList = nil;
    for (int i = 0; i < commitList.count; i++) {
        Commit *preCommit = [valueList lastObject];
        Commit *curCommit = commitList[i];
        if (preCommit && [curCommit.commitTime isSameDay:preCommit.commitTime]) {
            [valueList addObject:curCommit];
        }else{
            valueList = [NSMutableArray new];
            [_listGroups addObject:valueList];
            [valueList addObject:curCommit];
        }
    }
}

#pragma mark TableViewHeader
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kScaleFrom_iPhone5_Desgin(24);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    Commit *curCommit = [[_listGroups objectAtIndex:section] firstObject];
    return [tableView getHeaderViewWithStr:[curCommit.commitTime string_yyyy_MM_dd_EEE] andBlock:^(id obj) {
        DebugLog(@"\nitem.date.description :%@", curCommit.commitTime.description);
    }];
}

#pragma mark Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *curList = [_listGroups objectAtIndex:section];
    return curList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *curList = [_listGroups objectAtIndex:indexPath.section];
    Commit *curCommit = [curList objectAtIndex:indexPath.row];
    CommitListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_CommitListCell forIndexPath:indexPath];
    cell.curCommit = curCommit;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [CommitListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *curList = [_listGroups objectAtIndex:indexPath.section];
    Commit *curCommit = [curList objectAtIndex:indexPath.row];
    DebugLog(@"%@", curCommit.fullMessage);
    
    CommitFilesViewController *vc = [CommitFilesViewController new];
    vc.curProject = _curProject;
    vc.ownerGK = _curMRPR.des_owner_name;
    vc.projectName = _curMRPR.des_project_name;
    vc.commitId = curCommit.commitId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
