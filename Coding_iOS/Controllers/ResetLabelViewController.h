//
//  ResetLabelViewController.h
//  Coding_iOS
//
//  Created by zwm on 15/4/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@class ProjectTopic;
@class ProjectTopicLabel;
@interface ResetLabelViewController : BaseViewController

@property (weak, nonatomic) ProjectTopicLabel *ptLabel;
@property (weak, nonatomic) ProjectTopic *curProTopic;

@end
