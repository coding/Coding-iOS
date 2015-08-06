//
//  CSSearchCell.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/23.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Tweet.h"

#import "UITTTAttributedLabel.h"

typedef void (^UserBtnClickedBlock) (User *curUser);

@interface CSSearchCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (nonatomic, strong) Tweet *tweet;

@property (nonatomic, copy) UserBtnClickedBlock userBtnClickedBlock;
@property (copy, nonatomic) void (^mediaItemClickedBlock)(HtmlMediaItem *curItem);

+ (CGFloat)cellHeightWithObj:(id)obj;

@end
