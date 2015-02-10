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

@interface Coding_NetAPIManager : NSObject
+ (instancetype)sharedManager;

//UnRead
- (void)request_UnReadCountWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_UnReadNotificationsWithBlock:(void (^)(id data, NSError *error))block;


//Login
- (void)request_Login_WithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Register_WithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CaptchaNeededWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block;

//Project
- (void)request_Projects_WithObj:(Projects *)projects andBlock:(void (^)(Projects *data, NSError *error))block;
- (void)request_ProjectsHaveTasks_WithObj:(Projects *)projects andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Project_UpdateVisit_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectDetail_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectActivityList_WithObj:(ProjectActivities *)proActs andBlock:(void (^)(NSArray *data, NSError *error))block;
- (void)request_ProjectTaskList_WithObj:(Tasks *)tasks andBlock:(void (^)(Tasks *data, NSError *error))block;
- (void)request_ProjectMembers_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectMembersHaveTasks_WithObj:(Project *)project andBlock:(void (^)(NSArray *data, NSError *error))block;
- (void)request_ProjectMember_Quit:(ProjectMember *)curMember andBlock:(void (^)(id data, NSError *error))block;
//File
- (void)request_Folders:(ProjectFolders *)folders inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_RefreshCountInFolders:(ProjectFolders *)folders inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FilesInFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block;
- (void)request_RenameFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteFile:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block;
- (void)request_MoveFile:(ProjectFile *)file toFolder:(ProjectFolder *)folder andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CreatFolder:(NSString *)fileName inFolder:(ProjectFolder *)parentFolder inProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FileDetail:(ProjectFile *)file andBlock:(void (^)(id data, NSError *error))block;


//Code
- (void)request_CodeTree:(CodeTree *)codeTree withPro:(Project *)project codeTreeBlock:(void (^)(id codeTreeData, NSError *codeTreeError))block;
- (void)request_CodeFile:(CodeFile *)codeFile withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CodeBranchOrTagWithPath:(NSString *)path withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block;

//Task
- (void)request_AddTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditTask:(Task *)task oldTask:(Task *)oldTask andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditTaskContent:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditTaskOwner:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditTaskStatus:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ChandeTaskStatus:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_EditTaskPriority:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_TaskDetail:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CommentListOfTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DoCommentToTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeleteComment:(TaskComment *)comment ofTask:(Task *)task andBlock:(void (^)(id data, NSError *error))block;

//User
- (void)request_AddUser:(User *)user ToProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;

//Topic
- (void)request_ProjectTopicList_WithObj:(ProjectTopics *)proTopics andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectTopic_WithObj:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ModifyProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;
- (void)request_AddProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Comments_WithProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DoComment_WithProjectTpoic:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ProjectTopic_Delete_WithObj:(ProjectTopic *)proTopic andBlock:(void (^)(id data, NSError *error))block;


//Tweet
- (void)request_Tweets_WithObj:(Tweets *)tweets andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoLike_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoComment_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoTweet_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Likers_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Comments_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Delete_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_TweetComment_Delete_WithTweet:(Tweet *)tweet andComment:(Comment *)comment andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Detail_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;



//User
- (void)request_UserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ResetPassword_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FollowersOrFriends_WithObj:(Users *)curUsers andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FollowedOrNot_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_UserJobArrayWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_UserTagArrayWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_UpdateUserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;


//Message
- (void)request_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block;
- (void)request_SendPrivateMessage:(PrivateMessage *)nextMsg andBlock:(void (^)(id data, NSError *error))block;
- (void)request_SendPrivateMessage:(PrivateMessage *)nextMsg andBlock:(void (^)(id data, NSError *error))block progerssBlock:(void (^)(CGFloat progressValue))progress;
- (void)request_CodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block;
- (void)request_markReadWithCodingTip:(NSString *)tipIdStr andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeletePrivateMessage:(PrivateMessage *)curMsg andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeletePrivateMessagesWithObj:(PrivateMessage *)curObj andBlock:(void (^)(id data, NSError *error))block;

//Image
- (void)uploadUserIconImage:(UIImage *)image
       successBlock:(void (^)(NSString *imagePath))success
       failureBlock:(void (^)(NSError *error))failure
      progerssBlock:(void (^)(CGFloat progressValue))progress;

- (void)uploadTweetImage:(UIImage *)image
               doneBlock:(void (^)(NSString *imagePath, NSError *error))done
              progerssBlock:(void (^)(CGFloat progressValue))progress;

- (void)request_UpdateUserIconImage:(UIImage *)image
                       successBlock:(void (^)(id responseObj))success
                       failureBlock:(void (^)(NSError *error))failure
                      progerssBlock:(void (^)(CGFloat progressValue))progress;
- (void)loadImageWithPath:(NSString *)imageUrlStr completeBlock:(void (^)(UIImage *image, NSError *error))block;

//Other
- (void)request_Users_WithSearchString:(NSString *)searchStr andBlock:(void (^)(id data, NSError *error))block;
- (void)request_MDHtmlStr_WithMDStr:(NSString *)mdStr andBlock:(void (^)(id data, NSError *error))block;

@end
