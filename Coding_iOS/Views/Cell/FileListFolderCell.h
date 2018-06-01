//
//  FileListFolderCell.h
//  Coding_iOS
//
//  Created by Ease on 14/11/14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_FileListFolder @"FileListFolderCell"

#import <UIKit/UIKit.h>
#import "ProjectFile.h"
#import "SWTableViewCell.h"

@interface FileListFolderCell : SWTableViewCell
@property (strong, nonatomic) ProjectFile *folder;
+ (CGFloat)cellHeight;
@end

