//
//  ShopOderModel.m
//  Coding_iOS
//
//  Created by liaoyp on 15/11/21.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ShopOrderModel.h"

@implementation ShopOrderModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _page = @1;
        _pageSize = @20;
        _orderType  = ShopOrderAll;
        _dateSource = [NSMutableArray arrayWithCapacity:20];
    }
    return self;
}

- (NSString *)toPath
{
    switch (_orderType) {
        case ShopOrderAll:
            return @"api/gifts/orders";
            break;
            
        default:
            break;
    }
    return @"api/gifts/orders";
}

- (void)configOrderWithReson:(NSArray *)responseA
{
    if (responseA && [responseA count] > 0) {
        
        self.canLoadMore = (responseA.count >= _pageSize.intValue);
        if (!_willLoadMore) {
            _dateSource = [NSMutableArray arrayWithArray:responseA];
        }else
        {
            [_dateSource addObjectsFromArray:responseA];
        }
    }else{
        self.canLoadMore = NO;
    }
}

- (NSArray *)getDataSourceByOrderType
{
    switch (_orderType) {
        case ShopOrderAll:
            return _dateSource;
            break;
        case ShopOrderUnPay:
        {
            NSMutableArray *array  = [NSMutableArray arrayWithCapacity:10];
            [_dateSource enumerateObjectsUsingBlock:^(ShopOrder *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.status.intValue == 3) {
                    if (obj) {
                        [array addObject:obj];
                    }
                }
            }];
            return array;
            break;
        }
        case ShopOrderSend:
        {
            NSMutableArray *array  = [NSMutableArray arrayWithCapacity:10];
            [_dateSource enumerateObjectsUsingBlock:^(ShopOrder *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.status.intValue == 1) {
                    if (obj) {
                        [array addObject:obj];
                    }
                }
            }];
            return array;
            break;
        }
        case ShopOrderUnSend:
        {
            NSMutableArray *array  = [NSMutableArray arrayWithCapacity:10];
            [_dateSource enumerateObjectsUsingBlock:^(ShopOrder *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.status.intValue == 0) {
                    if (obj) {
                        [array addObject:obj];
                    }
                }
            }];
            return array;
            break;
        }
        default:
            break;
    }
}


@end
