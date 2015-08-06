//
//  CSMyTopicVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSMyTopicVC.h"

#import "Login.h"

#import "Coding_NetAPIManager.h"

#import "CSTopiclistView.h"
#import "CSTopicDetailVC.h"

@interface CSMyTopicVC ()
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;
@property (assign, nonatomic) NSInteger oldSelectedIndex;

@end

@implementation CSMyTopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if([self isMe]) {
        self.segmentItems = @[@"我关注的", @"我参与的"];
        self.title = @"我的话题";
    }else {
    
        self.segmentItems = @[@"Ta关注的", @"Ta参与的"];
        self.title = @"Ta的话题";
    }

    _oldSelectedIndex = 0;
    
    //添加myCarousel
    _myCarousel = ({
        iCarousel *icarousel = [[iCarousel alloc] init];
        icarousel.dataSource = self;
        icarousel.delegate = self;
        icarousel.decelerationRate = 1.0;
        icarousel.scrollSpeed = 1.0;
        icarousel.type = iCarouselTypeLinear;
        icarousel.pagingEnabled = YES;
        icarousel.clipsToBounds = YES;
        icarousel.bounceDistance = 0.2;
        [self.view addSubview:icarousel];
        [icarousel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kMySegmentControl_Height, 0, 0, 0));
        }];
        icarousel;
    });
    
    //添加滑块
    __weak typeof(_myCarousel) weakCarousel = _myCarousel;
    _mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height) Items:_segmentItems selectedBlock:^(NSInteger index) {
        if (index == _oldSelectedIndex) {
            return;
        }
        [weakCarousel scrollToItemAtIndex:index animated:NO];
    }];
    [self.view addSubview:_mySegmentControl];
    _myCarousel.scrollEnabled = YES;

}

- (BOOL)isMe{
    
    if(!_curUser) {
    
        _curUser = [Login curLoginUser];
    }
    
    return [_curUser.global_key isEqualToString:[Login curLoginUser].global_key];
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return _segmentItems.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    CSTopiclistView *listView = (CSTopiclistView *)view;
    if (listView) {
        
    }else{
        __weak CSMyTopicVC *weakSelf = self;
        CSMyTopicsType type = (index == 0 ? CSMyTopicsTypeWatched : CSMyTopicsTypeJoined);
        listView = [[CSTopiclistView alloc] initWithFrame:carousel.bounds globalKey:_curUser.global_key type:type block:^(NSDictionary *topic) {
            [weakSelf goToTopic:topic];
        }];
        listView.isMe = [self isMe];
    }
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
    return listView;
}

- (Projects *)projectsWithIndex:(NSUInteger)index{
    return [Projects projectsWithType:index andUser:nil];
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    [self.view endEditing:YES];
    if (_mySegmentControl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [_mySegmentControl moveIndexWithProgress:offset];
        }
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    if (_mySegmentControl) {
        _mySegmentControl.currentIndex = carousel.currentItemIndex;
    }
    if (_oldSelectedIndex != carousel.currentItemIndex) {
        _oldSelectedIndex = carousel.currentItemIndex;
        CSTopiclistView *curView = (CSTopiclistView *)carousel.currentItemView;
        [curView refreshToQueryData];
    }
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}


#pragma mark - 

- (void)goToTopic:(NSDictionary*)topic{
    CSTopicDetailVC *vc = [[CSTopicDetailVC alloc] init];
    vc.topicID = [topic[@"id"] intValue];
    [self.navigationController pushViewController:vc animated:YES];
}

@end


@interface CSMyTopicView ()<iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;
@property (assign, nonatomic) NSInteger oldSelectedIndex;
@property (strong, nonatomic) NSArray *segmentItems;
@end

@implementation CSMyTopicView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    self.segmentItems = @[@"我关注的", @"我参与的"];
    
    _oldSelectedIndex = 0;
    
    //添加myCarousel
    _myCarousel = ({
        iCarousel *icarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
        icarousel.dataSource = self;
        icarousel.delegate = self;
        icarousel.decelerationRate = 1.0;
        icarousel.scrollSpeed = 1.0;
        icarousel.type = iCarouselTypeLinear;
        icarousel.pagingEnabled = YES;
        icarousel.clipsToBounds = YES;
        icarousel.bounceDistance = 0.2;
        icarousel.disableGesture = YES;
        [self addSubview:icarousel];
        [icarousel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(kMySegmentControl_Height, 0, 0, 0));
        }];
        icarousel;
    });
    
    //添加滑块
    __weak typeof(_myCarousel) weakCarousel = _myCarousel;
    _mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height) Items:_segmentItems selectedBlock:^(NSInteger index) {
        if (index == _oldSelectedIndex) {
            return;
        }
        [weakCarousel scrollToItemAtIndex:index animated:NO];
    }];
    [self addSubview:_mySegmentControl];
    _myCarousel.scrollEnabled = NO;
    
    return self;
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return _segmentItems.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    CSTopiclistView *listView = (CSTopiclistView *)view;
    if (listView) {
        
    }else{
        __weak CSMyTopicView *weakSelf = self;
        CSMyTopicsType type = (index == 0 ? CSMyTopicsTypeWatched : CSMyTopicsTypeJoined);
        
        listView = [[CSTopiclistView alloc] initWithFrame:carousel.bounds globalKey:[Login curLoginUser].global_key type:type block:^(NSDictionary *topic) {
            [weakSelf goToTopic:topic];
        }];
        listView.isMe = YES;
    }
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
    return listView;
}

- (Projects *)projectsWithIndex:(NSUInteger)index{
    return [Projects projectsWithType:index andUser:nil];
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    [self endEditing:YES];
    if (_mySegmentControl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [_mySegmentControl moveIndexWithProgress:offset];
        }
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    if (_mySegmentControl) {
        _mySegmentControl.currentIndex = carousel.currentItemIndex;
    }
    if (_oldSelectedIndex != carousel.currentItemIndex) {
        _oldSelectedIndex = carousel.currentItemIndex;
        CSTopiclistView *curView = (CSTopiclistView *)carousel.currentItemView;
        [curView refreshToQueryData];
    }
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}


#pragma mark -

- (void)goToTopic:(NSDictionary*)topic{
    CSTopicDetailVC *vc = [[CSTopicDetailVC alloc] init];
    vc.topicID = [topic[@"id"] intValue];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

@end
