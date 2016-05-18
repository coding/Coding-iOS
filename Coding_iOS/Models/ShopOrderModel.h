//
//  ShopOderModel.h
//  Coding_iOS
//
//  Created by liaoyp on 15/11/21.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "BaseModel.h"
#import "ShopOrder.h"

typedef NS_ENUM(NSInteger, ShopOrderType)
{
    ShopOrderAll = 0,
    ShopOrderUnSend,
    ShopOrderSend,
};

@interface ShopOrderModel : BaseModel

@property (readwrite, nonatomic, strong) NSNumber *page,*pageSize;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (assign, nonatomic) ShopOrderType orderType;
@property (readwrite, strong) NSMutableArray *dateSource;

- (NSString *)toPath;

- (void)configOrderWithReson:(NSArray *)responseA;

- (NSArray *)getDataSourceByOrderType;

@end



