//
//  Project.h
//  Coding_iOS
//
//  Created by Ease on 15/4/23.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveGit/ObjectiveGit.h>//https://github.com/libgit2/objective-git

@interface Project : NSObject
@property (readwrite, nonatomic, strong) NSString *icon, *name, *owner_user_name, *backend_project_path, *full_name, *description_mine, *path, *parent_depot_path, *current_user_role,*project_path;
@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *is_public, *un_read_activities_count, *done, *processing, *star_count, *stared, *watch_count, *watched, *fork_count, *forked, *recommended, *pin, *current_user_role_id, *type, *gitReadmeEnabled, *max_member;
@property (assign, nonatomic) BOOL isStaring, isWatching, isLoadingMember, isLoadingDetail;

@property (strong, nonatomic) User *owner;
@property (strong, nonatomic) NSDate *created_at,*updated_at;

@property (strong, nonatomic) NSNumber *board_id;//目前一个项目，只有一个看板。。从看板列表接口得到
@property (assign, nonatomic) BOOL hasEverHandledBoard;

+ (Project *)project_All;
+ (Project *)project_FeedBack;

- (NSString *)toProjectPath;
- (NSDictionary *)toCreateParams;

- (NSString *)toUpdatePath;
- (NSDictionary *)toUpdateParams;

- (NSString *)toUpdateIconPath;

- (NSString *)toDeletePath;

- (NSString *)toArchivePath;

- (NSString *)toMembersPath;
- (NSDictionary *)toMembersParams;

- (NSString *)toUpdateVisitPath;
- (NSString *)toDetailPath;

- (NSString *)localMembersPath;

- (NSString *)toBranchOrTagPath:(NSString *)path;

#pragma mark Git

- (NSURL *)remoteURL;
- (NSURL *)localURL;
- (BOOL)isLocalRepoExist;
- (BOOL)deleteLocalRepo;
- (GTRepository *)localRepo;
- (void)gitCloneBlock:(void(^)(GTRepository *repo, NSError *error))handleBlock progressBlock:(void (^)(const git_transfer_progress *progress, BOOL *stop))progressBlock;
- (void)gitPullBlock:(void(^)(BOOL result, NSString *tipStr))handleBlock progressBlock:(void (^)(const git_transfer_progress *progress, BOOL *stop))progressBlock;

@end
