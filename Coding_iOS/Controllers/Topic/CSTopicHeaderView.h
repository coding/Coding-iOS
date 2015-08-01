//
//  CSTopicUsersCell.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/27.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_TopicCell @"CSTopicCell"

@interface CSTopicHeaderView : UIView
@property (nonatomic,weak)UIViewController *parentVC;
- (void)updateWithTopic:(NSDictionary*)data;
- (void)updateWithJoinedUsers:(NSArray*)userlist;

@end




