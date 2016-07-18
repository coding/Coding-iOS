//
//  CSHotTopicPagesVC.m
//  Coding_iOS
//
//  Created by Lambda on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSHotTopicPagesVC.h"

#import "CSHotTopicView.h"
#import "CSMyTopicVC.h"
#import "SMPageControl.h"
#import "CSSearchVC.h"
#import "CSSearchDisplayVC.h"

@interface CSHotTopicPagesVC ()<UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) SMPageControl *pageControl;
@property (nonatomic,strong) UIView *navigationBarView;

@property (nonatomic,strong)NSArray *navTitles;
//搜索
@property (nonatomic, strong) UISearchBar       *searchBar;
@property (strong, nonatomic) CSSearchDisplayVC *searchDisplayVC;
@end

@implementation CSHotTopicPagesVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClicked:)];
    [self.navigationItem setRightBarButtonItem:rightBarItem animated:NO];

    [self setupUI];
}

- (void)onGoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:self.navigationBarView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationBarView removeFromSuperview];
}

#pragma mark -
- (void)searchItemClicked:(id)sender{
    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:@"热门话题_搜索"];
    if(!_searchBar) {
        
        _searchBar = ({
            
            UISearchBar *searchBar = [[UISearchBar alloc] init];
            searchBar.delegate = self;
            [searchBar sizeToFit];
            [searchBar setPlaceholder:@"搜索冒泡、用户名、话题"];
            [searchBar setTintColor:[UIColor whiteColor]];
            [searchBar setTranslucent:NO];
            [searchBar insertBGColor:[UIColor colorWithHexString:@"0x28303b"]];
            searchBar;
        });
        [self.navigationController.view addSubview:_searchBar];
        [_searchBar setY:20];
    }
    
    if (!_searchDisplayVC) {
        _searchDisplayVC = ({
            CSSearchDisplayVC *searchVC = [[CSSearchDisplayVC alloc] initWithSearchBar:_searchBar contentsController:self];
            searchVC.parentVC = self;
            searchVC.delegate = self;
            searchVC.displaysSearchBarInNavigationBar = NO;
            searchVC;
        });
    }
    
    [_searchBar becomeFirstResponder];
}

#pragma mark -
#pragma mark UISearchBarDelegate Support

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    return YES;
}

#pragma mark -


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateNavItems:scrollView.contentOffset.x];
    
    float mid   = [UIScreen mainScreen].bounds.size.width/2 - 45.0;
    float width = [UIScreen mainScreen].bounds.size.width;
    CGFloat xOffset = scrollView.contentOffset.x;
    int i = 0;
    for(UILabel *v in _navTitles){
        CGFloat alpha = 0.0;
        if(v.frame.origin.x < mid)
            alpha = 1 - (xOffset - i*width) / width;
        else if(v.frame.origin.x >mid)
            alpha=(xOffset - i*width) / width + 1;
        else if(v.frame.origin.x == mid-5)
            alpha = 1.0;
        i++;
        v.alpha = alpha;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self sendNewIndex:scrollView];
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self sendNewIndex:scrollView];
}

-(void)sendNewIndex:(UIScrollView *)scrollView{
    CGFloat xOffset    = scrollView.contentOffset.x;
    NSInteger index = ((int) roundf(xOffset) % (2 * (int)kScreen_Width)) / kScreen_Width;
    
    if (self.pageControl.currentPage != index)
    {
        self.pageControl.currentPage = index;
    }
}

#pragma mark -

-(void)updateNavItems:(CGFloat) xOffset{
    __block int i = 0;
    [_navTitles enumerateObjectsUsingBlock:^(UIView* v, NSUInteger idx, BOOL *stop) {
        CGFloat distance = (kScreen_Width/2) - 60;
        CGSize vSize     = CGSizeMake(100, 16);
        CGFloat originX  = ((kScreen_Width/2 - vSize.width/2) + i*distance) - xOffset/(kScreen_Width/distance);
        v.frame          = (CGRect){originX, 8, vSize.width, vSize.height};
        i++;
    }];
}

- (void)setupUI {
    self.navigationItem.title = @"";
    
    CGRect frame                                              = CGRectMake(0, 0, kScreen_Width, self.view.bounds.size.height);
    self.scrollView                                           = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.backgroundColor                           = [UIColor clearColor];
    self.scrollView.pagingEnabled                             = YES;
    self.scrollView.showsHorizontalScrollIndicator            = NO;
    self.scrollView.showsVerticalScrollIndicator              = NO;
    self.scrollView.delegate                                  = self;
    self.scrollView.bounces                                   = NO;
    [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.scrollView .clipsToBounds = YES;
    self.scrollView.contentSize = CGSizeMake(kScreen_Width * 2, 0);
    
    _navigationBarView                 = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreen_Width, 44}];
    _navigationBarView.backgroundColor = [UIColor clearColor];
    
    // Make the page control
    
    self.pageControl = ({
        SMPageControl *pgC = [[SMPageControl alloc] init];
        pgC.userInteractionEnabled = NO;
        pgC.backgroundColor = [UIColor clearColor];
        pgC.pageIndicatorImage = [UIImage imageNamed:@"nav_page_unselected"];
        pgC.currentPageIndicatorImage = [UIImage imageNamed:@"nav_page_selected"];
        pgC.frame = CGRectMake(0, 32.0, kScreen_Width, 7.0);
        pgC.numberOfPages = 2;
        pgC.currentPage = 0;
        pgC;
    });

    _navigationBarView.userInteractionEnabled = NO;
    [_navigationBarView addSubview:self.pageControl];
    
    // Adds all views
    CSHotTopicView *v1 = [[CSHotTopicView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, self.view.height - 50)];
    v1.backgroundColor = [UIColor whiteColor];
    
    CSMyTopicView *v2 = [[CSMyTopicView alloc]initWithFrame:CGRectMake(kScreen_Width+1, 0, kScreen_Width, self.view.height - 50)];
    v2.backgroundColor = [UIColor whiteColor];
    
    
    v1.parentVC = self;
    v2.parentVC = self;
    
    [self.scrollView addSubview:v1];
    [self.scrollView addSubview:v2];
    
    
    CGFloat titleWidth = 100;
    CGFloat distance = (kScreen_Width/2) - 60;
    UILabel *la1 = [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width/2 - titleWidth/2) + 0*distance, 8, titleWidth, 16)];
    la1.text = @"热门话题";
    la1.textAlignment = NSTextAlignmentCenter;
    la1.font = [UIFont boldSystemFontOfSize:18];
    la1.textColor = [UIColor whiteColor];
    
    UILabel *la2 = [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width/2 - titleWidth/2) + 1*distance, 8, titleWidth, 16)];
    la2.text = @"我的话题";
    la2.textAlignment = NSTextAlignmentCenter;
    la2.font = [UIFont boldSystemFontOfSize:18];
    la2.textColor = [UIColor whiteColor];
    
    
    la2.alpha = 0;
    
    [_navigationBarView addSubview:la1];
    [_navigationBarView addSubview:la2];
    _navTitles = @[la1,la2];
    
}



@end
