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
@property (copy, nonatomic) void(^sentBlock)(Tweet *tweet);

@end
