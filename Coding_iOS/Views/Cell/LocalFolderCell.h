//
//  LocalFolderCell.h
//  Coding_iOS
//
//  Created by Ease on 15/9/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_LocalFolderCell @"LocalFolderCell"

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface LocalFolderCell : SWTableViewCell
- (void)setProjectName:(NSString *)name fileCount:(NSInteger)fileCount;
+ (CGFloat)cellHeight;
@end
