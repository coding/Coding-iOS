//
//  FileVersionCell.h
//  Coding_iOS
//
//  Created by Ease on 15/8/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_FileVersionCell @"FileVersionCell"

#import "SWTableViewCell.h"
#import "FileVersion.h"

@interface FileVersionCell : SWTableViewCell
@property (strong, nonatomic) FileVersion *curVersion;
@property (nonatomic,copy) void(^showDiskFileBlock)(NSURL *fileUrl, FileVersion *curVersion);
+ (CGFloat)cellHeight;
@end
