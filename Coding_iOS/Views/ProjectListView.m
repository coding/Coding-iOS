//
//  ProjectListView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectList @"ProjectListCell"
#import "ProjectListView.h"
#import "ProjectListCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"

@interface ProjectListView ()
@property (nonatomic, strong) Projects *myProjects;
@property (nonatomic , copy) ProjectListViewBlock block;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@end

@implementation ProjectListView

#pragma TabBar
- (void)tabBarItemClicked{
    if (_myTableView.contentOffset.y > 0) {
        [_myTableView setContentOffset:CGPointZero animated:YES];
    }else{
        [self refresh];
    }
}

- (id)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(ProjectListViewBlock)block
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myProjects = projects;
        _block = block;
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = kColorTableBG;
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ProjectListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectList];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            tableView;
        });
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
        if (_myProjects.list.count > 0) {
            [_myTableView reloadData];
        }else{
            [self sendRequest];
        }
    }
    return self;
}
- (void)setProjects:(Projects *)projects{
    self.myProjects = projects;
    [self refreshUI];
}
- (void)refreshUI{
    [_myTableView reloadData];
    [self refreshFirst];
}
- (void)refreshToQueryData{
    [self refresh];
}

- (void)refresh{
    if (_myProjects.isLoading) {
        return;
    }
    [self sendRequest];
}

- (void)refreshFirst{
    if (_myProjects && !_myProjects.list) {
        [self performSelector:@selector(refresh) withObject:nil afterDelay:0.3];
    }
}

- (void)sendRequest{
    if (_myProjects.list.count <= 0) {
        [self beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Projects_WithObj:_myProjects andBlock:^(Projects *data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [self endLoading];
        if (data) {
            [weakSelf.myProjects configWithProjects:data];
            [weakSelf.myTableView reloadData];
        }
        [weakSelf configBlankPage:EaseBlankPageTypeProject hasData:(weakSelf.myProjects.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}
#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.myProjects.list) {
        return [self.myProjects.list count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectList forIndexPath:indexPath];
    cell.project = [self.myProjects.list objectAtIndex:indexPath.row];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectListCell cellHeightWithObj:[_myProjects.list objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_block) {
        _block([self.myProjects.list objectAtIndex:indexPath.row]);
    }
}

@end
