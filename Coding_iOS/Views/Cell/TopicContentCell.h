//
//  TopicContentCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TopicContent @"TopicContentCell"

#import <UIKit/UIKit.h>
#import "ProjectTopic.h"

@interface TopicContentCell : UITableViewCell<UIWebViewDelegate>
@property (strong, nonatomic) ProjectTopic *curTopic;

@property (nonatomic, copy) void (^commentTopicBlock)(ProjectTopic *, id);
@property (nonatomic, copy) void (^cellHeightChangedBlock)();
@property (nonatomic, copy) void (^loadRequestBlock)(NSURLRequest *curRequest);
@property (nonatomic, copy) void (^deleteTopicBlock)(ProjectTopic *);
@property (nonatomic, copy) void (^addLabelBlock)();

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
