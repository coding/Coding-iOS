//
//  TaskActivityCell.h
//  Coding_iOS
//
//  Created by Ease on 15/6/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_TaskActivityCell @"TaskActivityCell"

#import <UIKit/UIKit.h>
#import "ProjectActivity.h"

@interface TaskActivityCell : UITableViewCell
@property (strong, nonatomic) ProjectActivity *curActivity;

- (void)configTop:(BOOL)isTop andBottom:(BOOL)isBottom;

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
