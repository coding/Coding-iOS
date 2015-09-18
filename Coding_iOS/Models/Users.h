//
//  Users.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef NS_ENUM(NSInteger, UsersType) {
    UsersTypeFollowers = 0,
    UsersTypeFriends_Attentive,
    UsersTypeFriends_Message,
    UsersTypeFriends_At,
    UsersTypeFriends_Transpond,
    
    UsersTypeProjectStar,
    UsersTypeProjectWatch,
    
    UsersTypeTweetLikers,
    UsersTypeAddToProject,
    UsersTypeAddFriend,
};

@interface Users : NSObject
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (assign, nonatomic) UsersType type;
@property (strong, nonatomic) User *owner;
@property (strong, nonatomic) NSString *project_owner_name, *project_name;

- (NSString *)toPath;
- (NSDictionary *)toParams;
- (void)configWithObj:(Users *)resultA;

- (NSDictionary *)dictGroupedByPinyin;

+(Users *)usersWithOwner:(User *)owner Type:(UsersType)type;
+(Users *)usersWithProjectOwner:(NSString *)owner_name projectName:(NSString *)name Type:(UsersType)type;

@end
