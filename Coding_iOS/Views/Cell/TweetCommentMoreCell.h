//
//  TweetCommentMoreCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-18.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TweetCommentMore @"TweetCommentMoreCell"

#import <UIKit/UIKit.h>

@interface TweetCommentMoreCell : UITableViewCell
@property (strong, nonatomic) NSNumber *commentNum;
+(CGFloat)cellHeight;
@end
