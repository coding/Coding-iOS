//
//  CSMyTopicVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSMyTopicVC.h"
#import "Topic.h"

#import "Login.h"

#import "Coding_NetAPIManager.h"

#import "CSTopiclistView.h"
#import "CSTopicDetailVC.h"

@interface CSMyTopicVC ()
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;
@property (assign, nonatomic) NSInteger oldSelectedIndex;

@property (strong, nonatomic) NSMutableDictionary *myTopicsDict;
@end

@implementation CSMyTopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.segmentItems = @[@"我关注的", @"我参与的"];
    self.title = @"我的话题";
    _myTopicsDict = [[NSMutableDictionary alloc] initWithCapacity:_segmentItems.count];
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
    _myCarousel.scrollEnabled = NO;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_myCarousel) {
//        ProjectListView *listView = (ProjectListView *)_myCarousel.currentItemView;
//        if (listView) {
//            [listView refreshToQueryData];
//        }
    }
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return _segmentItems.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    Projects *curPros = [_myTopicsDict objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    if (!curPros) {
        curPros = [self projectsWithIndex:index];
        [_myTopicsDict setObject:curPros forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
    CSTopiclistView *listView = (CSTopiclistView *)view;
    if (listView) {
        [listView setTopics:curPros];
    }else{
        __weak typeof(self) *weakSelf = self;
        listView = [[CSTopiclistView alloc] initWithFrame:carousel.bounds topics:curPros block:^(Project *project) {
            [weakSelf goToProject:project];
            DebugLog(@"\n=====%@", project.name);
        } tabBarHeight:CGRectGetHeight(self.rdv_tabBarController.tabBar.frame)];
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

- (void)goToTopic:(Topic*)topic{
    CSTopicDetailVC *vc = [[CSTopicDetailVC alloc] init];
    vc.topic = topic;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
