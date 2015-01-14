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

+ (void)handleNotificationInfo:(NSDictionary *)userInfo;
+ (UIViewController *)analyseVCFromLinkStr:(NSString *)linkStr;
+ (UIViewController *)presentingVC;
@end
