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
#import "MBProgressHUD+Add.h"
#import "ProjectTopicLabel.h"

@implementation Coding_NetAPIManager
+ (instancetype)sharedManager {
    static Coding_NetAPIManager *shared_manager = nil;
    static dispatch_once_t pred;
	dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
	return shared_manager;
}
//UnRead
- (void)request_UnReadCountWithBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"项目_私信_系统通知"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/unread-count" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UnReadNotificationsWithBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"AT_评论_系统_通知"];
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] init];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : [NSNumber numberWithInteger:0]} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
//            @我的
            [notificationDict setObject:[data valueForKeyPath:@"data"] forKey:kUnReadKey_notification_AT];
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : [NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:2], nil]} withMethodType:Get andBlock:^(id dataComment, NSError *errorComment) {
                if (dataComment) {
//                    评论
                    [notificationDict setObject:[dataComment valueForKeyPath:@"data"] forKey:kUnReadKey_notification_Comment];
                    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : [NSNumber numberWithInteger:4]} withMethodType:Get andBlock:^(id dataSystem, NSError *errorSystem) {
                        if (dataSystem) {
//                            系统
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
- (void)request_Login_WithParams:(id)params andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"登录"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:kNetPath_Code_Login withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
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
- (void)request_Register_WithParams:(id)params andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"注册"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/register" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
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
    [MobClick event:kUmeng_Event_Request label:@"是否需要验证码"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path  withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_SendMailToPath:(NSString *)path email:(NSString *)email j_captcha:(NSString *)j_captcha andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"发激活or重置密码邮件"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:@{@"email": email, @"j_captcha": j_captcha} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_SetPasswordToPath:(NSString *)path params:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"激活or重置密码"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
#pragma mark Project
- (void)request_Projects_WithObj:(Projects *)projects andBlock:(void (^)(Projects *data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"项目列表"];
    projects.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[projects toPath] withParams:[projects toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        projects.isLoading = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Projects *pros = [NSObject objectOfClass:@"Projects" fromJSON:resultData];
            block(pros, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectsHaveTasks_WithObj:(Projects *)projects andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"有任务的项目列表"];
    projects.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/projects" withParams:[projects toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Projects *pros = [NSObject objectOfClass:@"Projects" fromJSON:resultData];
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tasks/projects/count" withParams:nil withMethodType:Get andBlock:^(id datatasks, NSError *errortasks) {
                projects.isLoading = NO;
                if (datatasks) {
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
    [MobClick event:kUmeng_Event_Request label:@"更新项目已读"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toUpdateVisitPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectDetail_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"项目详情"];
    project.isLoadingDetail = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        project.isLoadingDetail = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Project *resultA = [NSObject objectOfClass:@"Project" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectActivityList_WithObj:(ProjectActivities *)proActs andBlock:(void (^)(NSArray *data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"项目动态"];
    proActs.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proActs toPath] withParams:[proActs toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        proActs.isLoading = NO;
        if (data) {
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
        [MobClick event:kUmeng_Event_Request label:@"退出项目"];
        [self showStatusBarQueryStr:@"正在退出项目"];
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMember toQuitPath] withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                [self showStatusBarSuccessStr:@"退出项目成功"];
                block(curMember, nil);
            }else{
                [self showStatusBarError:error];
                block(nil, error);
            }
        }];
    }else{
        [MobClick event:kUmeng_Event_Request label:@"移除成员"];
        [self showStatusBarQueryStr:@"正在移除成员"];
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMember toKickoutPath] withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                [self showStatusBarSuccessStr:@"移除成员成功"];
                block(curMember, nil);
            }else{
                [self showStatusBarError:error];
                block(nil, error);
            }
        }];
    }
}
- (void)request_Project_Pin:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"设置常用项目"];
    NSString *path = [NSString stringWithFormat:@"api/user/projects/pin"];
    NSDictionary *params = @{@"ids": project.id.stringValue};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:project.pin.boolValue? Delete: Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

-(void)request_NewProject_WithObj:(Project *)project image:(UIImage *)image andBlock:(void (^)(NSString *, NSError *))block{
    [MobClick event:kUmeng_Event_Request label:@"创建项目"];
    [self showStatusBarQueryStr:@"正在创建项目"];
    
    NSDictionary *fileDic;
    if (image) {
        fileDic = @{@"image":image,@"name":@"icon",@"fileName":@"icon.jpg"};
    }
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toProjectPath] file:fileDic withParams:[project toCreateParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [self showStatusBarSuccessStr:@"创建项目成功"];
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            [self showStatusBarError:error];
            block(nil, error);
        }
    }];
}

-(void)request_UpdateProject_WithObj:(Project *)project andBlock:(void (^)(Project *, NSError *))block{
    [MobClick event:kUmeng_Event_Request label:@"更新项目"];
    [self showStatusBarQueryStr:@"正在更新项目"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toUpdatePath] withParams:[project toUpdateParams] withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [self showStatusBarSuccessStr:@"更新项目成功"];
            id resultData = [data valueForKeyPath:@"data"];
            Project *resultA = [NSObject objectOfClass:@"Project" fromJSON:resultData];
            block(resultA, nil);
        }else{
            [self showStatusBarError:error];
            block(nil, error);
        }
    }];
}

-(void)request_UpdateProject_WithObj:(Project *)project icon:(UIImage *)icon andBlock:(void (^)(id, NSError *))block progerssBlock:(void (^)(CGFloat))progress{
    [MobClick event:kUmeng_Event_Request label:@"更新项目图标"];
//    [self showStatusBarQueryStr:@"正在上传项目图标"];
    
    // 缩小到最大 500x500
//    icon = [icon scaledToMaxSize:CGSizeMake(500, 500)];
    
    [[CodingNetAPIClient sharedJsonClient] uploadImage:icon path:[project toUpdateIconPath] name:@"file" successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            block(responseObject, nil);
            [self showStatusBarSuccessStr:@"更新项目图标成功"];
        }
        [self hideStatusBarProgress];
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
        [self showStatusBarError:error];
    } progerssBlock:progress];
}

-(void)request_DeleteProject_WithObj:(Project *)project password:(NSString *)password andBlock:(void (^)(Project *, NSError *))block{
    [MobClick event:kUmeng_Event_Request label:@"删除项目"];
    [self showStatusBarQueryStr:@"正在删除项目"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toDeletePath] withParams:[project toDeleteParamsWithPassword:password] withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [self showStatusBarSuccessStr:@"删除项目成功"];
            block(data, nil);
        }else{
            [self showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)request_ProjectTaskList_WithObj:(Tasks *)tasks andBlock:(void (^)(Tasks *data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"任务列表"];
    tasks.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tasks toRequestPath] withParams:[tasks toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tasks.isLoading = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Tasks *resultTasks = [NSObject objectOfClass:@"Tasks" fromJSON:resultData];
            block(resultTasks, nil);
        }else{
            block(nil, error);
        }

    }];
}
- (void)request_ProjectMembers_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"项目成员"];
    project.isLoadingMember = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toMembersPath] withParams:[project toMembersParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        project.isLoadingMember = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            if (resultData) {
                [NSObject saveResponseData:resultData toPath:[project localMembersPath]];
            }
            resultData = [resultData objectForKey:@"list"];

            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectMember"];
            
            __block NSUInteger mineIndex = 0;
            [resultA enumerateObjectsUsingBlock:^(ProjectMember *obj, NSUInteger idx, BOOL *stop) {
                if (obj.user_id.integerValue == [Login curLoginUser].id.integerValue) {
                    mineIndex = idx;
                    *stop = YES;
                }
            }];
            if (mineIndex > 0) {
                [resultA exchangeObjectAtIndex:mineIndex withObjectAtIndex:0];
            }
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectMembersHaveTasks_WithObj:(Project *)project andBlock:(void (^)(NSArray *data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"有任务的项目成员"];
    project.isLoadingMember = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toMembersPath] withParams:[project toMembersParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            resultData = [resultData objectForKey:@"list"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectMember"];
            
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/project/%d/task/user/count", project.id.intValue] withParams:nil withMethodType:Get andBlock:^(id datatasks, NSError *errortasks) {
                project.isLoadingMember = NO;
                if (datatasks) {
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
//File
- (void)request_Folders:(ProjectFolders *)folders inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"文件夹列表"];
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
- (void)request_RefreshCountInFolders:(ProjectFolders *)folders inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folders toFoldersCountPathWithObj:project.id] withParams:nil withMethodType:Get andBlock:^(id countData, NSError *countError) {
        if (countData) {
            //每个文件夹内的文件数量
            NSArray *countArray = [countData valueForKey:@"data"];
            NSMutableDictionary *countDict = [[NSMutableDictionary alloc] initWithCapacity:countArray.count];
            for (NSDictionary *item in countArray) {
                [countDict setObject:[item objectForKey:@"count"] forKey:[item objectForKey:@"folder"]];
            }
            for (ProjectFolder *folder in folders.list) {
                folder.count = [countDict objectForKey:folder.file_id];
                for (ProjectFolder *sub_folder in folder.sub_folders) {
                    sub_folder.count = [countDict objectForKey:sub_folder.file_id];
                }
            }
            folders.isLoading = NO;
            block(folders, nil);
        }else{
            folders.isLoading = NO;
            block(nil, countError);
        }
    }];
}
- (void)request_FilesInFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"文件列表"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folder toFilesPath] withParams:[folder toFilesParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
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
    [MobClick event:kUmeng_Event_Request label:@"删除文件夹"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folder toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            block(folder, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_RenameFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"重命名文件夹"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folder toRenamePath] withParams:nil withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            block(folder, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DeleteFiles:(NSArray *)fileIdList inProject:(NSNumber *)project_id andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"删除文件"];
    NSString *path = [NSString stringWithFormat:@"api/project/%@/file/delete", project_id.stringValue];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:@{@"fileIds" : fileIdList} withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            block(fileIdList, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_MoveFiles:(NSArray *)fileIdList toFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"移动文件"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[folder toMoveToPath] withParams:@{@"fileId": fileIdList} withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            block(fileIdList, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_CreatFolder:(NSString *)fileName inFolder:(ProjectFolder *)parentFolder inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"新建文件夹"];
    NSString *path = [NSString stringWithFormat:@"api/project/%@/mkdir", project.id.stringValue];
    NSDictionary *params = @{@"name" : fileName,
                             @"parentId" : (parentFolder && parentFolder.file_id)? parentFolder.file_id.stringValue : @"0" };
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
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
    [MobClick event:kUmeng_Event_Request label:@"文件详情"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[file toDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            resultData = [resultData valueForKeyPath:@"file"];
            ProjectFile *detailFile = [NSObject objectOfClass:@"ProjectFile" fromJSON:resultData];
            detailFile.project_id = file.project_id;
            block(detailFile, nil);
        }else{
            block(nil, error);
        }
    }];
}
//Code
- (void)request_CodeTree:(CodeTree *)codeTree withPro:(Project *)project codeTreeBlock:(void (^)(id codeTreeData, NSError *codeTreeError))block{
    [MobClick event:kUmeng_Event_Request label:@"代码目录"];
    NSString *treePath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/tree/%@/%@", project.owner_user_name, project.name, codeTree.ref, codeTree.path];
    NSString *treeinfoPath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/treeinfo/%@/%@", project.owner_user_name, project.name, codeTree.ref, codeTree.path];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:treePath withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            CodeTree *rCodeTree = [NSObject objectOfClass:@"CodeTree" fromJSON:resultData];
            
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:treeinfoPath withParams:nil withMethodType:Get andBlock:^(id infoData, NSError *infoError) {
                if (infoData) {
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
    [MobClick event:kUmeng_Event_Request label:@"代码文件"];
    NSString *filePath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/blob/%@/%@", project.owner_user_name, project.name, codeFile.ref, codeFile.path];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:filePath withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKey:@"data"];
            CodeFile *rCodeFile = [NSObject objectOfClass:@"CodeFile" fromJSON:resultData];
            block(rCodeFile, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_CodeBranchOrTagWithPath:(NSString *)path withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"分支or标签列表"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toBranchOrTagPath:path] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKey:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"CodeBranchOrTag"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

//Task
- (void)request_AddTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"添加任务"];
    [self showStatusBarQueryStr:@"正在添加任务"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toAddTaskPath] withParams:[task toAddTaskParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Task *resultT = [NSObject objectOfClass:@"Task" fromJSON:resultData];
            [self showStatusBarSuccessStr:@"添加任务成功"];
            block(resultT, nil);
        }else{
            [self showStatusBarError:error];
            block(nil, error);
        }
    }];
}
- (void)request_DeleteTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"删除任务"];
    [self showStatusBarQueryStr:@"正在删除任务"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toDeleteTaskPath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [self showStatusBarSuccessStr:@"删除任务成功"];
            block(task, nil);
        }else{
            [self showStatusBarError:error];
            block(nil, error);
        }
    }];
}
- (void)request_EditTask:(Task *)task oldTask:(Task *)oldTask andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"更新任务"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toUpdatePath] withParams:[task toUpdateParamsWithOld:oldTask] withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            block(task, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_EditTask:(Task *)task withDescriptionStr:(NSString *)descriptionStr andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"更新任务描述"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toUpdateDescriptionPath] withParams:@{@"description" : descriptionStr} withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            data = [data valueForKey:@"data"];
            Task_Description *taskD = [NSObject objectOfClass:@"Task_Description" fromJSON:data];
            block(taskD, nil);
        }else{
            block(nil, error);
        }
    }];
    
}

- (void)request_ChangeTaskStatus:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"编辑任务状态"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toEditTaskStatusPath] withParams:[task toChangeStatusParams] withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            task.status = [NSNumber numberWithInteger:(task.status.integerValue != 1? 1 : 2)];
            block(task, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_TaskDetail:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"任务详情"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toTaskDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Task *resultA = [NSObject objectOfClass:@"Task" fromJSON:resultData];
            if (resultA.has_description.boolValue) {
                [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[resultA toDescriptionPath] withParams:nil withMethodType:Get andBlock:^(id dataD, NSError *errorD) {
                    if (dataD) {
                        dataD = [dataD valueForKey:@"data"];
                        Task_Description *taskD = [NSObject objectOfClass:@"Task_Description" fromJSON:dataD];
                        resultA.task_description = taskD;
                        block(resultA, nil);
                    }else{
                        block(nil, errorD);
                    }
                }];
            }else{
                block(resultA, nil);
            }
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_CommentListOfTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"任务评论列表"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toCommentListPath] withParams:[task toCommentListParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            resultData = [resultData valueForKeyPath:@"list"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"TaskComment"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_DoCommentToTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"任务添加评论"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toDoCommentPath] withParams:[task toDoCommentParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            TaskComment *resultA = [NSObject objectOfClass:@"TaskComment" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DeleteComment:(TaskComment *)comment ofTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"任务删除评论"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/task/%ld/comment/%ld", (long)task.id.integerValue, (long)comment.id.integerValue] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

//User
- (void)request_AddUser:(User *)user ToProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"添加成员"];
//    一次添加多个成员(逗号分隔)：users=102,4
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/project/%ld/members/add", project.id.longValue] withParams:@{@"users" : user.id} withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark Topic
- (void)request_ProjectTopicList_WithObj:(ProjectTopics *)proTopics andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论列表"];
    proTopics.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopics toRequestPath] withParams:[proTopics toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        proTopics.isLoading = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopics *resultT = [NSObject objectOfClass:@"ProjectTopics" fromJSON:resultData];
            block(resultT, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectTopic_WithObj:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论详情"];
    proTopic.isTopicLoading = YES;
    //html详情
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toTopicPath] withParams:@{@"type": [NSNumber numberWithInteger:0]} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            //markdown详情
            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopic *resultT = [NSObject objectOfClass:@"ProjectTopic" fromJSON:resultData];
            
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toTopicPath] withParams:@{@"type": [NSNumber numberWithInteger:1]} withMethodType:Get andBlock:^(id dataMD, NSError *errorMD) {
                if (dataMD) {
                    resultT.mdTitle = [[dataMD valueForKey:@"data"] valueForKey:@"title"];
                    resultT.mdContent = [[dataMD valueForKey:@"data"] valueForKey:@"content"];
                    id labels = [[dataMD valueForKey:@"data"] valueForKey:@"labels"];
                    resultT.mdLabels = [NSObject arrayFromJSON:labels  ofObjects:@"ProjectTopicLabel"];
                    block(resultT, nil);
                }else{
                    proTopic.isTopicLoading = NO;
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
    [MobClick event:kUmeng_Event_Request label:@"项目讨论_批量修改标签"];
    proTopic.isTopicEditLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toLabelPath]
                                                        withParams:[proTopic toLabelParams]
                                                    withMethodType:Post
                                                          andBlock:^(id data, NSError *error) {
        proTopic.isTopicEditLoading = NO;
        if (data) {
            block(data, nil);
        } else {
            block(nil, error);
        }
    }];
}
- (void)request_ModifyProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block
{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论详情_提交编辑"];
    proTopic.isTopicEditLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toTopicPath] withParams:[proTopic toEditParams] withMethodType:Put andBlock:^(id data, NSError *error) {
        proTopic.isTopicEditLoading = NO;
        if (data) {
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
    [MobClick event:kUmeng_Event_Request label:(proTopic.project_id && proTopic.project_id.integerValue == feedbackId)? @"发送反馈" : @"添加讨论"];
    [self showStatusBarQueryStr:(proTopic.project_id && proTopic.project_id.integerValue == feedbackId)? @"正在发送反馈信息": @"正在添加讨论"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toAddTopicPath] withParams:[proTopic toAddTopicParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [self showStatusBarSuccessStr:(proTopic.project_id && proTopic.project_id.integerValue == feedbackId)? @"反馈成功": @"添加讨论成功"];
            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopic *resultT = [NSObject objectOfClass:@"ProjectTopic" fromJSON:resultData];
            block(resultT, nil);
        }else{
            [self showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)request_Comments_WithProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论评论列表"];
    proTopic.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toCommentsPath] withParams:[proTopic toCommentsParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        proTopic.isLoading = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopics *resultT = [NSObject objectOfClass:@"ProjectTopics" fromJSON:resultData];
            block(resultT, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DoComment_WithProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论添加评论"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toDoCommentPath] withParams:[proTopic toDoCommentParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            ProjectTopic *resultT = [NSObject objectOfClass:@"ProjectTopic" fromJSON:resultData];
            block(resultT, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ProjectTopic_Delete_WithObj:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"删除项目讨论"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[proTopic toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ProjectTopic_Count_WithPath:(NSString *)path
                                   andBlock:(void (^)(id data, NSError *error))block
{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论计数"];
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:nil
                                                    withMethodType:Get
                                                          andBlock:^(id data, NSError *error) {
                                                              if (data) {
                                                                  id resultData = [data valueForKeyPath:@"data"];
                                                                  block(resultData, nil);
                                                              } else {
                                                                  block(nil, error);
                                                              }
                                                          }];
}
- (void)request_ProjectTopic_LabelAll_WithPath:(NSString *)path
                                      andBlock:(void (^)(id data, NSError *error))block
{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论所有被使用标签"];
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:nil
                                                    withMethodType:Get
                                                          andBlock:^(id data, NSError *error) {
                                                              if (data) {
                                                                  id resultData = [data valueForKeyPath:@"data"];
                                                                  NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectTopicLabel"];
                                                                  block(resultA, nil);
                                                              } else {
                                                                  block(nil, error);
                                                              }
                                                          }];
}
- (void)request_ProjectTopic_LabelMy_WithPath:(NSString *)path
                                     andBlock:(void (^)(id data, NSError *error))block
{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论与我相关被使用标签"];
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:nil
                                                    withMethodType:Get
                                                          andBlock:^(id data, NSError *error) {
                                                              if (data) {
                                                                  id resultData = [data valueForKeyPath:@"data"];
                                                                  NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectTopicLabel"];
                                                                  block(resultA, nil);
                                                              } else {
                                                                  block(nil, error);
                                                              }
                                                          }];
}

- (void)request_ProjectTopic_AddLabel_WithPath:(NSString *)path
                                   andBlock:(void (^)(id data, NSError *error))block
{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论增加标签"];
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:nil
                                                    withMethodType:Post
                                                          andBlock:^(id data, NSError *error) {
                                                              if (data) {
                                                                  block(nil, nil);
                                                              } else {
                                                                  block(nil, error);
                                                              }
                                                          }];
}

- (void)request_ProjectTopic_DelLabel_WithPath:(NSString *)path
                                   andBlock:(void (^)(id data, NSError *error))block
{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论删除标签"];
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:nil
                                                    withMethodType:Delete
                                                          andBlock:^(id data, NSError *error) {
                                                              if (data) {
                                                                  block(nil, nil);
                                                              } else {
                                                                  block(nil, error);
                                                              }
                                                          }];
}

#pragma mark - Topic Label
- (void)request_ProjectTopicLabel_WithPath:(NSString *)path
                                  andBlock:(void (^)(id data, NSError *error))block
{
    [MobClick event:kUmeng_Event_Request label:@"项目讨论标签"];
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:nil
                                                    withMethodType:Get
                                                          andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectTopicLabel"];
            block(resultA, nil);
        } else {
            block(nil, error);
        }
    }];
}
- (void)request_ProjectTopicLabel_Del_WithPath:(NSString *)path
                                      andBlock:(void (^)(id data, NSError *error))block
{
    [MobClick event:kUmeng_Event_Request label:@"删除项目讨论标签"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:nil
                                                    withMethodType:Delete
                                                          andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        } else {
            block(nil, error);
        }
    }];
}
- (void)request_ProjectTopicLabel_Add_WithPath:(NSString *)path
                                    withParams:params
                                      andBlock:(void (^)(id data, NSError *error))block
{
    [MobClick event:kUmeng_Event_Request label:@"添加项目讨论标签"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:params
                                                    withMethodType:Post
                                                          andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ProjectTopicLabel_Modify_WithPath:(NSString *)path
                                       withParams:params
                                         andBlock:(void (^)(id data, NSError *error))block
{
    [MobClick event:kUmeng_Event_Request label:@"更新项目讨论标签"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path
                                                        withParams:params
                                                    withMethodType:Put
                                                          andBlock:^(id data, NSError *error) {
                                                              if (data) {
                                                                  id resultData = [data valueForKeyPath:@"data"];
                                                                  ProjectTopicLabel *resultT = [NSObject objectOfClass:@"ProjectTopicLabel" fromJSON:resultData];
                                                                  block(resultT, nil);
                                                              }else{
                                                                  block(nil, error);
                                                              }
                                                          }];
}

#pragma mark Tweet
- (void)request_Tweets_WithObj:(Tweets *)tweets andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"冒泡列表"];
    tweets.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweets toPath] withParams:[tweets toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweets.isLoading = NO;
        
        if (data) {
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
    [MobClick event:kUmeng_Event_Request label:@"冒泡喜欢"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDoLikePath] withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Tweet_DoComment_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"冒泡添加评论"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDoCommentPath] withParams:[tweet toDoCommentParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Comment *comment = [NSObject objectOfClass:@"Comment" fromJSON:resultData];
            block(comment, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_DoTweet_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"发送冒泡"];
    if (tweet.tweetImages && tweet.tweetImages.count > 0) {
        [MobClick event:kUmeng_Event_Request label:@"发送冒泡_有图"];
        
//        --------------------
//        /**
//         *  冒泡一张一张发送，有进度条
//         */
//        if ([tweet isAllImagesHaveDone]) {
//            [self showStatusBarQueryStr:@"正在发送冒泡"];
//            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tweet" withParams:[tweet toDoTweetParams] withMethodType:Post andBlock:^(id data, NSError *error) {
//                if (data) {
//                    id resultData = [data valueForKeyPath:@"data"];
//                    Tweet *tweet = [NSObject objectOfClass:@"Tweet" fromJSON:resultData];
//                    [self showStatusBarSuccessStr:@"冒泡发送成功"];
//                    block(tweet, nil);
//                }else{
//                    [self showStatusBarError:error];
//                    block(nil, error);
//                }
//            }];
//        }else{
//            for (int i=0; i < tweet.tweetImages.count; i++) {
//                TweetImage *imageItem = [tweet.tweetImages objectAtIndex:i];
//                if (imageItem.uploadState == TweetImageUploadStateInit) {
//                    imageItem.uploadState = TweetImageUploadStateIng;
//                    [self showStatusBarQueryStr:[NSString stringWithFormat:@"正在上传第 %d 张图片", i+1]];
//                    [self uploadTweetImage:imageItem.image doneBlock:^(NSString *imagePath, NSError *error) {
//                        if (imagePath) {
//                            imageItem.uploadState = TweetImageUploadStateSuccess;
//                            imageItem.imageStr = [NSString stringWithFormat:@" ![图片](%@) ", imagePath];
//                            [self request_Tweet_DoTweet_WithObj:tweet andBlock:block];
//                        }else{
//                            [self showError:error];
//                            [self showStatusBarError:error];
//                            block(nil, error);
//                            imageItem.uploadState = TweetImageUploadStateFail;
//                            imageItem.imageStr = [NSString stringWithFormat:@" ![图片]() "];
//                        }
//                    } progerssBlock:^(CGFloat progressValue) {
//                        [self showStatusBarProgress:progressValue];
//                        DebugLog(@"showStatusBarProgress %d : %.2f", i, progressValue);
//                    }];
//                    break;
//                }
//            }
//        }
//        -----------------
        /**
         *  冒泡多张一起发送，不显示进度条
         */
        [self showStatusBarQueryStr:@"正在发送冒泡"];
        for (int i=0; i < tweet.tweetImages.count; i++) {
            TweetImage *imageItem = [tweet.tweetImages objectAtIndex:i];
            if (imageItem.uploadState == TweetImageUploadStateInit) {
                imageItem.uploadState = TweetImageUploadStateIng;
                [self uploadTweetImage:imageItem.image doneBlock:^(NSString *imagePath, NSError *error) {
                    if (imagePath) {
                        imageItem.uploadState = TweetImageUploadStateSuccess;
                        imageItem.imageStr = [NSString stringWithFormat:@" ![图片](%@) ", imagePath];
                    }else{
                        [self showError:error];
                        [self showStatusBarError:error];
                        imageItem.uploadState = TweetImageUploadStateFail;
                        imageItem.imageStr = [NSString stringWithFormat:@" ![图片]() "];
                        block(nil, error);
                        return ;
                    }
                    if ([tweet isAllImagesHaveDone]) {
                        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tweet" withParams:[tweet toDoTweetParams] withMethodType:Post andBlock:^(id data, NSError *error) {
                            if (data) {
                                id resultData = [data valueForKeyPath:@"data"];
                                Tweet *tweet = [NSObject objectOfClass:@"Tweet" fromJSON:resultData];
                                [self showStatusBarSuccessStr:@"冒泡发送成功"];
                                block(tweet, nil);
                            }else{
                                [self showStatusBarError:error];
                                block(nil, error);
                            }
                        }];
                    }
                } progerssBlock:^(CGFloat progressValue) {
                    DebugLog(@"showStatusBarProgress %d : %.2f", i, progressValue);
                }];
            }
        }
//        -----------------

    }else{
        [MobClick event:kUmeng_Event_Request label:@"发送冒泡_无图"];
        [self showStatusBarQueryStr:@"正在发送冒泡"];
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tweet" withParams:[tweet toDoTweetParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                id resultData = [data valueForKeyPath:@"data"];
                Tweet *tweet = [NSObject objectOfClass:@"Tweet" fromJSON:resultData];
                [self showStatusBarSuccessStr:@"冒泡发送成功"];
                block(tweet, nil);
            }else{
                [self showStatusBarError:error];
                block(nil, error);
            }
        }];
    }
}

- (void)request_Tweet_Likers_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"冒泡喜欢的人"];
    tweet.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toLikersPath] withParams:[tweet toLikersParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweet.isLoading = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            resultData = [resultData valueForKeyPath:@"list"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"User"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_Comments_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"冒泡评论列表"];
    tweet.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toCommentsPath] withParams:[tweet toCommentsParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweet.isLoading = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            resultData = [resultData valueForKeyPath:@"list"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Comment"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_Delete_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"删除冒泡"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_TweetComment_Delete_WithTweet:(Tweet *)tweet andComment:(Comment *)comment andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"删除冒泡评论"];
    NSString *path = [NSString stringWithFormat:@"api/tweet/%d/comment/%d", tweet.id.intValue, comment.id.intValue];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Tweet_Detail_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"冒泡详情"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Tweet *resultA = [NSObject objectOfClass:@"Tweet" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
#pragma mark User
- (void)request_UserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"用户信息"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toUserInfoPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
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
    [MobClick event:kUmeng_Event_Request label:@"重置密码"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toResetPasswordPath] withParams:[curUser toResetPasswordParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_FollowersOrFriends_WithObj:(Users *)curUsers andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"关注or粉丝列表"];
    curUsers.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUsers toPath] withParams:[curUsers toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        curUsers.isLoading = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            User *loginUser = [Login curLoginUser];
            if (resultData
                && loginUser
                && (!curUsers.owner||
                    (curUsers.owner && curUsers.owner.global_key && [curUsers.owner.global_key isEqualToString:loginUser.global_key]))) {
                    [NSObject saveResponseData:resultData toPath:[loginUser localFriendsPath]];
                }
            Users *users = [NSObject objectOfClass:@"Users" fromJSON:resultData];
            block(users, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_FollowedOrNot_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"关注or取关某人"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toFllowedOrNotPath] withParams:[curUser toFllowedOrNotParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UserJobArrayWithBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"工作列表"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/options/jobs" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UserTagArrayWithBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"标签列表"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tagging/user_tag_list" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Tag"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UpdateUserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"修改个人信息"];
    [self showStatusBarQueryStr:@"正在修改个人信息"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toUpdateInfoPath] withParams:[curUser toUpdateInfoParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [self showStatusBarSuccessStr:@"个人信息修改成功"];
            id resultData = [data valueForKeyPath:@"data"];
            User *user = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (user) {
                [Login doLogin:resultData];
            }
            block(user, nil);
        }else{
            [self showStatusBarError:error];
            block(nil, error);
        }
    }];
}
#pragma mark Message
- (void)request_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"私信列表"];
    priMsgs.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[priMsgs toPath] withParams:[priMsgs toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        priMsgs.isLoading = NO;
        if (data) {
            id resultA = [PrivateMessages analyzeResponseData:data];
            block(resultA, nil);
            
            if (priMsgs.curFriend && priMsgs.curFriend.global_key) {//标记为已读
                [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/message/conversations/%@/read", priMsgs.curFriend.global_key] withParams:nil withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
                    if (data) {
                        [[UnReadManager shareManager] updateUnRead];
                    }
                }];
            }
            //存储到本地
            if (!priMsgs.willLoadMore && data) {
                [NSObject saveResponseData:data toPath:[priMsgs localPrivateMessagesPath]];
            }
        }else{
            //读取本地存储
            if (!priMsgs.willLoadMore) {
                NSDictionary *resultData = [NSObject loadResponseWithPath:[priMsgs localPrivateMessagesPath]];
                if (resultData) {
                    id resultA = [PrivateMessages analyzeResponseData:resultData];
                    block(resultA, nil);
                    return;
                }
            }
            block(nil, error);
        }
    }];
}

- (void)request_Fresh_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"轮询私信列表"];
    priMsgs.isPolling = YES;
    __weak PrivateMessages *weakMsgs = priMsgs;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[priMsgs toPollPath] withParams:[priMsgs toPollParams] withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        __strong PrivateMessages *strongMsgs = weakMsgs;
        strongMsgs.isPolling = NO;
        if (data) {
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
    [MobClick event:kUmeng_Event_Request label:@"发送私信"];
    nextMsg.sendStatus = PrivateMessageStatusSending;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[nextMsg toSendPath] withParams:[nextMsg toSendParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
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
        [MobClick event:kUmeng_Event_Request label:@"发送私信_有图"];
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
    }else{
//        发送私信
        [MobClick event:kUmeng_Event_Request label:@"发送私信_无图"];
        [self request_SendPrivateMessage:nextMsg andBlock:block];
    }
}

- (void)request_CodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"ATor评论or系统通知列表"];
    curTips.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curTips toTipsPath] withParams:[curTips toTipsParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        curTips.isLoading = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            CodingTips *resultA = [NSObject objectOfClass:@"CodingTips" fromJSON:resultData];
            block(resultA, nil);
            //            标记为已读
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/mark-read" withParams:[curTips toMarkReadParams] withMethodType:Post andBlock:^(id data1, NSError *error1) {
                if (data1) {
                    [[UnReadManager shareManager] updateUnRead];
                }
            }];
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_markReadWithCodingTip:(NSString *)tipIdStr andBlock:(void (^)(id data, NSError *error))block{
    if (!tipIdStr) {
        return;
    }
    [MobClick event:kUmeng_Event_Request label:@"标记某条消息为已读"];
    NSDictionary *params = @{@"id" : tipIdStr};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/mark-read" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [[UnReadManager shareManager] updateUnRead];
        }
    }];
}
- (void)request_DeletePrivateMessage:(PrivateMessage *)curMsg andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"删除私信"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMsg toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            block(curMsg, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DeletePrivateMessagesWithObj:(PrivateMessage *)curObj andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"删除私信对话"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curObj.friend toDeleteConversationPath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            block(curObj, nil);
        }else{
            block(nil, error);
        }
    }];
}

//Git Related
- (void)request_StarProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"收藏项目"];
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/%@", project.owner_user_name, project.name, project.stared.boolValue? @"unstar": @"star"];
    project.isStaring = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        project.isStaring = NO;
        if (data) {
            project.stared = [NSNumber numberWithBool:!project.stared.boolValue];
            project.star_count = [NSNumber numberWithInteger:project.star_count.integerValue + (project.stared.boolValue? 1: -1)];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_WatchProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"关注项目"];
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/%@", project.owner_user_name, project.name, project.watched.boolValue? @"unwatch": @"watch"];
    project.isWatching = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        project.isWatching = NO;
        if (data) {
            project.watched = [NSNumber numberWithBool:!project.watched.boolValue];
            project.watch_count = [NSNumber numberWithInteger:project.watch_count.integerValue + (project.watched.boolValue? 1: -1)];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ForkProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"Fork项目"];
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/fork", project.owner_user_name, project.name];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = @"正在Fork项目";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
//        此处得到的 data 是一个GitPro，需要在请求一次Pro的详细信息
        if (data) {
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
    [MobClick event:kUmeng_Event_Request label:@"项目_README"];
    
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
                        NSString *readMeHtml = [[[data valueForKey:@"data"] valueForKey:@"readme"] valueForKey:@"preview"];
                        block(readMeHtml? readMeHtml: @"我们推荐每个项目都新建一个README文件", nil);
                    }else{
                        block(nil, error);
                    }
                }];
            }else{
                block(@"我们推荐每个项目都新建一个README文件", nil);
            }
        }else{
            block(@"加载失败...", errorTemp);
        }
    }];
}
//Image
- (void)uploadUserIconImage:(UIImage *)image
               successBlock:(void (^)(NSString *imagePath))success
               failureBlock:(void (^)(NSError *error))failure
              progerssBlock:(void (^)(CGFloat progressValue))progress{
    [[CodingNetAPIClient sharedJsonClient] uploadImage:image path:@"api/user/avatar" name:@"file" successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *reslutString = [responseObject objectForKey:@"data"];
        DebugLog(@"%@", reslutString);
        success(reslutString);
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    } progerssBlock:^(CGFloat progressValue) {
        progress(progressValue);
    }];
}
- (void)uploadTweetImage:(UIImage *)image
               doneBlock:(void (^)(NSString *imagePath, NSError *error))done
           progerssBlock:(void (^)(CGFloat progressValue))progress{
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
        [self showHudTipStr:@"读图失败"];
        return;
    }
    [MobClick event:kUmeng_Event_Request label:@"更换头像"];

    [self showStatusBarQueryStr:@"正在上传头像"];
    CGSize maxSize = CGSizeMake(800, 800);
    if (image.size.width > maxSize.width || image.size.height > maxSize.height) {
        image = [image scaleToSize:maxSize usingMode:NYXResizeModeAspectFit];
    }
    [[CodingNetAPIClient sharedJsonClient] uploadImage:image path:@"api/user/avatar?update=1" name:@"file" successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self showStatusBarSuccessStr:@"上传头像成功"];
        id resultData = [responseObject valueForKeyPath:@"data"];
        success(resultData);
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [self showStatusBarError:error];
    } progerssBlock:progress];
}

- (void)loadImageWithPath:(NSString *)imageUrlStr completeBlock:(void (^)(UIImage *image, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"下载验证码"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrlStr]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        DebugLog(@"Response: %@", responseObject);
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"Image error: %@", error);
        block(nil, error);
    }];
    [requestOperation start];
}
//Other
- (void)request_Users_WithSearchString:(NSString *)searchStr andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"搜索用户"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/search" withParams:@{@"key" : searchStr} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"User"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_MDHtmlStr_WithMDStr:(NSString *)mdStr andBlock:(void (^)(id data, NSError *error))block{
    [MobClick event:kUmeng_Event_Request label:@"md-html转化"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/markdown/previewNoAt" withParams:@{@"content" : mdStr} withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}
@end