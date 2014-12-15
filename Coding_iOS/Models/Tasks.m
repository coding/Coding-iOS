//
//  Tasks.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Tasks.h"

@implementation Tasks
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Task", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _type = TaskQueryTypeAll;//processing.done
        _tasksDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (Tasks *)tasksWithPro:(Project *)project owner:(User *)owner queryType:(TaskQueryType)type{
    Tasks *tasks = [[Tasks alloc] init];
    tasks.owner = owner;
    tasks.backend_project_path = project.backend_project_path;
    tasks.type = type;
    tasks.entranceType = TaskEntranceTypeProject;
    return tasks;
}
+ (Tasks *)tasksWithPro:(Project *)project queryType:(TaskQueryType)type{
    Tasks *tasks = [[Tasks alloc] init];
    tasks.project = project;
    tasks.type = type;
    tasks.entranceType = TaskEntranceTypeMine;
    return tasks;
}
- (NSArray *)processingList{
    if (!_list) {
        return [NSArray array];
    }
    NSArray *list;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status.intValue == %d", 1];
    list = [self.list filteredArrayUsingPredicate:predicate];
    return list ? list : [NSArray array];
}
- (NSArray *)doneList{
    if (!_list) {
        return [NSArray array];
    }
    NSArray *list;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status.intValue == %d", 2];
    list = [self.list filteredArrayUsingPredicate:predicate];
    return list ? list : [NSArray array];
}

- (NSString *)queryType{
    NSString *queryType;
    switch (_type) {
        case TaskQueryTypeAll:
            queryType = @"all";
            break;
        case TaskQueryTypeProcessing:
            queryType = @"processing";
            break;
        case TaskQueryTypeDone:
            queryType = @"done";
            break;
        default:
            queryType = @"all";
            break;
    }
    return queryType;
}

- (NSDictionary *)toParams{
    if (_entranceType == TaskEntranceTypeProject) {
        return [self toParams_Project];
    }else{
        return [self toParams_Mine];
    }
}

- (NSString *)toRequestPath{
    if (_entranceType == TaskEntranceTypeProject) {
        return [self toRequestPath_Project];
    }else{
        return [self toRequestPath_Mine];
    }
}


- (NSDictionary *)toParams_Project{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue +1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}
- (NSString *)toRequestPath_Project{
    NSString *path;
    if (!_owner || !_owner.global_key) {
        path = [NSString stringWithFormat:@"api%@/tasks/%@", self.backend_project_path, self.queryType];
    }else{
        path = [NSString stringWithFormat:@"api%@/tasks/user/%@/%@", self.backend_project_path, _owner.global_key, self.queryType];
    }
    return path;
}

- (NSDictionary *)toParams_Mine{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue +1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}
- (NSString *)toRequestPath_Mine{
    NSString *path;
    if (_project && _project.id.intValue != -1) {
        path = [NSString stringWithFormat:@"api/tasks/project/%d/%@", _project.id.intValue, self.queryType];
    }else{
        path = [NSString stringWithFormat:@"api/tasks/%@", self.queryType];
    }
    return path;
}

- (void)configWithTasks:(Tasks *)resultA{
    self.page = resultA.page;
    self.totalPage = resultA.totalPage;
    self.totalRow = resultA.totalRow;
    
    if (_willLoadMore) {
        [self.list addObjectsFromArray:resultA.list];
    }else{
        self.list = [NSMutableArray arrayWithArray:resultA.list];
    }
    
    self.canLoadMore = self.page.intValue < self.totalPage.intValue;
}

@end
