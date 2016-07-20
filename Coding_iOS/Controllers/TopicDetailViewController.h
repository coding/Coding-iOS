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


@interface TopicDetailHeaderView : UIView
@property (strong, nonatomic) ProjectTopic *curTopic;
@property (nonatomic, copy) void (^goToUserBlock)(User *);
@property (nonatomic, copy) void (^commentBlock)(id sender);
@property (nonatomic, copy) void (^deleteBlock)(ProjectTopic *curTopic);
@end