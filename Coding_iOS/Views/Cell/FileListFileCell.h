//
//  FileListFileCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_FileListFile @"FileListFileCell"

#import <UIKit/UIKit.h>
#import "ProjectFile.h"
#import "Projects.h"
#import "SWTableViewCell.h"

@interface FileListFileCell : SWTableViewCell
@property (strong, nonatomic) ProjectFile *file;
@property (nonatomic,copy) void(^showDiskFileBlock)(NSURL *fileUrl, ProjectFile *file);
+ (CGFloat)cellHeight;
@end
