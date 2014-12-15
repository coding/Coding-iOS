//
//  TopicContentCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectTopic.h"
typedef void (^CommentTopicBlock) ();
@interface TopicContentCell : UITableViewCell<UIWebViewDelegate>
@property (strong, nonatomic) ProjectTopic *curTopic;
@property (nonatomic, copy) void (^commentTopicBlock)(ProjectTopic *, id);
@property (nonatomic, copy) void (^cellHeightChangedBlock) ();
@property (nonatomic, copy) void (^loadRequestBlock)(NSURLRequest *curRequest);
@property (nonatomic, copy) void (^deleteTopicBlock)(ProjectTopic *);

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
