//
//  Tasks.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

typedef NS_ENUM(NSInteger, TaskQueryType){
    TaskQueryTypeAll = 0,
    TaskQueryTypeProcessing,
    TaskQueryTypeDone
};

typedef NS_ENUM(NSInteger, TaskEntranceType){
    TaskEntranceTypeProject = 0,
    TaskEntranceTypeMine,
};

typedef NS_ENUM(NSInteger, TaskRoleType)
{
    TaskRoleTypeOwner = 0, //执行者
    TaskRoleTypeWatcher, //关注者
    TaskRoleTypeCreator,  //创建者
    TaskRoleTypeAll,   //所有任务
};

@interface Tasks : NSObject

@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (readwrite, nonatomic, strong) NSString *backend_project_path;//从Project中取来的
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (strong, nonatomic) NSArray *doneList, *processingList;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) Project *project;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (assign, nonatomic) TaskQueryType type;
@property (assign, nonatomic) TaskEntranceType entranceType;

+ (Tasks *)tasksWithPro:(Project *)project owner:(User *)owner queryType:(TaskQueryType)type;
+ (Tasks *)tasksWithPro:(Project *)project queryType:(TaskQueryType)type;

- (NSString *)queryType;
- (NSDictionary *)toParams;
- (NSString *)toRequestPath;

- (void)configWithTasks:(Tasks *)resultA;

@end
