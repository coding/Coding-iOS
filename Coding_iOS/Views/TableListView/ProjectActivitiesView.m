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
@property (strong, nonatomic) NSArray *titlesArray;
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
            [icarousel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self).insets(UIEdgeInsetsMake(kMySegmentControl_Height, 0, 0, 0));
            }];
            icarousel;
        });
        
        //添加滑块
        __weak typeof(_myCarousel) weakCarousel = _myCarousel;
        
        self.mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height) Items:self.titlesArray selectedBlock:^(NSInteger index) {
            [weakCarousel scrollToItemAtIndex:index animated:NO];
        }];
        
        [self addSubview:self.mySegmentControl];
        
    }
    return self;
}

#pragma mark - Getter/Setter
- (NSArray*)titlesArray
{
    if (nil == _titlesArray) {
        if (_myProject.is_public.boolValue) {
            _titlesArray = @[@"全部", @"讨论", @"代码", @"其他"];
        }else{
            _titlesArray = @[@"全部", @"任务", @"讨论", @"文件", @"代码", @"其他"];
        }
    }
    return _titlesArray;
}
#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [self.titlesArray count];
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
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
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

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    if (_mySegmentControl) {
        _mySegmentControl.currentIndex = carousel.currentItemIndex;
    }
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}
@end
