//
//  ProjectTaskListViewCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface ProjectTaskListViewCell : UITableViewCell
@property (strong, nonatomic) Task *task;
@property (copy, nonatomic) void(^checkViewClickedBlock)(Task *task);
+ (CGFloat)cellHeightWithObj:(id)obj;
@end
