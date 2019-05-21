//
//  Login.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Login.h"
#import "XGPush.h"
#import "AppDelegate.h"
#import "Coding_NetAPIManager.h"

#define kLoginStatus @"login_status"
#define kLoginPreUserEmail @"pre_user_email"
#define kLoginUserDict @"user_dict"
#define kLoginDataListPath @"login_data_list_path.plist"
#define kLoginTeamKey @"login_team_key"
#define kLoginPasswordKey(_key_) [NSString stringWithFormat:@"password|%@", _key_]

static User *curLoginUser;
static Team *curLoginTeam;

@implementation Login
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.remember_me = [NSNumber numberWithBool:YES];
        self.email = @"";
        self.password = @"";
        self.ssoType = @"default";
        self.ssoEnabled = NO;
    }
    return self;
}

- (NSString *)toPath{
    return @"api/v2/account/login";
}
- (NSDictionary *)toParams{
    NSString *password = [self.password sha1Str];
    if (self.ssoEnabled && [self.ssoType isEqualToString:@"ldap"]) {
        password = self.password;
    }
    NSMutableDictionary *params = @{@"account": self.email,
                                    @"password" : password,
                                    @"remember_me" : self.remember_me? @"true" : @"false",}.mutableCopy;
    if (self.j_captcha.length > 0) {
        params[@"j_captcha"] = self.j_captcha;
    }
    [Login p_setPassword:self.password forAccount:self.email.lowercaseString];//保存一下密码
    return params;
}

- (NSString *)goToLoginTipWithCaptcha:(BOOL)needCaptcha{
    if (kTarget_Enterprise && _company.length <= 0) {
        return @"请填写企业域名";
    }
    if (!_email || _email.length <= 0) {
        return @"请填写「手机号码/电子邮箱/用户名」";
    }
    if (!_password || _password.length <= 0) {
        return @"请填写密码";
    }
    if (needCaptcha && (!_j_captcha || _j_captcha.length <= 0)) {
        return @"请填写验证码";
    }
    return nil;
}

+ (BOOL)isLogin{
    NSNumber *loginStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginStatus];
    if (loginStatus.boolValue && [Login curLoginUser]) {
        User *loginUser = [Login curLoginUser];
        if (loginUser.status && loginUser.status.integerValue == 0) {
            return NO;
        }
        return YES;
    }else{
        return NO;
    }
}

+ (void)doLogin:(NSDictionary *)loginData{
    
//    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"cookies : %@", obj.description);
//    }];
    
    if (loginData) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:kLoginStatus];
        [defaults setObject:loginData forKey:kLoginUserDict];
        curLoginUser = [NSObject objectOfClass:@"User" fromJSON:loginData];
        [defaults synchronize];
        [Login setXGAccountWithCurUser];
        
        [self saveLoginData:loginData];
        
        if (kTarget_Enterprise) {
            if (![self curLoginCompany]) {
                [[Coding_NetAPIManager sharedManager] request_UpdateCompanyInfoBlock:^(id data, NSError *error) {
                }];
            }
            if (!curLoginUser.isAdministrator) {
                [[Coding_NetAPIManager sharedManager] request_UpdateIsAdministratorBlock:^(id data, NSError *error) {
                }];
            }
        }
    }else{
        [Login doLogout];
    }
}

+ (void) doLoginCompany:(NSDictionary *)loginCompanyData{
    if (loginCompanyData) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:loginCompanyData forKey:kLoginTeamKey];
        curLoginTeam = [NSObject objectOfClass:@"Team" fromJSON:loginCompanyData];
        [defaults synchronize];
    }
}

+ (void) updateLoginIsAdministrator:(NSNumber *)isAdministrator{
    if (!isAdministrator) {
        return;
    }
    if (!curLoginUser.isAdministrator || [curLoginUser.isAdministrator isEqualToNumber:isAdministrator]) {
        curLoginUser.isAdministrator = isAdministrator;
        
        NSMutableDictionary *loginData = [[[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserDict] mutableCopy];
        loginData[@"isAdministrator"] = isAdministrator;
        [self doLogin:loginData];
    }
}

+ (NSMutableDictionary *)readLoginDataList{
    NSMutableDictionary *loginDataList = [NSMutableDictionary dictionaryWithContentsOfFile:[self loginDataListPath]];
    if (!loginDataList) {
        loginDataList = [NSMutableDictionary dictionary];
    }
    return loginDataList;
}

+ (BOOL)saveLoginData:(NSDictionary *)loginData{
    BOOL saved = NO;
    if (loginData) {
        NSMutableDictionary *loginDataList = [self readLoginDataList];
        User *curUser = [NSObject objectOfClass:@"User" fromJSON:loginData];
        if (curUser.global_key.length > 0) {
            [loginDataList setObject:loginData forKey:curUser.global_key];
            saved = YES;
        }
        if (curUser.email.length > 0) {
            [loginDataList setObject:loginData forKey:curUser.email];
            saved = YES;
        }
        if (curUser.phone.length > 0) {
            [loginDataList setObject:loginData forKey:curUser.phone];
            saved = YES;
        }
        if (saved) {
            saved = [loginDataList writeToFile:[self loginDataListPath] atomically:YES];
        }
    }
    return saved;
}

+ (NSString *)loginDataListPath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentPath stringByAppendingPathComponent:kLoginDataListPath];
}

+ (User *)userWithGlobaykeyOrEmail:(NSString *)textStr{
    if (textStr.length <= 0) {
        return nil;
    }
    NSMutableDictionary *loginDataList = [self readLoginDataList];
    NSDictionary *loginData = [loginDataList objectForKey:textStr];
    return [NSObject objectOfClass:@"User" fromJSON:loginData];
}

+ (void)setXGAccountWithCurUser{
    if ([self isLogin]) {
        User *user = [Login curLoginUser];
        if (user && user.global_key.length > 0) {
            NSString *global_key = user.global_key;
            [XGPush setAccount:global_key];
            [(AppDelegate *)[UIApplication sharedApplication].delegate registerPush];
        }
    }else{
        [XGPush setAccount:nil];
        [XGPush unRegisterDevice];
    }
}

+ (void)doLogout{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:kLoginStatus];
    [defaults synchronize];
    //删掉 coding 的 cookie
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.domain hasSuffix:@".coding.net"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:obj];
        }
    }];
    [Login setXGAccountWithCurUser];
}

+ (void)setPreUserEmail:(NSString *)emailStr{
    if (emailStr.length <= 0) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:emailStr forKey:kLoginPreUserEmail];
    [defaults synchronize];
}

+ (NSString *)preUserEmail{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLoginPreUserEmail];
}

+ (User *)curLoginUser{
    if (!curLoginUser) {
        NSDictionary *loginData = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserDict];
        curLoginUser = loginData? [NSObject objectOfClass:@"User" fromJSON:loginData]: nil;
    }
    return curLoginUser;
}

+ (Team *)curLoginCompany{
    if (!curLoginTeam) {
        NSDictionary *loginCompanyData = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginTeamKey];
        curLoginTeam = loginCompanyData? [NSObject objectOfClass:@"Team" fromJSON:loginCompanyData]: nil;
    }
    return [curLoginTeam.global_key.lowercaseString isEqualToString:[NSObject baseCompany].lowercaseString]? curLoginTeam: nil;
}

+(BOOL)isLoginUserGlobalKey:(NSString *)global_key{
    if (global_key.length <= 0) {
        return NO;
    }
    return [[self curLoginUser].global_key isEqualToString:global_key];
}
+ (BOOL)canEditPro:(Project *)pro{
    if ([Login isLogin]) {
        return (pro.current_user_role_id.integerValue >= 90 ||
                [self curLoginUser].isAdministrator.boolValue);
    }
    return NO;
}

// Git Clone 需要用 http 的方式校验
+ (void)setPassword:(NSString *)password{
    if ([self curLoginUser].global_key) {
        [self p_setPassword:password forAccount:[self curLoginUser].global_key];
    }
}

+ (void)p_setPassword:(NSString *)password forAccount:(NSString *)account{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:password forKey:kLoginPasswordKey(account)];
    [defaults synchronize];
}

+ (NSString *)curPassword{
    if ([self isLogin]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        User *curU = [self curLoginUser];
        return ([defaults objectForKey:kLoginPasswordKey(curU.global_key)] ?:
                [defaults objectForKey:kLoginPasswordKey(curU.email)] ?:
                [defaults objectForKey:kLoginPasswordKey(curU.phone)]);
    }else{
        return nil;
    }
}

@end
