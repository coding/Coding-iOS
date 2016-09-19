//
//  MeRootServiceCell.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/8.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kCellIdentifier_MeRootServiceCell @"MeRootServiceCell"

#import <UIKit/UIKit.h>
#import "UserServiceInfo.h"

@interface MeRootServiceCell : UITableViewCell
@property (strong, nonatomic) UserServiceInfo *curServiceInfo;
@property (copy, nonatomic) void (^leftBlock)();
@property (copy, nonatomic) void (^rightBlock)();
+ (CGFloat)cellHeight;
@end
