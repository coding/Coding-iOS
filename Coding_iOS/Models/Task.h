//
//  Task.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-15.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Projects.h"
#import "Login.h"
#import "TaskComment.h"

@class Project;
@class Task_Description;

typedef NS_ENUM(NSInteger, TaskHandleType) {
    TaskHandleTypeAdd = 0,
    TaskHandleTypeEdit
};

@interface Task : NSObject
@property (readwrite, nonatomic, strong) User *owner, *creator;
@property (readwrite, nonatomic, strong) NSString *title, *content, *backend_project_path, *deadline, *path, *description_mine;
@property (readwrite, nonatomic, strong) NSDate *created_at, *updated_at;
@property (readonly, nonatomic, strong) NSDate *deadline_date;
@property (readwrite, nonatomic, strong) Project *project;
@property (readwrite, nonatomic, strong) NSNumber *id, *status, *owner_id, *priority, *comments, *has_description;
@property (readwrite, nonatomic, strong) NSMutableArray *commentList;
@property (nonatomic, assign) TaskHandleType handleType;
@property (nonatomic, assign) BOOL isRequesting, isRequestingDetail, isRequestingCommentList, needRefreshDetail;
@property (readwrite, nonatomic, strong) NSString *nextCommentStr;
@property (strong, nonatomic) Task_Description *task_description;

+ (Task *)taskWithProject:(Project *)project;
+ (Task *)taskWithBackend_project_path:(NSString *)backend_project_path andId:(NSString *)taskId;
+ (Task *)taskWithTask:(Task *)task;
- (BOOL)isSameToTask:(Task *)task;
//内容
- (NSString *)toEditTaskContentPath;
-(NSDictionary *)toEditContentParams;
//执行人
- (NSString *)toEditTaskOwnerPath;
-(NSDictionary *)toEditOwnerParams;
//任务状态
- (NSString *)toEditTaskStatusPath;
-(NSDictionary *)toEditStatusParams;
-(NSDictionary *)toChangeStatusParams;
//任务优先级
- (NSString *)toEditTaskPriorityPath;
-(NSDictionary *)toEditPriorityParams;
//更新任务
- (NSString *)toUpdatePath;
-(NSDictionary *)toUpdateParamsWithOld:(Task *)oldTask;
//添加新任务
- (NSString *)toAddTaskPath;
- (NSDictionary *)toAddTaskParams;
//删除任务
- (NSString *)toDeleteTaskPath;

//任务评论列表
- (NSString *)toCommentListPath;
- (NSDictionary *)toCommentListParams;

//任务详情
- (NSString *)toTaskDetailPath;

//任务描述
- (NSString *)toDescriptionPath;

//评论任务
- (NSString *)toDoCommentPath;
- (NSDictionary *)toDoCommentParams;

- (void)addNewComment:(TaskComment *)comment;
- (void)deleteComment:(TaskComment *)comment;
@end

@interface Task_Description : NSObject
@property (strong, nonatomic) NSString *description_mine, *markdown;
@property (strong, nonatomic) HtmlMedia *htmlMedia;
+ (instancetype)taskDescriptionFrom:(Task_Description *)oldDes;
+ (instancetype)defaultDescription;
- (BOOL)isSameTo:(Task_Description *)td;
@end
