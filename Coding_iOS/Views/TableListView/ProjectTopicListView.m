//
//  ProjectTopicListView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectTopicListView.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTopicCell.h"
#import "SVPullToRefresh.h"
#import "ProjectTag.h"

@interface ProjectTopicListView ()
{
    NSInteger _tempOrder;
}

@property (strong, nonatomic) ProjectTopics *myProTopics;
@property (copy, nonatomic) ProjectTopicBlock block;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;

@end

@implementation ProjectTopicListView

- (id)initWithFrame:(CGRect)frame
      projectTopics:(ProjectTopics *)projectTopics
              block:(ProjectTopicBlock)block
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myProTopics = projectTopics;
        _block = block;
        
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ProjectTopicCell class] forCellReuseIdentifier:kCellIdentifier_ProjectTopic];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView;
        });
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
        __weak typeof(self) weakSelf = self;
        [_myTableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf refreshMore];
        }];
        if (_myProTopics.list.count > 0) {
            [_myTableView reloadData];
        } else {
            [self sendRequest];
        }
    }
    return self;
}

- (void)setOrder:(NSInteger)order withLabelID:(NSNumber *)labelID andType:(TopicQueryType)type
{
    if (order != _tempOrder || ![_myProTopics.labelID isEqualToNumber:labelID] || _myProTopics.queryType != type) {
        _tempOrder = order;
        _myProTopics.labelID = labelID;
        _myProTopics.queryType = type;
        switch (_tempOrder) {
            case 0:
                _myProTopics.labelType = LabelOrderTypeUpdate;
                break;
            case 1:
                _myProTopics.labelType = LabelOrderTypeCreate;
                break;
            case 2:
                _myProTopics.labelType = LabelOrderTypeHot;
                break;
            default:
                break;
        }
        if (_myProTopics.isLoading || !_myProTopics.canLoadMore) {
            [_myTableView.infiniteScrollingView stopAnimating];
        }
        _myProTopics.willLoadMore = NO;
        [self sendRequest];
    }
}

- (void)setProTopics:(ProjectTopics *)proTopics
{
    if (_myProTopics != proTopics) {
        self.myProTopics = proTopics;
        [_myTableView reloadData];
        [_myTableView.infiniteScrollingView stopAnimating];
        _myTableView.showsInfiniteScrolling = self.myProTopics.canLoadMore;
        if (self.myProTopics.list.count > 0) {
            [self configBlankPage:EaseBlankPageTypeTopic hasData:YES hasError:NO reloadButtonBlock:nil];
        }
        [self refreshFirst];
    }
}

- (void)refreshToQueryData
{
    [self refresh];
}

- (void)refresh
{
    if (_myProTopics.isLoading) {
        return;
    }
    _myProTopics.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore
{
    if (_myProTopics.isLoading || !_myProTopics.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _myProTopics.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest
{
    if (!_myProTopics.willLoadMore) {
        if (_myProTopics.list.count <= 0) {
            [self beginLoading];
        }
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectTopicList_WithObj:_myProTopics andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myProTopics configWithTopics:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myProTopics.canLoadMore;
        }
        [weakSelf configBlankPage:EaseBlankPageTypeTopic hasData:(weakSelf.myProTopics.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

- (void)refreshFirst
{
    if (_myProTopics && !_myProTopics.list) {
        [self performSelector:@selector(refresh) withObject:nil afterDelay:0.3];
    }
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.myProTopics.list) {
        return [self.myProTopics.list count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectTopic forIndexPath:indexPath];
    cell.curTopic = [self.myProTopics.list objectAtIndex:indexPath.row];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0 hasSectionLine:indexPath.row != 0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ProjectTopicCell cellHeightWithObj:[_myProTopics.list objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_block) {
        ProjectTopic *curTopic = [self.myProTopics.list objectAtIndex:indexPath.row];
        _block(self, curTopic);
    }
}

@end
