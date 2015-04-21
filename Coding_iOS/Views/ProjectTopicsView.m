//
//  ProjectTopicsView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectTopicsView.h"
#import "TopicListView.h"

@interface ProjectTopicsView ()
{
    NSArray *_one;
    NSMutableArray *_two;
    NSArray *_three;
    NSArray *_total;
    NSMutableArray *_oneNumber;
    NSMutableArray *_twoNumber;
    NSMutableArray *_threeNumber;
    NSArray *_totalNumber;
    NSMutableArray *_totalIndex;
    NSInteger _segIndex;
}

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
        
        // 添加滑块
        _one = @[@"全部讨论", @"我参与的"];
        _two = [NSMutableArray arrayWithObjects:@"全部标签", @"Bug", @"Feature", @"反馈", nil];
        _three = @[@"最后评论排序", @"发布时间排序", @"热门排序"];
        _total = @[_one, _two, _three];
        _oneNumber = [NSMutableArray arrayWithObjects:@0, @0, nil];
        _twoNumber = [NSMutableArray arrayWithObjects:@0, @0, @0, @0, nil];
        _threeNumber = [NSMutableArray arrayWithObjects:@0, @0, @0, @0, nil];
       _totalNumber = @[_oneNumber, _twoNumber, _threeNumber];
        _totalIndex = [NSMutableArray arrayWithObjects:@0, @0, @0, nil];
        __weak typeof(self) weakSelf = self;
        self.mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height)
                                                                  Items:@[_one[0], _two[0], _three[0]]
                                                               withIcon:YES
                                                          selectedBlock:^(NSInteger index) {
                                                              [weakSelf openList:index];
                                                          }];
        [self addSubview:self.mySegmentControl];
    }
    return self;
}

- (void)changeIndex:(NSInteger)index withSegmentIndex:(NSInteger)segmentIndex
{
    [_totalIndex replaceObjectAtIndex:segmentIndex withObject:[NSNumber numberWithInteger:index]];
    [self.mySegmentControl setTitle:_total[segmentIndex][index] withIndex:segmentIndex];
    if (segmentIndex == 0) {
        [_myCarousel scrollToItemAtIndex:index animated:NO];
    }
    ProjectTopicListView *listView = (ProjectTopicListView *)[_myCarousel itemViewAtIndex:[_totalIndex[0] integerValue]];
    if ([_totalIndex[1] integerValue] == 0) {
        [listView setOrder:[_totalIndex[2] integerValue] withLabel:nil];
    } else {
        [listView setOrder:[_totalIndex[2] integerValue] withLabel:_two[[_totalIndex[1] integerValue]]];
    }
}

- (void)openList:(NSInteger)segmentIndex
{
    TopicListView *lView = (TopicListView *)[self viewWithTag:9898];
    if (!lView) {
        _segIndex = segmentIndex;
        NSArray *lists = (NSArray *)_total[segmentIndex];
        CGRect rect = CGRectMake(0, kMySegmentControl_Height, kScreen_Width, self.frame.size.height - kMySegmentControl_Height);

        NSArray *nAry = nil;
        if (segmentIndex == 0 ) {
            nAry = _totalNumber[0];
        } else if (segmentIndex == 1) {
            if ([_totalIndex[0] integerValue] == 0) {
                nAry = _totalNumber[1];
            } else {
                nAry = _totalNumber[2];
            }
        }
        __weak typeof(self) weakSelf = self;
       TopicListView *listView = [[TopicListView alloc] initWithFrame:rect
                                                                titles:lists
                                                               numbers:nAry
                                                          defaultIndex:[_totalIndex[segmentIndex] integerValue]
                                                         selectedBlock:^(NSInteger index) {
                                                             [weakSelf changeIndex:index withSegmentIndex:segmentIndex];
                                                         }];
        listView.tag = 9898;
        [self addSubview:listView];
        [listView showBtnView];
    } else if (_segIndex != segmentIndex) {
        _segIndex = segmentIndex;
        
        NSArray *nAry = nil;
        if (segmentIndex == 0 ) {
            nAry = _totalNumber[0];
        } else if (segmentIndex == 1) {
            if ([_totalIndex[0] integerValue] == 0) {
                nAry = _totalNumber[1];
            } else {
                nAry = _totalNumber[2];
            }
        }
        NSArray *lists = (NSArray *)_total[segmentIndex];
        __weak typeof(self) weakSelf = self;
        [lView changeWithTitles:lists
                        numbers:nAry
                   defaultIndex:[_totalIndex[segmentIndex] integerValue]
                  selectedBlock:^(NSInteger index) {
                       [weakSelf changeIndex:index withSegmentIndex:segmentIndex];
                   }];
    } else {
        [lView hideBtnView];
    }
}

- (void)refreshToQueryData
{
    UIView *currentItemView = self.myCarousel.currentItemView;
    if ([currentItemView isKindOfClass:[ProjectTopicListView class]]) {
        ProjectTopicListView *listView = (ProjectTopicListView *)currentItemView;
        [listView refreshToQueryData];
    }
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    ProjectTopics *curProTopics = [_myProTopicsDict objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    if (!curProTopics) {
        curProTopics = [ProjectTopics topicsWithPro:_myProject queryType:index];
        [_myProTopicsDict setObject:curProTopics forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
    ProjectTopicListView *listView = (ProjectTopicListView *)view;
    if (listView) {
        [listView setProTopics:curProTopics];
    } else {
        __weak typeof(self) weakSelf = self;
        listView = [[ProjectTopicListView alloc] initWithFrame:carousel.bounds
                                                 projectTopics:curProTopics
                                                         block:_block
                                                  andListBlock:^(ProjectTopicListView *projectTopicListView) {
                                                      [weakSelf getInfo:projectTopicListView andIndex:index];
                                                  }];
    }
   
    return listView;
}

- (void)getInfo:(ProjectTopicListView *)listView andIndex:(NSInteger)index
{
    if (index == 0) {
        [listView getLabelArray:_total[1] andNumberArray:_totalNumber[1] andAry:_totalNumber[2]];
    } else {
        [listView getLabelArray:_total[1] andNumberArray:_totalNumber[2] andAry:_totalNumber[1]];
    }
    [_totalNumber[0] replaceObjectAtIndex:index withObject:[NSNumber numberWithInteger:[listView getCount]]];
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
//    if (_mySegmentControl) {
//        float offset = carousel.scrollOffset;
//        if (offset > 0) {
//            [_mySegmentControl moveIndexWithProgress:offset];
//        }
//    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
//    if (_mySegmentControl) {
//        _mySegmentControl.currentIndex = carousel.currentItemIndex;
//    }
}

@end
