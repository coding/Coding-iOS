//
//  ProjectListCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectList @"ProjectListCell"

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "SWTableViewCell.h"

@interface ProjectListCell : SWTableViewCell
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;

+ (CGFloat)cellHeight;

@end
