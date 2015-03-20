//
//  ConversationCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_Conversation @"ConversationCell"

#import <UIKit/UIKit.h>
#import "PrivateMessage.h"

@interface ConversationCell : UITableViewCell
@property (strong, nonatomic) PrivateMessage *curPriMsg;

+ (CGFloat)cellHeight;
@end
