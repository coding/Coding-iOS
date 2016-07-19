//
//  UserTweetsViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-4.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Tweets.h"
#import "UIMessageInputView.h"

@interface UserOrProjectTweetsViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIMessageInputViewDelegate>
@property (strong, nonatomic) Tweets *curTweets;

@end
