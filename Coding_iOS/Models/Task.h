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
#import "ProjectTag.h"
#import "ResourceReference.h"

@class Project;
@class Task_Description;

typedef NS_ENUM(NSInteger, TaskHandleType) {
    TaskHandleTypeEdit = 0,
    TaskHandleTypeAddWithProject,
    TaskHandleTypeAddWithoutProject
};

@interface Task : NSObject
@property (readwrite, nonatomic, strong) User *owner, *creator;
@property (readwrite, nonatomic, strong) NSString *title, *content, *backend_project_path, *deadline, *path, *description_mine,*descript;
@property (readwrite, nonatomic, strong) NSDate *created_at, *updated_at;
@property (readonly, nonatomic, strong) NSDate *deadline_date;
@property (readwrite, nonatomic, strong) Project *project;
@property (readwrite, nonatomic, strong) NSNumber *id, *status, *owner_id, *priority, *comments, *has_description, *number,*resource_id;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSMutableArray *activityList, *labels, *watchers;
@property (nonatomic, assign) TaskHandleType handleType;
@property (nonatomic, assign) BOOL isRequesting, isRequestingDetail, isRequestingCommentList, needRefreshDetail;
@property (readwrite, nonatomic, strong) NSString *nextCommentStr;
@property (strong, nonatomic) Task_Description *task_description;
@property (strong, nonatomic) ResourceReference *resourceReference;

+ (Task *)taskWithProject:(Project *)project andUser:(User *)user;
+ (Task *)taskWithBackend_project_path:(NSString *)backend_project_path andId:(NSString *)taskId;
+ (Task *)taskWithTask:(Task *)task;
- (BOOL)isSameToTask:(Task *)task;
- (User *)hasWatcher:(User *)watcher;

//任务状态
- (NSString *)toEditTaskStatusPath;
-(NSDictionary *)toEditStatusParams;
-(NSDictionary *)toChangeStatusParams;
//更新任务
- (NSString *)toUpdatePath;
-(NSDictionary *)toUpdateParamsWithOld:(Task *)oldTask;
//更新任务描述
- (NSString *)toUpdateDescriptionPath;
//添加新任务
- (NSString *)toAddTaskPath;
- (NSDictionary *)toAddTaskParams;
//删除任务
- (NSString *)toDeleteTaskPath;
//任务评论列表
- (NSString *)toCommentListPath;
- (NSDictionary *)toCommentListParams;
//任务动态列表
- (NSString *)toActivityListPath;
//任务详情
- (NSString *)toTaskDetailPath;
//任务描述
- (NSString *)toDescriptionPath;
//任务关联资源
- (NSString *)toResourceReferencePath;
//任务关注者列表
- (NSString *)toWatchersPath;
//评论任务
- (NSString *)toDoCommentPath;
- (NSDictionary *)toDoCommentParams;

- (NSString *)toEditLabelsPath;

//- (void)addNewComment:(TaskComment *)comment;
//- (void)deleteComment:(TaskComment *)comment;
@end

@interface Task_Description : NSObject
@property (strong, nonatomic) NSString *description_mine, *markdown;
+ (instancetype)defaultDescription;
+ (instancetype)descriptionWithMdStr:(NSString *)mdStr;

@end
