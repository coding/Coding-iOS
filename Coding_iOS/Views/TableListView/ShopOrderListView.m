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
    ShopOderCell *_currentOrderCell;
    NSArray      *_dataSource;
}
@property (nonatomic, strong) ShopOrderModel *myOrder;
//@property (nonatomic , copy)  ProjectActivityBlock block;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@end

@implementation ShopOrderListView

- (instancetype)initWithFrame:(CGRect)frame withOder:(ShopOrderModel *)order
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _dataSource = [_myOrder getDataSourceByOrderType];
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.estimatedRowHeight = 690/2;
            [tableView registerClass:[ShopOderCell class] forCellReuseIdentifier:@"ShopOderCell"];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            tableView;
        });
        
        _currentOrderCell = [[ShopOderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ShopOderCell"];
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
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
        
        [self loadData];

    }
    return self;
}

- (void)reloadData
{
    _dataSource = [_myOrder getDataSourceByOrderType];
    [self.myTableView reloadData];
}

- (void)refresh
{
    [self loadData];
}

- (void)loadData
{
    __weak typeof(self) weakSelf = self;
    
    [[Coding_NetAPIManager sharedManager] request_shop_OrderListWithOrder:_myOrder andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            _dataSource = [_myOrder getDataSourceByOrderType];
            [weakSelf.myTableView reloadData];
//            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myOrder.canLoadMore;
        }
        [weakSelf configBlankPage:EaseBlankPageTypeTopic hasData:(weakSelf.myOrder.dateSource.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];

    }];
}


#pragma mark Table M


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShopOrder *item = [_dataSource objectAtIndex:indexPath.row];
    ShopOderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShopOderCell" forIndexPath:indexPath];
    [cell configViewWithModel:item];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShopOrder *item = [_dataSource objectAtIndex:indexPath.row];
    [_currentOrderCell configViewWithModel:item];
    return _currentOrderCell.cellHeight;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    ShopOrder *item = [_dataSource objectAtIndex:indexPath.row];
    //    if (_block) {
    //        _block([self.myProActs.list objectAtIndex:row]);
    //    }
}

@end



