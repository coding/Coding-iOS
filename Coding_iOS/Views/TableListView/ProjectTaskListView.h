//
//  ProjectTaskListView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tasks.h"
@class ProjectTaskListView;

typedef void(^ProjectTaskBlock)(ProjectTaskListView *taskListView, Task *task);

@interface ProjectTaskListView : UIView<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *status; //任务状态，进行中的为1，已完成的为2
@property (nonatomic, strong) NSString *label; //任务标签
@property (nonatomic, strong) NSString *project_id;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) TaskRoleType role;


- (id)initWithFrame:(CGRect)frame tasks:(Tasks *)tasks project_id:(NSString *)project_id keyword:(NSString *)keyword status:(NSString *)status label:(NSString *)label userId:(NSString *)userId role:(TaskRoleType )role block:(ProjectTaskBlock)block tabBarHeight:(CGFloat)tabBarHeight;
- (void)setTasks:(Tasks *)tasks;
- (void)refreshToQueryData;
- (void)tabBarItemClicked;
- (void)reloadData;
- (void)refresh;
@end
