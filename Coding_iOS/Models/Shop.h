//
//  Shop.h
//  Coding_iOS
//
//  Created by liaoyp on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
#import "ShopGoods.h"

typedef NS_ENUM(NSInteger, ShopType)
{
    ShopTypeAll = 0,
    ShopTypeExchangeable,
};

@interface Shop : BaseModel

@property (readwrite, nonatomic, strong) NSNumber *page,*pageSize;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (assign, nonatomic) ShopType shopType;
@property (readwrite, nonatomic, strong) User *curUser;

@property (readwrite, nonatomic, strong) NSArray *shopBannerArray;
@property (readwrite, nonatomic, strong) NSMutableArray *shopGoodsArray;

@property (readwrite, strong) NSArray *dateSource;

//该用户可用的code分数
@property (readwrite, nonatomic, strong) NSNumber *points_left,*points_total;

- (NSString *)toGiftsPath;

- (void)configWithGiftGoods:(NSArray *)responseA;

- (NSArray *)getExchangeGiftData;

@end
