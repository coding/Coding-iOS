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
- (NSString *)toPath;
- (NSDictionary *)toParams;

+ (BOOL) isLogin;
+ (void) doLogin:(NSDictionary *)loginData;
+ (void) doLogout;
+ (void)setPreUserEmail:(NSString *)emailStr;
+ (NSString *)preUserEmail;
+ (User *)curLoginUser;
+ (void)setXGAccountWithCurUser;
+ (User *)userWithGlobaykeyOrEmail:(NSString *)textStr;
+ (NSMutableDictionary *)readLoginDataList;
+(BOOL)isLoginUserGlobalKey:(NSString *)global_key;
@end
