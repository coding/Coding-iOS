//
//  CSHotTopicVC.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSScrollview.h"
#import "SWTableViewCell.h"
@class CSTopic;

#define kCellIdentifier_TopicCell @"kCellIdentifier_TopicCell"
@interface CSHotTopicView : UIView
@property (nonatomic,weak)UIViewController *parentVC;
@end

//普通cell
@interface CSTopicCell : SWTableViewCell

- (void)updateDisplayByTopic:(NSDictionary*)data;

+ (CGFloat)cellHeightWithData:(NSDictionary*)data;

@end

//title使用
@interface CSHotTopicTitleCell : UITableViewCell

@end

//ad cell
@interface CSHotAdCell : UITableViewCell

@end

