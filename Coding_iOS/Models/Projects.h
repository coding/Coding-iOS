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
#import "Project.h"




typedef NS_ENUM(NSInteger, ProjectsType)
{
    ProjectsTypeAll = 0,
    ProjectsTypeCreated,
    ProjectsTypeJoined,
    ProjectsTypeWatched,
    ProjectsTypeStared,
    ProjectsTypeToChoose,
    ProjectsTypeTaProject,
    ProjectsTypeTaStared,
    ProjectsTypeTaWatched,
    ProjectsTypeAllPublic,
};

@interface Projects : NSObject
@property (strong, nonatomic) User *curUser;
@property (assign, nonatomic) ProjectsType type;
//请求
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
//解析
@property (readwrite, nonatomic, strong) NSNumber *totalPage, *totalRow;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (strong, nonatomic, readonly) NSArray *pinList, *noPinList;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;

+ (Projects *)projectsWithType:(ProjectsType)type andUser:(User *)user;
- (NSDictionary *)toParams;
- (NSString *)toPath;
- (void)configWithProjects:(Projects *)responsePros;

@end





