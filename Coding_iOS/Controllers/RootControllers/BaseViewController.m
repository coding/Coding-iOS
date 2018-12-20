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
#import "UserOrProjectTweetsViewController.h"
#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"
#import "WebViewController.h"
#import "RootTabViewController.h"
#import "Message_RootViewController.h"
#import "WikiViewController.h"

#import "ProjectCommitsViewController.h"
#import "PRDetailViewController.h"
#import "CommitFilesViewController.h"
#import "FileViewController.h"
#import "CSTopicDetailVC.h"
#import "CodeViewController.h"
#import "EACodeReleaseViewController.h"
#import "Ease_2FA.h"

#import "Project_RootViewController.h"
#import "MyTask_RootViewController.h"
#import "Tweet_RootViewController.h"
#import "Message_RootViewController.h"
#import "Me_RootViewController.h"
#import "ProjectViewController.h"
#import "EACodeReleaseListViewController.h"
#import "EACodeBranchListViewController.h"
#import "MRPRListViewController.h"
#import "ProjectSettingViewController.h"
#import "CodeListViewController.h"
#import "NFileListViewController.h"
#import "TeamViewController.h"

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
@property (nonatomic ,strong) NSUserActivity *userActivity;

@end

@implementation BaseViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

    if (UIApplication.sharedApplication.statusBarOrientation != UIInterfaceOrientationPortrait
        && !([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeLeft)) {
        [self forceChangeToOrientation:UIInterfaceOrientationPortrait];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
    [_userActivity resignCurrent];
}

- (void)viewDidLoad{
    [super viewDidLoad];
//    self.view.backgroundColor = kColorTableBG;
    self.view.backgroundColor = kColorTableSectionBg;
    
    if (UIApplication.sharedApplication.statusBarOrientation != UIInterfaceOrientationPortrait
        && !([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeLeft)) {
        [self forceChangeToOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Handoff
    [self p_setupUserActivity];
}

- (void)tabBarItemClicked{
    DebugLog(@"\ntabBarItemClicked : %@", NSStringFromClass([self class]));
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate{
    return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation);
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
+ (void)goToVC:(UIViewController *)viewController{
    if (!viewController) {
        return;
    }
    UINavigationController *nav = [self presentingVC].navigationController;
    if (nav) {
        [nav pushViewController:viewController animated:YES];
    }
}

#pragma mark Login
- (void)loginOutToLoginVC{
    [Login doLogout];
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setupLoginViewController];
}


#pragma mark (URL - ViewController) 特么，放在这里放瞎了

#ifdef Target_Enterprise

- (void)p_setupUserActivity{
    NSString *webStr = nil;
    
    //    主 Tab
    if ([self isKindOfClass:Project_RootViewController.class]) {//Project
        webStr = @"/user/projects";
    }else if ([self isKindOfClass:MyTask_RootViewController.class]){//Task
        webStr = [NSString stringWithFormat:@"/user/tasks?owner=%@&status=1", [Login curLoginUser].id];
    }else if ([self isKindOfClass:Message_RootViewController.class]){//Message
        webStr = @"/user/messages/basic";
    }else if ([self isKindOfClass:Me_RootViewController.class]){//User
        webStr = @"/user/account/setting/basic";
        
        //        Project
    }else if ([self isKindOfClass:NProjectViewController.class]){
        Project *curPro = ((NProjectViewController *)self).myProject;
        webStr = [NSString stringWithFormat:@"/p/%@", curPro.name];
    }else if ([self isKindOfClass:ProjectViewController.class]){
        Project *curPro = ((ProjectViewController *)self).myProject;
        ProjectViewType type = ((ProjectViewController *)self).curType;
        NSString *sufStr = (type == ProjectViewTypeTasks? @"/tasks":
                            type == ProjectViewTypeFiles? @"/attachment":
                            type == ProjectViewTypeCodes? @"/git":
                            type == ProjectViewTypeMembers? @"/setting/member":
                            type == ProjectViewTypeActivities? @"":@"");
        webStr = [NSString stringWithFormat:@"/p/%@%@", curPro.name, sufStr];
    }else if ([self isKindOfClass:EACodeBranchListViewController.class]){
        Project *curPro = ((EACodeBranchListViewController *)self).myProject;
        webStr = [NSString stringWithFormat:@"/p/%@/git/branches", curPro.name];
    }else if ([self isKindOfClass:EACodeReleaseListViewController.class]){
        Project *curPro = ((EACodeReleaseListViewController *)self).myProject;
        webStr = [NSString stringWithFormat:@"/p/%@/git/releases", curPro.name];
    }else if ([self isKindOfClass:MRPRListViewController.class]){
        Project *curPro = ((MRPRListViewController *)self).curProject;
        BOOL isMR = ((MRPRListViewController *)self).isMR;
        webStr = [NSString stringWithFormat:@"/p/%@/git/%@", curPro.name, isMR? @"merges": @"pulls/open"];
    }else if ([self isKindOfClass:UserOrProjectTweetsViewController.class]){
        Tweets *curTweets = ((UserOrProjectTweetsViewController *)self).curTweets;
        if (curTweets.tweetType == TweetTypeProject) {
            webStr = [NSString stringWithFormat:@"/p/%@/setting/notice", curTweets.curPro.name];
        }else if (curTweets.tweetType == TweetTypeUserSingle){
            webStr = [NSString stringWithFormat:@"/u/%@/bubble", curTweets.curUser.global_key];
        }
    }else if ([self isKindOfClass:ProjectSettingViewController.class]){
        Project *curPro = ((ProjectSettingViewController *)self).project;
        webStr = [NSString stringWithFormat:@"/p/%@/setting", curPro.name];
        
        //        Task
    }else if ([self isKindOfClass:EditTaskViewController.class]){
        Task *curTask = ((EditTaskViewController *)self).myTask;
        NSString *project_name = [curTask.backend_project_path componentsSeparatedByString:@"/"].lastObject;
        webStr = [NSString stringWithFormat:@"/p/%@/task/%@", project_name, curTask.id];
        
        //        Tweet
    }else if ([self isKindOfClass:TweetDetailViewController.class]){
        Tweet *curTweet = ((TweetDetailViewController *)self).curTweet;
        if (curTweet.isProjectTweet) {
            webStr = [NSString stringWithFormat:@"/p/%@/setting/notice/%@", curTweet.project.name, curTweet.id];
        }else{
            webStr = [NSString stringWithFormat:@"/u/%@/pp/%@", curTweet.user_global_key ?: curTweet.owner.global_key, curTweet.id];
        }
        
        //        Message
    }else if ([self isKindOfClass:ConversationViewController.class]){
        PrivateMessages *curPriMs = ((ConversationViewController *)self).myPriMsgs;
        webStr = [NSString stringWithFormat:@"/user/messages/history/%@", curPriMs.curFriend.global_key];
        
        //        User
    }else if ([self isKindOfClass:UserInfoViewController.class]){
        User *curU = ((UserInfoViewController *)self).curUser;
        webStr = [NSString stringWithFormat:@"/u/%@", curU.global_key];
        
        //        Topic/File/MR/Code/Wiki/Release
    }else if ([self isKindOfClass:FileViewController.class]){
        ProjectFile *curFile = ((FileViewController *)self).curFile;
        if (curFile.project_owner_name && curFile.project_name) {
            webStr = curFile.owner_preview;
        }else if (curFile.owner_preview){
            webStr = [NSString stringWithFormat:@"/p/%@/attachment/default/preview/%@", curFile.project_name, curFile.file_id];
        }
    }else if ([self isKindOfClass:MRDetailViewController.class] || [self isKindOfClass:PRDetailViewController.class]){
        MRPR *curMRPR = [self valueForKey:@"curMRPR"];
        NSString *path = curMRPR.path;
        NSRange range = [path rangeOfString:@"/p/"];
        webStr = range.location == NSNotFound? path: [path substringFromIndex:range.location];
    }else if ([self isKindOfClass:CodeViewController.class]){
        Project *curPro = ((CodeViewController *) self).myProject;
        CodeFile *curCF = ((CodeViewController *) self).myCodeFile;
        webStr = [NSString stringWithFormat:@"/p/%@/git/blob/%@/%@", curPro.name, curCF.ref, curCF.path];
    }else if ([self isKindOfClass:WikiViewController.class]){
        WikiViewController *vc = (WikiViewController *)self;
        webStr = [NSString stringWithFormat:@"/p/%@/wiki", vc.myProject.name];
        if (vc.iid) {
            webStr = [webStr stringByAppendingFormat:@"/%@", vc.iid];
            if (vc.version.integerValue > 0) {
                webStr = [webStr stringByAppendingFormat:@"?version=%@", vc.version];
            }
        }
    }else if ([self isKindOfClass:EACodeReleaseViewController.class]){
        EACodeRelease *curR = ((EACodeReleaseViewController *)self).curRelease;
        webStr = [NSString stringWithFormat:@"/p/%@/git/releases/%@", curR.project.name, curR.tag_name];
        
        //        CodeList/FileList/Webview
    }else if ([self isKindOfClass:CodeListViewController.class]){
        Project *curPro = ((CodeListViewController *) self).myProject;
        CodeTree *curCT = ((CodeListViewController *) self).myCodeTree;
        webStr = [NSString stringWithFormat:@"/p/%@/git/tree/%@/%@", curPro.name, curCT.ref, curCT.path];
    }else if ([self isKindOfClass:NFileListViewController.class]){
        Project *curPro = ((NFileListViewController *) self).curProject;
        ProjectFile *curPF = ((NFileListViewController *) self).curFolder;
        webStr = [NSString stringWithFormat:@"/p/%@/attachment/%@", curPro.name, curPF.file_id];
    }else if ([self isKindOfClass:WebViewController.class]){
        webStr = ((WebViewController *)self).request.URL.absoluteString;
    }
    
    if (webStr) {
        NSURL *webURL = nil;
        if (![webStr hasPrefix:@"http"]) {
            webURL = [NSURL URLWithString:webStr relativeToURL:[NSURL URLWithString:[NSObject baseURLStr]]];
        }else{
            webURL = [NSURL URLWithString:webStr];
        }
        if (!_userActivity) {
            _userActivity = [[NSUserActivity alloc]initWithActivityType:@"com.alex.handoffdemo"];
            _userActivity.title = @"CODING_ENTERPRISE";
        }
        [_userActivity setWebpageURL:webURL];
        [_userActivity becomeCurrent];
    }
}

+ (UIViewController *)analyseVCFromLinkStr:(NSString *)linkStr analyseMethod:(AnalyseMethodType)methodType isNewVC:(BOOL *)isNewVC{
    DebugLog(@"\n analyseVCFromLinkStr : %@", linkStr);
    
    NSString *lowerLinkStr = linkStr.lowercaseString;
    if (!linkStr || linkStr.length <= 0) {
        return nil;
    }else if (!([linkStr hasPrefix:@"/"] ||
                [lowerLinkStr hasPrefix:kCodingAppScheme] ||
                [lowerLinkStr hasPrefix:kBaseUrlStr_Phone] ||
                [lowerLinkStr hasPrefix:[NSObject baseURLStr].lowercaseString] ||
                [lowerLinkStr hasPrefix:@"https://coding.net"])){//兼容一下先
        return nil;
    }
    NSRange pRange = [linkStr rangeOfString:@"/p/"];
    if (pRange.location != NSNotFound &&
        [linkStr rangeOfString:@"/u/"].location == NSNotFound &&
        [linkStr rangeOfString:@"/t/"].location == NSNotFound) {//强填 u
        NSString *defaultTeamStr = [NSString stringWithFormat:@"/u/%@", [Login curLoginCompany].global_key ?: [NSObject baseCompany]];
        linkStr = [linkStr stringByReplacingCharactersInRange:NSMakeRange(pRange.location, 0) withString:defaultTeamStr];
    }
    UIViewController *analyseVC = nil;
    UIViewController *presentingVC = nil;
    BOOL analyseVCIsNew = YES;
    if (methodType != AnalyseMethodTypeForceCreate) {
        presentingVC = [BaseViewController presentingVC];
    }
    
    NSString *teamRegexStr = @"/t/([^/]+)$";//AT某人
    NSString *userRegexStr = @"/u/([^/]+)$";//AT某人
    //    NSString *userTweetRegexStr = @"/u/([^/]+)/bubble$";//某人的冒泡
    //    NSString *ppRegexStr = @"/u/([^/]+)/pp/([0-9]+)";//冒泡
    NSString *pp_projectRegexStr = @"/[ut]/([^/]+)/p/([^\?]+)[\?]pp=([0-9]+)$";//项目内冒泡(含团队项目)
    NSString *topicRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/topic/(\\d+)";//讨论(含团队项目)
    NSString *taskRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/task/(\\d+)";//任务(含团队项目)
    NSString *fileRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/attachment/([^/]+)/preview/(\\d+)";//文件(含团队项目)
    NSString *gitMRPRCommitRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/git/(merge|pull|commit)/([^/#]+)";//MR(含团队项目)
    NSString *conversionRegexStr = @"/user/messages/history/([^/]+)$";//私信
    //    NSString *pp_topicRegexStr = @"/pp/topic/([0-9]+)$";//话题
    NSString *codeRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/git/blob/([^/]+)[/]?([^?]*)";//代码(含团队项目)
    NSString *twoFARegexStr = @"/app_intercept/show_2fa";//两步验证
    NSString *projectRegexStr = @"/[ut]/([^/]+)/p/([^/]+)";//项目(含团队项目)
    NSString *noticeRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/setting/notice/(\\d+)";//项目公告
    NSString *wikiRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/wiki/(\\d+)";//Wiki
    NSString *releaseRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/git/releases/([^/]+)[/]?([^?]*)";//Release
    NSArray *matchedCaptures = nil;
    
    if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:teamRegexStr]).count > 0) {
        //团队
        TeamViewController *vc = [TeamViewController new];
        NSString *team_global_key = matchedCaptures[1];
        vc.curTeam = [Team teamWithGK:team_global_key];
        analyseVC = vc;
    }else if ([linkStr hasSuffix:@"/admin"]){
        //企业
        TeamViewController *vc = [TeamViewController new];
        NSString *team_global_key = [NSObject baseCompany];
        vc.curTeam = [Team teamWithGK:team_global_key];
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:noticeRegexStr]).count > 0){
        //项目公告
        NSString *owner_user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        NSString *pp_id = matchedCaptures[3];
        Project *curPro = [Project new];
        curPro.owner_user_name = owner_user_global_key;
        curPro.name = project_name;
        TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
        vc.curTweet = [Tweet tweetInProject:curPro andPPID:pp_id];
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:wikiRegexStr]).count > 0){
        WikiViewController *vc = [WikiViewController new];
        Project *curPro = [Project new];
        curPro.owner_user_name = matchedCaptures[1];
        curPro.name = matchedCaptures[2];
        NSString *iid = matchedCaptures[3];
        vc.myProject = curPro;
        [vc setWikiIid:@(iid.integerValue) version:nil];
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:releaseRegexStr]).count > 0){
        EACodeReleaseViewController *vc = [EACodeReleaseViewController new];
        Project *curPro = [Project new];
        curPro.owner_user_name = matchedCaptures[1];
        curPro.name = matchedCaptures[2];
        EACodeRelease *curR = [EACodeRelease new];
        curR.project = curPro;
        curR.tag_name = matchedCaptures[3];
        vc.curRelease = curR;
        analyseVC = vc;
        //    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:ppRegexStr]).count > 0){
        //        //冒泡
        //        NSString *user_global_key = matchedCaptures[1];
        //        NSString *pp_id = matchedCaptures[2];
        //        if ([presentingVC isKindOfClass:[TweetDetailViewController class]]) {
        //            TweetDetailViewController *vc = (TweetDetailViewController *)presentingVC;
        //            if ([vc.curTweet.id.stringValue isEqualToString:pp_id]
        //                && [vc.curTweet.owner.global_key isEqualToString:user_global_key]) {
        //                [vc refreshTweet];
        //                analyseVCIsNew = NO;
        //                analyseVC = vc;
        //            }
        //        }
        //        if (!analyseVC) {
        //            TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
        //            vc.curTweet = [Tweet tweetWithGlobalKey:user_global_key andPPID:pp_id];
        //            analyseVC = vc;
        //        }
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
        
//        NSString *defaultTeamStr = [NSString stringWithFormat:@"/u/%@", [Login curLoginCompany].global_key ?: [NSObject baseCompany]];
//        linkStr = [linkStr stringByReplacingCharactersInRange:NSMakeRange(pRange.location, 0) withString:defaultTeamStr];
        
        
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
            UserInfoDetailViewController *vc = [UserInfoDetailViewController new];
            vc.curUser = [User userWithGlobalKey:user_global_key];
            analyseVC = vc;
            //        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:userTweetRegexStr]).count > 0){
            //            //某人的冒泡
            //            UserOrProjectTweetsViewController *vc = [[UserOrProjectTweetsViewController alloc] init];
            //            NSString *user_global_key = matchedCaptures[1];
            //            vc.curTweets = [Tweets tweetsWithUser:[User userWithGlobalKey:user_global_key]];
            //            analyseVC = vc;
            //        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:pp_topicRegexStr]).count > 0){
            //            //话题
            //            NSString *pp_topic_id = matchedCaptures[1];
            //            CSTopicDetailVC *vc = [CSTopicDetailVC new];
            //            vc.topicID = pp_topic_id.integerValue;
            //            analyseVC = vc;
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

#else

- (void)p_setupUserActivity{
    NSString *webStr = nil;
    
    //    主 Tab
    if ([self isKindOfClass:Project_RootViewController.class]) {//Project
        webStr = @"/user/projects";
    }else if ([self isKindOfClass:MyTask_RootViewController.class]){//Task
        webStr = [NSString stringWithFormat:@"/user/tasks?owner=%@&status=1", [Login curLoginUser].id];
    }else if ([self isKindOfClass:Tweet_RootViewController.class]){//Tweet
        Tweet_RootViewControllerType type = ((Tweet_RootViewController *)self).type;
        webStr = [NSString stringWithFormat:@"/pp%@", (type == Tweet_RootViewControllerTypeHot? @"/hot":
                                                       type == Tweet_RootViewControllerTypeFriend? @"/friends":
                                                       @"")];
    }else if ([self isKindOfClass:Message_RootViewController.class]){//Message
        webStr = @"/user/messages/basic";
    }else if ([self isKindOfClass:Me_RootViewController.class]){//User
        webStr = @"/user/account";
        
        //        Project
    }else if ([self isKindOfClass:NProjectViewController.class]){
        Project *curPro = ((NProjectViewController *)self).myProject;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@", curPro.owner_user_name, curPro.name];
    }else if ([self isKindOfClass:ProjectViewController.class]){
        Project *curPro = ((ProjectViewController *)self).myProject;
        ProjectViewType type = ((ProjectViewController *)self).curType;
        NSString *sufStr = (type == ProjectViewTypeTasks? @"/tasks":
                            type == ProjectViewTypeFiles? @"/attachment":
                            type == ProjectViewTypeTopics? @"/topics":
                            type == ProjectViewTypeCodes? @"/git":
                            type == ProjectViewTypeMembers? @"/setting/member":
                            type == ProjectViewTypeActivities? @"":@"");
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@%@", curPro.owner_user_name, curPro.name, sufStr];
    }else if ([self isKindOfClass:EACodeBranchListViewController.class]){
        Project *curPro = ((EACodeBranchListViewController *)self).myProject;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@/git/branches", curPro.owner_user_name, curPro.name];
    }else if ([self isKindOfClass:EACodeReleaseListViewController.class]){
        Project *curPro = ((EACodeReleaseListViewController *)self).myProject;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@/git/releases", curPro.owner_user_name, curPro.name];
    }else if ([self isKindOfClass:MRPRListViewController.class]){
        Project *curPro = ((MRPRListViewController *)self).curProject;
        BOOL isMR = ((MRPRListViewController *)self).isMR;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@/git/%@", curPro.owner_user_name, curPro.name, isMR? @"merges": @"pulls/open"];
    }else if ([self isKindOfClass:UserOrProjectTweetsViewController.class]){
        Tweets *curTweets = ((UserOrProjectTweetsViewController *)self).curTweets;
        if (curTweets.tweetType == TweetTypeProject) {
            webStr = [NSString stringWithFormat:@"/u/%@/p/%@/setting/notice", curTweets.curPro.owner_user_name, curTweets.curPro.name];
        }else if (curTweets.tweetType == TweetTypeUserSingle){
            webStr = [NSString stringWithFormat:@"/u/%@/bubble", curTweets.curUser.global_key];
        }
    }else if ([self isKindOfClass:ProjectSettingViewController.class]){
        Project *curPro = ((ProjectSettingViewController *)self).project;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@/setting", curPro.owner_user_name, curPro.name];
        
        //        Task
    }else if ([self isKindOfClass:EditTaskViewController.class]){
        Task *curTask = ((EditTaskViewController *)self).myTask;
        NSString *project_path = curTask.backend_project_path.copy;
        project_path = [[project_path stringByReplacingOccurrencesOfString:@"/user/" withString:@"/u/"] stringByReplacingOccurrencesOfString:@"/project/" withString:@"/p/"];
        webStr = [NSString stringWithFormat:@"%@/task/%@", project_path, curTask.id];
        
        //        Tweet
    }else if ([self isKindOfClass:TweetDetailViewController.class]){
        Tweet *curTweet = ((TweetDetailViewController *)self).curTweet;
        if (curTweet.isProjectTweet) {
            webStr = [NSString stringWithFormat:@"/u/%@/p/%@/setting/notice/%@", curTweet.project.owner_user_name, curTweet.project.name, curTweet.id];
        }else{
            webStr = [NSString stringWithFormat:@"/u/%@/pp/%@", curTweet.user_global_key ?: curTweet.owner.global_key, curTweet.id];
        }
        
        //        Message
    }else if ([self isKindOfClass:ConversationViewController.class]){
        PrivateMessages *curPriMs = ((ConversationViewController *)self).myPriMsgs;
        webStr = [NSString stringWithFormat:@"/user/messages/history/%@", curPriMs.curFriend.global_key];
        
        //        User
    }else if ([self isKindOfClass:UserInfoViewController.class]){
        User *curU = ((UserInfoViewController *)self).curUser;
        webStr = [NSString stringWithFormat:@"/u/%@", curU.global_key];
        
        //        Topic/File/MR/Code/Wiki/Release
    }else if ([self isKindOfClass:TopicDetailViewController.class]){
        ProjectTopic *curTopic = ((TopicDetailViewController *)self).curTopic;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@/topic/%@", curTopic.project.owner_user_name, curTopic.project.name, curTopic.id];
    }else if ([self isKindOfClass:FileViewController.class]){
        ProjectFile *curFile = ((FileViewController *)self).curFile;
        if (curFile.project_owner_name && curFile.project_name) {
            webStr = curFile.owner_preview;
        }else if (curFile.owner_preview){
            webStr = [NSString stringWithFormat:@"/u/%@/p/%@/attachment/default/preview/%@", curFile.project_owner_name, curFile.project_name, curFile.file_id];
        }
    }else if ([self isKindOfClass:MRDetailViewController.class] || [self isKindOfClass:PRDetailViewController.class]){
        MRPR *curMRPR = [self valueForKey:@"curMRPR"];
        webStr = curMRPR.path;
    }else if ([self isKindOfClass:CodeViewController.class]){
        Project *curPro = ((CodeViewController *) self).myProject;
        CodeFile *curCF = ((CodeViewController *) self).myCodeFile;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@/git/blob/%@/%@", curPro.owner_user_name, curPro.name, curCF.ref, curCF.path];
    }else if ([self isKindOfClass:WikiViewController.class]){
        WikiViewController *vc = (WikiViewController *)self;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@/wiki", vc.myProject.owner_user_name, vc.myProject.name];
        if (vc.iid) {
            webStr = [webStr stringByAppendingFormat:@"/%@", vc.iid];
            if (vc.version.integerValue > 0) {
                webStr = [webStr stringByAppendingFormat:@"?version=%@", vc.version];
            }
        }
    }else if ([self isKindOfClass:EACodeReleaseViewController.class]){
        EACodeRelease *curR = ((EACodeReleaseViewController *)self).curRelease;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@/git/releases/%@", curR.project.owner_user_name, curR.project.name, curR.tag_name];
        
        //        CodeList/FileList/Webview
    }else if ([self isKindOfClass:CodeListViewController.class]){
        Project *curPro = ((CodeListViewController *) self).myProject;
        CodeTree *curCT = ((CodeListViewController *) self).myCodeTree;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@/git/tree/%@/%@", curPro.owner_user_name, curPro.name, curCT.ref, curCT.path];
    }else if ([self isKindOfClass:NFileListViewController.class]){
        Project *curPro = ((NFileListViewController *) self).curProject;
        ProjectFile *curPF = ((NFileListViewController *) self).curFolder;
        webStr = [NSString stringWithFormat:@"/u/%@/p/%@/attachment/%@", curPro.owner_user_name, curPro.name, curPF.file_id];
    }else if ([self isKindOfClass:WebViewController.class]){
        webStr = ((WebViewController *)self).request.URL.absoluteString;
    }
    
    if (webStr) {
        NSURL *webURL = nil;
        if (![webStr hasPrefix:@"http"]) {
            webURL = [NSURL URLWithString:webStr relativeToURL:[NSURL URLWithString:[NSObject baseURLStr]]];
        }else{
            webURL = [NSURL URLWithString:webStr];
        }
        if (!_userActivity) {
            _userActivity = [[NSUserActivity alloc]initWithActivityType:@"com.alex.handoffdemo"];
            _userActivity.title = @"CODING";
        }
        [_userActivity setWebpageURL:webURL];
        [_userActivity becomeCurrent];
    }
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
    NSString *noticeRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/setting/notice/(\\d+)";//项目公告
    NSString *wikiRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/wiki/(\\d+)";//Wiki
    NSString *releaseRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/git/releases/([^/]+)[/]?([^?]*)";//Release
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
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:noticeRegexStr]).count > 0){
        //项目公告
        NSString *owner_user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        NSString *pp_id = matchedCaptures[3];
        Project *curPro = [Project new];
        curPro.owner_user_name = owner_user_global_key;
        curPro.name = project_name;
        TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
        vc.curTweet = [Tweet tweetInProject:curPro andPPID:pp_id];
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:wikiRegexStr]).count > 0){
        WikiViewController *vc = [WikiViewController new];
        Project *curPro = [Project new];
        curPro.owner_user_name = matchedCaptures[1];
        curPro.name = matchedCaptures[2];
        NSString *iid = matchedCaptures[3];
        vc.myProject = curPro;
        [vc setWikiIid:@(iid.integerValue) version:nil];
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:releaseRegexStr]).count > 0){
        EACodeReleaseViewController *vc = [EACodeReleaseViewController new];
        Project *curPro = [Project new];
        curPro.owner_user_name = matchedCaptures[1];
        curPro.name = matchedCaptures[2];
        EACodeRelease *curR = [EACodeRelease new];
        curR.project = curPro;
        curR.tag_name = matchedCaptures[3];
        vc.curRelease = curR;
        analyseVC = vc;
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
            ProjectTopic *curTopic = [ProjectTopic topicWithId:[NSNumber numberWithInteger:topic_id.integerValue]];
            Project *curPro = [[Project alloc] init];
            curPro.owner_user_name = matchedCaptures[1];
            curPro.name = matchedCaptures[2];
            curTopic.project = curPro;
            vc.curTopic = curTopic;
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
            UserOrProjectTweetsViewController *vc = [[UserOrProjectTweetsViewController alloc] init];
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

#endif

@end
