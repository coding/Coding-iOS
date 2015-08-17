//
//  Project.m
//  Coding_iOS
//
//  Created by Ease on 15/4/23.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "Project.h"
#import "Login.h"

@implementation Project
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isStaring = _isWatching = _isLoadingMember = _isLoadingDetail = NO;
        _recommended = [NSNumber numberWithInteger:0];
    }
    return self;
}

- (void)setFull_name:(NSString *)full_name{
    _full_name = full_name;
    NSArray *components = [_full_name componentsSeparatedByString:@"/"];
    if (components.count == 2) {
        if (!_owner_user_name) {
            _owner_user_name = components[0];
        }
        if (_name) {
            _name = components[1];
        }
    }
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
             @"gitEnabled":@"true",
             @"gitReadmeEnabled":@"true",
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

-(NSString *)toUpdateIconPath{
    return [NSString stringWithFormat:@"api/project/%@/project_icon",self.id];
}

-(NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/user/%@/project/%@",self.owner_user_name, self.name];
}

- (NSString *)toMembersPath{
    if ([_id isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"api/project/%d/members", self.id.intValue];
    }else{
        return [NSString stringWithFormat:@"api/user/%@/project/%@/members", _owner_user_name, _name];
    }
}
- (NSDictionary *)toMembersParams{
    return @{@"page" : [NSNumber numberWithInteger:1],
             @"pageSize" : [NSNumber numberWithInteger:500]};
}
- (NSString *)toUpdateVisitPath{
    if (self.owner_user_name.length > 0 && self.name.length > 0) {
        return [NSString stringWithFormat:@"api/user/%@/project/%@/update_visit", self.owner_user_name, self.name];
    }else{
        return [NSString stringWithFormat:@"api/project/%d/update_visit", self.id.intValue];
    }
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
//- (NSString *)description_mine{
//    if (_description_mine && _description_mine.length > 0) {
//        return _description_mine;
//    }else{
//        return @"未填写";
//    }
//}
@end
