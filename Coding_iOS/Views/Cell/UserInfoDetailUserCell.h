//
//  UserInfoDetailUserCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_UserInfoDetailUserCell @"UserInfoDetailUserCell"

#import <UIKit/UIKit.h>

@interface UserInfoDetailUserCell : UITableViewCell
- (void)setName:(NSString *)name icon:(NSString *)iconUrl;
+ (CGFloat)cellHeight;
@end
