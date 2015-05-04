//
//  TopicDetailViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectTopic.h"
#import "UIMessageInputView.h"


@interface TopicDetailViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIMessageInputViewDelegate>

@property (strong, nonatomic) ProjectTopic *curTopic;

@property (nonatomic, copy) void (^deleteTopicBlock)(ProjectTopic *);

- (void)refreshTopic;
@end
