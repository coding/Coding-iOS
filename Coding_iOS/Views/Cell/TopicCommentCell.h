//
//  TopicCommentCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectTopic.h"

@interface TopicCommentCell : UITableViewCell
@property (strong, nonatomic) ProjectTopic *toComment;

+ (CGFloat)cellHeightWithObj:(id)obj;

@end
