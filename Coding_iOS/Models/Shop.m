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
        self.pageSize = @20;
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
//+ (Tweets *)tweetsWithUser:(User *)curUser{
//    Tweets *tweets = [Tweets tweetsWithType:TweetTypeUserSingle];
//    tweets.curUser = curUser;
//    return tweets;
//}

- (NSString *)toGiftsPath{
    NSString *requstPath;
    switch (_shopType) {
        case ShopTypeAll:
            requstPath = @"/api/gifts";
            break;
        case ShopTypeExchangeable:
            requstPath = @"/api/gifts";
            break;
        default:
            break;
    }
    return requstPath;
}


- (void)configWithGiftGoods:(NSArray *)responseA{
    
    if (responseA && [responseA count] > 0) {
        ShopGoods *object = [responseA firstObject];
        [NSObject showHudTipStr: object.name];
        
        [_shopGoodsArray enumerateObjectsUsingBlock:^(ShopGoods *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (_points_total.doubleValue > obj.points_cost.doubleValue) {
                obj.exchangeable = YES;
            }
        }];
        
        _canLoadMore = responseA.count >= _pageSize.intValue;
        if (_page.intValue == 1) {
            
            _shopGoodsArray = [NSMutableArray arrayWithArray:responseA];
        }else
        {
            [_shopGoodsArray addObjectsFromArray:responseA];
        }
    }else{
        self.canLoadMore = NO;
    }
}


- (NSArray *)getExchangeGiftData
{
    if (_points_total && _points_total.doubleValue > 0) {
        NSMutableArray *mutaleArray = [NSMutableArray arrayWithCapacity:10];
        [_shopGoodsArray enumerateObjectsUsingBlock:^(ShopGoods *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (_points_total.doubleValue > obj.points_cost.doubleValue) {
                [mutaleArray addObject:obj];
            }
        }];
        return mutaleArray;
    }
    return [NSArray array];
}

@end
