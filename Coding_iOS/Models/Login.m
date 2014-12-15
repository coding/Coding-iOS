//
//  Login.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Login.h"
#import "UMessage.h"
#import "XGPush.h"
#import "AppDelegate.h"

#define kLoginStatus @"login_status"
#define kLoginUserId @"user_id"
#define kLoginUserDict @"user_dict"

static User *curLoginUser;

@implementation Login
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.remember_me = [NSNumber numberWithBool:YES];
        self.email = @"";
        self.password = @"";
    }
    return self;
}

- (NSDictionary *)toParams{
    if (self.j_captcha && self.j_captcha.length > 0) {
        return @{@"email" : self.email,
                 @"password" : [self.password sha1Str],
                 @"remember_me" : self.remember_me? @"true" : @"false",
                 @"j_captcha" : self.j_captcha};
    }else{
        return @{@"email" : self.email,
                 @"password" : [self.password sha1Str],
                 @"remember_me" : self.remember_me? @"true" : @"false"};
    }
}

- (NSString *)goToLoginTipWithCaptcha:(BOOL)needCaptcha{
    if (!_email || _email.length <= 0) {
        return @"请填写电子邮箱或个性后缀";
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
        return YES;
    }else{
        return NO;
    }
}
+ (void)doLogin:(NSDictionary *)loginData{
    if (loginData) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:kLoginStatus];
        [defaults setObject:loginData forKey:kLoginUserDict];
        curLoginUser = [NSObject objectOfClass:@"User" fromJSON:loginData];
        [defaults synchronize];
        [Login addUmengAliasWithCurUser:YES];
        [Login setXGAccountWithCurUser];
    }else{
        [Login doLogout];
    }
}

+ (void)addUmengAliasWithCurUser:(BOOL)add{
    User *user = [Login curLoginUser];
    if (user && user.global_key.length > 0) {
        NSString *global_key = user.global_key;
//        if (add) {
//            [UMessage addAlias:global_key type:kUmeng_MessageAliasTypeCoding response:^(id responseObject, NSError *error) {
//                NSLog(@"addAlias--------responseObject:%@-------error:%@", responseObject, error.description);
//            }];
//        }else{
//            [UMessage removeAlias:global_key type:kUmeng_MessageAliasTypeCoding response:^(id responseObject, NSError *error) {
//                NSLog(@"removeAlias--------responseObject:%@-------error:%@", responseObject, error.description);
//            }];
//        }
        //移除友盟推送的Alias
        [UMessage removeAlias:global_key type:kUmeng_MessageAliasTypeCoding response:^(id responseObject, NSError *error) {
            NSLog(@"removeAlias--------responseObject:%@-------error:%@", responseObject, error.description);
        }];
    }
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
    [Login addUmengAliasWithCurUser:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:kLoginStatus];
    [defaults synchronize];
    [Login setXGAccountWithCurUser];
}
+ (User *)curLoginUser{
    if (!curLoginUser) {
        NSDictionary *loginData = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserDict];
        curLoginUser = loginData? [NSObject objectOfClass:@"User" fromJSON:loginData]: nil;
    }
    return curLoginUser;
}
+ (BOOL)isOwnerOfProjectWithOwnerId:(NSNumber *)owner_id{
    User *curLoginUser = [Login curLoginUser];
    if (curLoginUser) {
        return (curLoginUser.id.integerValue == owner_id.integerValue);
    }else{
        return NO;
    }
}
@end
