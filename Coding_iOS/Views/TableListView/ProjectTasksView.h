//
//  ProjectTasksView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "Tasks.h"
#import "ProjectTaskListView.h"
#import "ProjectMember.h"


@interface ProjectTasksView : UIView

@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *status; //任务状态，进行中的为1，已完成的为2
@property (nonatomic, strong) NSString *label; //任务标签
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) TaskRoleType role;
@property (nonatomic, strong) NSString *project_id;
@property (nonatomic, copy) void(^selctUserBlock)(NSString *owner);

- (id)initWithFrame:(CGRect)frame project:(Project *)project block:(ProjectTaskBlock)block defaultIndex:(NSInteger)index;
- (void)refreshToQueryData;
- (ProjectMember *)selectedMember;

- (void)refresh;
@end
