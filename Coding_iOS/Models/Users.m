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
        _pageSize = [NSNumber numberWithInteger:9999];
    }
    return self;
}

+(Users *)usersWithOwner:(User *)owner Type:(UsersType)type{
    Users *users = [[Users alloc] init];
    users.owner = owner;
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
    return path;
}

- (NSDictionary *)toParams{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue+1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}

- (void)configWithObj:(Users *)resultA{
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
}
@end
