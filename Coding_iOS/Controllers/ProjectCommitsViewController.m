//
//  ProjectCommitsViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectCommitsViewController.h"
#import "CommitListCell.h"

#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"

#import "Coding_NetAPIManager.h"

#import "CommitFilesViewController.h"

@interface ProjectCommitsViewController ()
<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@end

@implementation ProjectCommitsViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    if (_curCommits.path.length > 0) {
        self.title = [NSString stringWithFormat:@"%@ : /%@", _curCommits.ref, _curCommits.path];
    }else{
        self.title = _curCommits.ref;
    }
    
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
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore:YES];
    }];
    
    [self refresh];
}

- (void)refresh{
    [self refreshMore:NO];
}

- (void)refreshMore:(BOOL)willLoadMore{
    if (_curCommits.isLoading) {
        return;
    }
    
    if (willLoadMore && !_curCommits.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }

    _curCommits.willLoadMore = willLoadMore;
    if (_curCommits.list.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    
    [[Coding_NetAPIManager sharedManager] request_Commits:_curCommits withPro:_curProject andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.curCommits configWithCommits:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = [weakSelf curCommits].canLoadMore;
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.curCommits.list > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark TableViewHeader
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kScaleFrom_iPhone5_Desgin(24);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ListGroupItem *item = [_curCommits.listGroups objectAtIndex:section];
    return [tableView getHeaderViewWithStr:[item.date string_yyyy_MM_dd_EEE] andBlock:^(id obj) {
        DebugLog(@"\nitem.date.description :%@", item.date.description);
    }];
}

#pragma mark Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _curCommits.listGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ListGroupItem *item = [_curCommits.listGroups objectAtIndex:section];
    return item.length;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ListGroupItem *item = [_curCommits.listGroups objectAtIndex:indexPath.section];
    NSInteger row = indexPath.row + item.location;
    Commit *curCommit = [_curCommits.list objectAtIndex:row];
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
    
    ListGroupItem *item = [_curCommits.listGroups objectAtIndex:indexPath.section];
    NSInteger row = indexPath.row + item.location;
    Commit *curCommit = [_curCommits.list objectAtIndex:row];
    
    DebugLog(@"%@", curCommit.fullMessage);
    
    CommitFilesViewController *vc = [CommitFilesViewController new];
    vc.curProject = _curProject;
    vc.ownerGK = _curProject.owner_user_name;
    vc.projectName = _curProject.name;
    vc.commitId = curCommit.commitId;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
