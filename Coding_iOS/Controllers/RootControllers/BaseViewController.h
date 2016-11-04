//
//  BaseViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

- (void)tabBarItemClicked;
- (void)loginOutToLoginVC;

+ (void)handleNotificationInfo:(NSDictionary *)userInfo applicationState:(UIApplicationState)applicationState;
+ (UIViewController *)analyseVCFromLinkStr:(NSString *)linkStr;
+ (void)presentLinkStr:(NSString *)linkStr;
+ (UIViewController *)presentingVC;
+ (void)presentVC:(UIViewController *)viewController;
+ (void)goToVC:(UIViewController *)viewController;
@end
