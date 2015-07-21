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

- (id)initWithFrame:(CGRect)frame tasks:(Tasks *)tasks block:(ProjectTaskBlock)block tabBarHeight:(CGFloat)tabBarHeight;
- (void)setTasks:(Tasks *)tasks;
- (void)refreshToQueryData;
- (void)tabBarItemClicked;
- (void)reloadData;
@end
