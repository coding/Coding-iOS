//
//  Team.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kEANeedTipRemainDays 5

#import <Foundation/Foundation.h>
#import "User.h"

@class TeamInfo;

@interface Team : NSObject
@property (strong, nonatomic) NSNumber *id, *member_count, *project_count, *current_user_role_id;
@property (strong, nonatomic) NSNumber *locked;//是否被锁定（停用）
@property (strong, nonatomic) NSString *name, *introduction, *avatar, *path, *global_key;
@property (strong, nonatomic) NSDate *created_at, *updated_at;
@property (strong, nonatomic) User *owner;
@property (strong, nonatomic) TeamInfo *info;//需要另行请求的参数 request_InfoOfTeam
@property (assign, nonatomic) BOOL hasDismissWebTip;
+ (instancetype)teamWithGK:(NSString *)global_key;
- (NSString *)toUpdateInfoPath;
- (NSDictionary *)toUpdateInfoParams;
@end

@interface TeamInfo : NSObject
@property (strong, nonatomic) NSNumber *balance, *remain_days, *trial, *payed;
@property (strong, nonatomic) NSDate *billing_date, *created_at, *estimate_date, *suspended_at;
@property (strong, nonatomic) NSNumber *locked;//是否被锁定（停用）
- (BOOL)isToped_up;
- (NSInteger)stopped_days;
- (NSInteger)beyond_days;
- (NSInteger)trial_left_days;
@end
