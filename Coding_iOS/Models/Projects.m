//
//  Projects.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Projects.h"

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

+ (Projects *)projectsWithType:(ProjectsType)projectsType{
    Projects *pros = [[Projects alloc] init];
    pros.page = [NSNumber numberWithInteger:1];
    pros.pageSize = [NSNumber numberWithInteger:9999];

    
    switch (projectsType) {
        case  ProjectsTypeAll:
            pros.type = @"all";
            break;
        case  ProjectsTypeJoined:
            pros.type = @"joined";
            break;
        case  ProjectsTypeCreated:
            pros.type = @"created";
            break;
        default:
            pros.type = @"all";
            break;
    }
    return pros;
}

- (NSDictionary *)toParams{
    if ([self.type isEqualToString:@"all"]) {
        return @{@"page" : _willLoadMore? [NSNumber numberWithInteger:self.page.integerValue+1]: [NSNumber numberWithInteger:1],
                 @"pageSize" : self.pageSize,
                 @"type" : self.type,
                 @"sort" : @"hot"};
    }else{
        return @{@"page" : _willLoadMore? [NSNumber numberWithInteger:self.page.integerValue+1]: [NSNumber numberWithInteger:1],
                 @"pageSize" : self.pageSize,
                 @"type" : self.type};
    }

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
        _canLoadMore = NO;
        _isLoading = NO;
        _willLoadMore = NO;
    }
    return self;
}
+(Project *)project_All{
    Project *pro = [[Project alloc] init];
    pro.id = [NSNumber numberWithInteger:-1];
    return pro;
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
@end












