//
//  TopicAnswerCommentMoreCell.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/18.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kCellIdentifier_TopicAnswerCommentMoreCell @"TopicAnswerCommentMoreCell"

#import <UIKit/UIKit.h>

@interface TopicAnswerCommentMoreCell : UITableViewCell
@property (strong, nonatomic) NSNumber *commentNum;
+(CGFloat)cellHeight;
@end
