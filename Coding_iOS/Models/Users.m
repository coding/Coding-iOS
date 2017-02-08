//
//  Users.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Users.h"

@implementation Users
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"User", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = @(99999999);
    }
    return self;
}

+(Users *)usersWithOwner:(User *)owner Type:(UsersType)type{
    Users *users = [[Users alloc] init];
    users.owner = owner;
    users.type = type;
    return users;
}

+(Users *)usersWithProjectOwner:(NSString *)owner_name projectName:(NSString *)name Type:(UsersType)type{
    Users *users = [[Users alloc] init];
    users.project_owner_name = owner_name;
    users.project_name = name;
    users.type = type;
    return users;
}

- (NSString *)toPath{
    NSString *path;
    if (_type == UsersTypeFollowers) {
        path = @"api/user/followers";
    }else if (_type == UsersTypeFriends_Message || _type == UsersTypeFriends_Attentive || _type == UsersTypeFriends_At || _type == UsersTypeFriends_Transpond){
        path = @"api/user/friends";
    }
    if (_owner && _owner.global_key) {
        path = [path stringByAppendingFormat:@"/%@", _owner.global_key];
    }
    if (_type == UsersTypeProjectStar) {
        path = [NSString stringWithFormat:@"api/user/%@/project/%@/stargazers", _project_owner_name, _project_name];
    }else if (_type == UsersTypeProjectWatch){
        path = [NSString stringWithFormat:@"api/user/%@/project/%@/watchers", _project_owner_name, _project_name];
    }
    return path;
}

- (NSDictionary *)toParams{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue+1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}

- (void)configWithObj:(Users *)resultA{
    if ([resultA isKindOfClass:[Users class]]) {
        self.page = resultA.page;
        self.pageSize = resultA.pageSize;
        self.totalPage = resultA.totalPage;
        self.totalRow = resultA.totalRow;
        if (_willLoadMore) {
            [self.list addObjectsFromArray:resultA.list];
        }else{
            self.list = [NSMutableArray arrayWithArray:resultA.list];
        }
        self.canLoadMore = self.page.intValue < self.totalPage.intValue;
    }else if ([resultA isKindOfClass:[NSArray class]]){
        self.list = [(NSArray *)resultA mutableCopy];
        self.canLoadMore = NO;
    }
}

- (NSDictionary *)dictGroupedByPinyin{
    if (self.list.count <= 0) {
        return @{@"#" : [NSMutableArray array]};
    }
    
    NSMutableDictionary *groupedDict = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *allKeys = [[NSMutableArray alloc] init];
    for (char c = 'A'; c < 'Z'+1; c++) {
        char key[2];
        key[0] = c;
        key[1] = '\0';
        [allKeys addObject:[NSString stringWithUTF8String:key]];
    }
    [allKeys addObject:@"#"];
    
    for (NSString *keyStr in allKeys) {
        [groupedDict setObject:[[NSMutableArray alloc] init] forKey:keyStr];
    }
    
    [self.list enumerateObjectsUsingBlock:^(User *obj, NSUInteger idx, BOOL *stop) {
        NSString *keyStr = nil;
        NSMutableArray *dataList = nil;
        
        if (obj.pinyinName.length > 1) {
            keyStr = [obj.pinyinName substringToIndex:1];
            if ([[groupedDict allKeys] containsObject:keyStr]) {
                dataList = [groupedDict objectForKey:keyStr];
            }
        }
        
        if (!dataList) {
            keyStr = @"#";
            dataList = [groupedDict objectForKey:keyStr];
        }
        
        [dataList addObject:obj];
        [groupedDict setObject:dataList forKey:keyStr];
    }];
    
    for (NSString *keyStr in allKeys) {
        NSMutableArray *dataList = [groupedDict objectForKey:keyStr];
        if (dataList.count <= 0) {
            [groupedDict removeObjectForKey:keyStr];
        }else if (dataList.count > 1){
            [dataList sortUsingComparator:^NSComparisonResult(User *obj1, User *obj2) {
                return [obj1.pinyinName compare:obj2.pinyinName];
            }];
        }
    }
    
    return groupedDict;
}
@end
