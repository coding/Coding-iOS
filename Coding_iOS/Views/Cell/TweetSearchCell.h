//
//  TweetSearchCell.h
//  Coding_iOS
//
//  Created by jwill on 15/11/19.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

#import "UITTTAttributedLabel.h"

typedef void (^UserBtnClickedBlock) (User *curUser);

@interface TweetSearchCell : UITableViewCell<TTTAttributedLabelDelegate>
@property (nonatomic, strong) Tweet *tweet;

@property (nonatomic, copy) UserBtnClickedBlock userBtnClickedBlock;
@property (copy, nonatomic) void (^mediaItemClickedBlock)(HtmlMediaItem *curItem);

+ (CGFloat)cellHeightWithObj:(id)obj;

@end
