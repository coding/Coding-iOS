//
//  BaseViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ConversationViewController.h"

#import "Login.h"
#import <RegexKitLite/RegexKitLite.h>
#import "UserInfoViewController.h"
#import "TweetDetailViewController.h"
#import "TopicDetailViewController.h"
#import "EditTaskViewController.h"
#import "ProjectViewController.h"
#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"
#import "WebViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
    
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait
        &&![self isMemberOfClass:NSClassFromString(@"CodeViewController")]) {
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
}

- (void)loadView{
    [super loadView];
    
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait
        &&![self isMemberOfClass:NSClassFromString(@"CodeViewController")]) {
        [self forceChangeToOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)tabBarItemClicked{
    NSLog(@"\ntabBarItemClicked : %@", NSStringFromClass([self class]));
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate{
    return UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)forceChangeToOrientation:(UIInterfaceOrientation)interfaceOrientation{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:interfaceOrientation] forKey:@"orientation"];
}

#pragma mark Notification
+ (void)handleNotificationInfo:(NSDictionary *)userInfo{
    //标记为已读
    NSString *notification_id = [userInfo objectForKey:@"notification_id"];
    if (notification_id) {
        [[Coding_NetAPIManager sharedManager] request_markReadWithCodingTip:notification_id andBlock:^(id data, NSError *error) {
            if (error) {
                NSLog(@"request_markReadWithCodingTip: %@", error.description);
            }else{
                NSLog(@"request_markReadWithCodingTip: %@", data);
            }
        }];
    }
    //弹出临时会话
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"handleNotificationInfo : %@", userInfo);
        NSString *param_url = [userInfo objectForKey:@"param_url"];
        [self presentLinkStr:param_url];
    });
}
+ (UIViewController *)analyseVCFromLinkStr:(NSString *)linkStr{
    NSLog(@"\n analyseVCFromLinkStr : %@", linkStr);
    if (!linkStr || linkStr.length <= 0) {
        return nil;
    }else if (![linkStr hasPrefix:@"/"] && ![linkStr hasPrefix:kNetPath_Code_Base]){
        return nil;
    }
    
    UIViewController *analyseVC = nil;

    NSString *userRegexStr = @"/u/([^/]+)$";
    NSString *ppRegexStr = @"/u/([^/]+)/pp/([0-9]+)$";
    NSString *topicRegexStr = @"/u/([^/]+)/p/([^/]+)/topic/(\\d+)";
    NSString *taskRegexStr = @"/u/([^/]+)/p/([^/]+)/task/(\\d+)";
    NSString *projectRegexStr = @"/u/([^/]+)/p/([^/]+)";
    NSString *conversionRegexStr = @"/user/messages/history/([^/]+)$";
    NSArray *matchedCaptures = nil;
    
    if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:userRegexStr]).count > 0) {
        //AT某人
        NSString *user_global_key = matchedCaptures[1];
        UserInfoViewController *vc = [[UserInfoViewController alloc] init];
        vc.curUser = [User userWithGlobalKey:user_global_key];
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:ppRegexStr]).count > 0){
        //冒泡
        NSString *user_global_key = matchedCaptures[1];
        NSString *pp_id = matchedCaptures[2];
        TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
        vc.curTweet = [Tweet tweetWithGlobalKey:user_global_key andPPID:pp_id];
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:topicRegexStr]).count > 0){
        //讨论
        NSString *topic_id = matchedCaptures[3];
        TopicDetailViewController *vc = [[TopicDetailViewController alloc] init];
        vc.curTopic = [ProjectTopic topicWithId:[NSNumber numberWithInteger:topic_id.integerValue]];
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:taskRegexStr]).count > 0){
        //任务
        NSString *user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        NSString *taskId = matchedCaptures[3];
        
        EditTaskViewController *vc = [[EditTaskViewController alloc] init];
        vc.myTask = [Task taskWithBackend_project_path:[NSString stringWithFormat:@"/user/%@/project/%@", user_global_key, project_name] andId:taskId];
        @weakify(vc);
        vc.taskChangedBlock = ^(Task *curTask, TaskEditType type){
            @strongify(vc);
            [vc dismissViewControllerAnimated:YES completion:nil];
        };
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:projectRegexStr]).count > 0){
        //项目
        NSString *user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        Project *curPro = [[Project alloc] init];
        curPro.owner_user_name = user_global_key;
        curPro.name = project_name;
        ProjectViewController *vc = [[ProjectViewController alloc] init];
        vc.myProject = curPro;
        vc.curIndex = 0;
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:conversionRegexStr]).count > 0) {
        //私信
        NSString *user_global_key = matchedCaptures[1];
        ConversationViewController *vc = [[ConversationViewController alloc] init];
        vc.myPriMsgs = [PrivateMessages priMsgsWithUser:[User userWithGlobalKey:user_global_key]];
        analyseVC = vc;
    }
    return analyseVC;
}
+ (void)presentLinkStr:(NSString *)linkStr{
    if (!linkStr || linkStr.length == 0) {
        return;
    }
    UIViewController *vc = [self analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self presentViewController:vc];
    }else{
        //网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self presentViewController:webVc];
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
    return result;
}

+ (void)presentViewController:(UIViewController *)viewController{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissModalViewControllerAnimated:)];
    [[self presentingVC] presentViewController:nav animated:YES completion:nil];
}

#pragma mark Login
- (void)loginOutToLoginVC{
    [Login doLogout];
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setupLoginViewController];
}

@end
