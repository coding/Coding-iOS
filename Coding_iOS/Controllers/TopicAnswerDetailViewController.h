//
//  TopicAnswerDetailViewController.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/18.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectTopic.h"

@interface TopicAnswerDetailViewController : BaseViewController
@property (strong, nonatomic) ProjectTopic *curAnswer;
@property (strong, nonatomic) ProjectTopic *curTopic;

@property (copy, nonatomic) void(^deleteAnswerBlock) (ProjectTopic *curAnswer);
@end
