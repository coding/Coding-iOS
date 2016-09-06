//
//  MRListViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/10/23.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kMRPRListViewController_IsNew NO

#define kMRPRListViewController_BottomViewHeight 49.0

#import "MRListViewController.h"
#import "XTSegmentControl.h"
#import "iCarousel.h"
#import "MRListView.h"
#import "MRDetailViewController.h"


@interface MRListViewController ()<iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;
@property (strong, nonatomic) NSMutableDictionary *myMRsDict;
@property (nonatomic, assign) NSInteger segmentIndex;

@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UISegmentedControl *mySegmentedControl;
@end

@implementation MRListViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColorTableBG;
    self.title = @"Merge Requests";
    _myMRsDict = [[NSMutableDictionary alloc] initWithCapacity:6];
    
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
        icarousel.scrollEnabled = kMRPRListViewController_IsNew;
        [self.view addSubview:icarousel];
        [icarousel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kMRPRListViewController_IsNew? kMySegmentControl_Height: 0, 0, 0, 0));
        }];
        icarousel;
    });
    
    //添加滑块
    if (kMRPRListViewController_IsNew) {
        __weak typeof(_myCarousel) weakCarousel = _myCarousel;
        _mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height) Items:@[@"我评审的", @"我发布的", @"其他的"] selectedBlock:^(NSInteger index) {
            [weakCarousel scrollToItemAtIndex:index animated:NO];
        }];
        [self.view addSubview:_mySegmentControl];
    }
    [self configBottomView];
    self.segmentIndex = 0;
}

- (void)setSegmentIndex:(NSInteger)segmentIndex{
    _segmentIndex = segmentIndex;
    if (self.mySegmentedControl.selectedSegmentIndex != _segmentIndex) {
        [self.mySegmentedControl setSelectedSegmentIndex:_segmentIndex];
    }
    MRListView *curView = (MRListView *)_myCarousel.currentItemView;
    curView.curMRPRS = [self curMRPRS];
    [curView refreshToQueryData];
}

- (MRPRS *)curMRPRS{
    NSString *curKey = [NSString stringWithFormat:@"%ld_%ld", (long)_myCarousel.currentItemIndex, (long)_segmentIndex];
    MRPRS *curMRPRS = _myMRsDict[curKey];
    if (!curMRPRS) {
        curMRPRS = [[MRPRS alloc] initWithType:(kMRPRListViewController_IsNew? MRPRSTypeMRMine: MRPRSTypeMRAll) + _myCarousel.currentItemIndex
                                  statusIsOpen:_segmentIndex == 0
                                        userGK:_curProject.owner_user_name
                                   projectName:_curProject.name];
        _myMRsDict[curKey] = curMRPRS;
    }
    return curMRPRS;
}

#pragma mark Segment
- (void)configBottomView{
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = self.view.backgroundColor;
        [_bottomView addLineUp:YES andDown:NO];
        [self.view addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(kMRPRListViewController_BottomViewHeight);
        }];
    }
    if (!_mySegmentedControl) {
        _mySegmentedControl = ({
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Open", @"Closed"]];
            segmentedControl.tintColor = kColorBrandGreen;
            [segmentedControl setTitleTextAttributes:@{
                                                       NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                                       }
                                            forState:UIControlStateSelected];
            [segmentedControl setTitleTextAttributes:@{
                                                       NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                       NSForegroundColorAttributeName: kColorBrandGreen
                                                       } forState:UIControlStateNormal];
            [segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
            segmentedControl;
        });
        _mySegmentedControl.frame = CGRectMake(kPaddingLeftWidth, (kMRPRListViewController_BottomViewHeight - 30)/2, kScreen_Width - 2*kPaddingLeftWidth, 30);
        [_bottomView addSubview:_mySegmentedControl];
    }
}

- (void)segmentedControlSelected:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.segmentIndex = segmentedControl.selectedSegmentIndex;
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return 3;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    
    MRListView *listView = (MRListView *)view;
    if (!listView) {
        listView = [[MRListView alloc] initWithFrame:carousel.bounds];
        __weak typeof(self) weakSelf = self;
        listView.clickedMRBlock = ^(MRPR *clickedMR){
            [weakSelf goToMRDetail:clickedMR];
        };
    }
    listView.curMRPRS = [self curMRPRS];
    if (index == carousel.currentItemIndex) {
        [listView refreshToQueryData];
    }
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
    return listView;
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
    MRListView *listView = (MRListView *)carousel.currentItemView;
    listView.curMRPRS = [self curMRPRS];
    [listView refreshToQueryData];
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}

#pragma mark goto VC
- (void)goToMRDetail:(MRPR *)curMR{
    NSLog(@"%@", curMR.title);
    MRDetailViewController *vc = [MRDetailViewController new];
    vc.curMRPR = curMR;
    vc.curProject = _curProject;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
