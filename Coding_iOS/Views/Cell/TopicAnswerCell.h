//
//  TopicAnswerCell.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/18.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kCellIdentifier_TopicAnswerCell @"TopicAnswerCell"

#import <UIKit/UIKit.h>
#import "ProjectTopic.h"

@interface TopicAnswerCell : UITableViewCell
@property (strong, nonatomic) ProjectTopic *curAnswer;
@property (strong, nonatomic) NSNumber *projectId;

@property (copy, nonatomic) void(^linkStrBlock)(NSString *linkStr);
@property (copy, nonatomic) void(^commentClickedBlock)(ProjectTopic *curAnswer, ProjectTopic *toComment, id sender);

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
