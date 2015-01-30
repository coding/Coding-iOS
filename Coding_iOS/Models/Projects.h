//
//  Projects.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Task.h"
#import "File.h"
#import "Commit.h"
#import "ProjectTopic.h"
#import "QcTask.h"
#import "HtmlMedia.h"
#import "Depot.h"
#import "ListGroupItem.h"
#import "TaskComment.h"
#import "ProjectActivities.h"




typedef NS_ENUM(NSInteger, ProjectsType)
{
     ProjectsTypeAll = 0,
     ProjectsTypeJoined,
     ProjectsTypeCreated
};

@interface Projects : NSObject
//请求
@property (readwrite, nonatomic, strong) NSString *type;
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
//解析
@property (readwrite, nonatomic, strong) NSNumber *totalPage, *totalRow;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;

+ (Projects *)projectsWithType:(ProjectsType)projectsType;
- (NSDictionary *)toParams;
- (void)configWithProjects:(Projects *)responsePros;

@end

@interface Project : NSObject
@property (readwrite, nonatomic, strong) NSString *icon, *name, *owner_user_name, *backend_project_path, *full_name, *description_mine, *path;
@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *is_public, *un_read_activities_count, *done, *processing;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;

+(Project *)project_All;

- (NSString *)toMembersPath;
- (NSDictionary *)toMembersParams;

- (NSString *)toUpdateVisitPath;
- (NSString *)toDetailPath;

- (NSString *)localMembersPath;

- (NSString *)toBranchOrTagPath:(NSString *)path;
@end




