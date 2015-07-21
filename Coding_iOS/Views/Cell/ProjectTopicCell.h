//
//  ProjectTopicCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectTopic @"ProjectTopicCell"

#import <UIKit/UIKit.h>
#import "ProjectTopic.h"

@interface ProjectTopicCell : UITableViewCell
@property (strong, nonatomic) ProjectTopic *curTopic;;

+(CGFloat)cellHeightWithObj:(id)aObj;
@end


@interface ProjectTopicCellTagsView : UIView
@property (strong, nonatomic) NSArray *tags;

- (instancetype)initWithTags:(NSArray *)tags;
+ (instancetype)viewWithTags:(NSArray *)tags;
+ (CGFloat)getHeightForTags:(NSArray *)tags;
@end