//
//  ShopGoods.h
//  Coding_iOS
//
//  Created by liaoyp on 15/11/21.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "BaseModel.h"

@interface ShopGoods : BaseModel

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *points_cost;
@property (strong, nonatomic) NSString *image ,*name, *description;
@property (assign, nonatomic) BOOL exchangeable; //能否兑换的

@end
