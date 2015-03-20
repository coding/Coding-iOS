//
//  TweetCommentCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TweetComment @"TweetCommentCell"

#import <UIKit/UIKit.h>
#import "UITTTAttributedLabel.h"
#import "Comment.h"

@interface TweetCommentCell : UITableViewCell
@property (strong, nonatomic) UITTTAttributedLabel *commentLabel;
- (void)configWithComment:(Comment *)curComment topLine:(BOOL)has;
+(CGFloat)cellHeightWithObj:(id)obj;
@end
