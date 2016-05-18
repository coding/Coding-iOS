//
//  TaskDescriptionCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/20.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_TaskDescriptionCell @"TaskDescriptionCell"

#import <UIKit/UIKit.h>

@interface TaskDescriptionCell : UITableViewCell
@property (copy, nonatomic) void(^buttonClickedBlock)();
- (void)setTitleStr:(NSString *)title andSpecail:(BOOL)isSpecail;

+ (CGFloat)cellHeight;
@end
