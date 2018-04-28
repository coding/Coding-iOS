//
//  TaskBoardsViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/25.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "TaskBoardsViewController.h"
#import "iCarousel.h"
#import "EABoardTaskListView.h"
#import "Coding_NetAPIManager.h"
#import "EditTaskViewController.h"
#import "SMPageControl.h"

@interface TaskBoardsViewController ()<iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) iCarousel *myCarousel;
@property (strong, nonatomic) UIBarButtonItem *addItem;
@property (strong, nonatomic) SMPageControl *myPageControl;

@property (strong, nonatomic) NSArray<EABoardTaskList *> *myBoardTLs;

@end

@implementation TaskBoardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"任务看板";
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
        [self.view addSubview:icarousel];
        [icarousel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 49, 0));
        }];
        icarousel;
    });
    self.addItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(addItemClicked:)];
}

- (void)addItemClicked:(id)sender{
    EditTaskViewController *vc = [EditTaskViewController new];
    EABoardTaskList *curBoardTL = ((EABoardTaskListView *)_myCarousel.currentItemView).myBoardTL;
    vc.myTask = [Task taskWithBoardTaskList:curBoardTL andUser:[Login curLoginUser]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_myBoardTLs) {
        [self refresh];
    }else{
        [(EABoardTaskListView *)_myCarousel.currentItemView refresh];
    }
}

- (void)refresh{
    if (!_myBoardTLs) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;;
    [[Coding_NetAPIManager sharedManager] request_BoardTaskListsInPro:_myProject andBlock:^(NSArray<EABoardTaskList *> *data, NSError *error) {
        [weakSelf.view endLoading];
        if (data) {
            weakSelf.myBoardTLs = data;
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:weakSelf.myBoardTLs.count > 0 hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

- (void)setMyBoardTLs:(NSArray<EABoardTaskList *> *)myBoardTLs{
    NSMutableArray<EABoardTaskList *> *freshBoardTLs = myBoardTLs.mutableCopy ?: @[].mutableCopy;
    if (freshBoardTLs.count == 2 && !_myProject.hasEverHandledBoard) {
        freshBoardTLs = @[[EABoardTaskList blankBoardTLWithProject:_myProject]].mutableCopy;
    }else{
        [freshBoardTLs addObject:[EABoardTaskList blankBoardTLWithProject:_myProject]];
    }
    BOOL needReloadCarousel = NO;
    if (!_myBoardTLs) {
        needReloadCarousel = YES;
    }else{
        NSSet *oldSet = [NSSet setWithArray:[_myBoardTLs valueForKey:@"id"]];
        NSSet *freshSet = [NSSet setWithArray:[freshBoardTLs valueForKey:@"id"]];
        if (![freshSet isEqualToSet:oldSet]) {
            needReloadCarousel = YES;
        }
    }
    if (needReloadCarousel) {
        _myBoardTLs = freshBoardTLs.copy;
        [_myCarousel reloadData];
        [self configPageControl];
        [self configNavItem];
        self.view.backgroundColor = _myBoardTLs.count == 1? kColorTableBG: kColorTableSectionBg;
        self.myPageControl.hidden = (_myBoardTLs.count == 1);
    }else{
        [(EABoardTaskListView *)_myCarousel.currentItemView refresh];
    }
}

- (void)configNavItem{
    if (_myBoardTLs.count <= _myCarousel.currentItemIndex) {
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        EABoardTaskList *curBoardTL = _myBoardTLs[_myCarousel.currentItemIndex];
        self.navigationItem.rightBarButtonItem = (curBoardTL.isBlankType || curBoardTL.type == EABoardTaskListDone)? nil: self.addItem;
    }
}

- (void)configPageControl{
    if (!_myPageControl) {
        _myPageControl = ({
            SMPageControl *pageControl = [SMPageControl new];
            pageControl.userInteractionEnabled = NO;
            pageControl.backgroundColor = [UIColor clearColor];
            [self.view addSubview:pageControl];
            [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.view);
                make.height.mas_equalTo(10);
                make.bottom.offset(-(50 - 10)/ 2);
            }];
            pageControl;
        });
    }
    NSInteger numberOfPages = _myBoardTLs.count;
    _myPageControl.numberOfPages = numberOfPages;
    for (NSInteger index = 0; index < numberOfPages; index++) {
        [_myPageControl setImage:[UIImage imageNamed:(index == numberOfPages - 1)? @"taskboard_add_page_unselected": @"taskboard_normal_page_unselected"] forPage:index];
        [_myPageControl setCurrentImage:[UIImage imageNamed:(index == numberOfPages - 1)? @"taskboard_add_page_selected": @"taskboard_normal_page_selected"] forPage:index];
    }
    _myPageControl.currentPage = _myCarousel.currentItemIndex;
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return _myBoardTLs.count;
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    EABoardTaskListView *listView = (EABoardTaskListView *)view;
    if (!listView) {
        listView = [EABoardTaskListView new];
        __weak typeof(self) weakSelf = self;
        listView.boardTLsChangedBlock = ^{
            [weakSelf refresh];
        };
    }
    listView.frame = carousel.bounds;
    listView.myBoardTL = _myBoardTLs[index];
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
    return listView;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
    _myPageControl.currentPage = carousel.currentItemIndex;
    [self configNavItem];
}

@end
