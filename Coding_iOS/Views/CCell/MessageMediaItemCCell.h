//
//  MessageMediaItemCCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-17.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCCellIdentifier_MessageMediaItem @"MessageMediaItemCCell"
#define kCCellIdentifier_MessageMediaItem_Single @"MessageMediaItemCCell_Single"

#import <UIKit/UIKit.h>
#import "HtmlMedia.h"
#import "PrivateMessage.h"
#import "YLImageView.h"

@interface MessageMediaItemCCell : UICollectionViewCell
@property (copy, nonatomic) void (^refreshMessageMediaCCellBlock)(CGFloat diff);

//@property (strong, nonatomic) PrivateMessage *curPriMsg, *prePriMsg;
@property (strong, nonatomic) NSObject *curObj;
@property (strong, nonatomic) YLImageView *imgView;

+(CGSize)ccellSizeWithObj:(NSObject *)obj;
+(CGSize)monkeyCcellSize;

@end
