//
//  TweetDetailCommentCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TweetDetailComment @"TweetDetailCommentCell"

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "UITTTAttributedLabel.h"

@interface TweetDetailCommentCell : UITableViewCell

@property (strong, nonatomic) Comment *toComment;
@property (nonatomic, copy) void (^commentToCommentBlock)(Comment *, id);
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;
//@property (strong, nonatomic) UITapImageView *ownerIconView;

+ (CGFloat)cellHeightWithObj:(id)obj;

@end
