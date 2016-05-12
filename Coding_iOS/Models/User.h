//
//  User.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (readwrite, nonatomic, strong) NSString *avatar, *name, *global_key, *path, *slogan, *company, *tags_str, *tags, *location, *job_str, *job, *email, *birthday, *pinyinName;
@property (readwrite, nonatomic, strong) NSString *curPassword, *resetPassword, *resetPasswordConfirm, *phone, *introduction, *phone_country_code, *country;

@property (readwrite, nonatomic, strong) NSNumber *id, *sex, *follow, *followed, *fans_count, *follows_count, *tweets_count, *status, *points_left, *email_validation, *is_phone_validated;
@property (readwrite, nonatomic, strong) NSDate *created_at, *last_logined_at, *last_activity_at, *updated_at;

+ (User *)userWithGlobalKey:(NSString *)global_key;

- (BOOL)isSameToUser:(User *)user;

- (NSString *)toUserInfoPath;

- (NSString *)toResetPasswordPath;
- (NSDictionary *)toResetPasswordParams;

- (NSString *)toFllowedOrNotPath;
- (NSDictionary *)toFllowedOrNotParams;

- (NSString *)toUpdateInfoPath;
- (NSDictionary *)toUpdateInfoParams;

- (NSString *)toDeleteConversationPath;

- (NSString *)localFriendsPath;

- (NSString *)changePasswordTips;
@end
