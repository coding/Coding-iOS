//
//  ProjectActivities.h
//  Coding_iOS
//
//  Created by Ease on 14/12/1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Projects.h"

typedef NS_ENUM(NSInteger, ProjectActivityType)
{
    ProjectActivityTypeAll = 0,
    ProjectActivityTypeTask,
    ProjectActivityTypeTopic,
    ProjectActivityTypeFile,
    ProjectActivityTypeCode,
    ProjectActivityTypeOther
};

@class Task;
@class ProjectTopic;

@interface ProjectActivities : NSObject
@property (readwrite, nonatomic, strong) NSNumber *project_id, *last_id, *user_id;
@property (readwrite, nonatomic, strong) NSString *type;

@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSMutableArray *list, *listGroups;
@property (readwrite, nonatomic, strong) Project *curProject;
@property (readwrite, nonatomic, strong) User *curUser;
@property (assign, nonatomic) BOOL isOfUser;

+ (ProjectActivities *)proActivitiesWithPro:(Project *)project type:(ProjectActivityType)type;
+ (ProjectActivities *)proActivitiesWithPro:(Project *)project user:(User *)user;
- (NSString *)toPath;
- (NSDictionary *)toParams;

- (void)configWithProActList:(NSArray *)responseA;
@end

@interface ProjectActivity : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id;
@property (readwrite, nonatomic, strong) NSString *target_type, *action, *action_msg, *type, *ref, *ref_type, *ref_path, *pull_request_title, *merge_request_title, *comment_content;
@property (readwrite, nonatomic, strong) User *user, *target_user;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) Task *origin_task, *task;
@property (readwrite, nonatomic, strong) TaskComment *taskComment, *origin_taskComment;
@property (readwrite, nonatomic, strong) Project *project;
@property (readwrite, nonatomic, strong) ProjectTopic *project_topic;
@property (readwrite, nonatomic, strong) File *file;
@property (readwrite, nonatomic, strong) QcTask *qc_task;
@property (readwrite, nonatomic, strong) Depot *depot, *source_depot;
@property (readwrite, nonatomic, strong) NSMutableArray *commits;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;

@property (readonly, nonatomic, strong) NSMutableArray *actionMediaItems, *contentMediaItems;
@property (readonly, nonatomic, strong) NSMutableString *actionStr, *contentStr;

@end
