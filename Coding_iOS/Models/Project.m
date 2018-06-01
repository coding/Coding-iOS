//
//  Project.m
//  Coding_iOS
//
//  Created by Ease on 15/4/23.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "Project.h"
#import "Login.h"
#import "NProjectViewController.h"
#import "EALocalCodeListViewController.h"

@implementation Project

- (BOOL)hasEverHandledBoard{
    NSNumber *hasEverHandledBoard = [[NSUserDefaults standardUserDefaults] objectForKey:self.p_hasEverHandledBoardKey];
    return hasEverHandledBoard? hasEverHandledBoard.boolValue : NO;
}

- (void)setHasEverHandledBoard:(BOOL)hasEverHandledBoard{
    [[NSUserDefaults standardUserDefaults] setObject:@(hasEverHandledBoard) forKey:self.p_hasEverHandledBoardKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)p_hasEverHandledBoardKey{
    return [NSString stringWithFormat:@"%@/%@/hasEverHandledBoardKey", self.owner_user_name, self.name];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isStaring = _isWatching = _isLoadingMember = _isLoadingDetail = NO;
        _recommended = [NSNumber numberWithInteger:0];
    }
    return self;
}

- (void)setBackend_project_path:(NSString *)backend_project_path{
    if ([backend_project_path hasPrefix:@"/team/"]) {
        backend_project_path = [backend_project_path stringByReplacingOccurrencesOfString:@"/team/" withString:@"/user/"];
    }
    _backend_project_path = backend_project_path;
}

-(id)copyWithZone:(NSZone*)zone {
    Project *person = [[[self class] allocWithZone:zone] init];
    person.icon = [_icon copy];
    person.name = [_name copy];
    person.owner_user_name = [_owner_user_name copy];
    person.backend_project_path = [_backend_project_path copy];
    person.full_name = [_full_name copy];
    person.description_mine = [_description_mine copy];
    person.path = [_path copy];
    person.current_user_role = [_current_user_role copy];
    person.id = [_id copy];
    person.owner_id = [_owner_id copy];
    person.is_public = [_is_public copy];
    person.un_read_activities_count = [_un_read_activities_count copy];
    person.done = [_done copy];
    person.processing = [_processing copy];
    person.star_count = [_star_count copy];
    person.stared = [_stared copy];
    person.watch_count = [_watch_count copy];
    person.watched = [_watched copy];
    person.fork_count = [_fork_count copy];
    person.recommended = [_recommended copy];
    person.current_user_role_id = [_current_user_role_id copy];
    person.isStaring = _isStaring;
    person.isWatching = _isWatching;
    person.isLoadingMember = _isLoadingMember;
    person.isLoadingMember = _isLoadingMember;
    person.created_at = [_created_at copy];
    person.updated_at = [_updated_at copy];
    person.project_path=[_project_path copy];
    person.owner=[_owner copy];
    return person;
}

- (NSString *)owner_user_name{
    return _owner_user_name ?: [NSObject baseCompany];
}

- (void)setFull_name:(NSString *)full_name{
    _full_name = full_name;
    NSArray *components = [_full_name componentsSeparatedByString:@"/"];
    if (components.count == 2) {
        if (!_owner_user_name) {
            _owner_user_name = components[0];
        }
        if (_name) {
            _name = components[1];
        }
    }
}

+(Project *)project_All{
    Project *pro = [[Project alloc] init];
    pro.id = [NSNumber numberWithInteger:-1];
    return pro;
}

+ (Project *)project_FeedBack{
    Project *pro = [[Project alloc] init];
    pro.id = [NSNumber numberWithInteger:38894];//iOS公开项目
    pro.is_public = [NSNumber numberWithBool:YES];
    return pro;
}

-(NSString *)toProjectPath{
    return kTarget_Enterprise? [NSString stringWithFormat:@"api/team/%@/project", [NSObject baseCompany]]: @"api/project";
}

-(NSDictionary *)toCreateParams{
    
    NSString *type;
    if ([self.is_public isEqual:@YES]) {
        type = @"1";
    }else{
        type = @"2";
    }
    if (kTarget_Enterprise) {
        return @{@"name":self.name,
                 @"description":self.description_mine,
                 @"type":type,
                 @"gitEnabled":@"true",
                 @"gitReadmeEnabled": _gitReadmeEnabled.boolValue? @"true": @"false",
                 @"gitIgnore":@"no",
                 @"gitLicense":@"no",
                 //             @"importFrom":@"no",
                 @"vcsType":@"git",
                 @"teamGK": [NSObject baseCompany],
                 @"joinTeam": @"true",
                 };
    }else{
        return @{@"name":self.name,
                 @"description":self.description_mine,
                 @"type":type,
                 @"gitEnabled":@"true",
                 @"gitReadmeEnabled": _gitReadmeEnabled.boolValue? @"true": @"false",
                 @"gitIgnore":@"no",
                 @"gitLicense":@"no",
                 //             @"importFrom":@"no",
                 @"vcsType":@"git"};
    }
}

-(NSString *)toUpdatePath{
    return @"api/project";
}

-(NSDictionary *)toUpdateParams{
    return @{@"name":self.name,
             @"description":self.description_mine,
             @"id":self.id
             //             @"default_branch":[NSNull null]
             };
}

-(NSString *)toUpdateIconPath{
    return [NSString stringWithFormat:@"api/project/%@/project_icon",self.id];
}

-(NSString *)toDeletePath{
    if (kTarget_Enterprise) {
        return [NSString stringWithFormat:@"api/team/%@/project/%@/delete", [Login curLoginCompany].global_key, _id];
    }else{
        return [NSString stringWithFormat:@"api/user/%@/project/%@",self.owner_user_name, self.name];
    }
}

- (NSString *)toArchivePath{
    if (kTarget_Enterprise) {
        return [NSString stringWithFormat:@"api/team/%@/project/%@/archive", [Login curLoginCompany].global_key, self.id];
    }else{
        return [NSString stringWithFormat:@"api/project/%@/archive", self.id];
    }
}

- (NSString *)toMembersPath{
    if ([_id isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"api/project/%d/members", self.id.intValue];
    }else{
        return [NSString stringWithFormat:@"api/user/%@/project/%@/members", _owner_user_name, _name];
    }
}
- (NSDictionary *)toMembersParams{
    return @{@"page" : [NSNumber numberWithInteger:1],
             @"pageSize" : [NSNumber numberWithInteger:500]};
}
- (NSString *)toUpdateVisitPath{
    if (self.owner_user_name.length > 0 && self.name.length > 0) {
        return [NSString stringWithFormat:@"api/user/%@/project/%@/update_visit", self.owner_user_name, self.name];
    }else{
        return [NSString stringWithFormat:@"api/project/%d/update_visit", self.id.intValue];
    }
}
- (NSString *)toDetailPath{
    return [NSString stringWithFormat:@"api/user/%@/project/%@", self.owner_user_name, self.name];
}
- (NSString *)localMembersPath{
    return [NSString stringWithFormat:@"%@_MembersPath", self.id.stringValue];
}

- (NSString *)toBranchOrTagPath:(NSString *)path{
    return [NSString stringWithFormat:@"api/user/%@/project/%@/git/%@", self.owner_user_name, self.name, path];
}
//- (NSString *)description_mine{
//    if (_description_mine && _description_mine.length > 0) {
//        return _description_mine;
//    }else{
//        return @"未填写";
//    }
//}

- (NSURL *)remoteURL{
    NSURL *remoteURL;
    if (kTarget_Enterprise) {
        remoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@.git", [NSObject e_URLStr], self.owner_user_name, self.name]];
    }else{
        remoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://git.coding.net/%@/%@.git", self.owner_user_name, self.name]];
    }
    return remoteURL;
}
- (NSURL *)localURL{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL *appDocsDir = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSURL *localURL = [NSURL URLWithString:[NSString stringWithFormat:@"repositories/%@/%@", self.owner_user_name, self.name] relativeToURL:appDocsDir];
    return localURL;
}
- (BOOL)isLocalRepoExist{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:self.localURL.path];
}
- (BOOL)deleteLocalRepo{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtURL:self.localURL error:nil];
}
- (GTRepository *)localRepo{
    NSError *error = nil;
    GTRepository *repo = [GTRepository repositoryWithURL:self.localURL error:&error];
    return repo;
}
- (void)gitCloneBlock:(void(^)(GTRepository *repo, NSError *error))handleBlock progressBlock:(void (^)(const git_transfer_progress *progress, BOOL *stop))progressBlock{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        GTCheckoutOptions *checkoutOptions = [GTCheckoutOptions checkoutOptionsWithStrategy:GTCheckoutStrategyForce];
        NSMutableDictionary *cloneOptions = @{GTRepositoryCloneOptionsCheckoutOptions: checkoutOptions}.mutableCopy;
        if (weakSelf.is_public && !weakSelf.is_public.boolValue) {//私有项目
            cloneOptions[GTRepositoryCloneOptionsCredentialProvider] = [weakSelf.class p_credentialProvider];
        }
        GTRepository *repo = [GTRepository cloneFromURL:weakSelf.remoteURL toWorkingDirectory:weakSelf.localURL options:cloneOptions error:&error transferProgressBlock:progressBlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handleBlock) {
                handleBlock(repo, error);
            }
        });
    });
}
- (void)gitPullBlock:(void(^)(BOOL result, NSString *tipStr))handleBlock progressBlock:(void (^)(const git_transfer_progress *progress, BOOL *stop))progressBlock{
    if (!self.isLocalRepoExist) {
        handleBlock(NO, @"本地仓库未找到");
    }else{
        GTRepository *repo = [GTRepository repositoryWithURL:self.localURL error:nil];
        if (!repo) {
            handleBlock(NO, @"本地仓库未找到");
        }else{
            GTConfiguration *configuration = [repo configurationWithError:nil];
            GTRemote *remote = configuration.remotes.firstObject;
            if (!remote) {
                handleBlock(NO, @"仓库信息不完整");
            }else{
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error = nil;
                    NSArray<GTBranch *> *branchList = [repo localBranchesWithError:&error];
                    if (branchList.count > 0) {
                        GTBranch *curBranch = branchList.firstObject;
                        NSMutableDictionary *options = @{GTRepositoryRemoteOptionsDownloadTags: @(GTRemoteDownloadTagsAuto)}.mutableCopy;
                        if (weakSelf.is_public && !weakSelf.is_public.boolValue) {//私有项目
                            options[GTRepositoryRemoteOptionsCredentialProvider] = [weakSelf.class p_credentialProvider];
                        }
                        NSError *error = nil;
                        BOOL result = [repo pullBranch:curBranch fromRemote:remote withOptions:options error:&error progress:progressBlock];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (handleBlock) {
                                handleBlock(result, error.localizedDescription);
                            }
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (handleBlock) {
                                handleBlock(NO, @"本地分支为空，请删除后，重新 clone 代码");
                            }
                        });
                    }
                });
            }
        }
    }
}

+ (GTCredentialProvider *)p_credentialProvider{
    __block NSInteger credTimes = 0;
    GTCredentialProvider *provider = [GTCredentialProvider providerWithBlock:^GTCredential *(GTCredentialType type, NSString *URL, NSString *credUserName) {
        GTCredential *cred = nil;
        if (type & GTCredentialTypeUserPassPlaintext) {
            if (credTimes < 10) {//用户名密码错了不知道提示，居然不知道停的。。
                NSString *userName = [Login curLoginUser].global_key ?: @"";
                NSString *password = [Login curPassword] ?: @"";
                cred = [GTCredential credentialWithUserName:userName password:password error:nil];
            }else{
                [self p_handleCredentialFailure];
            }
        }
        credTimes++;
        return cred;
    }];
    return provider;
}

+ (void)p_handleCredentialFailure{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"身份验证失败！" message:@"HTTP/S 协议需要用户的密码" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *textStr = alertCtrl.textFields[0].text;
        [Login setPassword:textStr];
        //下面这段，貌似没必要。。用户自己去再次点击也可以
        UIViewController *vc = [BaseViewController presentingVC];
        if ([vc isKindOfClass:[NProjectViewController class]]) {
            [(NProjectViewController *)vc cloneRepo];
        }else if ([vc isKindOfClass:[EALocalCodeListViewController class]]){
            [(EALocalCodeListViewController *)vc pullRepo];
        }
    }];
    [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入密码";
        textField.secureTextEntry = YES;
    }];
    [alertCtrl addAction:cancelA];
    [alertCtrl addAction:confirmA];
    [[BaseViewController presentingVC] presentViewController:alertCtrl animated:YES completion:nil];
}

@end
