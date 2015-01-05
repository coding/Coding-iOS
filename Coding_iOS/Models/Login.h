//
//  Login.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
@interface Login : NSObject
//请求
@property (readwrite, nonatomic, strong) NSString *email, *password, *j_captcha;
@property (readwrite, nonatomic, strong) NSNumber *remember_me;

- (NSString *)goToLoginTipWithCaptcha:(BOOL)needCaptcha;
- (NSDictionary *)toParams;

+ (BOOL) isLogin;
+ (void) doLogin:(NSDictionary *)loginData;
+ (void) doLogout;
+ (User *)curLoginUser;
+ (void)addUmengAliasWithCurUser:(BOOL)add;
+ (void)setXGAccountWithCurUser;
+ (BOOL)isOwnerOfProjectWithOwnerId:(NSNumber *)owner_id;
+ (User *)userWithGlobaykeyOrEmail:(NSString *)textStr;
@end
