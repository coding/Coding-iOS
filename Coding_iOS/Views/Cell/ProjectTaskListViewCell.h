//
//  ProjectTaskListViewCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectTaskList @"ProjectTaskListViewCell"

#import <UIKit/UIKit.h>
#import "Task.h"

@interface ProjectTaskListViewCell : UITableViewCell
@property (strong, nonatomic) Task *task;
@property (copy, nonatomic) void(^checkViewClickedBlock)(Task *task);
+ (CGFloat)cellHeightWithObj:(id)obj;
@end

@interface ProjectTaskListViewCellTagsView : UIView
@property (strong, nonatomic) NSArray *tags;
@property (strong, nonatomic) NSDate *deadline_date;
@property (assign, nonatomic) BOOL done;
+ (instancetype)viewWithTags:(NSArray *)tags andDate:(NSDate *)deadline_date;
- (void)reloadData;
@end

@interface ProjectTaskListViewCellDateView : UIView
+ (instancetype)viewWithDate:(NSDate *)deadline_date andDone:(BOOL)done;
- (void)setDate:(NSDate *)deadline_date andDone:(BOOL)done;
@end