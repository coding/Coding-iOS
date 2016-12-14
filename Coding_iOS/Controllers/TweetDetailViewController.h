//
//  TweetDetailViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Tweets.h"
#import "ODRefreshControl.h"
#import "UIMessageInputView.h"


@interface TweetDetailViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TTTAttributedLabelDelegate, UIMessageInputViewDelegate>
@property (strong, nonatomic) Tweet *curTweet;
@property (strong, nonatomic) Project *curProject;//项目内冒泡有这个，@ 人的时候用
@property (copy, nonatomic) void(^deleteTweetBlock)(Tweet *);

- (void)refreshTweet;

@end
