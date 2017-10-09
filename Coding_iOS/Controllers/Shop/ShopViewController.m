//
//  ShopViewController.m
//  Coding_iOS
//
//  Created by liaoyp on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ShopViewController.h"
#import "ShopOrderViewController.h"
#import "ExchangeGoodsViewController.h"
#import "WebViewController.h"
#import "XTSegmentControl.h"
#import "ShopBannerView.h"
#import "ShopGoodsCCell.h"
#import "ODRefreshControl.h"

#import "Shop.h"
#import "ShopBanner.h"
#import "iCarousel.h"
@class ShopListView;

#import "Coding_NetAPIManager.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@protocol ShopListViewDelegate <NSObject>

- (void)startRefreWithShopView:(ShopListView *)listView;

- (void)didSelectGoodItem:(ShopGoods *)good;

@end

@interface ShopListView : UIView

@property(nonatomic, weak)id<ShopListViewDelegate> delegate;
@property(nonatomic, strong)NSArray *dataSource;
@property(nonatomic, strong,readonly)ODRefreshControl *myRefreshControl;

@end


@interface ShopViewController ()<iCarouselDataSource,iCarouselDelegate,ShopListViewDelegate>
{
    UIView                  *_collectionHeaderView;
    XTSegmentControl        *_shopSegmentControl;
    ShopBannerView          *_shopBannerView;
    
    NSInteger               _oldSelectedIndex;
    BOOL                    _isRequest;
}

@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) NSArray *titlesArray;
@property (strong, nonatomic) iCarousel *myCarousel;
@property(nonatomic,strong)Shop *shopObject;

@end

@implementation ShopViewController


#pragma mark-
#pragma mark---------------------- Button事件 ---------------------------

- (void)exchangeHistoryBtnClicked:(UIButton *)button
{
    ShopOrderViewController *orderViewController = [[ShopOrderViewController alloc] init];
    [self.navigationController pushViewController:orderViewController animated:YES];
}

- (void)startRefreWithShopView:(ShopListView *)listView
{
    __weak typeof(self) weakSelf = self;
    __weak typeof(iCarousel) *weakCarousel = _myCarousel;

    [[Coding_NetAPIManager sharedManager] request_shop_giftsWithShop:_shopObject andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [listView.myRefreshControl endRefreshing];
        if (data) {
            [weakSelf carouselCurrentItemIndexDidChange:weakCarousel];
            
        }else
            [NSObject showHudTipStr:@"Error"];
        
    }];
}

- (void)bannerClicked:(NSString *)linkStr{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        //网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}

#pragma mark---------------------- ShopListViewDelegate --------------------
- (void)didSelectGoodItem:(ShopGoods *)model
{
//    if (!model.exchangeable) {
//        [NSObject showHudTipStr:@"您的码币余额不足，不能兑换该商品"];
//        return;
//    }
    ExchangeGoodsViewController *exChangeViewController = [[ExchangeGoodsViewController alloc] init];
    exChangeViewController.shopGoods = model;
    [self.navigationController pushViewController:exChangeViewController animated:YES];
}


#pragma mark-
#pragma mark---------------------- ControllerLife ---------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"我的商城";
    _shopObject = [[Shop alloc] init];
    _shopObject.shopType = ShopTypeAll;

    [self setUpView];
    
    // 一次性加载所有数据，暂时没有做分页的需要，先注释.
//    __weak typeof(self) weakSelf = self;
//    [_collectionView addInfiniteScrollingWithActionHandler:^{
//        [weakSelf refreshMore];
//    }];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shop_nar_history_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(exchangeHistoryBtnClicked:)] animated:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestgiftsList];

//    if (!_isRequest) {
//        _isRequest = YES;
//        [self requestgiftsList];
//    }
}

#pragma mark-
#pragma mark---------------------- 网络请求 ---------------------------

- (void)refreshMore{
    if (!_shopObject.isLoading || !_shopObject.canLoadMore) {
        return;
    }
    _shopObject.willLoadMore = YES;
    _shopObject.page = @(_shopObject.page.intValue + 1);
    [self loadGiftsList];
}

- (void)requestgiftsList {
    if (_shopObject.dateSource.count == 0) {
        [self.view beginLoading];
    }
//    __weak typeof(self) weakSelf = self;
//    [[Coding_NetAPIManager sharedManager] request_shop_bannersWithBlock:^(id data, NSError *error) {
//        weakSelf.shopObject.shopBannerArray = data;
//    }];
    
//    [[Coding_NetAPIManager sharedManager] request_shop_userPointWithShop:_shopObject andBlock:^(id data, NSError *error) {
//        if (data) {
//            [weakSelf loadGiftsList];
//        }
//    }];
    [self loadGiftsList];
}

- (void)loadGiftsList
{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_shop_giftsWithShop:_shopObject andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        if (data) {
            ShopListView *listView = (ShopListView *)[weakSelf.myCarousel currentItemView];
            if (weakSelf.myCarousel.currentItemIndex == 0) {
                listView.dataSource = weakSelf.shopObject.dateSource;
            }else if(weakSelf.myCarousel.currentItemIndex == 1)
            {
                listView.dataSource = [weakSelf.shopObject getExchangeGiftData];
            }
        }else
            [NSObject showHudTipStr:@"Error"];
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
        _titlesArray = @[@"全部商品", @"可兑换商品"];
    }
    return _titlesArray;
}
#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [self.titlesArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    
    ShopListView *listView = (ShopListView *)view;
    if (listView) {
        
    }else{
        listView = [[ShopListView alloc] initWithFrame:carousel.bounds];
    }
    listView.delegate = self;
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
    
    ShopListView *listView = (ShopListView *)carousel.currentItemView;
    if (_mySegmentControl) {
        _mySegmentControl.currentIndex = carousel.currentItemIndex;
    }
    
    if (carousel.currentItemIndex == 0) {
        listView.dataSource = _shopObject.dateSource;
        
    }else if(carousel.currentItemIndex == 1)
    {
        listView.dataSource = [_shopObject getExchangeGiftData];
    }
    
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    _myCarousel.delegate = nil;
    _myCarousel.dataSource = nil;
}

@end


@interface ShopListView () <UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView     *_collectionView;
}

@end

@implementation ShopListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpCollectionView];
    }
    return self;
}

- (void)setUpCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    CGFloat itemW = (kScreen_Width - 12 * 3) / 2;
//    CGFloat itemH = itemW * (175.0/284.0) + 10 +21 +5 +13 +5;
    CGFloat itemW = kScreen_Width;
    CGFloat itemH = 110;
    
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    
    [_collectionView registerClass:[ShopGoodsCCell class] forCellWithReuseIdentifier:@"TopicProductCollectionCellIdentifier"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.layer.masksToBounds = NO;
    _collectionView.alwaysBounceVertical = YES;
    [self addSubview:_collectionView];
    
     _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:_collectionView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh
{
    
    if (_delegate && [_delegate respondsToSelector:@selector(startRefreWithShopView:)]) {
        [_delegate startRefreWithShopView:self];
    }
}

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    [_collectionView reloadData];
    
    [self configBlankPage:EaseBlankPageTypeNoExchangeGoods hasData:_dataSource.count > 0 hasError:NO reloadButtonBlock:^(id sender) {
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TopicProductCollectionCellIdentifier" forIndexPath:indexPath];
    BaseModel *model = _dataSource[indexPath.row];
    [cell configViewWithModel:model];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [cell addLineUp:NO andDown:YES andColor:kColorDDD andLeftSpace:kPaddingLeftWidth];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopGoods *model = _dataSource[indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectGoodItem:)]) {
        [_delegate didSelectGoodItem:model];
    }
}
@end
