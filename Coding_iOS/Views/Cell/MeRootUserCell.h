//
//  MeRootUserCell.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/8.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kCellIdentifier_MeRootUserCell @"MeRootUserCell"

#import <UIKit/UIKit.h>
#import "User.h"

@interface MeRootUserCell : UITableViewCell
@property (strong, nonatomic) User *curUser;
+ (CGFloat)cellHeight;
@end
