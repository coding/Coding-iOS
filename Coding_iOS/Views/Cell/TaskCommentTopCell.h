//
//  TaskCommentTopCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/28.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TaskCommentTop @"TaskCommentTopCell"

#import <UIKit/UIKit.h>

@interface TaskCommentTopCell : UITableViewCell
@property (strong, nonatomic) UILabel *commentNumStrLabel;
+ (CGFloat)cellHeight;
@end
