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
#import "EAPayViewController.h"

#import <AlipaySDK/AlipaySDK.h>

@interface ShopOrderListView ()<UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *dataSource;

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
//            tableView.estimatedRowHeight = 690/2;
            [tableView registerClass:[ShopOderCell class] forCellReuseIdentifier:@"ShopOderCell"];
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tableView.separatorColor = kColorDDD;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
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
    if (_myOrder.isLoading) {
        return;
    }
    _myOrder.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore
{
    if (_myOrder.isLoading || !_myOrder.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _myOrder.willLoadMore = YES;
    _myOrder.page = @(_myOrder.page.intValue +1);
    [self sendRequest];
}

- (void)sendRequest
{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_shop_OrderListWithOrder:_myOrder andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        
        weakSelf.dataSource = [weakSelf.myOrder getDataSourceByOrderType];
        if (weakSelf.myTableView.contentOffset.y < 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.myTableView reloadData];
            });
        }else{
            [weakSelf.myTableView reloadData];
        }
    }];
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{//sendRequest 中刷新，会跳帧
//    self.dataSource = [self.myOrder getDataSourceByOrderType];
//    [self.myTableView reloadData];
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
    __weak typeof(self) weakSelf = self;
    cell.deleteActionBlock = ^{
        [weakSelf deleteOrder:item];
    };
    cell.payActionBlock = ^{
        [weakSelf payOrder:item];
    };
    [cell configViewWithModel:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)deleteOrder:(ShopOrder *)order{
    __weak typeof(self) weakSelf = self;
    [[UIActionSheet bk_actionSheetCustomWithTitle:@"确定要取消此订单吗？" buttonTitles:nil destructiveTitle:@"确定取消" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [NSObject showHUDQueryStr:@"正在取消订单"];
            [[Coding_NetAPIManager sharedManager] request_shop_deleteOrder:order.orderNo andBlock:^(id data, NSError *error) {
                [NSObject hideHUDQuery];
                if (data) {
                    [NSObject showHudTipStr:@"订单已取消"];
                    [weakSelf.myOrder.dateSource removeObject:order];
                    [weakSelf reloadData];
                }
            }];
        }
    }] showInView:self];
}

- (void)payOrder:(ShopOrder *)order{
    EAPayViewController *vc = [EAPayViewController new];
    vc.shopOrder = order;
    [BaseViewController goToVC:vc];
}

- (void)dealloc
{
    _currentOrderCell = nil;
    _myRefreshControl = nil;
    _myTableView.dataSource = nil;
    _myTableView.delegate = nil;
}

@end



