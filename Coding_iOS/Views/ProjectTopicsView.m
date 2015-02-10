//
//  ProjectTopicsView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectTopicsView.h"

@interface ProjectTopicsView ()
@property (nonatomic, strong) Project *myProject;
@property (nonatomic , copy) ProjectTopicBlock block;
@property (strong, nonatomic) NSMutableDictionary *myProTopicsDict;
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;
@end

@implementation ProjectTopicsView

- (id)initWithFrame:(CGRect)frame project:(Project *)project block:(ProjectTopicBlock)block defaultIndex:(NSInteger)index{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myProject = project;
        _block = block;
        _myProTopicsDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        //添加myCarousel
        self.myCarousel = ({
            iCarousel *icarousel = [[iCarousel alloc] init];
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
        self.mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height) Items:@[@"全部讨论", @"我参与的"] selectedBlock:^(NSInteger index) {
            [weakCarousel scrollToItemAtIndex:index animated:NO];
        }];
        [self addSubview:self.mySegmentControl];
    }
    return self;
}

- (void)refreshToQueryData{
    UIView *currentItemView = self.myCarousel.currentItemView;
    if ([currentItemView isKindOfClass:[ProjectTopicListView class]]) {
        ProjectTopicListView *listView = (ProjectTopicListView *)currentItemView;
        [listView refreshToQueryData];
    }
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return 2;
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    ProjectTopics *curProTopics = [_myProTopicsDict objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    if (!curProTopics) {
        curProTopics = [ProjectTopics topicsWithPro:_myProject queryType:index];
        [_myProTopicsDict setObject:curProTopics forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
    ProjectTopicListView *listView = (ProjectTopicListView *)view;
    if (listView) {
        [listView setProTopics:curProTopics];
    }else{
        listView = [[ProjectTopicListView alloc] initWithFrame:carousel.bounds projectTopics:curProTopics block:_block];
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
- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    if (_mySegmentControl) {
        [_mySegmentControl endMoveIndex:carousel.currentItemIndex];
    }
}

@end
