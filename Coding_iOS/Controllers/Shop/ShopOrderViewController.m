//
//  ShopOrderViewController.m
//  Coding_iOS
//
//  Created by liaoyp on 15/11/21.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ShopOrderViewController.h"
#import "XTSegmentControl.h"
#import "iCarousel.h"
#import "Project.h"
#import "ShopOrderModel.h"
#import "ShopOrderListView.h"
#import "Coding_NetAPIManager.h"

@interface ShopOrderViewController ()<iCarouselDataSource,iCarouselDelegate>
@property (nonatomic, strong) ShopOrderModel *myOrder;
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) NSArray *titlesArray;
@property (strong, nonatomic) iCarousel *myCarousel;

@end

@implementation ShopOrderViewController


#pragma mark-
#pragma mark---------------------- ControllerLife ---------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"历史订单";
    
    _myOrder = [[ShopOrderModel alloc] init];
    _myOrder.orderType = ShopOrderAll;
    
    [self setUpView];
    [self loadData];
}

- (void)loadData
{
    __weak typeof(self) weakSelf = self;
    __weak typeof(iCarousel) *weakCarosel = _myCarousel;

    [self.view beginLoading];
    [[Coding_NetAPIManager sharedManager] request_shop_OrderListWithOrder:_myOrder andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        if (data) {
            
            [weakSelf carouselCurrentItemIndexDidChange:weakCarosel];
//            weakSelf.myOrder.orderType = ShopOrderAll;
//            ShopOrderListView *listView = (ShopOrderListView *)[weakSelf.myCarousel itemViewAtIndex:weakSelf.myOrder.orderType];
//            [listView reloadData];
        }
    }];
}


- (void)setUpView
{
    //添加myCarousel
    self.myCarousel = ({
        iCarousel *icarousel = [[iCarousel alloc] initWithFrame:CGRectZero];
        icarousel.dataSource = self;
        icarousel.delegate = self;
        icarousel.decelerationRate = 1.0;
        icarousel.scrollSpeed = 1.0;
        icarousel.type = iCarouselTypeLinear;
        icarousel.pagingEnabled = YES;
        icarousel.clipsToBounds = YES;
        icarousel.bounceDistance = 0.2;
        [self.view addSubview:icarousel];
        [icarousel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kMySegmentControl_Height, 0, 0, 0));
        }];
        
        icarousel;
    });
    __weak typeof(self) weakSelf = self;
    self.mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height) Items:self.titlesArray selectedBlock:^(NSInteger index) {
        [weakSelf.myCarousel scrollToItemAtIndex:index animated:NO];
    }];
    [self.view addSubview:self.mySegmentControl];
}

#pragma mark - Getter/Setter
- (NSArray*)titlesArray
{
    if (nil == _titlesArray) {
        _titlesArray = @[@"全部订单", @"未发货", @"已发货",];
    }
    return _titlesArray;
}
#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [self.titlesArray count];
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    
    _myOrder.orderType = index;
    ShopOrderListView *listView = (ShopOrderListView *)view;
    if (listView) {

    }else{
        listView = [[ShopOrderListView alloc] initWithFrame:carousel.bounds withOder:_myOrder];
    }
    [listView reloadData];
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
    return listView;
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    if (_mySegmentControl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [_mySegmentControl moveIndexWithProgress:offset];
        }
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    
    ShopOrderListView *listView = (ShopOrderListView *)carousel.currentItemView;
     _myOrder.orderType = carousel.currentItemIndex;
     listView.myOrder = _myOrder;
    [listView reloadData];

    EaseBlankPageType  _orderEmptyType;
    if (_myOrder.orderType == ShopOrderSend)
    {
        _orderEmptyType = EaseBlankPageTypeShopSendOrders;
    }else if (_myOrder.orderType == ShopOrderUnSend)
    {
        _orderEmptyType = EaseBlankPageTypeShopUnSendOrders;
    }else
        _orderEmptyType = EaseBlankPageTypeShopOrders;
    
    [listView configBlankPage:_orderEmptyType hasData:( [_myOrder getDataSourceByOrderType].count > 0) hasError:NO reloadButtonBlock:^(id sender) {
    }];
    
    if (_mySegmentControl) {
        _mySegmentControl.currentIndex = carousel.currentItemIndex;
    }
    
    
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}

- (void)dealloc
{
    _myCarousel.dataSource  = nil;
    _myCarousel.delegate = nil;
    _mySegmentControl = nil;
}

@end



