//
//  Coding_NetAPIManager.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#import "CodingNetAPIClient.h"
#import "Projects.h"
#import "Tasks.h"
#import "ProjectMember.h"
#import "ProjectTopics.h"
#import "Tweets.h"
#import "Users.h"
#import "PrivateMessages.h"
#import "ProjectMember.h"
#import "CodingTips.h"
#import "CodeTree.h"
#import "CodeFile.h"
#import "ProjectFolders.h"
#import "ProjectFiles.h"
#import "CodeBranchOrTag.h"
#import "MRPRS.h"
#import "MRPR.h"
#import "MRPRBaseInfo.h"
#import "ReviewersInfo.h"
#import "Reviewer.h"
#import "Commit.h"
#import "FileChanges.h"
#import "FileLineChange.h"
#import "CommitInfo.h"
#import "Commits.h"
#import "ProjectTag.h"
#import "CodingBanner.h"
#import "PointRecords.h"
#import "FileVersion.h"
#import "Shop.h"
#import "ShopOrderModel.h"
#import "ProjectCount.h"
#import "ActivenessModel.h"
#import "MRPRPreInfo.h"

#import <UMSocialCore/UMSocialCore.h>

@class CSTopic, Team, EAWiki;

typedef NS_ENUM(NSUInteger, VerifyType){
    VerifyTypeUnknow = 0,
    VerifyTypePassword,
    VerifyTypeTotp,
};

typedef NS_ENUM(NSInteger, PurposeType) {
    PurposeToRegister = 0,
    PurposeToPasswordActivate,
    PurposeToPasswordReset
};

@interface Coding_NetAPIManager : NSObject
+ (instancetype)sharedManager;

#pragma mark - UnRead
- (void)request_UnReadCountWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_UnReadNotificationsWithBlock:(void (^)(id data, NSError *error))block;


#pragma mark - Login
- (void)request_Login_With2FA:(NSString *)otpCode andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Login_WithPath:(NSString *)path Params:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Login_With_UMSocialResponse:(UMSocialResponse *)resp andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Register_V2_WithParams:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CaptchaNeededWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block;
- (void)request_SetPasswordToPath:(NSString *)path params:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CheckPhoneCodeWithPhone:(NSString *)phone code:(NSString *)code type:(PurposeType)type block:(void (^)(id data, NSError *error))block;
- (void)request_ActivateBySetGlobal_key:(NSString *)global_key block:(void (^)(id data, NSError *error))block;
- (void)request_SendActivateEmail:(NSString *)email block:(void (^)(id data, NSError *error))block;

#pragma mark - Project
- (void)request_Projects_WithObj:(Projects *)projects andBlock:(void (^)(Projects *data, NSError *error))block;
- (void)request_ProjectsCatergoryAndCounts_WithObj:(ProjectCount *)pCount andBlock:(void (^)(ProjectCount *data, NSError *error))block;
- (void)request_ProjectsHaveTasks_WithObj:(Projects *)projects andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Project_UpdateVisit_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectDetail_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectActivityList_WithObj:(ProjectActivities *)proActs andBlock:(void (^)(NSArray *data, NSError *error))block;
- (void)request_ProjectTaskList_WithObj:(Tasks *)tasks andBlock:(void (^)(Tasks *data, NSError *error))block;
- (void)request_ProjectMembers_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectMembersHaveTasks_WithObj:(Project *)project andBlock:(void (^)(NSArray *data, NSError *error))block;
- (void)request_ProjectMember_Quit:(ProjectMember *)curMember andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Project_Pin:(Project *)project andBlock:(void (^)(id data, NSError *error))block;

- (void)request_NewProject_WithObj:(Project *)project image:(UIImage *)image andBlock:(void (^)(NSString *data, NSError *error))block;
- (void)request_UpdateProject_WithObj:(Project *)project andBlock:(void (^)(Project *data, NSError *error))block;
- (void)request_UpdateProject_WithObj:(Project *)project icon:(UIImage *)icon andBlock:(void (^)(id data, NSError *error))block progerssBlock:(void (^)(CGFloat progressValue))progress;;
- (void)request_DeleteProject_WithObj:(Project *)project passCode:(NSString *)passCode type:(VerifyType)type andBlock:(void (^)(Project *data, NSError *error))block;
- (void)request_TransferProject:(Project *)project toUser:(User *)user passCode:(NSString *)passCode type:(VerifyType)type andBlock:(void (^)(Project *data, NSError *error))block;
- (void)request_EditAliasOfMember:(ProjectMember *)curMember inProject:(Project *)curPro andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditTypeOfMember:(ProjectMember *)curMember inProject:(Project *)curPro andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectServiceInfo:(Project *)curPro andBlock:(void (^)(id data, NSError *error))block;


#pragma mark Team
- (void)request_JoinedTeamsBlock:(void (^)(id data, NSError *error))block;
- (void)request_DetailOfTeam:(Team *)team andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectsInTeam:(Team *)team isJoined:(BOOL)isJoined andBlock:(void (^)(id data, NSError *error))block;
- (void)request_MembersInTeam:(Team *)team andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - MRPR
- (void)request_MRPRS_WithObj:(MRPRS *)curMRPRS andBlock:(void (^)(MRPRS *data, NSError *error))block;
- (void)request_MRPRBaseInfo_WithObj:(MRPR *)curMRPR andBlock:(void (^)(MRPRBaseInfo *data, NSError *error))block;
- (void)request_MRPRPreInfo_WithObj:(MRPR *)curMRPR andBlock:(void (^)(MRPRPreInfo *data, NSError *error))block;
- (void)request_MRReviewerInfo_WithObj:(MRPR *)curMRPR andBlock:(void (^)(ReviewersInfo *data, NSError *error))block;
- (void)request_MRPRCommits_WithObj:(MRPR *)curMRPR andBlock:(void (^)(NSArray *data, NSError *error))block;
- (void)request_MRPRFileChanges_WithObj:(MRPR *)curMRPR andBlock:(void (^)(FileChanges *data, NSError *error))block;
- (void)request_MRPRAccept:(MRPR *)curMRPR andBlock:(void (^)(id data, NSError *error))block;
- (void)request_MRPRRefuse:(MRPR *)curMRPR andBlock:(void (^)(id data, NSError *error))block;
- (void)request_MRPRAuthorization:(MRPR *)curMRPR andBlock:(void (^)(id data, NSError *error))block;
- (void)request_MRPRCancelAuthorization:(MRPR *)curMRPR andBlock:(void (^)(id data, NSError *error))block;
- (void)request_MRPRCancel:(MRPR *)curMRPR andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CommitInfo_WithUserGK:(NSString *)userGK projectName:(NSString *)projectName commitId:(NSString *)commitId andBlock:(void (^)(CommitInfo *data, NSError *error))block;
- (void)request_PostCommentWithPath:(NSString *)path params:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteLineNote:(NSNumber *)lineNoteId inProject:(NSString *)projectName ofUser:(NSString *)userGK andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteLineNoteWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - File
- (void)request_Folders:(ProjectFolders *)folders inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FilesInFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block;
- (void)request_RenameFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteFiles:(NSArray *)fileIdList inProject:(NSNumber *)project_id andBlock:(void (^)(id data, NSError *error))block;
- (void)request_MoveFiles:(NSArray *)fileIdList toFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block;
- (void)request_MoveFolder:(NSNumber *)folderId toFolder:(ProjectFolder *)folder inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CreatFolder:(NSString *)fileName inFolder:(ProjectFolder *)parentFolder inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FileDetail:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FileContent:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditFile:(ProjectFile *)file withContent:(NSString *)contentStr andBlock:(void (^)(id data, NSError *error))block;
- (void)request_RenameFile:(ProjectFile *)file withName:(NSString *)nameStr andBlock:(void (^)(id data, NSError *error))block;

- (void)request_ActivityListOfFile:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block;
- (void)request_VersionListOfFile:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteComment:(NSNumber *)comment_id inFile:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block;
- (void)request_RemarkFileVersion:(FileVersion *)curVersion withStr:(NSString *)remarkStr andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteFileVersion:(FileVersion *)curVersion andBlock:(void (^)(id data, NSError *error))block;
- (void)request_OpenShareOfFile:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CloseFileShareHash:(NSString *)hashStr andBlock:(void (^)(id data, NSError *error))block;

- (void)request_OpenShareOfWiki:(EAWiki *)wiki andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CloseWikiShareHash:(NSString *)hashStr andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Code
- (void)request_CodeTree:(CodeTree *)codeTree withPro:(Project *)project codeTreeBlock:(void (^)(id codeTreeData, NSError *codeTreeError))block;
- (void)request_CodeFile:(CodeFile *)codeFile withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditCodeFile:(CodeFile *)codeFile withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CodeBranchOrTagWithPath:(NSString *)path withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Commits:(Commits *)curCommits withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_UploadAssets:(NSArray *)assets inCodeTree:(CodeTree *)codeTree withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block progerssBlock:(void (^)(CGFloat progressValue))progressBlock;
- (void)request_CreateCodeFile:(CodeFile *)codeFile withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block;

#pragma mark Wiki
- (void)request_WikiListWithPro:(Project *)pro andBlock:(void (^)(id data, NSError *error))block;
- (void)request_WikiDetailWithPro:(Project *)pro iid:(NSNumber *)iid version:(NSNumber *)version andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteWikiWithPro:(Project *)pro iid:(NSNumber *)iid andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ModifyWiki:(EAWiki *)wiki pro:(Project *)pro andBlock:(void (^)(id data, NSError *error))block;
- (void)request_WikiHistoryWithWiki:(EAWiki *)wiki pro:(Project *)pro andBlock:(void (^)(id data, NSError *error))block;
- (void)request_RevertWiki:(NSNumber *)wikiIid toVersion:(NSNumber *)version pro:(Project *)pro andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Task
- (void)request_AddTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditTask:(Task *)task oldTask:(Task *)oldTask andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditTask:(Task *)task withDescriptionStr:(NSString *)descriptionStr andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditTask:(Task *)task withTags:(NSMutableArray *)selectedTags andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ChangeTaskStatus:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_TaskDetail:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_TaskResourceReference:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteResourceReference:(NSNumber *)iid ofTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteResourceReference:(NSNumber *)iid ResourceReferencePath:(NSString *)ResourceReferencePath andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ActivityListOfTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DoCommentToTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteComment:(TaskComment *)comment ofTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ChangeWatcher:(User *)watcher ofTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_projects_tasks_labelsWithRole:(TaskRoleType)role projectId:(NSString *)projectId andBlock:(void (^)(id data, NSError *error))block; //任务标签
- (void)request_tasks_searchWithUserId:(NSString *)userId role:(TaskRoleType )role project_id:(NSString *)project_id keyword:(NSString *)keyword status:(NSString *)status label:(NSString *)label page:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block;
- (void)request_project_tasks_countWithProjectId:(NSString *)projectId andBlock:(void (^)(id data, NSError *error))block;

//项目内
- (void)request_project_task_countWithProjectId:(NSString *)projectId andBlock:(void (^)(id data, NSError *error))block;
- (void)request_project_user_tasks_countsWithProjectId:(NSString *)projectId memberId:(NSString *)memberId andBlock:(void (^)(id data, NSError *error))block;
- (void)request_tasks_searchWithUserId:(NSString *)userId role:(TaskRoleType )role project_id:(NSString *)project_id andBlock:(void (^)(id data, NSError *error))block;
- (void)request_projects_tasks_labelsWithRole:(TaskRoleType)role projectId:(NSString *)projectId projectName:(NSString *)projectName memberId:(NSString *)memberId owner_user_name:(NSString *)owner_user_name andBlock:(void (^)(id data, NSError *error))block;


#pragma mark - User
- (void)request_AddUser:(User *)user ToProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Topic
- (void)request_ProjectTopicList_WithObj:(ProjectTopics *)proTopics andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectTopic_WithObj:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ModifyProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;
- (void)request_AddProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Comments_WithProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Comments_WithAnswer:(ProjectTopic *)proTopic inProjectId:(NSNumber *)projectId andBlock:(void (^)(id data, NSError *error))block;
- (void)request_UpvoteAnswer:(ProjectTopic *)proTopic inProjectId:(NSNumber *)projectId andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DoComment_WithProjectTpoic:(ProjectTopic *)proTopic andAnswerId:(NSNumber *)answerId andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectTopic_Delete_WithObj:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectTopicComment_Delete_WithObj:(ProjectTopic *)proTopic projectId:(NSNumber *)projectId andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ChangeWatcher:(User *)watcher ofTopic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;

- (void)request_ModifyProjectTpoicLabel:(ProjectTopic *)proTopic
                               andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectTopic_Count_WithPath:(NSString *)path
                                   andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectTopic_LabelMy_WithPath:(NSString *)path
                                     andBlock:(void (^)(id data, NSError *error))block;

#pragma mark -  Project Tag
- (void)request_TagListInProject:(Project *)project type:(ProjectTagType)type andBlock:(void (^)(id data, NSError *error))block;
- (void)request_AddTag:(ProjectTag *)tag toProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteTag:(ProjectTag *)tag inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ModifyTag:(ProjectTag *)tag inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Tweet
- (void)request_Tweets_WithObj:(Tweets *)tweets andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoLike_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoComment_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoTweet_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoProjectTweet_WithPro:(NSNumber *)pro_id content:(NSString *)content andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Likers_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_LikesAndRewards_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Comments_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Delete_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_TweetComment_Delete_WithTweet:(Tweet *)tweet andComment:(Comment *)comment andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Detail_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_PublicTweetsWithTopic:(NSInteger)topicID last_id:(NSNumber *)last_id andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - User
- (void)request_UserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ResetPassword_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FollowersOrFriends_WithObj:(Users *)curUsers andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FollowedOrNot_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_UserJobArrayWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_UserTagArrayWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_UpdateUserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_GeneratePhoneCodeToResetPhone:(NSString *)phone phoneCountryCode:(NSString *)phoneCountryCode withCaptcha:(NSString *)captcha block:(void (^)(id data, NSError *error))block;
- (void)request_PointRecords:(PointRecords *)records andBlock:(void (^)(id data, NSError *error))block;
- (void)request_RewardToTweet:(NSString *)tweet_id encodedPassword:(NSString *)encodedPassword andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ServiceInfoBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Message
- (void)request_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Fresh_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block;
- (void)request_SendPrivateMessage:(PrivateMessage *)nextMsg andBlock:(void (^)(id data, NSError *error))block;
- (void)request_SendPrivateMessage:(PrivateMessage *)nextMsg andBlock:(void (^)(id data, NSError *error))block progerssBlock:(void (^)(CGFloat progressValue))progress;
- (void)request_playedPrivateMessage:(PrivateMessage *)pm;
- (void)request_CodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block;
- (void)request_markReadWithCodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block;
- (void)request_markReadWithCodingTipIdStr:(NSString *)tipIdStr andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeletePrivateMessage:(PrivateMessage *)curMsg andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeletePrivateMessagesWithObj:(PrivateMessage *)curObj andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Git Related
- (void)request_StarProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_WatchProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ForkProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ReadMeOFProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FileDiffDetailWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ForkTreeWithOwner:(NSString *)owner_name project:(NSString *)project_name andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Image
- (void)uploadTweetImage:(UIImage *)image
               doneBlock:(void (^)(NSString *imagePath, NSError *error))done
              progerssBlock:(void (^)(CGFloat progressValue))progress;

- (void)request_UpdateUserIconImage:(UIImage *)image
                       successBlock:(void (^)(id responseObj))success
                       failureBlock:(void (^)(NSError *error))failure
                      progerssBlock:(void (^)(CGFloat progressValue))progress;
- (void)loadImageWithPath:(NSString *)imageUrlStr completeBlock:(void (^)(UIImage *image, NSError *error))block;

#pragma mark - Other
- (void)request_Users_WithSearchString:(NSString *)searchStr andBlock:(void (^)(id data, NSError *error))block;
- (void)request_MDHtmlStr_WithMDStr:(NSString *)mdStr inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_VerifyTypeWithBlock:(void (^)(VerifyType type, NSError *error))block;

- (void)request_Users_WithTopicID:(NSInteger)topicID andBlock:(void (^)(id data, NSError *error))block;
- (void)request_JoinedUsers_WithTopicID:(NSInteger)topicID page:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Users_activenessWithGlobalKey:(NSString *)globalKey andBlock:(void (^)(ActivenessModel *data, NSError *error))block;

#pragma mark - 2FA
- (void)post_Close2FAGeneratePhoneCode:(NSString *)phone withCaptcha:(NSString *)captcha block:(void (^)(id data, NSError *error))block;
- (void)post_Close2FAWithPhone:(NSString *)phone code:(NSString *)code block:(void (^)(id data, NSError *error))block;
- (void)get_is2FAOpenBlock:(void (^)(BOOL data, NSError *error))block;

#pragma mark - Topic HotKey
- (void)request_TopicHotkeyWithBlock:(void (^)(id data, NSError *error))block;
#pragma mark - Topic
- (void)request_TopicAdlistWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_HotTopiclistWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_DefautsHotTopicNamelistWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_WithSearchString:(NSString *)strSearch andPage:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block;

- (void)requestWithSearchString:(NSString *)strSearch typeStr:(NSString*)type andPage:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block;

- (void)request_TopicDetailsWithTopicID:(NSInteger)topicID block:(void (^)(id data, NSError *error))block;
- (void)request_TopTweetWithTopicID:(NSInteger)topicID block:(void (^)(id data, NSError *error))block;

- (void)request_JoinedTopicsWithUserGK:(NSString *)userGK page:(NSInteger)page block:(void (^)(id data, BOOL hasMoreData, NSError *error))block;
- (void)request_WatchedTopicsWithUserGK:(NSString *)userGK page:(NSInteger)page block:(void (^)(id data, BOOL hasMoreData, NSError *error))block;

- (void)request_Topic_DoWatch_WithUrl:(NSString *)url andBlock:(void (^)(id data, NSError *error))block;
- (void)request_BannersWithBlock:(void (^)(id data, NSError *error))block;

#pragma mark shop

- (void)request_shop_userPointWithShop:(Shop *)_shop andBlock:(void (^)(id data, NSError *error))block;

- (void)request_shop_giftsWithShop:(Shop *)shop andBlock:(void (^)(id data, NSError *error))block;

- (void)request_shop_bannersWithBlock:(void (^)(id data, NSError *error))block;

- (void)request_shop_OrderListWithOrder:(ShopOrderModel *)_order andBlock:(void (^)(id data, NSError *error))block;


- (void)request_shop_check_passwordWithpwd:(NSString *)pwd andBlock:(void (^)(id data, NSError *error))block;

- (void)request_shop_exchangeWithParms:(NSDictionary *)parms andBlock:(void (^)(id data, NSError *error))block;
- (void)request_shop_orderWithParms:(NSDictionary *)parms andBlock:(void (^)(ShopOrder *shopOrder, NSError *error))block;
- (void)request_shop_payOrder:(NSString *)orderId method:(NSString *)method andBlock:(void (^)(NSDictionary *payDict, NSError *error))block;
- (void)request_shop_deleteOrder:(NSString *)orderId andBlock:(void (^)(id data, NSError *error))block;

- (void)request_LocationListWithParams:(NSDictionary *)params block:(void (^)(id data, NSError *error))block;

@end
