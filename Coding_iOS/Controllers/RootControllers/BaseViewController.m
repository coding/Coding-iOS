//
//  BaseViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ConversationViewController.h"
#import "MRDetailViewController.h"

#import "Login.h"
#import <RegexKitLite-NoWarning/RegexKitLite.h>
#import "UserInfoViewController.h"
#import "TweetDetailViewController.h"
#import "TopicDetailViewController.h"
#import "EditTaskViewController.h"
#import "ProjectViewController.h"
#import "NProjectViewController.h"
#import "UserTweetsViewController.h"
#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"
#import "WebViewController.h"
#import "RootTabViewController.h"
#import "Message_RootViewController.h"

#import "ProjectCommitsViewController.h"
#import "PRDetailViewController.h"
#import "CommitFilesViewController.h"
#import "FileViewController.h"
#import "CSTopicDetailVC.h"
#import "CodeViewController.h"
#import "Ease_2FA.h"

#import "UnReadManager.h"

typedef NS_ENUM(NSInteger, AnalyseMethodType) {
    AnalyseMethodTypeJustRefresh = 0,
    AnalyseMethodTypeLazyCreate,
    AnalyseMethodTypeForceCreate
};

#pragma mark - UIViewController (Dismiss)
@interface UIViewController (Dismiss)
- (void)dismissModalVC;
@end
@implementation UIViewController (Dismiss)
- (void)dismissModalVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

#pragma mark - BaseViewController

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    if (self.interfaceOrientation != UIInterfaceOrientationPortrait
        && !([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeLeft)) {
        [self forceChangeToOrientation:UIInterfaceOrientationPortrait];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = kColorTableBG;
    
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait
        && !([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeLeft)) {
        [self forceChangeToOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)tabBarItemClicked{
    DebugLog(@"\ntabBarItemClicked : %@", NSStringFromClass([self class]));
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate{
    return UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)forceChangeToOrientation:(UIInterfaceOrientation)interfaceOrientation{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:interfaceOrientation] forKey:@"orientation"];
}

#pragma mark Notification
+ (void)handleNotificationInfo:(NSDictionary *)userInfo applicationState:(UIApplicationState)applicationState{
    if (applicationState == UIApplicationStateInactive) {
        //If the application state was inactive, this means the user pressed an action button from a notification.
        //标记为已读
        NSString *notification_id = [userInfo objectForKey:@"notification_id"];
        if (notification_id) {
            [[Coding_NetAPIManager sharedManager] request_markReadWithCodingTipIdStr:notification_id andBlock:^(id data, NSError *error) {
            }];
        }
        //弹出临时会话
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DebugLog(@"handleNotificationInfo : %@", userInfo);
            NSString *param_url = [userInfo objectForKey:@"param_url"];
            [self presentLinkStr:param_url];
        });
    }else if (applicationState == UIApplicationStateActive){
        NSString *param_url = [userInfo objectForKey:@"param_url"];
        [self analyseVCFromLinkStr:param_url analyseMethod:AnalyseMethodTypeJustRefresh isNewVC:nil];//AnalyseMethodTypeJustRefresh
        //标记未读
        UIViewController *presentingVC = [BaseViewController presentingVC];
        if ([presentingVC isKindOfClass:[Message_RootViewController class]]) {
            [(Message_RootViewController *)presentingVC refresh];
        }
        [[UnReadManager shareManager] updateUnRead];
    }
}

+ (UIViewController *)analyseVCFromLinkStr:(NSString *)linkStr{
    return [self analyseVCFromLinkStr:linkStr analyseMethod:AnalyseMethodTypeForceCreate isNewVC:nil];
}

+ (UIViewController *)analyseVCFromLinkStr:(NSString *)linkStr analyseMethod:(AnalyseMethodType)methodType isNewVC:(BOOL *)isNewVC{
    DebugLog(@"\n analyseVCFromLinkStr : %@", linkStr);
    
    if (!linkStr || linkStr.length <= 0) {
        return nil;
    }else if (!([linkStr hasPrefix:@"/"] ||
                [linkStr hasPrefix:kCodingAppScheme] ||
                [linkStr hasPrefix:kBaseUrlStr_Phone] ||
                [linkStr hasPrefix:[NSObject baseURLStr]])){
        return nil;
    }
    
    UIViewController *analyseVC = nil;
    UIViewController *presentingVC = nil;
    BOOL analyseVCIsNew = YES;
    if (methodType != AnalyseMethodTypeForceCreate) {
        presentingVC = [BaseViewController presentingVC];
    }
    
    NSString *userRegexStr = @"/u/([^/]+)$";//AT某人
    NSString *userTweetRegexStr = @"/u/([^/]+)/bubble$";//某人的冒泡
    NSString *ppRegexStr = @"/u/([^/]+)/pp/([0-9]+)";//冒泡
    NSString *pp_projectRegexStr = @"/[ut]/([^/]+)/p/([^\?]+)[\?]pp=([0-9]+)$";//项目内冒泡(含团队项目)
    NSString *topicRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/topic/(\\d+)";//讨论(含团队项目)
    NSString *taskRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/task/(\\d+)";//任务(含团队项目)
    NSString *fileRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/attachment/([^/]+)/preview/(\\d+)";//文件(含团队项目)
    NSString *gitMRPRCommitRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/git/(merge|pull|commit)/([^/#]+)";//MR(含团队项目)
    NSString *conversionRegexStr = @"/user/messages/history/([^/]+)$";//私信
    NSString *pp_topicRegexStr = @"/pp/topic/([0-9]+)$";//话题
    NSString *codeRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/git/blob/([^/]+)[/]?([^?]*)";//代码(含团队项目)
    NSString *twoFARegexStr = @"/app_intercept/show_2fa";//两步验证
    NSString *projectRegexStr = @"/[ut]/([^/]+)/p/([^/]+)";//项目(含团队项目)
    NSArray *matchedCaptures = nil;
    if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:ppRegexStr]).count > 0){
        //冒泡
        NSString *user_global_key = matchedCaptures[1];
        NSString *pp_id = matchedCaptures[2];
        if ([presentingVC isKindOfClass:[TweetDetailViewController class]]) {
            TweetDetailViewController *vc = (TweetDetailViewController *)presentingVC;
            if ([vc.curTweet.id.stringValue isEqualToString:pp_id]
                && [vc.curTweet.owner.global_key isEqualToString:user_global_key]) {
                [vc refreshTweet];
                analyseVCIsNew = NO;
                analyseVC = vc;
            }
        }
        if (!analyseVC) {
            TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
            vc.curTweet = [Tweet tweetWithGlobalKey:user_global_key andPPID:pp_id];
            analyseVC = vc;
        }
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:pp_projectRegexStr]).count > 0){
        //项目内冒泡
        NSString *owner_user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        NSString *pp_id = matchedCaptures[3];
        Project *curPro = [Project new];
        curPro.owner_user_name = owner_user_global_key;
        curPro.name = project_name;
        TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
        vc.curTweet = [Tweet tweetInProject:curPro andPPID:pp_id];
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:gitMRPRCommitRegexStr]).count > 0){
        //MR
        NSString *path = [matchedCaptures[0] stringByReplacingOccurrencesOfString:@"https://coding.net" withString:@""];
        
        if ([matchedCaptures[3] isEqualToString:@"commit"]) {
            if ([presentingVC isKindOfClass:[CommitFilesViewController class]]) {
                CommitFilesViewController *vc = (CommitFilesViewController *)presentingVC;
                if ([vc.commitId isEqualToString:matchedCaptures[3]] &&
                    [vc.projectName isEqualToString:matchedCaptures[2]] &&
                    [vc.ownerGK isEqualToString:matchedCaptures[1]]) {
                    [vc refresh];
                    analyseVCIsNew = NO;
                    analyseVC = vc;
                }
            }
            if (!analyseVC) {
                analyseVC = [CommitFilesViewController vcWithPath:path];
            }
        }else{
            if ([presentingVC isKindOfClass:[PRDetailViewController class]]) {
                PRDetailViewController *vc = (PRDetailViewController *)presentingVC;
                if ([vc.curMRPR.path isEqualToString:path]) {
                    [vc refresh];
                    analyseVCIsNew = NO;
                    analyseVC = vc;
                }
            }
            if (!analyseVC) {
                if([path rangeOfString:@"merge"].location == NSNotFound) {
                     analyseVC = [PRDetailViewController vcWithPath:path];
                } else {
                    analyseVC = [MRDetailViewController vcWithPath:path];
                }
            }
        }
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:topicRegexStr]).count > 0){
        //讨论
        NSString *topic_id = matchedCaptures[3];
        if ([presentingVC isKindOfClass:[TopicDetailViewController class]]) {
            TopicDetailViewController *vc = (TopicDetailViewController *)presentingVC;
            if ([vc.curTopic.id.stringValue isEqualToString:topic_id]) {
                [vc refreshTopic];
                analyseVCIsNew = NO;
                analyseVC = vc;
            }
        }
        if (!analyseVC) {
            TopicDetailViewController *vc = [[TopicDetailViewController alloc] init];
            vc.curTopic = [ProjectTopic topicWithId:[NSNumber numberWithInteger:topic_id.integerValue]];
            analyseVC = vc;
        }
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:taskRegexStr]).count > 0){
        //任务
        NSString *user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        NSString *taskId = matchedCaptures[3];
        NSString *backend_project_path = [NSString stringWithFormat:@"/user/%@/project/%@", user_global_key, project_name];
        if ([presentingVC isKindOfClass:[EditTaskViewController class]]) {
            EditTaskViewController *vc = (EditTaskViewController *)presentingVC;
            if ([vc.myTask.backend_project_path isEqualToString:backend_project_path]
                && [vc.myTask.id.stringValue isEqualToString:taskId]) {
                [vc queryToRefreshTaskDetail];
                analyseVCIsNew = NO;
                analyseVC = vc;
            }
        }
        if (!analyseVC) {
            EditTaskViewController *vc = [[EditTaskViewController alloc] init];
            vc.myTask = [Task taskWithBackend_project_path:[NSString stringWithFormat:@"/user/%@/project/%@", user_global_key, project_name] andId:taskId];
            @weakify(vc);
            vc.taskChangedBlock = ^(){
                @strongify(vc);
                [vc dismissViewControllerAnimated:YES completion:nil];
            };
            analyseVC = vc;
        }
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:fileRegexStr]).count > 0){
        //文件
        NSString *user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        NSString *fileId = matchedCaptures[4];
        if ([presentingVC isKindOfClass:[FileViewController class]]) {
            FileViewController *vc = (FileViewController *)presentingVC;
            if (vc.curFile.file_id.integerValue == fileId.integerValue) {
                [vc requestFileData];
                analyseVCIsNew = NO;
                analyseVC = vc;
            }
        }
        if (!analyseVC) {
            ProjectFile *curFile = [[ProjectFile alloc] initWithFileId:@(fileId.integerValue) inProject:project_name ofUser:user_global_key];
            FileViewController *vc = [FileViewController vcWithFile:curFile andVersion:nil];
            analyseVC = vc;
        }
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:conversionRegexStr]).count > 0) {
        //私信
        NSString *user_global_key = matchedCaptures[1];
        if ([presentingVC isKindOfClass:[ConversationViewController class]]) {
            ConversationViewController *vc = (ConversationViewController *)presentingVC;
            if ([vc.myPriMsgs.curFriend.global_key isEqualToString:user_global_key]) {
                [vc doPoll];
                analyseVCIsNew = NO;
                analyseVC = vc;
            }
        }
        if (!analyseVC) {
            ConversationViewController *vc = [[ConversationViewController alloc] init];
            vc.myPriMsgs = [PrivateMessages priMsgsWithUser:[User userWithGlobalKey:user_global_key]];
            analyseVC = vc;
        }
    }else if (methodType != AnalyseMethodTypeJustRefresh){
        if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:userRegexStr]).count > 0) {
            //AT某人
            NSString *user_global_key = matchedCaptures[1];
            UserInfoViewController *vc = [[UserInfoViewController alloc] init];
            vc.curUser = [User userWithGlobalKey:user_global_key];
            analyseVC = vc;
        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:userTweetRegexStr]).count > 0){
            //某人的冒泡
            UserTweetsViewController *vc = [[UserTweetsViewController alloc] init];
            NSString *user_global_key = matchedCaptures[1];
            vc.curTweets = [Tweets tweetsWithUser:[User userWithGlobalKey:user_global_key]];
            analyseVC = vc;
        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:pp_topicRegexStr]).count > 0){
            //话题
            NSString *pp_topic_id = matchedCaptures[1];
            CSTopicDetailVC *vc = [CSTopicDetailVC new];
            vc.topicID = pp_topic_id.integerValue;
            analyseVC = vc;
        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:codeRegexStr]).count > 0){
            //代码
            NSString *user_global_key = matchedCaptures[1];
            NSString *project_name = matchedCaptures[2];
            NSString *ref = matchedCaptures[3];
            NSString *path = matchedCaptures.count >= 5? matchedCaptures[4]: @"";
            
            Project *curPro = [[Project alloc] init];
            curPro.owner_user_name = user_global_key;
            curPro.name = project_name;
            CodeFile *codeFile = [CodeFile codeFileWithRef:ref andPath:path];
            CodeViewController *vc = [CodeViewController codeVCWithProject:curPro andCodeFile:codeFile];
            analyseVC = vc;
        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:twoFARegexStr]).count > 0){
            //两步验证
            analyseVC = [OTPListViewController new];
        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:projectRegexStr]).count > 0){
            //项目
            NSString *user_global_key = matchedCaptures[1];
            NSString *project_name = matchedCaptures[2];
            Project *curPro = [[Project alloc] init];
            curPro.owner_user_name = user_global_key;
            curPro.name = project_name;
            NProjectViewController *vc = [[NProjectViewController alloc] init];
            vc.myProject = curPro;
            analyseVC = vc;
        }
    }
    if (isNewVC) {
        *isNewVC = analyseVCIsNew;
    }
    return analyseVC;
}

+ (void)presentLinkStr:(NSString *)linkStr{
    if (!linkStr || linkStr.length == 0) {
        return;
    }
    BOOL isNewVC = YES;
    UIViewController *vc = [self analyseVCFromLinkStr:linkStr analyseMethod:AnalyseMethodTypeLazyCreate isNewVC:&isNewVC];
    if (vc && isNewVC) {
        [self presentVC:vc];
    }else if (!vc){
        if (![linkStr hasPrefix:kCodingAppScheme]) {
            //网页
            WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
            [self presentVC:webVc];
        }
    }
}

+ (UIViewController *)presentingVC{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[RootTabViewController class]]) {
        result = [(RootTabViewController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}

+ (void)presentVC:(UIViewController *)viewController{
    if (!viewController) {
        return;
    }
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:viewController];
    if (!viewController.navigationItem.leftBarButtonItem) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissModalVC)];
    }
    [[self presentingVC] presentViewController:nav animated:YES completion:nil];
}

#pragma mark Login
- (void)loginOutToLoginVC{
    [Login doLogout];
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setupLoginViewController];
}

@end
