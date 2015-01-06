//
//  MessageMediaItemCCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-17.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HtmlMedia.h"
#import "PrivateMessage.h"

@interface MessageMediaItemCCell : UICollectionViewCell
@property (copy, nonatomic) void (^refreshMessageMediaCCellBlock)(CGFloat diff);

@property (strong, nonatomic) PrivateMessage *curPriMsg, *prePriMsg;
@property (strong, nonatomic) NSObject *curObj;
@property (strong, nonatomic) UIImageView *imgView;

+(CGSize)ccellSizeWithObj:(NSObject *)obj;
@end
