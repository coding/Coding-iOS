//
//  TaskCommentCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/28.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TaskComment @"TaskCommentCell"

#import <UIKit/UIKit.h>
#import "TaskComment.h"

@interface TaskCommentCell : UITableViewCell
@property (strong, nonatomic) TaskComment *curComment;
+ (CGFloat)cellHeightWithObj:(id)obj;

@end
