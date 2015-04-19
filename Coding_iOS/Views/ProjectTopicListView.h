//
//  ProjectTopicListView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectTopics.h"
@class ProjectTopicListView;

typedef void(^ProjectTopicBlock)(ProjectTopicListView *projectTopicListView, ProjectTopic *projectTopic);
typedef void(^TopicListBlock)(ProjectTopicListView *projectTopicListView);

@interface ProjectTopicListView : UIView<UITableViewDataSource, UITableViewDelegate>

- (id)initWithFrame:(CGRect)frame
      projectTopics:(ProjectTopics *)projectTopics
              block:(ProjectTopicBlock)block
       andListBlock:(TopicListBlock)listBlock;
- (void)setProTopics:(ProjectTopics *)proTopics;
- (void)refreshToQueryData;

- (NSInteger)getCount;
- (void)getLabelArray:(NSMutableArray *)labelAry andNumberArray:(NSMutableArray *)numberAry;
- (void)setOrder:(NSInteger)order withLabel:(NSString *)label;

@end
