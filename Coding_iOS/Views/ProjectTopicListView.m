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


@interface ProjectTopicListView ()
{
    NSString *_tempLabel;
    NSMutableArray *_tempAry;
    NSInteger _tempOrder;
}

@property (strong, nonatomic) ProjectTopics *myProTopics;
@property (copy, nonatomic) ProjectTopicBlock block;
@property (copy, nonatomic) TopicListBlock listBlock;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;

@end

@implementation ProjectTopicListView

- (id)initWithFrame:(CGRect)frame
      projectTopics:(ProjectTopics *)projectTopics
              block:(ProjectTopicBlock)block
       andListBlock:(TopicListBlock)listBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myProTopics = projectTopics;
        _block = block;
        self.listBlock = listBlock;
        _tempAry = [NSMutableArray arrayWithCapacity:10];
        
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
        }else{
            [self sendRequest];
        }
    }
    return self;
}

- (void)setOrder:(NSInteger)order withLabel:(NSString *)label
{
    BOOL change = FALSE;
    if (label) {
        change = [label isEqualToString:_tempLabel] ? FALSE : TRUE;
    } else if (_tempLabel) {
        change = TRUE;
    }
    if (order != _tempOrder || change) {
        _tempOrder = order;
        _tempLabel = label;
        
        [self resetAry];
    }
}

- (void)resetAry
{
    [_tempAry removeAllObjects];
    for (ProjectTopic *topic in _myProTopics.list) {
    }
}

- (void)getLabelArray:(NSMutableArray *)labelAry andNumberArray:(NSMutableArray *)numberAry
{
    BOOL isExist;
    for (ProjectTopic *topic in _myProTopics.list) {
        for (NSString *label in topic.labels) {
            isExist = FALSE;
            for (int i=1; i<labelAry.count; i++) {
                NSString *temp = labelAry[i];
                if ([temp isEqualToString:label]) {
                    isExist = TRUE;
                    NSNumber *tNumber = numberAry[i];
                    [numberAry replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:[tNumber integerValue] + 1]];
                    break;
                }
            }
            if (!isExist) {
                [labelAry addObject:label];
                [numberAry addObject:[NSNumber numberWithInteger:1]];
            }
        }
    }
    [numberAry replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:_myProTopics.list.count]];
}


- (NSInteger)getCount
{
    return _myProTopics.list.count;
}

- (void)setProTopics:(ProjectTopics *)proTopics{
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
- (void)refreshToQueryData{
    [self refresh];
}
- (void)refresh{
    if (_myProTopics.isLoading) {
        return;
    }
    _myProTopics.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore{
    if (_myProTopics.isLoading || !_myProTopics.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _myProTopics.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest{
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
            if (weakSelf.listBlock) {
                weakSelf.listBlock(self);
            }
        }
        [weakSelf configBlankPage:EaseBlankPageTypeTopic hasData:(weakSelf.myProTopics.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

- (void)refreshFirst{
    if (_myProTopics && !_myProTopics.list) {
        [self performSelector:@selector(refresh) withObject:nil afterDelay:0.3];
    }
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.myProTopics.list) {
        return [self.myProTopics.list count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectTopic forIndexPath:indexPath];
    cell.curTopic = [self.myProTopics.list objectAtIndex:indexPath.row];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectTopicCell cellHeightWithObj:[_myProTopics.list objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_block) {
        ProjectTopic *curTopic = [self.myProTopics.list objectAtIndex:indexPath.row];
        DebugLog(@"%@", curTopic.title);
        _block(self, curTopic);
    }
}



@end
