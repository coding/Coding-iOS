//
//  ShopSwitchCell.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/9/19.
//  Copyright © 2017年 Coding. All rights reserved.
//
#define kCellIdentifier_ShopSwitchCell @"ShopSwitchCell"

#import <UIKit/UIKit.h>

#import "ShopGoods.h"

@interface ShopSwitchCell : UITableViewCell

@property (strong, nonatomic)ShopGoods *shopGoods;
@property (copy, nonatomic) void(^updateBlock)();

@end
