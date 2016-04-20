//
//  MRListView.m
//  Coding_iOS
//
//  Created by Ease on 15/10/23.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "MRListView.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "Coding_NetAPIManager.h"
#import "MRPRListCell.h"

@interface MRListView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@end

@implementation MRListView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] init];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[MRPRListCell class] forCellReuseIdentifier:kCellIdentifier_MRPRListCell];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 49, 0);//外部 segment bar 的高度
            tableView.contentInset = insets;
            tableView.scrollIndicatorInsets = insets;
            tableView;
        });
        
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
        __weak typeof(self) weakSelf = self;
        [_myTableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf refreshMore:YES];
        }];
    }
    return self;
}

- (void)refresh{
    [self refreshMore:NO];
}
- (void)refreshMore:(BOOL)willLoadMore{
    MRPRS *curMRPRS = [self curMRPRS];
    if (curMRPRS.isLoading) {
        return;
    }
    if (willLoadMore && !curMRPRS.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    curMRPRS.willLoadMore = willLoadMore;
    [self sendRequest:curMRPRS];
}

- (void)sendRequest:(MRPRS *)curMRPRS{
    if (curMRPRS.list.count <= 0) {
        [self beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(curMRPRS) weakMRPRS = curMRPRS;
    [[Coding_NetAPIManager sharedManager] request_MRPRS_WithObj:curMRPRS andBlock:^(MRPRS *data, NSError *error) {
        [weakSelf endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakMRPRS configWithMRPRS:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = [weakSelf curMRPRS].canLoadMore;
        }
        [weakSelf configBlankPage:EaseBlankPageTypeView hasData:([weakSelf curMRPRS].list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refreshMore:NO];
        }];
    }];
}

- (void)refreshToQueryData{
    if (self.curMRPRS.list > 0) {
        __weak typeof(self) weakSelf = self;
        [self configBlankPage:EaseBlankPageTypeView hasData:([self curMRPRS].list.count > 0) hasError:NO reloadButtonBlock:^(id sender) {
            [weakSelf refreshMore:NO];
        }];
    }
    [self.myTableView reloadData];
    [self refresh];
}

#pragma mark TableM
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self curMRPRS].list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MRPR *curMRPR = [[self curMRPRS].list objectAtIndex:indexPath.row];
    MRPRListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRPRListCell forIndexPath:indexPath];
    cell.curMRPR = curMRPR;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MRPRListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.clickedMRBlock) {
        MRPR *curMR = self.curMRPRS.list[indexPath.row];
        self.clickedMRBlock(curMR);
    }
}


@end
