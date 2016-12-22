//
//  ProjectTaskListView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectTaskListView.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTaskListViewCell.h"
#import "SVPullToRefresh.h"

@interface ProjectTaskListView ()

@property (strong, nonatomic) Tasks *myTasks;
@property (copy, nonatomic) ProjectTaskBlock block;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (nonatomic, assign) NSInteger page;
@end

@implementation ProjectTaskListView

#pragma TabBar
- (void)tabBarItemClicked{
    if (_myTableView.contentOffset.y > 0) {
        [_myTableView setContentOffset:CGPointZero animated:YES];
    }else if (!self.myRefreshControl.isAnimating){
        [self.myRefreshControl beginRefreshing];
        [self.myTableView setContentOffset:CGPointMake(0, -44)];
        [self refresh];
    }
}
- (void)reloadData{
    if (self.myTableView) {
        [self.myTableView reloadData];
    }
}

- (id)initWithFrame:(CGRect)frame tasks:(Tasks *)tasks project_id:(NSString *)project_id keyword:(NSString *)keyword status:(NSString *)status label:(NSString *)label userId:(NSString *)userId role:(TaskRoleType )role block:(ProjectTaskBlock)block tabBarHeight:(CGFloat)tabBarHeight{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myTasks = tasks;
        _block = block;
        _page = 1;
        
        self.project_id = project_id;
        self.keyword = keyword;
        self.status = status;
        self.label = label;
        self.userId = userId;
        self.role = role;

        
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ProjectTaskListViewCell class] forCellReuseIdentifier:kCellIdentifier_ProjectTaskList];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            if (tabBarHeight != 0) {
                UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, tabBarHeight, 0);
                tableView.contentInset = insets;
                tableView.scrollIndicatorInsets = insets;
            }
            tableView;
        });
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        __weak typeof(self) weakSelf = self;
        [_myTableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf refreshMore];
        }];
        if (_myTasks.list.count > 0) {
            [_myTableView reloadData];
        }else{
            [self sendRequest];
        }
    }
    return self;
}

- (void)setTasks:(Tasks *)tasks{
    if (_myTasks != tasks) {
        self.userId = tasks.owner.id.stringValue;
        self.project_id = tasks.project.id.stringValue;
        self.myTasks = tasks;
        [_myTableView reloadData];
        [_myTableView.infiniteScrollingView stopAnimating];
        _myTableView.showsInfiniteScrolling = self.myTasks.canLoadMore;
        if (self.myTasks.list.count > 0) {
            [self configBlankPage:EaseBlankPageTypeTask hasData:YES hasError:NO reloadButtonBlock:nil];
        }
        [self refreshFirst];
    }
}
- (void)refreshToQueryData{
    [self refresh];
}

- (void)refreshFirst{
    if (_myTasks && !_myTasks.list) {
        [self refresh];
    }
}

- (void)refresh{
    if (_myTasks.isLoading) {
        return;
    }
    _page = 1;
    _myTasks.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore{
    if (_myTasks.isLoading || !_myTasks.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _page++;
    _myTasks.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest{
    if (_myTasks.list.count <= 0) {
        [self beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    
    [[Coding_NetAPIManager sharedManager] request_tasks_searchWithUserId:_userId role:_role project_id:_project_id keyword:_keyword status:_status label:_label page:_page andBlock:^(Tasks *data, NSError *error) {
        [weakSelf endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myTasks configWithTasks:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myTasks.canLoadMore;
        }
        [weakSelf configBlankPage:EaseBlankPageTypeTask hasData:(weakSelf.myTasks.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
               
    }];
}



#pragma mark Table M
- (NSArray *)tableDataListInSection:(NSInteger)section{
    NSArray *dataList;
    if (section == 0) {
        if (_myTasks.processingList.count > 0) {
            dataList = _myTasks.processingList;
        }else{
            dataList = _myTasks.doneList;
        }
    }else{
        dataList = _myTasks.doneList;
    }
    return dataList;
}

- (NSInteger)numberOfSections{
    NSInteger num = 0;
    if (_myTasks.processingList.count > 0) {
        num++;
    }
    if (_myTasks.doneList.count > 0) {
        num++;
    }
    return num;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (section == 0) {
        if (_myTasks.processingList.count > 0) {
            num = _myTasks.processingList.count;
        }else{
            num = _myTasks.doneList.count;
        }
    }else{
        num = _myTasks.doneList.count;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectTaskListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectTaskList forIndexPath:indexPath];
    
    NSArray *dataList = [self tableDataListInSection:indexPath.section];
    __weak typeof(self) weakSelf = self;
    cell.task = [dataList objectAtIndex:indexPath.row];
    cell.checkViewClickedBlock = ^(Task *task){
        if (task.isRequesting) {
            return ;
        }else{
            task.isRequesting = YES;
        }
        //ChangeTaskStatus后，task对象的status属性会直接在请求结束后被修改
        [[Coding_NetAPIManager sharedManager] request_ChangeTaskStatus:task andBlock:^(id data, NSError *error) {
            [weakSelf.myTableView reloadData];
            task.isRequesting = NO;
        }];
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:48];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *dataList = [self tableDataListInSection:indexPath.section];
    return [ProjectTaskListViewCell cellHeightWithObj:[dataList objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *dataList = [self tableDataListInSection:indexPath.section];
    if (_block) {
        Task *curTask = [dataList objectAtIndex:indexPath.row];
        _block(self, curTask);
    }
}

#pragma mark TableViewHeader
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerV = [UIView new];
    headerV.backgroundColor = kColorTableSectionBg;
    return headerV;
}

@end
