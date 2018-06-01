//
//  IntroductionViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/6/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#ifdef Target_Enterprise

#import "BaseViewController.h"

@class IntroductionItem, IntroductionHomePage, IntroductionIndexPage;

@interface IntroductionViewController : BaseViewController

- (void)presentLoginUI;

@end

@interface IntroductionHomePage : UIView
@property (strong, nonatomic) IntroductionItem *curItem;

@end

@interface IntroductionIndexPage : UIView
@property (strong, nonatomic) IntroductionItem *curItem;
@end

@interface IntroductionItem : NSObject
+ (instancetype)itemWithTitle:(NSString *)title content:(NSString *)content imagePrefix:(NSString *)imagePrefix;
@property (strong, nonatomic) NSString *title, *content, *imagePrefix;
@property (assign, nonatomic) BOOL isHomePage;
@end

#else

#import <IFTTTJazzHands.h>

@interface IntroductionViewController : IFTTTAnimatedPagingScrollViewController

@end

#endif
