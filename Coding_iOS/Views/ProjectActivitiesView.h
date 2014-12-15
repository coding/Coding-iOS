//
//  ProjectActivitiesView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "XTSegmentControl.h"
#import "iCarousel.h"
#import "ProjectActivityListView.h"

@interface ProjectActivitiesView : UIView <iCarouselDataSource, iCarouselDelegate>
@property (copy, nonatomic) void (^htmlItemClickedBlock)(HtmlMediaItem *clickedItem, ProjectActivity *proAct, BOOL isContent);
@property (copy, nonatomic) void (^userIconClickedBlock)(User *);

- (id)initWithFrame:(CGRect)frame project:(Project *)project block:(ProjectActivityBlock)block defaultIndex:(NSInteger)index;

@end
