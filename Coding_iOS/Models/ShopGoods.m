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
    }
    return self;
}
@end

@implementation ShopGoodsOption

@end