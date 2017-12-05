//
//  Shop.m
//  Coding_iOS
//
//  Created by liaoyp on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "Shop.h"

@implementation Shop

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.page = @1;
        self.pageSize = @100;
        self.shopType = ShopTypeAll;
        self.shopGoodsArray = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

+ (Shop *)tweetsWithType:(ShopType)shopType{
    Shop *tweets = [[Shop alloc] init];
    tweets.shopType = shopType;
    tweets.canLoadMore = NO;
    tweets.isLoading = NO;
    tweets.willLoadMore = NO;
    return tweets;
}

- (void)setShopType:(ShopType)shopType
{
    _shopType = shopType;
    
    switch (_shopType) {
        case ShopTypeAll:
        {
            _dateSource = _shopGoodsArray;
        }
            break;
        case ShopTypeExchangeable:
        {
            _dateSource = [self getExchangeGiftData];
        }
            break;
        default:
            break;
    }
    
}

- (NSString *)toGiftsPath{
    NSString *requstPath;
    switch (_shopType) {
        case ShopTypeAll:
            requstPath = @"/api/gifts";
            break;
        case ShopTypeExchangeable:

            break;
        default:
            break;
    }
    return requstPath;
}


- (void)configWithGiftGoods:(NSArray *)responseA{
    
    if (responseA && [responseA count] > 0) {
        [responseA enumerateObjectsUsingBlock:^(ShopGoods *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.available_points.doubleValue >= obj.points_cost.doubleValue) {
                obj.exchangeable = YES;
            }
        }];
        
        self.canLoadMore = (responseA.count >= _pageSize.intValue);
        
        if (_page.intValue == 1) {
            
            _shopGoodsArray = [NSMutableArray arrayWithArray:responseA];
        }else
        {
            [_shopGoodsArray addObjectsFromArray:responseA];
        }
        if (_shopType == ShopTypeAll) {
            _dateSource = _shopGoodsArray;
        }
    }else{
        self.canLoadMore = NO;
    }
}


- (NSArray *)getExchangeGiftData
{
    NSMutableArray *mutaleArray = [NSMutableArray new];
    [_shopGoodsArray enumerateObjectsUsingBlock:^(ShopGoods *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.exchangeable) {
            [mutaleArray addObject:obj];
        }
    }];
    return mutaleArray;

}

@end
