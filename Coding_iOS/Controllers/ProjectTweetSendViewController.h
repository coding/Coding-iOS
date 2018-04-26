//
//  ProjectTweetSendViewController.h
//  Coding_iOS
//
//  Created by Ease on 16/7/19.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Project.h"
#import "Tweet.h"

@interface ProjectTweetSendViewController : BaseViewController
@property (strong, nonatomic) Project *curPro;
@property (strong, nonatomic) Tweet *curTweet;//有的话，就是编辑。。没有的话，就是添加
@property (copy, nonatomic) void(^sentBlock)(Tweet *tweet);

@end
