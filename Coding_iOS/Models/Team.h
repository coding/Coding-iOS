//
//  Team.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Team : NSObject
@property (strong, nonatomic) NSNumber *id, *member_count, *project_count, *current_user_role_id;
@property (strong, nonatomic) NSString *name, *introduction, *avatar, *path, *global_key;
@property (strong, nonatomic) NSDate *created_at, *updated_at;
@property (strong, nonatomic) User *owner;
@end