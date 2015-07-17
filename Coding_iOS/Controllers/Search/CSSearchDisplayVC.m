//
//  CSSearchDisplayVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/14.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSSearchDisplayVC.h"

#import "TopicHotkeyView.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"

#import "CSSearchModel.h"

#import "RKSwipeBetweenViewControllers.h"
#import "CSHotTopicVC.h"
#import "CSMyTopicVC.h"

#define kCellIdentifier_Search  @"com.coding.search.tweet.result"

@interface CSSearchDisplayVC () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *btnMore;
@property (nonatomic, strong) TopicHotkeyView *topicHotkeyView;

@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *tweetsArr;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL      isLoading;

@property (nonatomic, strong) UIScrollView  *searchHistoryView;

- (void)initSubViewsInContentView;
- (void)initSearchResultsTableView;
- (void)initSearchHistoryView;
- (void)didClickedMoreHotkey:(id)sender;
- (void)didCLickedCleanSearchHistory:(id)sender;
@end

@implementation CSSearchDisplayVC

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    
    if(!visible) {
    
        if(_contentView) {
        
            [_contentView removeFromSuperview];
            [_searchTableView removeFromSuperview];
            [super setActive:visible animated:animated];
        }
    }else {
    
        [super setActive:visible animated:animated];
        NSArray *subViews = self.searchContentsController.view.subviews;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
            
            for (UIView *view in subViews) {
                
                if ([view isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                    
                    NSArray *sub = view.subviews;
                    ((UIView*)sub[2]).hidden = YES;
                }
            }
        } else {
           
            [[subViews lastObject] removeFromSuperview];
        }
        
        if(!_contentView) {
            
            _contentView = [[UIView alloc] init];
            _contentView.frame = CGRectMake(0.0f, 60.0f, kScreen_Width, kScreen_Height - 60.0f);
            _contentView.backgroundColor = [UIColor whiteColor];
            
            [self initSubViewsInContentView];
        }
        
        [self.searchBar.superview addSubview:_contentView];
        [self.searchBar.superview bringSubviewToFront:_contentView];
        __weak typeof(self) weakSelf = self;
        self.searchBar.delegate = weakSelf;
    }
}

#pragma mark -
#pragma mark Private Method

- (void)initSubViewsInContentView {

    UILabel *lblHotKey = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 5.0f, 100, 30.0f)];
    [lblHotKey setText:@"热门话题"];
    [lblHotKey setFont:[UIFont systemFontOfSize:14.0f]];
    [lblHotKey setTextColor:[UIColor colorWithHexString:@"0x999999"]];
    [_contentView addSubview:lblHotKey];
    
    UIImage *imgMore = [UIImage imageNamed:@"me_info_arrow_left"];
    _btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMore = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 31.0f, 10.0f, 20.0f, 20.0f)];
    [_btnMore setImage:imgMore forState:UIControlStateNormal];
    [_btnMore addTarget:self action:@selector(didClickedMoreHotkey:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_btnMore];
    
    _topicHotkeyView = [[TopicHotkeyView alloc] init];
    [_contentView addSubview:_topicHotkeyView];
    [_topicHotkeyView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(@0);
        make.top.mas_equalTo(@40);
        make.width.mas_equalTo(kScreen_Width);
        make.height.mas_equalTo(@0);
    }];
    
    [self initSearchHistoryView];
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_TopicHotkeyWithBlock:^(id data, NSError *error) {
        if(data) {
            NSArray *array = data;
            NSMutableArray *hotkeyArray = [[NSMutableArray alloc] initWithCapacity:6];
            for (int i = 0; i < (array.count >= 6 ? 6 : array.count); i++) {
                [hotkeyArray addObject:[(NSDictionary *)array[i] objectForKey:@"name"]];
            }
            
            [weakSelf.topicHotkeyView setHotkeys:hotkeyArray];
            [weakSelf.topicHotkeyView mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.left.mas_equalTo(@0);
                make.top.mas_equalTo(@40);
                make.width.mas_equalTo(kScreen_Width);
                make.height.mas_equalTo(weakSelf.topicHotkeyView.frame.size.height);
            }];
//            [weakSelf.searchHistoryView setFrame:CGRectMake(weakSelf.searchHistoryView.frame.origin.x, weakSelf.topicHotkeyView.frame.origin.y + weakSelf.topicHotkeyView.frame.size.height,
//                                                            weakSelf.searchHistoryView.frame.size.width, weakSelf.searchHistoryView.frame.size.height)];
        }
    }];
}

- (void)initSearchResultsTableView {

    _tweetsArr = [[NSMutableArray alloc] init];
    _currentPage = 1;
    
    _searchTableView = ({
    
        UITableView *tableView = [[UITableView alloc] initWithFrame:_contentView.frame style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier_Search];
        tableView.dataSource = self;
        tableView.delegate = self;
        {
            __weak typeof(self) weakSelf = self;
            [tableView addInfiniteScrollingWithActionHandler:^{
                [weakSelf loadMore];
            }];
        }
        
        [self.searchBar.superview addSubview:tableView];
        [self.searchBar.superview bringSubviewToFront:tableView];
        tableView;
    });
    
//    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.searchTableView];
//    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [self refresh];
}

- (void)initSearchHistoryView {

    if(!_searchHistoryView) {
    
        _searchHistoryView = [[UIScrollView alloc] init];
        _searchHistoryView.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_searchHistoryView];
        
        [_searchHistoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(_topicHotkeyView.mas_bottom);
            make.left.mas_equalTo(@0);
            make.width.mas_equalTo(@320);
            make.height.mas_equalTo(@280);
        }];
    }
    
    [[_searchHistoryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSArray *array = [CSSearchModel getSearchHistory];
    CGFloat imageLeft = 12.0f;
    CGFloat textLeft = 32.0f;
    CGFloat height = 35.0f;
    UILabel *lblHistory = nil;
    UIImageView *imageView = nil;
    UIImage *image = [UIImage imageNamed:@"time_clock_icon"];
    
    for (int i = 0; i < array.count; i++) {
        
        lblHistory = [[UILabel alloc] initWithFrame:CGRectMake(textLeft, i * height, kScreen_Width - 2 * textLeft, height)];
        lblHistory.textColor = [UIColor colorWithHexString:@"0x999999"];
        lblHistory.text = array[i];
        
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(imageLeft, i * height + (35 - image.size.height) / 2 + 2, image.size.width, image.size.height);
        
        [_searchHistoryView addSubview:lblHistory];
        [_searchHistoryView addSubview:imageView];
        lblHistory = nil;
        imageView = nil;
    }
    
    if(array.count) {
    
        UIButton *btnClean = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClean setTitle:@"清除搜索历史" forState:UIControlStateNormal];
        [btnClean setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
        [btnClean setTitleColor:[UIColor colorWithHexString:@"0x3bbd79" andAlpha:.3] forState:UIControlStateHighlighted];
        [btnClean setFrame:CGRectMake(0, array.count * height, kScreen_Width, height)];
        [_searchHistoryView addSubview:btnClean];
        [btnClean addTarget:self action:@selector(didCLickedCleanSearchHistory:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)didClickedMoreHotkey:(id)sender {

    RKSwipeBetweenViewControllers *nav_topic = [RKSwipeBetweenViewControllers newSwipeBetweenViewControllers];
    [nav_topic.viewControllerArray addObjectsFromArray:@[[CSHotTopicVC new],[CSMyTopicVC new]]];
    nav_topic.buttonText = @[@"热门话题", @"我的话题"];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    
    if (self.parentVC) {
        [self.parentVC.view.window.layer addAnimation:transition forKey:nil];
        [self.parentVC presentViewController:nav_topic animated:NO completion:^{
            
        }];
    }

}

- (void)didCLickedCleanSearchHistory:(id)sender {

    [CSSearchModel cleanAllSearchHistory];
    [self initSearchHistoryView];
}

#pragma mark -
#pragma mark Search Data Request

- (void)refresh {
    
    if(_isLoading)
        return;
    
    [self requestDataWithPage:_currentPage];
}

- (void)loadMore {

    if(_isLoading)
        return;
    
    if(_currentPage >= _totalPage)
        return;
    
    [self requestDataWithPage:_currentPage + 1];
}

- (void)requestDataWithPage:(NSInteger)page {

    if(page < 1)
        page = 1;
    
    _isLoading = YES;
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Tweet_WithSearchString:self.searchBar.text andPage:page andBlock:^(id data, NSError *error) {
       
        if(data) {
            
            NSDictionary *dataDic = (NSDictionary *)data;
            weakSelf.currentPage = [[dataDic valueForKey:@"page"] intValue];
            weakSelf.totalPage = [[dataDic valueForKey:@"totalPage"] intValue];
            NSArray *resultA = [NSObject arrayFromJSON:[dataDic objectForKey:@"list"] ofObjects:@"Tweet"];
            [weakSelf.tweetsArr addObjectsFromArray:resultA];
            [weakSelf.searchTableView reloadData];
            [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
            weakSelf.searchTableView.showsInfiniteScrolling = weakSelf.currentPage >= weakSelf.totalPage ? NO : YES;
        }
        
        weakSelf.isLoading = NO;
    }];
}

#pragma mark -
#pragma mark UISearchBarDelegate Support

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [CSSearchModel addSearchHistory:searchBar.text];
    [self initSearchHistoryView];
    
//    if(!_searchTableView) {
//        
//        [self initSearchResultsTableView];
//    }
//    else {
//        
//        [self.searchBar.superview bringSubviewToFront:_searchTableView];
//    }
//    
//    [searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark UITableViewDelegate & UITableViewDataSource Support

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_tweetsArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Search forIndexPath:indexPath];
    Tweet *tweet = _tweetsArr[indexPath.row];
    cell.textLabel.text = tweet.content;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
