//
//  Coding_NetAPIManager.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Coding_NetAPIManager.h"
#import "JDStatusBarNotification.h"
#import "UnReadManager.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import <MMMarkdown/MMMarkdown.h>
#import "MBProgressHUD+Add.h"
#import "Register.h"
#import "ResourceReference.h"

@implementation Coding_NetAPIManager
+ (instancetype)sharedManager {
    static Coding_NetAPIManager *shared_manager = nil;
    static dispatch_once_t pred;
	dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
	return shared_manager;
}
#pragma mark UnRead
- (void)request_UnReadCountWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/unread-count" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Notification label:@"Tab首页的红点通知"];
            
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UnReadNotificationsWithBlock:(void (^)(id data, NSError *error))block{
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] init];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : @(0)} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
//            @我的
            [notificationDict setObject:[data valueForKeyPath:@"data"] forKey:kUnReadKey_notification_AT];
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : @[@(1), @(2)]} withMethodType:Get andBlock:^(id dataComment, NSError *errorComment) {
                if (dataComment) {
//                    评论
                    [notificationDict setObject:[dataComment valueForKeyPath:@"data"] forKey:kUnReadKey_notification_Comment];
                    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : @[@(4),@(6)]} withMethodType:Get andBlock:^(id dataSystem, NSError *errorSystem) {
                        if (dataSystem) {
//                            系统
                            [MobClick event:kUmeng_Event_Request_Notification label:@"消息页面的红点通知"];

                            [notificationDict setObject:[dataSystem valueForKeyPath:@"data"] forKey:kUnReadKey_notification_System];
                            block(notificationDict, nil);
                        }else{
                            block(nil, errorSystem);
                        }
                    }];
                }else{
                    block(nil, errorComment);
                }
            }];
        }else{
            block(nil, error);
        }
    }];
}
#pragma mark Login
- (void)request_Login_With2FA:(NSString *)otpCode andBlock:(void (^)(id data, NSError *error))block{
    if (otpCode.length <= 0) {
        return;
    }
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/check_two_factor_auth_code" withParams:@{@"code" : otpCode} withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"登录_2FA码"];

            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Login_WithPath:(NSString *)path Params:(id)params andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/unread-count" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data_check, NSError *error_check) {//检查当前账号未设置邮箱和GK
                if (error_check.userInfo[@"msg"][@"user_need_activate"]) {
                    block(nil, error_check);
                }else{
                    [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"登录_密码"];
                    
                    User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
                    if (curLoginUser) {
                        [Login doLogin:resultData];
                    }
                    block(curLoginUser, nil);
                }
            }];
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Register_WithParams:(id)params andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/register" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"注册"];

            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Register_V2_WithParams:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/v2/account/register";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"注册_V2"];
            
            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_CaptchaNeededWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path  withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"是否需要验证码"];

            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_SetPasswordToPath:(NSString *)path params:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"激活or重置密码"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_CheckPhoneCodeWithPhone:(NSString *)phone code:(NSString *)code type:(PurposeType)type block:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/account/register/check_phone_code";
    NSMutableDictionary *params = @{@"phone": phone,
                                    @"code": code}.mutableCopy;
    switch (type) {
        case PurposeToRegister:
            params[@"type"] = @"register";
            break;
        case PurposeToPasswordActivate:
            params[@"type"] = @"activate";
            break;
        case PurposeToPasswordReset:
            params[@"type"] = @"reset";
            break;
    }
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"校验手机验证码"];
        }
        block(data, error);
    }];
}

- (void)request_GeneratePhoneCodeWithPhone:(NSString *)phone type:(PurposeType)type block:(void (^)(id data, NSError *error))block{
    NSString *path;
    NSDictionary *params = @{@"phone": phone};
    switch (type) {
        case PurposeToRegister:
            path = @"api/account/register/generate_phone_code";
            break;
        case PurposeToPasswordActivate:
            path = @"api/account/activate/generate_phone_code";
            break;
        case PurposeToPasswordReset:
            path = @"api/account/reset_password/generate_phone_code";
            break;
    }
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"生成手机验证码"];
        }
        block(data, error);
    }];
}
- (void)request_SetPasswordWithPhone:(NSString *)phone code:(NSString *)code password:(NSString *)password captcha:(NSString *)captcha type:(PurposeType)type block:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/account/register/phone";
    NSMutableDictionary *params = @{@"phone": phone,
                                    @"code": code,
                                    @"password": [password sha1Str]}.mutableCopy;
    switch (type) {
        case PurposeToRegister:{
            path = @"api/account/register/phone";
            params[@"channel"] = [Register channel];
            break;
        }
        case PurposeToPasswordActivate:
            path = @"api/account/activate/phone/set_password";
            break;
        case PurposeToPasswordReset:
            path = @"api/phone/resetPassword";
            break;
    }
    if (captcha.length > 0) {
        params[@"j_captcha"] = captcha;
    }
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:type == PurposeToRegister? @"手机注册账号": @"设置or重置密码"];
            if (type == PurposeToRegister) {
                User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:data[@"data"]];
                if (curLoginUser) {
                    [Login doLogin:data[@"data"]];
                }
                block(curLoginUser, nil);
                return ;
            }
        }
        block(data, error);
    }];
}
- (void)request_SetPasswordWithEmail:(NSString *)email captcha:(NSString *)captcha type:(PurposeType)type block:(void (^)(id data, NSError *error))block{
    NSString *path;
    NSDictionary *params = @{@"email": email,
                             @"j_captcha": captcha};
    switch (type) {
        case PurposeToPasswordActivate:
            path = @"api/activate";
            break;
        case PurposeToPasswordReset:
            path = @"api/resetPassword";
            break;
        default:
            path = nil;
            break;
    }
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"发激活or重置密码邮件"];
        }
        block(data, nil);
    }];
}
- (void)request_ActivateByPhone:(NSString *)phone setEmail:(NSString *)email global_key:(NSString *)global_key block:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/account/activate/phone";
    NSDictionary *params = @{@"phone" : phone,
                             @"email": email,
                             @"global_key": global_key};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"激活账号_设置邮箱KEY"];
            
            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ActivateBySetGlobal_key:(NSString *)global_key block:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/account/global_key/acitvate";
    NSDictionary *params = @{@"global_key": global_key};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"激活账号_设置GK"];
            
            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_SendActivateEmail:(NSString *)email block:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/register/email/send" withParams:@{@"email": email} withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            if ([(NSNumber *)data[@"data"] boolValue]) {
                [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"激活账号_重发激活邮件"];
                
                block(data, nil);
            }else{
                [NSObject showHudTipStr:@"发送失败"];
                block(nil, nil);
            }
        }else{
            block(nil, error);
        }
    }];
}
#pragma mark Project
- (void)request_Projects_WithObj:(Projects *)projects andBlock:(void (^)(Projects *data, NSError *error))block{
    projects.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[projects toPath] withParams:[projects toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        projects.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_RootList label:@"项目列表"];

            id resultData = [data valueForKeyPath:@"data"];
            Projects *pros = [NSObject objectOfClass:@"Projects" fromJSON:resultData];
            block(pros, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ProjectsCatergoryAndCounts_WithObj:(ProjectCount *)pCount andBlock:(void (^)(ProjectCount *data, NSError *error))block
{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/project_count" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_RootList label:@"筛选列表"];
            
            id resultData = [data valueForKeyPath:@"data"];
           ProjectCount *prosC = [NSObject objectOfClass:@"ProjectCount" fromJSON:resultData];
            block(prosC, nil);
        }else{
            block(nil, error);
        }
    }];

}

- (void)request_ProjectsHaveTasks_WithObj:(Projects *)projects andBlock:(void (^)(id data, NSError *error))block{
    projects.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/projects" withParams:[projects toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Projects *pros = [NSObject objectOfClass:@"Projects" fromJSON:resultData];
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tasks/projects/count" withParams:nil withMethodType:Get andBlock:^(id datatasks, NSError *errortasks) {
                projects.isLoading = NO;
                if (datatasks) {
                    [MobClick event:kUmeng_Event_Request_RootList label:@"有任务的项目列表"];

                    NSMutableArray *list = [[NSMutableArray alloc] init];
                    NSArray *taskProArray = [datatasks objectForKey:@"data"];
                    for (NSDictionary *dict in taskProArray) {
                        for (Project *curPro in pros.list) {
                            if (curPro.id.intValue == ((NSNumber *)[dict objectForKey:@"project"]).intValue) {
                                curPro.done = [dict objectForKey:@"done"];
                                curPro.processing = [dict objectForKey:@"processing"];
                                [list addObject:curPro];
                            }
                        }
                    }
                    pros.list = list;
                    block(pros, nil);
                }else{
                    block(nil, error);
                }
            }];
        }else{
            projects.isLoading = NO;
            block(nil, error);
        }
    }];
}
- (void)request_Project_UpdateVisit_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toUpdateVisitPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Notification label:@"更新项目为已读"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectDetail_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    project.isLoadingDetail = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        project.isLoadingDetail = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"获取项目详情"];

            id resultData = [data valueForKeyPath:@"data"];
            Project *resultA = [NSObject objectOfClass:@"Project" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectActivityList_WithObj:(ProjectActivities *)proActs andBlock:(void (^)(NSArray *data, NSError *error))block{
    proActs.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proActs toPath] withParams:[proActs toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        proActs.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:[NSString stringWithFormat:@"项目动态_%@", proActs.type]];

            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectActivity"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectMember_Quit:(ProjectMember *)curMember andBlock:(void (^)(id data, NSError *error))block{
    if (curMember.user_id.intValue == [Login curLoginUser].id.intValue) {
        [NSObject showStatusBarQueryStr:@"正在退出项目"];
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMember toQuitPath] withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"退出项目"];

                [NSObject showStatusBarSuccessStr:@"退出项目成功"];
                block(curMember, nil);
            }else{
                [NSObject showStatusBarError:error];
                block(nil, error);
            }
        }];
    }else{
        [NSObject showStatusBarQueryStr:@"正在移除成员"];
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMember toKickoutPath] withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"移除成员"];

                [NSObject showStatusBarSuccessStr:@"移除成员成功"];
                block(curMember, nil);
            }else{
                [NSObject showStatusBarError:error];
                block(nil, error);
            }
        }];
    }
}
- (void)request_Project_Pin:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/projects/pin"];
    NSDictionary *params = @{@"ids": project.id.stringValue};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:project.pin.boolValue? Delete: Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"设置常用项目"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

-(void)request_NewProject_WithObj:(Project *)project image:(UIImage *)image andBlock:(void (^)(NSString *, NSError *))block{
    [NSObject showStatusBarQueryStr:@"正在创建项目"];
    NSDictionary *fileDic;
    if (image) {
        fileDic = @{@"image":image,@"name":@"icon",@"fileName":@"icon.jpg"};
    }
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toProjectPath] file:fileDic withParams:[project toCreateParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"创建项目"];

            [NSObject showStatusBarSuccessStr:@"创建项目成功"];
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}

-(void)request_UpdateProject_WithObj:(Project *)project andBlock:(void (^)(Project *, NSError *))block{
    [NSObject showStatusBarQueryStr:@"正在更新项目"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toUpdatePath] withParams:[project toUpdateParams] withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"设置项目"];

            [NSObject showStatusBarSuccessStr:@"更新项目成功"];
            id resultData = [data valueForKeyPath:@"data"];
            Project *resultA = [NSObject objectOfClass:@"Project" fromJSON:resultData];
            block(resultA, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}

-(void)request_UpdateProject_WithObj:(Project *)project icon:(UIImage *)icon andBlock:(void (^)(id, NSError *))block progerssBlock:(void (^)(CGFloat))progress{
    [[CodingNetAPIClient sharedJsonClient] uploadImage:icon path:[project toUpdateIconPath] name:@"file" successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"更改项目图标"];

            block(responseObject, nil);
            [NSObject showStatusBarSuccessStr:@"更新项目图标成功"];
        }
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
        [NSObject showStatusBarError:error];
    } progerssBlock:progress];
}

- (void)request_DeleteProject_WithObj:(Project *)project passCode:(NSString *)passCode type:(VerifyType)type andBlock:(void (^)(Project *data, NSError *error))block{
    if (!project.name || !passCode) {
        return;
    }
    NSDictionary *params;
    if (type == VerifyTypePassword) {
        params = @{
                   @"name": project.name,
                   @"two_factor_code": [passCode sha1Str]
                   };
    }else if (type == VerifyTypeTotp){
        params = @{
                   @"name": project.name,
                   @"two_factor_code": passCode
                   };
    }else{
        return;
    }
    [NSObject showStatusBarQueryStr:@"正在删除项目"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toDeletePath] withParams:params withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"删除项目"];

            [NSObject showStatusBarSuccessStr:@"删除项目成功"];
            block(data, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)request_TransferProject:(Project *)project toUser:(User *)user passCode:(NSString *)passCode type:(VerifyType)type andBlock:(void (^)(Project *data, NSError *error))block{
    if (project.id.stringValue.length <= 0 || user.global_key.length <= 0|| passCode.length <= 0) {
        return;
    }
    NSString *path = [NSString stringWithFormat:@"api/project/%@/transfer_to/%@", project.id.stringValue, user.global_key];
    NSDictionary *params;
    if (type == VerifyTypePassword) {
        params = @{@"two_factor_code": [passCode sha1Str]};
    }else if (type == VerifyTypeTotp){
        params = @{@"two_factor_code": passCode};
    }else{
        return;
    }
    [NSObject showStatusBarQueryStr:@"正在转让项目"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"转让项目"];
            
            [NSObject showStatusBarSuccessStr:@"转让项目成功"];
            block(data, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)request_ProjectTaskList_WithObj:(Tasks *)tasks andBlock:(void (^)(Tasks *data, NSError *error))block{
    tasks.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tasks toRequestPath] withParams:[tasks toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tasks.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_RootList label:@"任务_列表"];

            id resultData = [data valueForKeyPath:@"data"];
            Tasks *resultTasks = [NSObject objectOfClass:@"Tasks" fromJSON:resultData];
            block(resultTasks, nil);
        }else{
            block(nil, error);
        }

    }];
}
- (void)request_ProjectMembers_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    project.isLoadingMember = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toMembersPath] withParams:[project toMembersParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        project.isLoadingMember = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"项目成员"];

            id resultData = [data valueForKeyPath:@"data"];
            if (resultData) {//存储到本地
                [NSObject saveResponseData:resultData toPath:[project localMembersPath]];
            }
            resultData = [resultData objectForKey:@"list"];

            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectMember"];
            [resultA sortUsingComparator:^NSComparisonResult(ProjectMember *obj1, ProjectMember *obj2) {
                if ([obj1.user_id isEqualToNumber:[Login curLoginUser].id]) {
                    return NSOrderedAscending;
                }else if ([obj2.user_id isEqualToNumber:[Login curLoginUser].id]){
                    return NSOrderedDescending;
                }else{
                    return obj1.type.intValue < obj2.type.intValue;
                }
            }];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectMembersHaveTasks_WithObj:(Project *)project andBlock:(void (^)(NSArray *data, NSError *error))block{
    project.isLoadingMember = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toMembersPath] withParams:[project toMembersParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            resultData = [resultData objectForKey:@"list"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectMember"];
            
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/project/%d/task/user/count", project.id.intValue] withParams:nil withMethodType:Get andBlock:^(id datatasks, NSError *errortasks) {
                project.isLoadingMember = NO;
                if (datatasks) {
                    [MobClick event:kUmeng_Event_Request_Get label:@"有任务的项目成员"];

                    NSMutableArray *list = [[NSMutableArray alloc] init];
                    
                    NSArray *taskMembersArray = [datatasks objectForKey:@"data"];
                    for (ProjectMember *curMember in resultA) {
                        BOOL hasTask = NO;
                        for (NSDictionary *dict in taskMembersArray) {
                            if (curMember.user_id.intValue == ((NSNumber *)[dict objectForKey:@"user"]).intValue) {
                                curMember.done = [dict objectForKey:@"done"];
                                curMember.processing = [dict objectForKey:@"processing"];
                                hasTask = YES;
                                break;
                            }
                        }
                        if (hasTask) {
                            if (curMember.user_id.integerValue == [Login curLoginUser].id.integerValue) {
                                [list insertObject:curMember atIndex:0];
                            }else{
                                [list addObject:curMember];
                            }
                        }else if (curMember.user_id.integerValue == [Login curLoginUser].id.integerValue){
                            [list insertObject:curMember atIndex:0];
                        }
                    }
                    block(list, nil);
                }else{
                    block(nil, errortasks);
                }
            }];
        }else{
            project.isLoadingMember = NO;
            block(nil, error);
        }
    }];
}
- (void)request_EditAliasOfMember:(ProjectMember *)curMember inProject:(Project *)curPro andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/project/%@/members/update_alias/%@", curPro.id, curMember.user_id];
    NSDictionary *params = @{@"alias": curMember.editAlias};
    [NSObject showStatusBarQueryStr:@"正在设置备注"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"项目成员_设置备注名"];
            
            [NSObject showStatusBarSuccessStr:@"备注设置成功"];
        }else{
            [NSObject showStatusBarError:error];
        }
        block(data, error);
    }];
}
- (void)request_EditTypeOfMember:(ProjectMember *)curMember inProject:(Project *)curPro andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/project/%@/member/%@/%@", curPro.id, curMember.user.global_key, curMember.editType];
    [NSObject showStatusBarQueryStr:@"正在设置成员类型"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"项目成员_设置成员类型"];
            
            [NSObject showStatusBarSuccessStr:@"成员类型设置成功"];
        }else{
            [NSObject showStatusBarError:error];
        }
        block(data, error);
    }];
}
#pragma mark MRPR
- (void)request_MRPRS_WithObj:(MRPRS *)curMRPRS andBlock:(void (^)(MRPRS *data, NSError *error))block{
    curMRPRS.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMRPRS toPath] withParams:[curMRPRS toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        curMRPRS.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"MRPR_列表"];

            id resultData = [data valueForKeyPath:@"data"];
            MRPRS *resultA = [NSObject objectOfClass:@"MRPRS" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];

}

- (void)request_MRPRBaseInfo_WithObj:(MRPR *)curMRPR andBlock:(void (^)(MRPRBaseInfo *data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMRPR toBasePath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"MRPR_详情页面"];

            id resultData = [data valueForKeyPath:@"data"];
            MRPRBaseInfo *resultA = [NSObject objectOfClass:@"MRPRBaseInfo" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_MRPRCommits_WithObj:(MRPR *)curMRPR andBlock:(void (^)(NSArray *data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMRPR toCommitsPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"MRPR_提交记录列表"];

            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Commit"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_MRPRFileChanges_WithObj:(MRPR *)curMRPR andBlock:(void (^)(FileChanges *data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMRPR toFileChangesPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"MRPR_文件改动列表"];

            id resultData = [data valueForKeyPath:@"data"];
            FileChanges *resultA = [NSObject objectOfClass:@"FileChanges" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_MRPRAccept:(MRPR *)curMRPR andBlock:(void (^)(id data, NSError *error))block{
    [NSObject showStatusBarQueryStr:@"正在合并请求"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMRPR toAcceptPath] withParams:[curMRPR toAcceptParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"MRPR_合并"];

            [NSObject showStatusBarSuccessStr:@"合并请求成功"];
            block(data, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}
- (void)request_MRPRRefuse:(MRPR *)curMRPR andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMRPR toRefusePath] withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"MRPR_拒绝"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_MRPRCancel:(MRPR *)curMRPR andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMRPR toCancelPath] withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"MRPR_取消"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_CommitInfo_WithUserGK:(NSString *)userGK projectName:(NSString *)projectName commitId:(NSString *)commitId andBlock:(void (^)(CommitInfo *data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/commit/%@", userGK, projectName, commitId];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"某次提交记录的详情"];

            id resultData = [data valueForKeyPath:@"data"];
            CommitInfo *resultA = [NSObject objectOfClass:@"CommitInfo" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_PostCommentWithPath:(NSString *)path params:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"LineNote_评论_添加"];

            NSString *noteable_type = [params objectForKey:@"noteable_type"];
            if ([noteable_type isEqualToString:@"MergeRequestBean"] ||
                [noteable_type isEqualToString:@"PullRequestBean"] ||
                [noteable_type isEqualToString:@"Commit"]) {
                id resultData = [data valueForKeyPath:@"data"];
                ProjectLineNote *note = [NSObject objectOfClass:@"ProjectLineNote" fromJSON:resultData];
                block(note, nil);
            }else{
                block(data, nil);
            }
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_DeleteLineNote:(NSNumber *)lineNoteId inProject:(NSString *)projectName ofUser:(NSString *)userGK andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/line_notes/%@", userGK, projectName, lineNoteId.stringValue];
    [self request_DeleteLineNoteWithPath:path andBlock:block];
}

- (void)request_DeleteLineNoteWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"LineNote_评论_删除"];
            
            block(data, nil);
            
        }else{
            block(nil, error);
        }
    }];
}
#pragma mark File
- (void)request_Folders:(ProjectFolders *)folders inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    folders.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folders toFoldersPathWithObj:project.id] withParams:[folders toFoldersParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            ProjectFolders *proFolders = [NSObject objectOfClass:@"ProjectFolders" fromJSON:resultData];
            ProjectFolder *defaultFolder = [ProjectFolder defaultFolder];
            [proFolders.list insertObject:defaultFolder atIndex:0];
            for (ProjectFolder *folder in proFolders.list) {
                folder.project_id = project.id;
                for (ProjectFolder *sub_folder in folder.sub_folders) {
                    sub_folder.project_id = project.id;
                }
            }
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folders toFoldersCountPathWithObj:project.id] withParams:nil withMethodType:Get andBlock:^(id countData, NSError *countError) {
                if (countData) {
                    [MobClick event:kUmeng_Event_Request_Get label:@"文件夹列表"];
                   
                    //每个文件夹内的文件数量
                    NSArray *countArray = [countData valueForKey:@"data"];
                    NSMutableDictionary *countDict = [[NSMutableDictionary alloc] initWithCapacity:countArray.count];
                    for (NSDictionary *item in countArray) {
                        [countDict setObject:[item objectForKey:@"count"] forKey:[item objectForKey:@"folder"]];
                    }
                    for (ProjectFolder *folder in proFolders.list) {
                        folder.count = [countDict objectForKey:folder.file_id];
                        for (ProjectFolder *sub_folder in folder.sub_folders) {
                            sub_folder.count = [countDict objectForKey:sub_folder.file_id];
                        }
                    }
                    for (ProjectFolder *folder in folders.list) {//原来文件夹的文件数也更新一下
                        folder.count = [countDict objectForKey:folder.file_id];
                        for (ProjectFolder *sub_folder in folder.sub_folders) {
                            sub_folder.count = [countDict objectForKey:sub_folder.file_id];
                        }
                    }
                    folders.isLoading = NO;
                    block(proFolders, nil);
                }else{
                    folders.isLoading = NO;
                    block(nil, countError);
                }
            }];
            
        }else{
            folders.isLoading = NO;
            block(nil, error);
        }
    }];
}
- (void)request_FilesInFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folder toFilesPath] withParams:[folder toFilesParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"文件列表"];

            id resultData = [data valueForKeyPath:@"data"];
            ProjectFiles *files = [NSObject objectOfClass:@"ProjectFiles" fromJSON:resultData];
            for (ProjectFile *file in files.list) {
                file.project_id = folder.project_id;
            }
            block(files, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DeleteFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folder toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"文件夹_删除"];

            block(folder, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_RenameFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folder toRenamePath] withParams:nil withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"文件夹_重命名"];

            block(folder, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DeleteFiles:(NSArray *)fileIdList inProject:(NSNumber *)project_id andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/project/%@/file/delete", project_id.stringValue];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:@{@"fileIds" : fileIdList} withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"文件_删除"];

            block(fileIdList, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_MoveFiles:(NSArray *)fileIdList toFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folder toMoveToPath] withParams:@{@"fileId": fileIdList} withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"文件_移动"];

            block(fileIdList, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_CreatFolder:(NSString *)fileName inFolder:(ProjectFolder *)parentFolder inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/project/%@/mkdir", project.id.stringValue];
    NSDictionary *params = @{@"name" : fileName,
                             @"parentId" : (parentFolder && parentFolder.file_id)? parentFolder.file_id.stringValue : @"0" };
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"文件夹_新建"];

            id resultData = [data valueForKeyPath:@"data"];
            ProjectFolder *createdFolder = [NSObject objectOfClass:@"ProjectFolder" fromJSON:resultData];
            createdFolder.project_id = project.id;
            block(createdFolder, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_FileDetail:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[file toDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"文件详情"];

            id resultData = [data valueForKeyPath:@"data"];
            resultData = [resultData valueForKeyPath:@"file"];
            ProjectFile *detailFile = [NSObject objectOfClass:@"ProjectFile" fromJSON:resultData];
            if (file.project_id) {
                detailFile.project_id = file.project_id;
            }
            block(detailFile, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_FileContent:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[file toDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"文件_获取内容"];
            
            id resultData = [data valueForKeyPath:@"data"];
            resultData = [resultData valueForKeyPath:@"content"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_EditFile:(ProjectFile *)file withContent:(NSString *)contentStr andBlock:(void (^)(id data, NSError *error))block{
    if (!contentStr || !file.name) {
        return;
    }
    NSString *path = [NSString stringWithFormat:@"api/project/%@/files/%@/edit", file.project_id, file.file_id];
    NSDictionary *params = @{@"name" : file.name,
                             @"content" : contentStr};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"文件_编辑内容"];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_RenameFile:(ProjectFile *)file withName:(NSString *)nameStr andBlock:(void (^)(id data, NSError *error))block{
    if (!nameStr) {
        return;
    }
    NSString *path = [NSString stringWithFormat:@"api/project/%@/files/%@/rename", file.project_id, file.file_id];
    NSDictionary *params = @{@"name" : nameStr};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"文件_重命名"];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ActivityListOfFile:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[file toActivityListPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"文件动态列表"];

            id resultData = [data valueForKeyPath:@"data"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectActivity"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_VersionListOfFile:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[file toHistoryListPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"文件版本列表"];

            id resultData = [data valueForKeyPath:@"data"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"FileVersion"];
            [resultA setValue:file.project_id forKey:@"project_id"];
            [resultA setValue:file.fileType forKey:@"fileType"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_DeleteComment:(NSNumber *)comment_id inFile:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/project/%@/files/%@/comment/%@", file.project_id.stringValue, file.file_id.stringValue, comment_id.stringValue];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"文件_评论_删除"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_RemarkFileVersion:(FileVersion *)curVersion withStr:(NSString *)remarkStr andBlock:(void (^)(id data, NSError *error))block{
    if (!remarkStr) {
        return;
    }
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curVersion toRemarkPath] withParams:@{@"remark" : remarkStr} withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"历史文件_修改备注"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_DeleteFileVersion:(FileVersion *)curVersion andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curVersion toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"历史文件_删除"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_OpenShareOfFile:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/share/create";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:[file toShareParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"文件_开启共享"];
            
            NSString *share_url = [[data valueForKey:@"data"] valueForKey:@"url"];
            block(share_url, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_CloseShareHash:(NSString *)hashStr andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/share/%@", hashStr];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"文件_关闭共享"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark Code
- (void)request_CodeTree:(CodeTree *)codeTree withPro:(Project *)project codeTreeBlock:(void (^)(id codeTreeData, NSError *codeTreeError))block{
    NSString *refAndPath = [NSString handelRef:codeTree.ref path:codeTree.path];
    NSString *treePath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/tree/%@", project.owner_user_name, project.name, refAndPath];
    NSString *treeinfoPath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/treeinfo/%@", project.owner_user_name, project.name, refAndPath];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:treePath withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            CodeTree *rCodeTree = [NSObject objectOfClass:@"CodeTree" fromJSON:resultData];
            
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:treeinfoPath withParams:nil withMethodType:Get andBlock:^(id infoData, NSError *infoError) {
                if (infoData) {
                    [MobClick event:kUmeng_Event_Request_Get label:@"代码目录"];

                    infoData = [infoData valueForKey:@"data"];
                    infoData = [infoData valueForKey:@"infos"];
                    NSMutableArray *infoArray = [NSObject arrayFromJSON:infoData ofObjects:@"CodeTree_CommitInfo"];
                    [rCodeTree configWithCommitInfos:infoArray];
                    
                    block(rCodeTree, nil);
                }else{
                    block(nil, infoError);
                }
            }];
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_CodeFile:(CodeFile *)codeFile withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *filePath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/blob/%@", project.owner_user_name, project.name, [NSString handelRef:codeFile.ref path:codeFile.path]];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:filePath withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"代码文件内容"];

            id resultData = [data valueForKey:@"data"];
            CodeFile *rCodeFile = [NSObject objectOfClass:@"CodeFile" fromJSON:resultData];
            rCodeFile.path = codeFile.path;
            block(rCodeFile, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_EditCodeFile:(CodeFile *)codeFile withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *filePath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/edit/%@", project.owner_user_name, project.name, [NSString handelRef:codeFile.ref path:codeFile.path]];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:filePath withParams:[codeFile toEditParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"代码文件_修改"];
            
            block(data, nil);//{"code":0}
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_CodeBranchOrTagWithPath:(NSString *)path withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toBranchOrTagPath:path] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"(分支_标签)_列表"];

            id resultData = [data valueForKey:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"CodeBranchOrTag"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Commits:(Commits *)curCommits withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/commits/%@", project.owner_user_name, project.name, [NSString handelRef:curCommits.ref path:curCommits.path]];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:[curCommits toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"提交记录_列表"];

            id resultData = [data valueForKey:@"data"];
            resultData = [resultData valueForKey:@"commits"];
            Commits *resultA = [NSObject objectOfClass:@"Commits" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark Task
- (void)request_AddTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [NSObject showStatusBarQueryStr:@"正在添加任务"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toAddTaskPath] withParams:[task toAddTaskParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"任务_添加"];

            id resultData = [data valueForKeyPath:@"data"];
            Task *resultT = [NSObject objectOfClass:@"Task" fromJSON:resultData];
            [NSObject showStatusBarSuccessStr:@"添加任务成功"];
            block(resultT, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}
- (void)request_DeleteTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [NSObject showStatusBarQueryStr:@"正在删除任务"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toDeleteTaskPath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"任务_删除"];

            [NSObject showStatusBarSuccessStr:@"删除任务成功"];
            block(task, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}
- (void)request_EditTask:(Task *)task oldTask:(Task *)oldTask andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toUpdatePath] withParams:[task toUpdateParamsWithOld:oldTask] withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"任务_修改"];

            block(task, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_EditTask:(Task *)task withDescriptionStr:(NSString *)descriptionStr andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toUpdateDescriptionPath] withParams:@{@"description" : descriptionStr} withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"任务_修改描述"];

            data = [data valueForKey:@"data"];
            Task_Description *taskD = [NSObject objectOfClass:@"Task_Description" fromJSON:data];
            block(taskD, nil);
        }else{
            block(nil, error);
        }
    }];
    
}

- (void)request_EditTask:(Task *)task withTags:(NSMutableArray *)selectedTags andBlock:(void (^)(id data, NSError *error))block{
    NSDictionary *params = @{@"label_id" : [selectedTags valueForKey:@"id"]};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toEditLabelsPath] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"任务_修改标签"];

            block(data, nil);
        }else{
            block(nil,error);
        }
    }];
}

- (void)request_ChangeTaskStatus:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toEditTaskStatusPath] withParams:[task toChangeStatusParams] withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"任务_完成or开启"];

            task.status = [NSNumber numberWithInteger:(task.status.integerValue != 1? 1 : 2)];
            block(task, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_TaskDetail:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toTaskDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {//请求任务基本内容
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Task *resultA = [NSObject objectOfClass:@"Task" fromJSON:resultData];
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[resultA toWatchersPath] withParams:@{@"pageSize": @1000} withMethodType:Get andBlock:^(id dataW, NSError *errorW) {//请求任务关注者
                if (dataW) {
                    dataW = dataW[@"data"][@"list"];
                    NSArray *watchers = [NSObject arrayFromJSON:dataW ofObjects:@"User"];
                    resultA.watchers = watchers.mutableCopy;
                    
                    if (resultA.has_description.boolValue) {
                        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[resultA toDescriptionPath] withParams:nil withMethodType:Get andBlock:^(id dataD, NSError *errorD) {//请求任务描述
                            if (dataD) {
                                [MobClick event:kUmeng_Event_Request_Get label:@"任务_详情_有描述"];

                                dataD = [dataD valueForKey:@"data"];
                                Task_Description *taskD = [NSObject objectOfClass:@"Task_Description" fromJSON:dataD];
                                resultA.task_description = taskD;
                                block(resultA, nil);
                            }else{
                                block(nil, errorD);
                            }
                        }];
                    }else{
                        [MobClick event:kUmeng_Event_Request_Get label:@"任务_详情_无描述"];
                        
                        block(resultA, nil);
                    }
                }else{
                    block(nil, errorW);
                }
            }];
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_TaskResourceReference:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toResourceReferencePath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"任务_关联资源"];

            ResourceReference *rr = [NSObject objectOfClass:@"ResourceReference" fromJSON:data[@"data"]];
            block(rr, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_DeleteResourceReference:(NSNumber *)iid ofTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toResourceReferencePath] withParams:@{@"iid": iid} withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"任务_关联资源_删除"];
        }
        block(data, error);
    }];
}
- (void)request_ActivityListOfTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toActivityListPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"任务_动态列表"];

            id resultData = [data valueForKeyPath:@"data"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectActivity"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DoCommentToTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toDoCommentPath] withParams:[task toDoCommentParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"任务_评论_添加"];

            id resultData = [data valueForKeyPath:@"data"];
            TaskComment *resultA = [NSObject objectOfClass:@"TaskComment" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DeleteComment:(TaskComment *)comment ofTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/task/%ld/comment/%ld", (long)task.id.integerValue, (long)comment.id.integerValue] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"任务_评论_删除"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ChangeWatcher:(User *)watcher ofTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/task/%@/user/%@/watch", task.id.stringValue, watcher.global_key];
    User *hasWatcher = [task hasWatcher:watcher];
    NetworkMethod method = hasWatcher? Delete: Post;

    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:method andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:method == Post? @"任务_添加关注者": @"任务_删除关注者"];
            
            if (!hasWatcher && watcher) {
                [task.watchers addObject:watcher];
            }else if (hasWatcher){
                [task.watchers removeObject:hasWatcher];
            }
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark User
- (void)request_AddUser:(User *)user ToProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
//    一次添加多个成员(逗号分隔)：users=102,4 (以后只支持 gk，不支持 id 了)
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/project/%ld/members/gk/add", project.id.longValue] withParams:@{@"users" : user.global_key} withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"项目_添加成员"];

            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark Topic
- (void)request_ProjectTopicList_WithObj:(ProjectTopics *)proTopics andBlock:(void (^)(id data, NSError *error))block{
    proTopics.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopics toRequestPath] withParams:[proTopics toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        proTopics.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"讨论列表"];

            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopics *resultT = [NSObject objectOfClass:@"ProjectTopics" fromJSON:resultData];
            block(resultT, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectTopic_WithObj:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block{
    proTopic.isTopicLoading = YES;
    //html详情
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toTopicPath] withParams:@{@"type": [NSNumber numberWithInteger:0]} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            //markdown详情
            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopic *resultT = [NSObject objectOfClass:@"ProjectTopic" fromJSON:resultData];
            resultT.mdLabels = [resultT.labels mutableCopy];
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toTopicPath] withParams:@{@"type": [NSNumber numberWithInteger:1]} withMethodType:Get andBlock:^(id dataMD, NSError *errorMD) {
                proTopic.isTopicLoading = NO;
                if (dataMD) {
                    [MobClick event:kUmeng_Event_Request_Get label:@"讨论详情"];

                    resultT.mdTitle = [[dataMD valueForKey:@"data"] valueForKey:@"title"];
                    resultT.mdContent = [[dataMD valueForKey:@"data"] valueForKey:@"content"];
                    block(resultT, nil);
                }else{
                    block(nil, errorMD);
                }
            }];
        } else {
            proTopic.isTopicLoading = NO;
            block(nil, error);
        }
    }];
}
- (void)request_ModifyProjectTpoicLabel:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block
{
    proTopic.isTopicEditLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toLabelPath]
                                                        withParams:[proTopic toLabelParams]
                                                    withMethodType:Post
                                                          andBlock:^(id data, NSError *error) {
        proTopic.isTopicEditLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"讨论_标签_修改"];
            
            block(data, nil);
        } else {
            block(nil, error);
        }
    }];
}
- (void)request_ModifyProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block
{
    proTopic.isTopicEditLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toTopicPath] withParams:[proTopic toEditParams] withMethodType:Put andBlock:^(id data, NSError *error) {
        proTopic.isTopicEditLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"讨论_编辑"];

            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopic *resultT = [NSObject objectOfClass:@"ProjectTopic" fromJSON:resultData];
            block(resultT, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_AddProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block{
    NSInteger feedbackId = 38894;
    [NSObject showStatusBarQueryStr:(proTopic.project_id && proTopic.project_id.integerValue == feedbackId)? @"正在发送反馈信息": @"正在添加讨论"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toAddTopicPath] withParams:[proTopic toAddTopicParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:(proTopic.project_id && proTopic.project_id.integerValue == feedbackId)? @"发送反馈" : @"讨论_添加"];

            [NSObject showStatusBarSuccessStr:(proTopic.project_id && proTopic.project_id.integerValue == feedbackId)? @"反馈成功": @"添加讨论成功"];
            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopic *resultT = [NSObject objectOfClass:@"ProjectTopic" fromJSON:resultData];
            block(resultT, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)request_Comments_WithProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block{
    proTopic.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toCommentsPath] withParams:[proTopic toCommentsParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        proTopic.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"讨论_评论列表"];

            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopics *resultT = [NSObject objectOfClass:@"ProjectTopics" fromJSON:resultData];
            block(resultT, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DoComment_WithProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toDoCommentPath] withParams:[proTopic toDoCommentParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"讨论_评论_添加"];

            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopic *resultT = [NSObject objectOfClass:@"ProjectTopic" fromJSON:resultData];
            block(resultT, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ProjectTopic_Delete_WithObj:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"讨论_删除"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ProjectTopic_Count_WithPath:(NSString *)path
                                   andBlock:(void (^)(id data, NSError *error))block
{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:nil
                                                    withMethodType:Get
                                                          andBlock:^(id data, NSError *error) {
                                                              if (data) {
                                                                  [MobClick event:kUmeng_Event_Request_Get label:@"讨论_数量"];

                                                                  id resultData = [data valueForKeyPath:@"data"];
                                                                  block(resultData, nil);
                                                              } else {
                                                                  block(nil, error);
                                                              }
                                                          }];
}
- (void)request_ProjectTopic_LabelMy_WithPath:(NSString *)path
                                     andBlock:(void (^)(id data, NSError *error))block
{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:nil
                                                    withMethodType:Get
                                                          andBlock:^(id data, NSError *error) {
                                                              if (data) {
                                                                  [MobClick event:kUmeng_Event_Request_Get label:@"讨论_标签列表_与我相关"];

                                                                  id resultData = [data valueForKeyPath:@"data"];
                                                                  NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectTag"];
                                                                  block(resultA, nil);
                                                              } else {
                                                                  block(nil, error);
                                                              }
                                                          }];
}

#pragma mark - Project Tag
- (void)request_TagListInProject:(Project *)project type:(ProjectTagType)type andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = nil;
    switch (type) {
        case ProjectTagTypeTopic:
            path = [NSString stringWithFormat:@"api/project/%@/topic/label?withCount=true", project.id.stringValue];
            break;
            case ProjectTagTypeTask:
            path = [NSString stringWithFormat:@"api/user/%@/project/%@/task/label?withCount=true", project.owner_user_name, project.name];
            break;
        default:
            return;
            break;
    }
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"标签列表"];

            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectTag"];
            block(resultA, nil);
        } else {
            block(nil, error);
        }
    }];

}
- (void)request_AddTag:(ProjectTag *)tag toProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/topics/label", project.owner_user_name, project.name];
    NSDictionary *params = @{@"name" : tag.name,
                             @"color" : tag.color};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"标签_添加"];

            block(data[@"data"], nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DeleteTag:(ProjectTag *)tag inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/topics/label/%@", project.owner_user_name, project.name, tag.id.stringValue];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"标签_删除"];

            block(data, nil);
        } else {
            block(nil, error);
        }
    }];
}
- (void)request_ModifyTag:(ProjectTag *)tag inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/topics/label/%@", project.owner_user_name, project.name, tag.id.stringValue];
    NSDictionary *params = @{@"name" : tag.name,
                             @"color" : tag.color};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"标签_修改"];

            block(data, nil);
        } else {
            block(nil, error);
        }
    }];

}

#pragma mark Tweet
- (void)request_Tweets_WithObj:(Tweets *)tweets andBlock:(void (^)(id data, NSError *error))block{
    tweets.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweets toPath] withParams:[tweets toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweets.isLoading = NO;
        
        if (data) {
            [MobClick event:kUmeng_Event_Request_RootList label:@"冒泡_列表"];

            [NSObject saveResponseData:data toPath:[tweets localResponsePath]];
            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Tweet"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_DoLike_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDoLikePath] withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_点赞"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Tweet_DoComment_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDoCommentPath] withParams:[tweet toDoCommentParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_评论_添加"];

            id resultData = [data valueForKeyPath:@"data"];
            Comment *comment = [NSObject objectOfClass:@"Comment" fromJSON:resultData];
            block(comment, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_DoTweet_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    //发送冒泡内容 block
    void (^sendTweetBlock)() = ^{
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tweet" withParams:[tweet toDoTweetParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                [MobClick event:kUmeng_Event_Request_ActionOfServer label:tweet.tweetImages.count > 0? @"冒泡_添加_有图": @"冒泡_添加_无图"];
                
                id resultData = [data valueForKeyPath:@"data"];
                Tweet *result = [NSObject objectOfClass:@"Tweet" fromJSON:resultData];
                [NSObject showStatusBarSuccessStr:@"冒泡发送成功"];
                block(result, nil);
            }else{
                [NSObject showStatusBarError:error];
                block(nil, error);
            }
        }];
    };
    //开始发送
    [NSObject showStatusBarQueryStr:@"正在发送冒泡"];
    //无图片的冒泡，直接发送
    if (tweet.tweetImages.count <= 0) {
        sendTweetBlock();
        return;
    }
    //判断图片是否全部上传完毕，是的话就发送该冒泡 block
    BOOL (^whetherAllImagesUploadedAndSendTweetBlock)() = ^{
        if (tweet.isAllImagesDoneSucess) {
            sendTweetBlock();
        }
        return tweet.isAllImagesDoneSucess;
    };
    //图片均已上传，直接发送
    if (whetherAllImagesUploadedAndSendTweetBlock()) {
        return;
    }
    //遍历上传图片
    for (TweetImage *imageItem in tweet.tweetImages) {
        if (imageItem.imageStr.length > 0) {
            whetherAllImagesUploadedAndSendTweetBlock();
        }else{
            if (imageItem.uploadState != TweetImageUploadStateIng) {
                imageItem.uploadState = TweetImageUploadStateIng;
                [self uploadTweetImage:imageItem.image doneBlock:^(NSString *imagePath, NSError *error) {
                    imageItem.uploadState = imagePath? TweetImageUploadStateSuccess: TweetImageUploadStateFail;
                    if (!imagePath) {
                        [NSObject showStatusBarError:error];
                        block(nil, error);
                    }else{
                        imageItem.imageStr = [NSString stringWithFormat:@"![](%@)", imagePath];
                        whetherAllImagesUploadedAndSendTweetBlock();
                    }
                } progerssBlock:^(CGFloat progressValue) {
                    DebugLog(@"progressValue %@ : %.2f", imageItem.assetURL.query, progressValue);
                }];
            }
        }
    }
}

- (void)request_Tweet_Likers_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    tweet.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toLikersPath] withParams:[tweet toLikersParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweet.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡_点赞的人_列表"];

            id resultData = [data valueForKeyPath:@"data"];
            resultData = [resultData valueForKeyPath:@"list"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"User"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_LikesAndRewards_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    tweet.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toLikesAndRewardsPath] withParams:[tweet toLikesAndRewardsParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweet.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡_赞赏的人_列表"];
            
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_Comments_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    tweet.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toCommentsPath] withParams:[tweet toCommentsParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweet.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡_评论_列表"];

            id resultData = [data valueForKeyPath:@"data"];
            if ([resultData isKindOfClass:[NSDictionary class]]) {
                resultData = [resultData valueForKeyPath:@"list"];
            }
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Comment"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_Delete_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_删除"];

            [NSObject showHudTipStr:@"删除成功"];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_TweetComment_Delete_WithTweet:(Tweet *)tweet andComment:(Comment *)comment andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/tweet/%d/comment/%d", tweet.id.intValue, comment.id.intValue];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_评论_删除"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Tweet_Detail_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡_详情"];

            id resultData = [data valueForKeyPath:@"data"];
            Tweet *resultA = [NSObject objectOfClass:@"Tweet" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_PublicTweetsWithTopic:(NSInteger)topicID andBlock:(void (^)(id data, NSError *error))block {
    //TODO psy lastid，是否要做分页
    NSString *path = [NSString stringWithFormat:@"api/public_tweets/topic/%ld",(long)topicID];
    NSDictionary *params = @{
                             @"type" : @"topic",
                             @"sort" : @"new"
                             };
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_冒泡列表"];
            
            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Tweet"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark User
- (void)request_UserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toUserInfoPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_RootList label:@"用户信息"];

            id resultData = [data valueForKeyPath:@"data"];
            User *user = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (user.id.intValue == [Login curLoginUser].id.intValue) {
                [Login doLogin:resultData];
            }
            block(user, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ResetPassword_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toResetPasswordPath] withParams:[curUser toResetPasswordParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"重置密码"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_FollowersOrFriends_WithObj:(Users *)curUsers andBlock:(void (^)(id data, NSError *error))block{
    curUsers.isLoading = YES;
    NSString *path = [curUsers toPath];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:[curUsers toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        curUsers.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"关注or粉丝列表"];

            id resultData = [data valueForKeyPath:@"data"];
            
            if ([path hasSuffix:@"friends"] && resultData) {//AT某人时的列表数据，要保存在本地
                User *loginUser = [Login curLoginUser];
                if (loginUser) {
                    [NSObject saveResponseData:resultData toPath:[loginUser localFriendsPath]];
                }
            }
            
            //处理数据
            NSObject *resultA = nil;
            if ([path hasSuffix:@"stargazers"] || [path hasSuffix:@"watchers"]) {
                resultA = [NSArray arrayFromJSON:resultData ofObjects:@"User"];
            }else{
                resultA = [NSObject objectOfClass:@"Users" fromJSON:resultData];
            }
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_FollowedOrNot_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toFllowedOrNotPath] withParams:[curUser toFllowedOrNotParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"关注某人"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UserJobArrayWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/options/jobs" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"个人信息_职位列表"];

            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UserTagArrayWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tagging/user_tag_list" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"个人信息_个性标签列表"];

            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Tag"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UpdateUserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [NSObject showStatusBarQueryStr:@"正在修改个人信息"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toUpdateInfoPath] withParams:[curUser toUpdateInfoParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"个人信息_修改"];

            [NSObject showStatusBarSuccessStr:@"个人信息修改成功"];
            id resultData = [data valueForKeyPath:@"data"];
            User *user = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (user) {
                [Login doLogin:resultData];
            }
            block(user, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)request_GeneratePhoneCodeToResetPhone:(NSString *)phone block:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/user/generate_phone_code";
    NSDictionary *params = @{@"phone": phone};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"生成手机验证码_绑定手机号"];
        }
        block(data, error);
    }];
}
- (void)request_ResetPhone:(NSString *)phone code:(NSString *)code andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/user/updateInfo";
    NSMutableDictionary *params = [[Login curLoginUser] toUpdateInfoParams].mutableCopy;
    params[@"phone"] = phone;
    params[@"code"] = code;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"个人信息_修改手机号码"];
            
            id resultData = [data valueForKeyPath:@"data"];
            User *user = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (user) {
                [Login doLogin:resultData];
            }
            block(user, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_PointRecords:(PointRecords *)records andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[records toPath] withParams:[records toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"码币记录"];

            data = [data valueForKey:@"data"];
            PointRecords *resultA = [NSObject objectOfClass:@"PointRecords" fromJSON:data];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_RewardToTweet:(NSString *)tweet_id encodedPassword:(NSString *)encodedPassword andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/tweet/%@/app_reward", tweet_id];
    NSDictionary *params = encodedPassword.length > 0? @{@"encodedPassword": encodedPassword}: nil;
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"打赏成功"];
        }else{
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"打赏失败"];
        }
        block(data, error);
    }];
}
#pragma mark Message
- (void)request_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block{
    priMsgs.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[priMsgs toPath] withParams:[priMsgs toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        priMsgs.isLoading = NO;
        if (data) {
            if (priMsgs.curFriend) {
                [MobClick event:kUmeng_Event_Request_Get label:@"私信_列表"];
            }else{
                [MobClick event:kUmeng_Event_Request_RootList label:@"会话列表"];
            }

            id resultA = [PrivateMessages analyzeResponseData:data];
            block(resultA, nil);
            
            if (priMsgs.curFriend && priMsgs.curFriend.global_key) {//标记为已读
                [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/message/conversations/%@/read", priMsgs.curFriend.global_key] withParams:nil withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
                    if (data) {
                        [[UnReadManager shareManager] updateUnRead];
                    }
                }];
            }
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Fresh_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block{
    priMsgs.isPolling = YES;
    __weak PrivateMessages *weakMsgs = priMsgs;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[priMsgs toPollPath] withParams:[priMsgs toPollParams] withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        __strong PrivateMessages *strongMsgs = weakMsgs;
        strongMsgs.isPolling = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"私信_轮询"];

            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"PrivateMessage"];
            
            {//标记为已读
                NSString *myGK = [Login curLoginUser].global_key;
                [resultA enumerateObjectsUsingBlock:^(PrivateMessage *obj, NSUInteger idx, BOOL *stop) {
                    if (idx == 0) {
                        [priMsgs freshLastId:obj.id];
                    }
                    if (obj.sender.global_key.length > 0 && ![obj.sender.global_key isEqualToString:myGK]) {
                        *stop = YES;
                        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/message/conversations/%@/read", obj.sender.global_key] withParams:nil withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
                            DebugLog(@"request_Fresh_PrivateMessages Mark Sucess");
                        }];
                    }
                }];
            }
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_SendPrivateMessage:(PrivateMessage *)nextMsg andBlock:(void (^)(id data, NSError *error))block{
    nextMsg.sendStatus = PrivateMessageStatusSending;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[nextMsg toSendPath] withParams:[nextMsg toSendParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"私信_发送_(有图和无图)"];

            id resultData = [data valueForKeyPath:@"data"];
            PrivateMessage *resultA = [NSObject objectOfClass:@"PrivateMessage" fromJSON:resultData];
            nextMsg.sendStatus = PrivateMessageStatusSendSucess;
            block(resultA, nil);
        }else{
            nextMsg.sendStatus = PrivateMessageStatusSendFail;
            block(nil, error);
        }
    }];
}

- (void)request_SendPrivateMessage:(PrivateMessage *)nextMsg andBlock:(void (^)(id data, NSError *error))block progerssBlock:(void (^)(CGFloat progressValue))progress{
    nextMsg.sendStatus = PrivateMessageStatusSending;
    if (nextMsg.nextImg && (!nextMsg.extra || nextMsg.extra.length <= 0)) {
        [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"私信_发送_有图"];
//        先上传图片
        [self uploadTweetImage:nextMsg.nextImg doneBlock:^(NSString *imagePath, NSError *error) {
            if (imagePath) {
//                上传成功后，发送私信
                nextMsg.extra = imagePath;
                [self request_SendPrivateMessage:nextMsg andBlock:block];
            }else{
                nextMsg.sendStatus = PrivateMessageStatusSendFail;
                block(nil, error);
            }
        } progerssBlock:^(CGFloat progressValue) {
        }];
    } else if (nextMsg.voiceMedia) {
        [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"私信_发送_语音"];
        [[CodingNetAPIClient sharedJsonClient] uploadVoice:nextMsg.voiceMedia.file withPath:@"api/message/send_voice" withParams:[nextMsg toSendParams] andBlock:^(id data, NSError *error) {
            if (data) {
                id resultData = [data valueForKeyPath:@"data"];
                PrivateMessage *result = [NSObject objectOfClass:@"PrivateMessage" fromJSON:resultData];
                nextMsg.sendStatus = PrivateMessageStatusSendSucess;
                block(result, nil);
            }else{
                nextMsg.sendStatus = PrivateMessageStatusSendFail;
                block(nil, error);
            }
        }];
    } else {
//        发送私信
        [self request_SendPrivateMessage:nextMsg andBlock:block];
    }
}

- (void)request_playedPrivateMessage:(PrivateMessage *)pm {
    NSString *path = [NSString stringWithFormat:@"/api/message/conversations/%@/play", pm.id];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
        DebugLog(@"request_playedPrivateMessage Mark Sucess");
    }];
}

- (void)request_CodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block{
    curTips.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curTips toTipsPath] withParams:[curTips toTipsParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        curTips.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"消息通知_列表"];

            id resultData = [data valueForKeyPath:@"data"];
            CodingTips *resultA = [NSObject objectOfClass:@"CodingTips" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_markReadWithCodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/mark-read" withParams:[curTips toMarkReadParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"消息通知_标记某类型全部为已读"];

            block(data, nil);
            [[UnReadManager shareManager] updateUnRead];
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_markReadWithCodingTipIdStr:(NSString *)tipIdStr andBlock:(void (^)(id data, NSError *error))block{
    if (tipIdStr.length <= 0) {
        return;
    }
    NSDictionary *params = @{@"id" : tipIdStr};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/mark-read" withParams:params withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"消息通知_标记某条消息为已读"];

            block(data, nil);
            [[UnReadManager shareManager] updateUnRead];
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_DeletePrivateMessage:(PrivateMessage *)curMsg andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMsg toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"私信_删除"];

            block(curMsg, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DeletePrivateMessagesWithObj:(PrivateMessage *)curObj andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curObj.friend toDeleteConversationPath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"会话_删除"];

            block(curObj, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark Git Related
- (void)request_StarProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/%@", project.owner_user_name, project.name, project.stared.boolValue? @"unstar": @"star"];
    project.isStaring = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        project.isStaring = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"项目_收藏"];

            project.stared = [NSNumber numberWithBool:!project.stared.boolValue];
            project.star_count = [NSNumber numberWithInteger:project.star_count.integerValue + (project.stared.boolValue? 1: -1)];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_WatchProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/%@", project.owner_user_name, project.name, project.watched.boolValue? @"unwatch": @"watch"];
    project.isWatching = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        project.isWatching = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"项目_关注"];

            project.watched = [NSNumber numberWithBool:!project.watched.boolValue];
            project.watch_count = [NSNumber numberWithInteger:project.watch_count.integerValue + (project.watched.boolValue? 1: -1)];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ForkProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/fork", project.owner_user_name, project.name];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = @"正在Fork项目";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
//        此处得到的 data 是一个GitPro，需要在请求一次Pro的详细信息
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"项目_Fork"];

            project.forked = [NSNumber numberWithBool:!project.forked.boolValue];
            project.fork_count = [NSNumber numberWithInteger:project.fork_count.integerValue +1];
            
            Project *forkedPro = [[Project alloc] init];
            forkedPro.owner_user_name = [Login curLoginUser].global_key;
            forkedPro.name = project.name;
            [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:forkedPro andBlock:^(id data, NSError *error) {
                [hud hide:YES];
                if (data) {
                    block(data, nil);
                }else{
                    block(nil, error);
                }
            }];
        }else{
            [hud hide:YES];
            block(nil, error);
        }
    }];
}
- (void)request_ReadMeOFProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [[Coding_NetAPIManager sharedManager] request_CodeBranchOrTagWithPath:@"list_branches" withPro:project andBlock:^(id dataTemp, NSError *errorTemp) {
        if (dataTemp) {
            NSArray *branchList = (NSArray *)dataTemp;
            if (branchList.count > 0) {
                __block NSString *defultBranch = @"master";
                [branchList enumerateObjectsUsingBlock:^(CodeBranchOrTag *obj, NSUInteger idx, BOOL *stop) {
                    if (obj.is_default_branch.boolValue) {
                        defultBranch = obj.name;
                    }
                }];
                
                NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/tree/%@",project.owner_user_name, project.name, defultBranch];
                [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
                    if (data) {
                        [MobClick event:kUmeng_Event_Request_Get label:@"项目_README"];

                        id resultData = data[@"data"][@"readme"];
                        if (resultData) {
                            CodeFile *rCodeFile = [NSObject objectOfClass:@"CodeFile" fromJSON:data[@"data"]];
                            CodeFile_RealFile *realFile = [NSObject objectOfClass:@"CodeFile_RealFile" fromJSON:resultData];
                            rCodeFile.path = realFile.path;
                            rCodeFile.file = realFile;
                            block(rCodeFile, nil);
                        }else{
                            block(@"我们推荐每个项目都新建一个README文件（客户端暂时不支持创建和编辑README）", nil);
                        }
                    }else{
                        block(nil, error);
                    }
                }];
            }else{
                [MobClick event:kUmeng_Event_Request_Get label:@"项目_README"];

                block(@"我们推荐每个项目都新建一个README文件（客户端暂时不支持创建和编辑README）", nil);
            }
        }else{
            block(@"加载失败...", errorTemp);
        }
    }];
}

- (void)request_FileDiffDetailWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block{
    NSString *commentsPath = [path stringByReplacingOccurrencesOfString:@"/commitDiffContent" withString:@"/commitDiffComment"];
    NSMutableDictionary *resultA = [NSMutableDictionary new];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            resultA[@"rawData"] = data;
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:commentsPath withParams:nil withMethodType:Get andBlock:^(id dataC, NSError *errorC) {
                if (dataC) {
                    [MobClick event:kUmeng_Event_Request_Get label:@"文件改动_详情"];
                    
                    resultA[@"commentsData"] = dataC;
                    block(resultA, nil);
                }else{
                    block(nil, error);
                }
            }];
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ForkTreeWithOwner:(NSString *)owner_name project:(NSString *)project_name andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/forks", owner_name, project_name];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            data = data[@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:data ofObjects:@"Project"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
#pragma mark Image
- (void)uploadTweetImage:(UIImage *)image
               doneBlock:(void (^)(NSString *imagePath, NSError *error))done
           progerssBlock:(void (^)(CGFloat progressValue))progress{
    if (!image) {
        done(nil, [NSError errorWithDomain:@"DATA EMPTY" code:0 userInfo:@{NSLocalizedDescriptionKey : @"有张照片没有读取成功"}]);
        return;
    }
    [[CodingNetAPIClient sharedJsonClient] uploadImage:image path:@"api/tweet/insert_image" name:@"tweetImg" successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *reslutString = [responseObject objectForKey:@"data"];
        DebugLog(@"%@", reslutString);
        done(reslutString, nil);
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        done(nil, error);
    } progerssBlock:^(CGFloat progressValue) {
        progress(progressValue);
    }];
}
- (void)request_UpdateUserIconImage:(UIImage *)image
                       successBlock:(void (^)(id responseObj))success
                       failureBlock:(void (^)(NSError *error))failure
                      progerssBlock:(void (^)(CGFloat progressValue))progress{
    if (!image) {
        [NSObject showHudTipStr:@"读图失败"];
        return;
    }
    [NSObject showStatusBarQueryStr:@"正在上传头像"];
    CGSize maxSize = CGSizeMake(800, 800);
    if (image.size.width > maxSize.width || image.size.height > maxSize.height) {
        image = [image scaleToSize:maxSize usingMode:NYXResizeModeAspectFit];
    }
    [[CodingNetAPIClient sharedJsonClient] uploadImage:image path:@"api/user/avatar?update=1" name:@"file" successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"个人信息_更换头像"];

        [NSObject showStatusBarSuccessStr:@"上传头像成功"];
        id resultData = [responseObject valueForKeyPath:@"data"];
        success(resultData);
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [NSObject showStatusBarError:error];
    } progerssBlock:progress];
}

- (void)loadImageWithPath:(NSString *)imageUrlStr completeBlock:(void (^)(UIImage *image, NSError *error))block{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrlStr]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MobClick event:kUmeng_Event_Request_Get label:@"下载验证码"];

        DebugLog(@"Response: %@", responseObject);
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"Image error: %@", error);
        block(nil, error);
    }];
    [requestOperation start];
}
#pragma mark Other
- (void)request_Users_WithSearchString:(NSString *)searchStr andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/search" withParams:@{@"key" : searchStr} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"搜索用户"];

            id resultData = [data valueForKeyPath:@"data"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"User"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Users_WithTopicID:(NSInteger)topicID andBlock:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/tweet_topic/%ld/hot_joined",(long)topicID];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_热门参与者"];

            id resultData = [data valueForKeyPath:@"data"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"User"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_JoinedUsers_WithTopicID:(NSInteger)topicID page:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/tweet_topic/%ld/joined",(long)topicID];
    NSDictionary *params = @{
                             @"page":@(page),
                             @"pageSize":@(100)
                             };
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_全部参与者"];

            id resultData = data[@"data"][@"list"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"User"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_MDHtmlStr_WithMDStr:(NSString *)mdStr inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/markdown/previewNoAt";
    if (project.name && project.owner_user_name) {
        path = [NSString stringWithFormat:@"api/user/%@/project/%@/markdownNoAt", project.owner_user_name, project.name];
    }
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:@{@"content" : mdStr} withMethodType:Post andBlock:^(id data, NSError *error) {
        [MobClick event:kUmeng_Event_Request_Get label:@"md-html转化"];

        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block([self localMDHtmlStr_WithMDStr:mdStr], error);
        }
    }];
}

- (NSString *)localMDHtmlStr_WithMDStr:(NSString *)mdStr{
    NSError  *error = nil;
    NSString *htmlStr;
    @try {
        htmlStr = [MMMarkdown HTMLStringWithMarkdown:mdStr error:&error];
    }
    @catch (NSException *exception) {
        htmlStr = @"加载失败！";
    }
    if (error) {
        htmlStr = @"加载失败！";
    }
    return htmlStr;
}

- (void)request_VerifyTypeWithBlock:(void (^)(VerifyType type, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/2fa/method" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"高危操作_获取校验类型"];

            VerifyType type = VerifyTypeUnknow;
            NSString *typeStr = [data valueForKey:@"data"];
            if ([typeStr isEqualToString:@"password"]) {
                type = VerifyTypePassword;
            }else if ([typeStr isEqualToString:@"totp"]){
                type = VerifyTypeTotp;
            }
            block(type, nil);
        }else{
            block(VerifyTypeUnknow, error);
        }
    }];
}

#pragma mark - 2FA
- (void)post_Close2FAGeneratePhoneCode:(NSString *)phone block:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/twofa/close/code" withParams:@{@"phone": phone, @"from": @"mart"} withMethodType:Post andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}

- (void)post_Close2FAWithPhone:(NSString *)phone code:(NSString *)code block:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/twofa/close" withParams:@{@"phone": phone, @"code": code} withMethodType:Post andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}

- (void)get_is2FAOpenBlock:(void (^)(BOOL data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/2fa/method" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        block([data[@"data"] isEqualToString:@"totp"], error);
    }];
}

#pragma mark -
#pragma mark Topic HotKey

- (void)request_TopicHotkeyWithBlock:(void (^)(id data, NSError *error))block {

    NSString *path = @"/api/tweet_topic/hot?page=1&pageSize=20";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_热门话题_Key"];

            id resultData = [data valueForKey:@"data"];
            block(resultData, nil);
        }else {
        
            block(nil, error);
        }
    }];
}

#pragma mark - topic
- (void)request_TopicAdlistWithBlock:(void (^)(id data, NSError *error))block {
    NSString *path = @"/api/tweet_topic/marketing_ad";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_Banner"];

            id resultData = [data valueForKey:@"data"];
            block(resultData, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_HotTopiclistWithBlock:(void (^)(id data, NSError *error))block {
        NSString *path = @"/api/tweet_topic/hot";
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
            if(data) {
                [MobClick event:kUmeng_Event_Request_Get label:@"话题_热门话题_榜单"];

                id resultData = [data valueForKey:@"data"];
                block(resultData, nil);
                
            }else {
                block(nil, error);
            }
        }];
}

- (void)request_Tweet_WithSearchString:(NSString *)strSearch andPage:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block {

    NSString *path = [NSString stringWithFormat:@"/api/search/quick?q=%@&page=%d", strSearch, (int)page];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
       
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡_搜索"];

            id resultData = [(NSDictionary *)[data valueForKey:@"data"] objectForKey:@"tweets"];
            block(resultData, nil);
        }else {
        
            block(nil, error);
        }
    }];
}

- (void)requestWithSearchString:(NSString *)strSearch typeStr:(NSString*)type andPage:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/api/esearch/%@?q=%@&page=%d",type,strSearch, (int)page];
    if ([type isEqualToString:@"all"]) {
        path=[NSString stringWithFormat:@"%@&types=projects,project_topics,tasks,tweets,files,friends,merge_requests,pull_requests",path];
    }else if ([type isEqualToString:@"public_project"]) {
        path=[NSString stringWithFormat:@"/api/esearch/project?q=%@  related:false&page=%d",strSearch,(int)page];
    }
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"全局_搜索"];
            
//            id resultData = [(NSDictionary *)[data valueForKey:@"data"] objectForKey:@"tweets"];
            id resultData = [data valueForKey:@"data"];
            block(resultData, nil);
        }else {
            
            block(nil, error);
        }
    }];
}


- (void)request_TopicDetailsWithTopicID:(NSInteger)topicID block:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"/api/tweet_topic/%ld",(long)topicID];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_详情"];

            id resultData = data[@"data"];
            block(resultData, nil);
        }else {
            
            block(nil, error);
        }
    }];
}

- (void)request_TopTweetWithTopicID:(NSInteger)topicID block:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/public_tweets/topic/%ld/top",(long)topicID];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_热门冒泡列表"];

            id resultData = data[@"data"];
            Tweet *tweet =[NSObject objectOfClass:@"Tweet" fromJSON:resultData];
            block(tweet, nil);
        }else {
            
            block(nil, error);
        }
    }];
}


- (void)request_JoinedTopicsWithUserGK:(NSString *)userGK page:(NSInteger)page block:(void (^)(id data, BOOL hasMoreData, NSError *error))block {
    NSString *path = [[NSString stringWithFormat:@"api/user/%@/tweet_topic/joined",userGK] stringByAppendingString:[NSString stringWithFormat:@"?page=%d&extraInfo=1", (int)page]];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_我参与的"];

            id resultData = data[@"data"];
            BOOL hasMoreData = [resultData[@"totalPage"] intValue] - [resultData[@"page"] intValue];
            block(resultData, hasMoreData, nil);
        }else {
            block(nil, NO, error);
        }
    }];
}

- (void)request_WatchedTopicsWithUserGK:(NSString *)userGK page:(NSInteger)page block:(void (^)(id data, BOOL hasMoreData, NSError *error))block {
    NSString *path = [[NSString stringWithFormat:@"/api/user/%@/tweet_topic/watched",userGK] stringByAppendingString:[NSString stringWithFormat:@"?page=%d&extraInfo=1", (int)page]];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_我关注的"];

            id resultData = data[@"data"];
            BOOL hasMoreData = [resultData[@"totalPage"] intValue] - [resultData[@"page"] intValue];
            block(resultData, hasMoreData, nil);
        }else {
            block(nil, NO, error);
        }
    }];
}

- (void)request_Topic_DoWatch_WithUrl:(NSString *)url andBlock:(void (^)(id data, NSError *error))block{
    
    BOOL isUnwatched = [url hasSuffix:@"unwatch"];
    NetworkMethod method = isUnwatched ? Delete : Post;
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:url withParams:nil withMethodType:method andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"话题_关注"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_BannersWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/banner/type/app" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡列表_Banner"];

            data = [data valueForKey:@"data"];
            NSArray *resultA = [NSArray arrayFromJSON:data ofObjects:@"CodingBanner"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark-
#pragma mark---------------------- shop ---------------------------


- (void)request_shop_bannersWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"/api/gifts/sliders" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
            data = [data valueForKey:@"data"];
            NSArray *resultA = [NSArray arrayFromJSON:data ofObjects:@"ShopBanner"];
            
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_shop_userPointWithShop:(Shop *)_shop andBlock:(void (^)(id data, NSError *error))block
{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/points" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
             data = [data valueForKey:@"data"];
            _shop.points_left = [data objectForKey:@"points_left"];
            _shop.points_total = [data objectForKey:@"points_total"];
            block(data, nil);
        }else
            block(nil, error);
    }];
}


- (void)request_shop_giftsWithShop:(Shop *)_shop andBlock:(void (^)(id data, NSError *error))block
{
    NSDictionary *parsms = @{@"page":_shop.page , @"pageSize":_shop.pageSize};
    _shop.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[_shop toGiftsPath] withParams:parsms withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        _shop.isLoading = NO;
        if (data) {
            data = [[data valueForKey:@"data"] valueForKey:@"list"];
            NSArray *resultA = [NSArray arrayFromJSON:data ofObjects:@"ShopGoods"];
            [_shop configWithGiftGoods:resultA];
            
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_shop_OrderListWithOrder:(ShopOrderModel *)_order andBlock:(void (^)(id data, NSError *error))block
{
    NSDictionary *parsms = @{@"page":_order.page , @"pageSize":_order.pageSize};
    _order.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[_order toPath] withParams:parsms withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        _order.isLoading = NO;
        data = [data valueForKey:@"data"];
        if (data) {
            data = [data valueForKey:@"list"];
            NSArray *resultA = [NSArray arrayFromJSON:data ofObjects:@"ShopOrder"];
            [_order configOrderWithReson:resultA];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_shop_check_passwordWithpwd:(NSString *)pwd andBlock:(void (^)(id data, NSError *error))block
{
    if ([pwd isEmpty]) {
        return;
    }
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/check_password" withParams:@{@"password":[pwd sha1Str]} withMethodType:Post andBlock:^(id data, NSError *error) {
        NSNumber *code = [data valueForKey:@"code"];
        if (!error && code.intValue == 0) {
            block(code, nil);
        }else{
            block(nil, error);
        }
    }];
}
///

- (void)request_shop_exchangeWithParms:(NSDictionary *)parms andBlock:(void (^)(id data, NSError *error))block
{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/gifts/exchange" withParams:parms withMethodType:Post andBlock:^(id data, NSError *error) {
        data = [data valueForKey:@"data"];
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];

}

- (void)request_LocationListWithParams:(NSDictionary *)params block:(void (^)(id data, NSError *error))block{
    NSString *path  = @"api/region";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            data = data[@"data"];
        }
        block(data, error);
    }];
}
@end