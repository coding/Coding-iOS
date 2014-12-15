//
//  ProjectTasksView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "XTSegmentControl.h"
#import "iCarousel.h"
#import "ProjectTaskListView.h"

@interface ProjectTasksView : UIView<iCarouselDataSource, iCarouselDelegate>
- (id)initWithFrame:(CGRect)frame project:(Project *)project block:(ProjectTaskBlock)block defaultIndex:(NSInteger)index;
- (void)refreshToQueryData;
@end
