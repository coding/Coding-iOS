//
//  Login.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Team.h"
#import "Project.h"

@interface Login : NSObject
//请求
@property (readwrite, nonatomic, strong) NSString *email, *password, *j_captcha, *company, *ssoType;
@property (readwrite, nonatomic, strong) NSNumber *remember_me;
@property (readwrite, nonatomic) BOOL ssoEnabled;

- (NSString *)goToLoginTipWithCaptcha:(BOOL)needCaptcha;
- (NSString *)toPath;
- (NSDictionary *)toParams;

+ (BOOL) isLogin;
+ (void) doLogin:(NSDictionary *)loginData;
+ (void) doLoginCompany:(NSDictionary *)loginCompanyData;
+ (void) updateLoginIsAdministrator:(NSNumber *)isAdministrator;
+ (void) doLogout;
+ (void)setPreUserEmail:(NSString *)emailStr;
+ (NSString *)preUserEmail;
+ (User *)curLoginUser;
+ (Team *)curLoginCompany;

+ (void)setXGAccountWithCurUser;
+ (User *)userWithGlobaykeyOrEmail:(NSString *)textStr;
+ (NSMutableDictionary *)readLoginDataList;
+ (BOOL)isLoginUserGlobalKey:(NSString *)global_key;
+ (BOOL)canEditPro:(Project *)pro;

// Git Clone 需要用 http 的方式校验
+ (void)setPassword:(NSString *)password;
+ (NSString *)curPassword;

@end
