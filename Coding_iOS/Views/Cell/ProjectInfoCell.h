//
//  ProjectInfoCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectInfoCell @"ProjectInfoCell"

#import <UIKit/UIKit.h>
#import "Projects.h"

@interface ProjectInfoCell : UITableViewCell
@property (nonatomic, strong) Project *curProject;
@property (nonatomic, copy) void (^projectBlock)(Project *);
+ (CGFloat)cellHeight;
@end
