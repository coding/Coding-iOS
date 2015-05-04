//
//  ProjectTopicLabelView.h
//  Coding_iOS
//
//  Created by zwm on 15/4/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProjectTopic;
@interface ProjectTopicLabelView : UIView

@property (assign, nonatomic, readonly) CGFloat labelH;
@property (nonatomic, copy) void (^delLabelBlock)(NSInteger index);

- (id)initWithFrame:(CGRect)frame projectTopic:(ProjectTopic *)topic md:(BOOL)isMD;

@end
