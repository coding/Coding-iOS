//
//  ProjectActivitiesView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectActivitiesView.h"
#import "XTSegmentControl.h"

@interface ProjectActivitiesView ()
@property (nonatomic, strong) Project *myProject;
@property (nonatomic , copy) ProjectActivityBlock block;
@property (strong, nonatomic) NSMutableDictionary *myProActivitiesDict;
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;

@end

@implementation ProjectActivitiesView

- (id)initWithFrame:(CGRect)frame project:(Project *)project block:(ProjectActivityBlock)block defaultIndex:(NSInteger)index{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myProject = project;
        _block = block;
        _myProActivitiesDict = [[NSMutableDictionary alloc] initWithCapacity:6];
        //添加myCarousel
        frame.origin.y +=  kMySegmentControl_Height;
        frame.size.height -= kMySegmentControl_Height;
        self.myCarousel = ({
            iCarousel *icarousel = [[iCarousel alloc] initWithFrame:frame];
            icarousel.dataSource = self;
            icarousel.delegate = self;
            icarousel.decelerationRate = 1.0;
            icarousel.scrollSpeed = 1.0;
            icarousel.type = iCarouselTypeLinear;
            icarousel.pagingEnabled = YES;
            icarousel.clipsToBounds = YES;
            icarousel.bounceDistance = 0.2;
            [self addSubview:icarousel];
            icarousel;
        });
        
        //添加滑块
        frame.origin.y = 0;
        frame.size.height = kMySegmentControl_Height;
        __weak typeof(_myCarousel) weakCarousel = _myCarousel;
        if (_myProject.is_public.boolValue) {
            self.mySegmentControl = [[XTSegmentControl alloc] initWithFrame:frame Items:@[@"全部", @"讨论", @"代码", @"其他"] selectedBlock:^(NSInteger index) {
                [weakCarousel scrollToItemAtIndex:index animated:NO];
            }];
        }else{
            self.mySegmentControl = [[XTSegmentControl alloc] initWithFrame:frame Items:@[@"全部", @"任务", @"讨论", @"文档", @"代码", @"其他"] selectedBlock:^(NSInteger index) {
                [weakCarousel scrollToItemAtIndex:index animated:NO];
            }];
        }
        [self addSubview:self.mySegmentControl];
        
    }
    return self;
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return 6;
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    
    if (_myProject.is_public.boolValue) {
        switch (index) {
            case 0:
                index = ProjectActivityTypeAll;
                break;
            case 1:
                index = ProjectActivityTypeTopic;
                break;
            case 2:
                index = ProjectActivityTypeCode;
                break;
            case 3:
                index = ProjectActivityTypeOther;
                break;
            default:
                index = ProjectActivityTypeAll;
                break;
        }
    }else{
        index = index;
    }
    ProjectActivities *curProActs = [_myProActivitiesDict objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    if (!curProActs) {
        curProActs = [ProjectActivities proActivitiesWithPro:_myProject type:index];
        [_myProActivitiesDict setObject:curProActs forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
    ProjectActivityListView *listView = (ProjectActivityListView *)view;
    if (listView) {
        [listView setProAtcs:curProActs];
    }else{
        listView = [[ProjectActivityListView alloc] initWithFrame:carousel.bounds proAtcs:curProActs block:_block];
        listView.htmlItemClickedBlock = _htmlItemClickedBlock;
        listView.userIconClickedBlock = _userIconClickedBlock;
    }
    return listView;
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    if (_mySegmentControl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [_mySegmentControl moveIndexWithProgress:offset];
        }
    }
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel{
    if (_mySegmentControl) {
        [_mySegmentControl endMoveIndex:carousel.currentItemIndex];
    }
}
@end
