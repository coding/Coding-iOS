//
//  ShopOrderListView.m
//  Coding_iOS
//
//  Created by liaoyp on 15/11/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ShopOrderListView.h"
#import "ShopOderCell.h"
#import "ODRefreshControl.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "Coding_NetAPIManager.h"

@interface ShopOrderListView ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray      *_dataSource;
}
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ShopOderCell *currentOrderCell;

@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@end

@implementation ShopOrderListView

- (instancetype)initWithFrame:(CGRect)frame withOder:(ShopOrderModel *)order
{
    self = [super initWithFrame:frame];
    if (self) {
        _myOrder = order;
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
            tableView.backgroundColor = kColorTableSectionBg;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.estimatedRowHeight = 690/2;
            [tableView registerClass:[ShopOderCell class] forCellReuseIdentifier:@"ShopOderCell"];
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tableView.separatorColor = [UIColor colorWithHexString:@"0xC8C8C8"];
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            tableView;
        });
        
        _currentOrderCell = [[ShopOderCell alloc] initWithFrame:CGRectZero];

        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)reloadData
{
    _dataSource = [_myOrder getDataSourceByOrderType];
    
    if (_dataSource.count > 0) {
        
        [_myTableView.tableFooterView removeFromSuperview];
        _myTableView.tableFooterView = nil;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width
                                                                    , (86 +88 +25)/2)];
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tipsLabel.font = [UIFont systemFontOfSize:12];
        tipsLabel.backgroundColor = [UIColor clearColor];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.numberOfLines = 2;
        tipsLabel.text = @"温馨提示：\n 所有兑换商品都定于每周五发货，请耐心等待哦！";
        tipsLabel.textColor = [UIColor colorWithHexString:@"0xB5B5B5"];
        [footView addSubview:tipsLabel];
        [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(footView.mas_left).offset(28);
            make.right.equalTo(footView.mas_right).offset(-28);
            make.bottom.equalTo(footView.mas_bottom).offset(-28);
        }];
        _myTableView.tableFooterView = footView;
    }else
        _myTableView.tableFooterView = nil;
    
    [self.myTableView reloadData];
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
}


- (void)refresh
{
    [self.myRefreshControl endRefreshing];
    
//    [self loadData];
}

- (void)refreshMore
{
    if (_myOrder.isLoading || !_myOrder.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _myOrder.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest
{
//    __weak typeof(self) weakSelf = self;
//    [[Coding_NetAPIManager sharedManager] request_Comments_WithProjectTpoic:self. andBlock:^(id data, NSError *error) {
//        [weakSelf.refreshControl endRefreshing];
//        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
//        if (data) {
//            [weakSelf.curTopic configWithComments:data];
//            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.curTopic.canLoadMore;
//        }
//        [weakSelf.myTableView reloadData];
//    }];
    
    __weak typeof(self) weakSelf = self;
    _myOrder.page = @(_myOrder.page.intValue +1);
    [[Coding_NetAPIManager sharedManager] request_shop_OrderListWithOrder:_myOrder andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            _dataSource = [_myOrder getDataSourceByOrderType];
            [weakSelf.myTableView reloadData];
        }
//        [weakSelf configBlankPage:EaseBlankPageTypeTopic hasData:(weakSelf.myOrder.dateSource.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
//            [weakSelf refresh];
//        }];

    }];

}

//- (void)loadData
//{
//    __weak typeof(self) weakSelf = self;
//    
//    [[Coding_NetAPIManager sharedManager] request_shop_OrderListWithOrder:_myOrder andBlock:^(id data, NSError *error) {
//        [weakSelf.myRefreshControl endRefreshing];
//        [weakSelf endLoading];
//        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
//        if (data) {
//            _dataSource = [_myOrder getDataSourceByOrderType];
//            [weakSelf.myTableView reloadData];
//        }
//        [weakSelf configBlankPage:EaseBlankPageTypeTopic hasData:(weakSelf.myOrder.dateSource.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
//            [weakSelf refresh];
//        }];
//
//    }];
//}


#pragma mark Table M

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_dataSource.count > 0) {
        return 1;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShopOrder *item = [_dataSource objectAtIndex:indexPath.section];
    [_currentOrderCell configViewWithModel:item];
    return _currentOrderCell.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 12;
    }
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShopOrder *item = [_dataSource objectAtIndex:indexPath.section];
    ShopOderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShopOderCell" forIndexPath:indexPath];
    [cell configViewWithModel:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    ShopOrder *item = [_dataSource objectAtIndex:indexPath.row];
    
}

- (void)dealloc
{
    _currentOrderCell = nil;
    _myRefreshControl = nil;
    _myTableView.dataSource = nil;
    _myTableView.delegate = nil;
}

@end



