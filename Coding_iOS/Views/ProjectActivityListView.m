//
//  ProjectActivityListView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#import "ProjectActivityListView.h"
#import "ProjectActivityListCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "SVPullToRefresh.h"

@interface ProjectActivityListView ()

@property (nonatomic, strong) ProjectActivities *myProActs;
@property (nonatomic , copy) ProjectActivityBlock block;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@property (nonatomic, assign) NSInteger un_read_activities_count;

@end
@implementation ProjectActivityListView

- (id)initWithFrame:(CGRect)frame proAtcs:(ProjectActivities *)proAtcs block:(ProjectActivityBlock)block{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myProActs = proAtcs;
        _block = block;
        _un_read_activities_count = self.myProActs.curProject.un_read_activities_count.intValue;

        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ProjectActivityListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectActivityList];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            tableView;
        });
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        __weak typeof(self) weakSelf = self;
        [_myTableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf refreshMore];
        }];
        [self sendRequest];
    }
    return self;
}


- (void)setProAtcs:(ProjectActivities *)proAtcs{
    if (_myProActs != proAtcs) {
        self.myProActs = proAtcs;
        [_myTableView reloadData];
        [_myTableView.infiniteScrollingView stopAnimating];
        _myTableView.showsInfiniteScrolling = self.myProActs.canLoadMore;
        if (self.myProActs.list.count > 0) {
            [self configBlankPage:EaseBlankPageTypeActivity hasData:YES hasError:NO reloadButtonBlock:nil];
        }
        [self refreshFirst];
    }
}

- (void)refreshFirst{
    if (_myProActs && (!_myProActs.list || _myProActs.list.count <= 0)) {
        [self refresh];
    }
}

- (void)refresh{
    if (_myProActs.isLoading) {
        return;
    }
    _myProActs.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore{
    if (_myProActs.isLoading || !_myProActs.canLoadMore) {
        return;
    }
    _myProActs.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest{
    if (!_myProActs.willLoadMore) {
        if (_myProActs.list.count <= 0) {
            [self beginLoading];
        }
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectActivityList_WithObj:_myProActs andBlock:^(NSArray *data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myProActs configWithProActList:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myProActs.canLoadMore;
        }
        [weakSelf configBlankPage:EaseBlankPageTypeActivity hasData:(weakSelf.myProActs.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _myProActs.listGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ListGroupItem *item = [_myProActs.listGroups objectAtIndex:section];
    return item.hide? 0 : item.length;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ListGroupItem *item = [_myProActs.listGroups objectAtIndex:indexPath.section];
    NSUInteger row = indexPath.row +item.location;
    ProjectActivity *curProAct = [_myProActs.list objectAtIndex:row];
    ProjectActivityListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectActivityList forIndexPath:indexPath];
    BOOL haveRead, isTop, isBottom;
    
    if (_myProActs.isOfUser || ![_myProActs.type isEqualToString:@"all"]) {
        haveRead = YES;
        isTop = (row == item.location);
        isBottom = (row == item.location +item.length -1);
    }else{
        haveRead = row >= _un_read_activities_count;
        isTop = (row == item.location) || (row == _un_read_activities_count);
        isBottom = (row == item.location +item.length -1) || (row == _un_read_activities_count-1);
    }
    
    [cell configWithProAct:curProAct haveRead:haveRead isTop:isTop isBottom:isBottom];
    [cell.userIconView addTapBlock:^(id obj) {
        if (_userIconClickedBlock) {
            _userIconClickedBlock(curProAct.user);
        }
    }];
    cell.htmlItemClickedBlock = self.htmlItemClickedBlock;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:
     (row == item.location +item.length -1)? 0:85];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ListGroupItem *item = [_myProActs.listGroups objectAtIndex:indexPath.section];
    NSUInteger row = indexPath.row +item.location;
    return [ProjectActivityListCell cellHeightWithObj:[_myProActs.list objectAtIndex:row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ListGroupItem *item = [_myProActs.listGroups objectAtIndex:indexPath.section];
    NSUInteger row = indexPath.row +item.location;
    if (_block) {
        _block([self.myProActs.list objectAtIndex:row]);
    }
}

#pragma mark TableViewHeader
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kScaleFrom_iPhone5_Desgin(24);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ListGroupItem *item = [_myProActs.listGroups objectAtIndex:section];
    return [tableView getHeaderViewWithStr:[item.date string_yyyy_MM_dd_EEE] andBlock:^(id obj) {
        DebugLog(@"\nitem.date.description :%@", item.date.description);
    }];
}

@end
