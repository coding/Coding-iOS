//
//  TweetSendViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "QBImagePickerController.h"

#import "Tweets.h"

@class TweetSendLocationResponse;

@interface TweetSendViewController : BaseViewController
@property (copy, nonatomic) void(^sendNextTweet)(Tweet *nextTweet);

@property (nonatomic,strong) TweetSendLocationResponse *locationData;

@end
