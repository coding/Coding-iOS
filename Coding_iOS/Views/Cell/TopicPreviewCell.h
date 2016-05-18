//
//  TopicPreviewCell.h
//  Coding_iOS
//
//  Created by 周文敏 on 15/4/20.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_TopicPreviewCell @"TopicPreviewCell"

#import <UIKit/UIKit.h>

@class ProjectTopic;
@interface TopicPreviewCell : UITableViewCell

@property (strong, nonatomic) ProjectTopic *curTopic;
@property (assign, nonatomic) BOOL isLabel;

@property (nonatomic, copy) void (^cellHeightChangedBlock)();
@property (nonatomic, copy) void (^addLabelBlock)();
@property (nonatomic, copy) void (^delLabelBlock)();
@property (nonatomic, copy) void (^clickedLinkStrBlock)(NSString *linkStr);

+ (CGFloat)cellHeightWithObjWithLabel:(id)obj;
+ (CGFloat)cellHeightWithObj:(id)obj;

@end
