//
//  UserInfoIconCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_UserInfoIconCell @"UserInfoIconCell"

#import <UIKit/UIKit.h>

@interface UserInfoIconCell : UITableViewCell
- (void)setTitle:(NSString *)title icon:(NSString *)iconName;
+ (CGFloat)cellHeight;

- (void)addTipIcon;
- (void)removeTip;
@end
