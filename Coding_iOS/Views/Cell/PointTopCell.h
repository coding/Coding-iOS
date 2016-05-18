//
//  PointTopCell.h
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_PointTopCell @"PointTopCell"

#import <UIKit/UIKit.h>

@interface PointTopCell : UITableViewCell
@property (strong, nonatomic) NSString *pointLeftStr;
+ (CGFloat)cellHeight;
@end
