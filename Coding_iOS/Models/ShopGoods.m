//
//  ShopGoods.m
//  Coding_iOS
//
//  Created by liaoyp on 15/11/21.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ShopGoods.h"

@implementation ShopGoods
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ShopGoodsOption", @"options", nil];
        _usePoint = YES;
    }
    return self;
}

- (BOOL)hasAvailablePoints{
    return (_available_points && _available_points.floatValue > 0);
}

- (BOOL)needToPay{
    return self.curPrice.floatValue > 0;
}

- (NSString *)curPrice{
    return [NSString stringWithFormat:@"%.2f", !_usePoint? _points_cost.floatValue * 50: MAX(0, _points_cost.floatValue - _available_points.floatValue) * 50];
}

- (NSString *)curPointWillUse{
    return [NSString stringWithFormat:@"%.2f", !_usePoint? 0: MIN(_points_cost.floatValue, _available_points.floatValue)];
}

@end

@implementation ShopGoodsOption

@end
