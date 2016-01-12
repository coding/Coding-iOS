//
//  ProjectMember.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ProjectMember : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id, *project_id, *user_id, *type, *done, *processing;//type:80是member，100是creater
@property (readwrite, nonatomic, strong) User *user;
@property (readwrite, nonatomic, strong) NSDate *created_at, *last_visit_at;
@property (strong, nonatomic) NSString *alias, *editAlias;
@property (strong, nonatomic) NSNumber *editType;
+ (ProjectMember *)member_All;
- (NSString *)toQuitPath;
- (NSString *)toKickoutPath;
@end
