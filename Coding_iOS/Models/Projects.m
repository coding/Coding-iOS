//
//  Projects.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Projects.h"
#import "Login.h"
#import "NSString+Common.h"

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
    pros.pageSize = [NSNumber numberWithInteger:9999];
    return pros;
}

- (NSString *)typeStr{
    NSString *typeStr;
    switch (_type) {
        case  ProjectsTypeAll:
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
    if (self.type >= ProjectsTypeTaProject) {
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
    
    if (_willLoadMore) {
        [self.list addObjectsFromArray:responsePros.list];
    }else{
        self.list = [NSMutableArray arrayWithArray:responsePros.list];
    }
    self.canLoadMore = (self.page.integerValue < self.totalPage.integerValue);
}

@end


@implementation Project
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isStaring = _isWatching = _isLoadingMember = _isLoadingDetail = NO;
        _readMeHeight = 1;
        _recommended = [NSNumber numberWithInteger:0];
    }
    return self;
}
+(Project *)project_All{
    Project *pro = [[Project alloc] init];
    pro.id = [NSNumber numberWithInteger:-1];
    return pro;
}

+ (Project *)project_FeedBack{
    Project *pro = [[Project alloc] init];
    pro.id = [NSNumber numberWithInteger:38894];//iOS公开项目
    pro.is_public = [NSNumber numberWithBool:YES];
    return pro;
}

-(NSString *)toProjectPath{
    return @"api/project";
}

-(NSDictionary *)toCreateParams{
    
    NSString *type;
    if ([self.is_public isEqual:@YES]) {
        type = @"1";
    }else{
        type = @"2";
    }
    
    return @{@"name":self.name,
             @"description":self.description_mine,
             @"type":type,
             @"gitEnabled":@"false",
             @"gitReadmeEnabled":@"false",
             @"gitIgnore":@"no",
             @"gitLicense":@"no",
//             @"importFrom":@"no",
             @"vcsType":@"git"};
}

-(NSString *)toUpdatePath{
    return [self toProjectPath];
}

-(NSDictionary *)toUpdateParams{
    return @{@"name":self.name,
             @"description":self.description_mine,
             @"id":self.id
//             @"default_branch":[NSNull null]
             };
}

-(NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/project/%@",self.id];
}

-(NSDictionary *)toDeleteParamsWithPassword:(NSString *)password{
    return @{@"user_name":[Login curLoginUser].name,
             @"name":self.name,
             @"porject_id":[self.id stringValue],
             @"password":[password sha1Str]};
}

- (NSString *)toMembersPath{
    return [NSString stringWithFormat:@"api/project/%d/members", self.id.intValue];
}
- (NSDictionary *)toMembersParams{
    return @{@"page" : [NSNumber numberWithInteger:1],
             @"pageSize" : [NSNumber numberWithInteger:500]};
}
- (NSString *)toUpdateVisitPath{
    return [NSString stringWithFormat:@"api/project/%d/update_visit", self.id.intValue];
}
- (NSString *)toDetailPath{
    return [NSString stringWithFormat:@"api/user/%@/project/%@", self.owner_user_name, self.name];
}
- (NSString *)localMembersPath{
    return [NSString stringWithFormat:@"%@_MembersPath", self.id.stringValue];
}

- (NSString *)toBranchOrTagPath:(NSString *)path{
    return [NSString stringWithFormat:@"api/user/%@/project/%@/git/%@", self.owner_user_name, self.name, path];
}
- (NSString *)description_mine{
    if (_description_mine && _description_mine.length > 0) {
        return _description_mine;
    }else{
        return @"未填写";
    }
}
@end












