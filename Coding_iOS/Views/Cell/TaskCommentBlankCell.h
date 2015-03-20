//
//  TaskCommentBlankCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/28.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TaskCommentBlank @"TaskCommentBlankCell"

#import <UIKit/UIKit.h>

@interface TaskCommentBlankCell : UITableViewCell
@property (strong, nonatomic) UILabel *blankStrLabel;
+ (CGFloat)cellHeight;
@end
