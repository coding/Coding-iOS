//
//  ForkTreeCell.h
//  Coding_iOS
//
//  Created by Ease on 15/9/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_ForkTreeCell @"ForkTreeCell"

#import <UIKit/UIKit.h>
#import "Project.h"

@interface ForkTreeCell : UITableViewCell
@property (strong, nonatomic) Project *project;
+ (CGFloat)cellHeight;
@end
