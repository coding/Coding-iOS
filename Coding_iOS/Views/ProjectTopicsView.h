//
//  ProjectTopicsView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTSegmentControl.h"
#import "iCarousel.h"
#import "ProjectTopics.h"
#import "ProjectTopicListView.h"

@interface ProjectTopicsView : UIView
- (id)initWithFrame:(CGRect)frame
            project:(Project *)project
              block:(ProjectTopicBlock)block
       defaultIndex:(NSInteger)index;
- (void)refreshToQueryData;

@end
