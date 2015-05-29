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
    
    if (_list.count > 0) {
        NSPredicate *donePredicate = [NSPredicate predicateWithFormat:@"status.intValue == %d", 2];
        NSPredicate *processingPredicate = [NSPredicate predicateWithFormat:@"status.intValue == %d", 1];
        _doneList = [self.list filteredArrayUsingPredicate:donePredicate];
        _processingList = [self.list filteredArrayUsingPredicate:processingPredicate];
    }else{
        _doneList = _processingList = nil;
    }
}

@end
