//
//  Projects.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Projects.h"
#import "Login.h"

@implementation Projects

- (instancetype)init
{
    self = [super init];
    if (self) {
        _canLoadMore = NO;
        _isLoading = NO;
        _willLoadMore = NO;
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Project", @"list", nil];
    }
    return self;
}

+ (Projects *)projectsWithType:(ProjectsType)type andUser:(User *)user{
    Projects *pros = [[Projects alloc] init];
    pros.type = type;
    pros.curUser = user;
    
    pros.page = [NSNumber numberWithInteger:1];
    pros.pageSize = @(99999999);
    return pros;
}

- (NSString *)typeStr{
    NSString *typeStr;
    switch (_type) {
        case  ProjectsTypeAll:
        case  ProjectsTypeToChoose:
            typeStr = @"all";
            break;
        case  ProjectsTypeJoined:
            typeStr = @"joined";
            break;
        case  ProjectsTypeCreated:
            typeStr = @"created";
            break;
        case  ProjectsTypeTaProject:
            typeStr = @"project";
            break;
        case  ProjectsTypeTaStared:
            typeStr = @"stared";
            break;
        case  ProjectsTypeTaWatched:
            typeStr = @"watched";
            break;
        case  ProjectsTypeWatched:
            typeStr = @"watched";
            break;
        case  ProjectsTypeStared:
            typeStr = @"stared";
            break;
        default:
            typeStr = @"all";
            break;
    }
    return typeStr;
}


- (NSDictionary *)toParams{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"page" : [NSNumber numberWithInteger:_willLoadMore? self.page.integerValue+1 : 1],
                                     @"pageSize" : self.pageSize,
                                     @"type" : [self typeStr]}];
    if (self.type == ProjectsTypeAll) {
        [params setObject:@"hot" forKey:@"sort"];
    }
    return params;
}

- (NSString *)toPath{
    NSString *path;
    if (self.type==ProjectsTypeAllPublic) {
        path = @"api/public/all";
    }else if (self.type >= ProjectsTypeTaProject && self.type < ProjectsTypeAllPublic) {
        path = [NSString stringWithFormat:@"api/user/%@/public_projects", _curUser.global_key];
    }else{
        path = @"api/projects";
    }
    return path;
}

- (void)configWithProjects:(Projects *)responsePros{
    self.page = responsePros.page;
    self.totalRow = responsePros.totalRow;
    self.totalPage = responsePros.totalPage;
    self.canLoadMore = (self.page.integerValue < self.totalPage.integerValue);

    NSArray *projectList = responsePros.list;
    if (self.type == ProjectsTypeToChoose) {
        projectList = [projectList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"is_public == %d", NO]];
    }
    if (!projectList) {
        return;
    }
    
    if (_willLoadMore) {
        [self.list addObjectsFromArray:projectList];
    }else{
        self.list = [NSMutableArray arrayWithArray:projectList];
    }
}
- (NSArray *)pinList{
    NSArray *list = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pin.intValue == 1"];
    list = [self.list filteredArrayUsingPredicate:predicate];
    return list;
}
- (NSArray *)noPinList{
    NSArray *list = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pin.intValue == 0"];
    list = [self.list filteredArrayUsingPredicate:predicate];
    return list;
}
@end













