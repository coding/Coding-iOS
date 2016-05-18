//
//  ProjectListTaCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectListTaCell @"ProjectListTaCell"

#import <UIKit/UIKit.h>
#import "Projects.h"

@interface ProjectListTaCell : UITableViewCell
@property (nonatomic, strong) Project *project;
+ (CGFloat)cellHeight;
@end
