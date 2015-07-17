//
//  CSMyTopicVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSMyTopicVC.h"
#import "XTSegmentControl.h"
#import "iCarousel.h"

@interface CSMyTopicVC ()
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;
@end

@implementation CSMyTopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    self.segmentItems = @[@"我参与的", @"我收藏的"];
    
    //添加myCarousel
//    _myCarousel = ({
//        iCarousel *icarousel = [[iCarousel alloc] init];
//        icarousel.dataSource = self;
//        icarousel.delegate = self;
//        icarousel.decelerationRate = 1.0;
//        icarousel.scrollSpeed = 1.0;
//        icarousel.type = iCarouselTypeLinear;
//        icarousel.pagingEnabled = YES;
//        icarousel.clipsToBounds = YES;
//        icarousel.bounceDistance = 0.2;
//        [self.view addSubview:icarousel];
//        [icarousel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kMySegmentControl_Height, 0, 0, 0));
//        }];
//        icarousel;
//    });
    
    //添加滑块
//    __weak typeof(_myCarousel) weakCarousel = _myCarousel;
//    _mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height) Items:_segmentItems selectedBlock:^(NSInteger index) {
//        if (index == _oldSelectedIndex) {
//            return;
//        }
//        [weakCarousel scrollToItemAtIndex:index animated:NO];
//    }];
//    [self.view addSubview:_mySegmentControl];
//    [self setupNavBtn];
//    self.icarouselScrollEnabled = NO;

}


@end
