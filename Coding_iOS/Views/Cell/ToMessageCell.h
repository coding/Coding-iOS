//
//  ToMessageCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ToMessage @"ToMessageCell"

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ToMessageType) {
    ToMessageTypeAT = 0,
    ToMessageTypeComment,
    ToMessageTypeSystemNotification,
    ToMessageTypeProjectFollows,
    ToMessageTypeProjectFans,
};

@interface ToMessageCell : UITableViewCell

@property (assign, nonatomic) ToMessageType type;
@property (strong, nonatomic) NSNumber *unreadCount;
+ (CGFloat)cellHeight;


@end
