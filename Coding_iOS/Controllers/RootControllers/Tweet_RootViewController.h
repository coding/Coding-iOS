//
//  Tweet_RootViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ODRefreshControl.h"
#import "Tweets.h"
#import "UIMessageInputView.h"

typedef NS_ENUM(NSUInteger, Tweet_RootViewControllerType){
    Tweet_RootViewControllerTypeAll = 0,
    Tweet_RootViewControllerTypeFriend,
    Tweet_RootViewControllerTypeHot,
    Tweet_RootViewControllerTypeMine
};


@interface Tweet_RootViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIMessageInputViewDelegate>
+ (instancetype)newTweetVCWithType:(Tweet_RootViewControllerType)type;

- (void)refresh;
@end
