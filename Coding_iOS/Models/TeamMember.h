//
//  TeamMember.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface TeamMember : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id, *team_id, *user_id, *role;//role:80是member，100是creater
@property (readwrite, nonatomic, strong) User *user;
@property (readwrite, nonatomic, strong) NSDate *created_at, *updated_at;
@property (strong, nonatomic) NSString *alias, *default2faMethod;

//edit
@property (strong, nonatomic) NSString *editAlias;
@property (strong, nonatomic) NSNumber *editType;

@end