//
//  MessageCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_Message @"MessageCell"
#define kCellIdentifier_MessageMedia @"MessageMediaCell"
#define kCellIdentifier_MessageVoice @"MessageVoiceCell"

#import <UIKit/UIKit.h>
#import "PrivateMessage.h"
#import "UILongPressMenuImageView.h"

@interface MessageCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UILongPressMenuImageView *bgImgView;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;

- (void)setCurPriMsg:(PrivateMessage *)curPriMsg andPrePriMsg:(PrivateMessage *)prePriMsg;

@property (copy, nonatomic) void(^tapUserIconBlock)(User *sender);
@property (copy, nonatomic) void (^refreshMessageMediaCCellBlock)(CGFloat diff);
@property (copy, nonatomic) void (^resendMessageBlock)(PrivateMessage *curPriMsg);

+ (CGFloat)cellHeightWithObj:(id)obj preObj:(id)preObj;
@end
