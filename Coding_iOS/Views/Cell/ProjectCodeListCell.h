//
//  ProjectCodeListCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectCodeList @"ProjectCodeListCell"

#import <UIKit/UIKit.h>
#import "CodeTree.h"

@interface ProjectCodeListCell : UITableViewCell
@property (strong, nonatomic) CodeTree_File *file;
+ (CGFloat)cellHeight;
@end
