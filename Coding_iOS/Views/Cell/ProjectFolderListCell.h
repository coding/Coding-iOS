//
//  ProjectFolderListCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectFolderList @"ProjectFolderListCell"

#import <UIKit/UIKit.h>
#import "ProjectFolder.h"
#import "SWTableViewCell.h"

@interface ProjectFolderListCell : SWTableViewCell
@property (strong, nonatomic) ProjectFolder *folder;
@property (assign, nonatomic) BOOL useToMove;
+ (CGFloat)cellHeight;
@end
