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
#import "XHRealTimeBlur.h"
#import "CSSearchModel.h"
#import "RKSwipeBetweenViewControllers.h"
#import "CSHotTopicView.h"
#import "CSMyTopicVC.h"
#import "CSSearchCell.h"
#import "UserInfoViewController.h"
#import "WebViewController.h"
#import "TweetDetailViewController.h"

#import "CSHotTopicPagesVC.h"

#import "CSTopicDetailVC.h"

#define kCellIdentifier_Search  @"com.coding.search.tweet.result"

@interface CSSearchDisplayVC () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) XHRealTimeBlur *backgroundView;
@property (nonatomic, strong) UIButton *btnMore;
@property (nonatomic, strong) TopicHotkeyView *topicHotkeyView;

@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *tweetsArr;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) BOOL      isLoading;
@property (nonatomic, strong) UILabel   *headerLabel;

@property (nonatomic, strong) UIScrollView  *searchHistoryView;

- (void)initSubViewsInContentView;
- (void)initSearchResultsTableView;
- (void)initSearchHistoryView;
- (void)didCLickedCleanSearchHistory:(id)sender;
- (void)didClickedContentView:(UIGestureRecognizer *)sender;
- (void)didClickedHistory:(UIGestureRecognizer *)sender;

@end

@implementation CSSearchDisplayVC

- (void)dealloc {
    _searchHistoryView.delegate = nil;
}

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    
    if(!visible) {
        
        [_searchTableView removeFromSuperview];
        [_backgroundView removeFromSuperview];
        [_contentView removeFromSuperview];
        
        _searchTableView = nil;
        _contentView = nil;
        _backgroundView = nil;
        _searchHistoryView = nil;
        
        [super setActive:visible animated:animated];
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

            _contentView = ({
            
                UIView *view = [[UIView alloc] init];
                view.frame = CGRectMake(0.0f, 44 + kSafeArea_Top, kScreen_Width, kScreen_Height - (44 + kSafeArea_Top));
                view.backgroundColor = kColorNavBG;
                view.userInteractionEnabled = YES;
                
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedContentView:)];
                [view addGestureRecognizer:tapGestureRecognizer];
                
                view;
            });
            
            _backgroundView = ({
            
                XHRealTimeBlur *blur = [[XHRealTimeBlur alloc] initWithFrame:_contentView.frame];
                blur.blurStyle = XHBlurStyleTranslucentWhite;
                blur;
                
            });
            _backgroundView.userInteractionEnabled = NO;
            
            [self initSubViewsInContentView];
        }
    
//        [self.searchBar.superview addSubview:_backgroundView];
//        [self.searchBar.superview addSubview:_contentView];
//        [self.searchBar.superview bringSubviewToFront:_contentView];
        [self.parentVC.view addSubview:_backgroundView];
        [self.parentVC.view addSubview:_contentView];
        [self.parentVC.view bringSubviewToFront:_contentView];
        __weak typeof(self) weakSelf = self;
        self.searchBar.delegate = weakSelf;
    }
}

#pragma mark -
#pragma mark Private Method

- (void)initSubViewsInContentView {
    __weak typeof(self) weakSelf = self;
    
    _topicHotkeyView = [[TopicHotkeyView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0)];
    _topicHotkeyView.block = ^(NSDictionary *dict){
        [weakSelf.searchBar resignFirstResponder];
        
        CSTopicDetailVC *vc = [[CSTopicDetailVC alloc] init];
        vc.topicID = [dict[@"id"] intValue];
        [weakSelf.parentVC.navigationController pushViewController:vc animated:YES];
        
    };
    [_contentView addSubview:_topicHotkeyView];
    [_topicHotkeyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@0);
        make.top.mas_equalTo(@0);
        make.width.mas_equalTo(kScreen_Width);
        make.height.mas_equalTo(@0);
    }];
    
    [self initSearchHistoryView];
    
    [[Coding_NetAPIManager sharedManager] request_TopicHotkeyWithBlock:^(id data, NSError *error) {
        if(data && _contentView) {
            NSArray *array = data;
            NSMutableArray *hotkeyArray = [[NSMutableArray alloc] initWithCapacity:6];
            for (int i = 0; i < array.count; i++) {
                if (i == 6) {
                    break;
                }
                [hotkeyArray addObject:array[i]];
            }
            
            [weakSelf.topicHotkeyView setHotkeys:hotkeyArray];
            [weakSelf.topicHotkeyView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(weakSelf.topicHotkeyView.frame.size.height);
            }];
        }
    }];
}

- (void)initSearchResultsTableView {
    
    _tweetsArr = [[NSMutableArray alloc] init];
    _currentPage = 1;
    _totalCount = 0;
    _totalPage = 0;
    
    if(!_searchTableView) {
        _searchTableView = ({
            
            UITableView *tableView = [[UITableView alloc] initWithFrame:_contentView.frame style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[CSSearchCell class] forCellReuseIdentifier:kCellIdentifier_Search];
            tableView.dataSource = self;
            tableView.delegate = self;
            {
                __weak typeof(self) weakSelf = self;
                [tableView addInfiniteScrollingWithActionHandler:^{
                    [weakSelf loadMore];
                }];
            }
            
            [self.parentVC.view addSubview:tableView];
            
            self.headerLabel = ({
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, kScreen_Width, 44)];
                label.backgroundColor = [UIColor clearColor];
                label.textColor = kColor999;
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:12];
                
                label;
            });
            
            UIView *headview = ({
                UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
                v.backgroundColor = [UIColor whiteColor];
                [v addSubview:self.headerLabel];
                v;
            });
            tableView.tableHeaderView = headview;
            
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView;
        });
    }
    [_searchTableView.superview bringSubviewToFront:_searchTableView];

    [_searchTableView reloadData];
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
            make.width.mas_equalTo(kScreen_Width);
            make.height.mas_equalTo(@350);
        }];
        _searchHistoryView.contentSize = CGSizeMake(kScreen_Width, 0);
    }
    
    [[_searchHistoryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.5)];
        view.backgroundColor = kColorDDD;
        [_searchHistoryView addSubview:view];
    }
    NSArray *array = [CSSearchModel getSearchHistory];
    CGFloat imageLeft = 12.0f;
    CGFloat textLeft = 34.0f;
    CGFloat height = 40.0f;
    
    for (int i = 0; i < array.count; i++) {
        
        UILabel *lblHistory = [[UILabel alloc] initWithFrame:CGRectMake(textLeft, i * height, kScreen_Width - textLeft, height)];
        lblHistory.userInteractionEnabled = YES;
        lblHistory.font = [UIFont systemFontOfSize:14];
        lblHistory.textColor = kColor222;
        lblHistory.text = array[i];
        
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        leftView.left = 12;
        leftView.centerY = lblHistory.centerY;
        leftView.image = [UIImage imageNamed:@"icon_search_clock"];
        
        UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        rightImageView.right = kScreen_Width - 12;
        rightImageView.centerY = lblHistory.centerY;
        rightImageView.image = [UIImage imageNamed:@"icon_arrow_searchHistory"];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(imageLeft, (i + 1) * height, kScreen_Width - imageLeft, 0.5)];
        view.backgroundColor = kColorDDD;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedHistory:)];
        [lblHistory addGestureRecognizer:tapGestureRecognizer];
        
        [_searchHistoryView addSubview:lblHistory];
        [_searchHistoryView addSubview:leftView];
        [_searchHistoryView addSubview:rightImageView];
        [_searchHistoryView addSubview:view];
    }
    
    if(array.count) {
    
        UIButton *btnClean = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClean.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnClean setTitle:@"清除搜索历史" forState:UIControlStateNormal];
        [btnClean setTitleColor:[UIColor colorWithHexString:@"0x1bbf75"] forState:UIControlStateNormal];
        [btnClean setFrame:CGRectMake(0, array.count * height, kScreen_Width, height)];
        [_searchHistoryView addSubview:btnClean];
        [btnClean addTarget:self action:@selector(didCLickedCleanSearchHistory:) forControlEvents:UIControlEventTouchUpInside];
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(imageLeft, (array.count + 1) * height, kScreen_Width - imageLeft, 0.5)];
            view.backgroundColor = kColorDDD;
            [_searchHistoryView addSubview:view];
        }
    }
    
}

- (void)didCLickedCleanSearchHistory:(id)sender {

    [CSSearchModel cleanAllSearchHistory];
    [self initSearchHistoryView];
}

- (void)didClickedContentView:(UIGestureRecognizer *)sender {

    [self.searchBar resignFirstResponder];
}

- (void)didClickedHistory:(UIGestureRecognizer *)sender {

    UILabel *label = (UILabel *)sender.view;
    self.searchBar.text = label.text;
    [CSSearchModel addSearchHistory:self.searchBar.text];
    [self initSearchHistoryView];
    [self.searchBar resignFirstResponder];
    
    [self initSearchResultsTableView];
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
    
    if(page == 1)
        self.headerLabel.text = @"";
    
    _isLoading = YES;
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Tweet_WithSearchString:self.searchBar.text andPage:page andBlock:^(id data, NSError *error) {
       
        if(data) {
            NSDictionary *dataDic = (NSDictionary *)data;
            weakSelf.currentPage = [[dataDic valueForKey:@"page"] intValue];
            weakSelf.totalPage = [[dataDic valueForKey:@"totalPage"] intValue];
            weakSelf.totalCount = [[dataDic valueForKey:@"totalRow"] intValue];
            NSArray *resultA = [NSObject arrayFromJSON:[dataDic objectForKey:@"list"] ofObjects:@"Tweet"];
            [weakSelf.tweetsArr addObjectsFromArray:resultA];
            [weakSelf.searchTableView reloadData];
            [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
            weakSelf.searchTableView.showsInfiniteScrolling = weakSelf.currentPage >= weakSelf.totalPage ? NO : YES;
        }
        
        weakSelf.isLoading = NO;
        weakSelf.headerLabel.text = [NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的冒泡", (long)weakSelf.totalCount, weakSelf.searchBar.text, nil];
    }];
}

- (void)analyseLinkStr:(NSString *)linkStr{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.parentVC.navigationController pushViewController:vc animated:YES];
    }else{
        //网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.parentVC.navigationController pushViewController:webVc animated:YES];
    }
}



#pragma mark -
#pragma mark UISearchBarDelegate Support

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [CSSearchModel addSearchHistory:searchBar.text];
    [self initSearchHistoryView];
    [self.searchBar resignFirstResponder];
    
    [self initSearchResultsTableView];
    
}

#pragma mark -
#pragma mark UITableViewDelegate & UITableViewDataSource Support

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_tweetsArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CSSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Search forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Tweet *tweet = _tweetsArr[indexPath.row];
    cell.tweet = tweet;
    
    __weak typeof(self) weakSelf = self;
    
    cell.userBtnClickedBlock = ^(User *curUser){
        UserInfoViewController *vc = [[UserInfoViewController alloc] init];
        vc.curUser = curUser;
        [self.parentVC.navigationController pushViewController:vc animated:YES];
    };
    cell.mediaItemClickedBlock = ^(HtmlMediaItem *curItem){
        [weakSelf analyseLinkStr:curItem.href];
    };
    
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = _tweetsArr[indexPath.row];
    return[CSSearchCell cellHeightWithObj:tweet];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tweet *tweet = _tweetsArr[indexPath.row];
    
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
    vc.curTweet = tweet;
    vc.deleteTweetBlock = ^(Tweet *toDeleteTweet){
    };
    [self.parentVC.navigationController pushViewController:vc animated:YES];
    
}

@end
