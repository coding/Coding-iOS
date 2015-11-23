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
#import "XTSegmentControl.h"
#import "ShopBannerView.h"
#import "ShopGoodsCCell.h"

#import "Shop.h"
#import "ShopBanner.h"

#import "Coding_NetAPIManager.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface ShopViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView        *_collectionView;
    UIView                  *_collectionHeaderView;
    
    XTSegmentControl        *_shopSegmentControl;
    ShopBannerView          *_shopBannerView;
    NSInteger               _oldSelectedIndex;
    BOOL                    _isRequest;

}

@property(nonatomic,strong)XTSegmentControl *shopSegmentControl;
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


#pragma mark-
#pragma mark---------------------- ControllerLife ---------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"我的商城";
    _shopObject = [[Shop alloc] init];
    _shopObject.shopType = ShopTypeAll;
    
    [self setUpCollectionView];
    [self setUpSegmentControl];
    
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
    if (!_isRequest) {
        _isRequest = YES;
        [self requestgiftsList];
    }

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
    
    [self.view beginLoading];
    [[Coding_NetAPIManager sharedManager] request_shop_bannersWithBlock:^(id data, NSError *error) {
        _shopObject.shopBannerArray = data;
        [_collectionView reloadData];
    }];
    
    [[Coding_NetAPIManager sharedManager] request_shop_userPointWithShop:_shopObject andBlock:^(id data, NSError *error) {
        if (data) {
            [ self loadGiftsList];
        }
    }];
}

- (void)loadGiftsList
{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_shop_giftsWithShop:_shopObject andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        if (data) {
            [_collectionView reloadData];
        }else
            [NSObject showHudTipStr:@"Error"];
    }];
}



#pragma mark-
#pragma mark---------------------- initView ---------------------------

- (void)setUpCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = (self.view.frame.size.width - 12 * 3) / 2;
    CGFloat itemH = itemW * (175.0/284.0) + 10 +21 +5 +13 +5;

    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    
    [_collectionView registerClass:[ShopGoodsCCell class] forCellWithReuseIdentifier:@"TopicProductCollectionCellIdentifier"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.layer.masksToBounds = NO;
    [self.view addSubview:_collectionView];
    
    CGFloat bannerHeight = kMySegmentControl_Height;
    _collectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _collectionView.frame.size.width, bannerHeight)];
    _collectionHeaderView.backgroundColor = [UIColor whiteColor];
    [_collectionView addSubview:_collectionHeaderView];
    
}

- (void)setUpSegmentControl
{
    //添加滑块
    NSArray *_segmentItems = @[@"全部商品",@"可兑换商品"];
    //__weak typeof(_shopSegmentControl) weakCarousel = _shopSegmentControl;
    _shopSegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_collectionHeaderView.frame)- kMySegmentControl_Height - 5, kScreen_Width, kMySegmentControl_Height) Items:_segmentItems selectedBlock:^(NSInteger index) {
        if (index == _oldSelectedIndex) {
            return;
        }
        _oldSelectedIndex = index;
        _shopObject.shopType = index;
        [_collectionView reloadData];
        
        //        [weakCarousel scrollToItemAtIndex:index animated:NO];
    }];
    _shopSegmentControl.backgroundColor = [UIColor whiteColor];
    [_collectionHeaderView addSubview:_shopSegmentControl];
    [self.view bringSubviewToFront:_shopSegmentControl];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y + scrollView.contentInset.top;
    CGFloat _shopSegmentControlY = CGRectGetHeight(_collectionHeaderView.frame) - kMySegmentControl_Height - 5;
    if (offsetY > _shopSegmentControlY) {
        _shopSegmentControl.frame = CGRectMake(0, offsetY, kScreen_Width, kMySegmentControl_Height);
    }else
    {
        _shopSegmentControl.frame = CGRectMake(0, _shopSegmentControlY , kScreen_Width, kMySegmentControl_Height);
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _shopObject.dateSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TopicProductCollectionCellIdentifier" forIndexPath:indexPath];
    BaseModel *model = _shopObject.dateSource[indexPath.row];
    [cell configViewWithModel:model];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat height = kMySegmentControl_Height;
    NSArray * shopBannerArray = _shopObject.shopBannerArray;
    if ( shopBannerArray && shopBannerArray.count > 0) {
        
        CGFloat bannerHeight = kScreen_Width * (270.0/640);
        _shopBannerView = [[ShopBannerView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, bannerHeight)];
        _shopBannerView.curBannerList = shopBannerArray;
        [_collectionHeaderView addSubview:_shopBannerView];
        _shopBannerView.tapActionBlock = ^(ShopBanner *banner){

        };
        [_shopBannerView reloadData];
        _shopSegmentControl.frame = CGRectMake(0, bannerHeight, kScreen_Width, kMySegmentControl_Height);
        height = kMySegmentControl_Height  + bannerHeight ;
        _collectionHeaderView.frame = CGRectMake(0, 0, kScreen_Width, height);
    }
    
    return UIEdgeInsetsMake(5 + height, 10, 10, 10);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopGoods *model = _shopObject.dateSource[indexPath.row];
    if (!model.exchangeable) {
        [NSObject showHudTipStr:@"您的码币余额不足，不能兑换该商品"];
        return;
    }
    ExchangeGoodsViewController *exChangeViewController = [[ExchangeGoodsViewController alloc] init];
    exChangeViewController.shopGoods = model;
    [self.navigationController pushViewController:exChangeViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

@end
