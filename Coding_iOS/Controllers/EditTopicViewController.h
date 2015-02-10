//
//  EditTopicViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Projects.h"

typedef NS_ENUM(NSInteger, TopicEditType) {
    TopicEditTypeAdd = 0,
    TopicEditTypeModify,
    TopicEditTypeFeedBack
};

@interface EditTopicViewController : BaseViewController

@property (strong, nonatomic) ProjectTopic *curProTopic;
@property (nonatomic, assign) TopicEditType type;

@property (copy, nonatomic) void(^topicChangedBlock)(ProjectTopic *curTopic, TopicEditType type);

@end
