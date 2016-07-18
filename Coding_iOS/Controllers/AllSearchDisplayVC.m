//
//  AllSearchDisplayVC.m
//  Coding_iOS
//
//  Created by jwill on 15/11/19.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "AllSearchDisplayVC.h"
#import "TopicHotkeyView.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "XHRealTimeBlur.h"
#import "CSSearchModel.h"
#import "RKSwipeBetweenViewControllers.h"
#import "CSHotTopicView.h"
#import "CSMyTopicVC.h"
#import "UserInfoViewController.h"
#import "WebViewController.h"
#import "CSHotTopicPagesVC.h"
#import "CSTopicDetailVC.h"
#import "PublicSearchModel.h"
#import "Login.h"
#import "NSString+Attribute.h"

// cell--------------
#import "ProjectAboutMeListCell.h"
#import "FileSearchCell.h"
#import "TweetSearchCell.h"
#import "UserSearchCell.h"
#import "TaskSearchCell.h"
#import "TopicSearchCell.h"
#import "PRMRSearchCell.h"

// nav--------
#import "TweetDetailViewController.h"
#import "ConversationViewController.h"

@interface AllSearchDisplayVC () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) XHRealTimeBlur *backgroundView;
@property (nonatomic, strong) UIButton *btnMore;
@property (nonatomic, strong) TopicHotkeyView *topicHotkeyView;

@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *dateSource;
@property (nonatomic, assign) BOOL      isLoading;
@property (nonatomic, strong) UILabel   *headerLabel;
@property (nonatomic, strong) PublicSearchModel *searchPros;
@property (nonatomic, strong) UIScrollView  *searchHistoryView;
@property (nonatomic, assign) double historyHeight;
- (void)initSearchResultsTableView;
- (void)initSearchHistoryView;
- (void)didClickedMoreHotkey:(UIGestureRecognizer *)sender;
- (void)didCLickedCleanSearchHistory:(id)sender;
- (void)didClickedContentView:(UIGestureRecognizer *)sender;
- (void)didClickedHistory:(UIGestureRecognizer *)sender;

@end

@implementation AllSearchDisplayVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
                view.frame = CGRectMake(0.0f, 0, kScreen_Width, kScreen_Height - 60.0f);
                view.backgroundColor = [UIColor clearColor];
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
            
            [self initSearchHistoryView];
        }
        
        
        [self.parentVC.view addSubview:_backgroundView];
        [self.parentVC.view addSubview:_contentView];
        [self.parentVC.view bringSubviewToFront:_contentView];
        self.searchBar.delegate = self;
    }
}

#pragma mark - UI

- (void)initSearchResultsTableView {
    
    _dateSource = [[NSMutableArray alloc] init];
    
    if(!_searchTableView) {
        _searchTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:_contentView.frame style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[TweetSearchCell class] forCellReuseIdentifier:@"TweetSearchCell"];
            [tableView registerClass:[ProjectAboutMeListCell class] forCellReuseIdentifier:@"ProjectAboutMeListCell"];
            [tableView registerClass:[FileSearchCell class] forCellReuseIdentifier:@"FileSearchCell"];
            [tableView registerClass:[UserSearchCell class] forCellReuseIdentifier:@"UserSearchCell"];
            [tableView registerClass:[TaskSearchCell class] forCellReuseIdentifier:@"TaskSearchCell"];
            [tableView registerClass:[TopicSearchCell class] forCellReuseIdentifier:@"TopicSearchCell"];
            [tableView registerClass:[PRMRSearchCell class] forCellReuseIdentifier:@"PRMRSearchCell"];

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
                label.textColor = [UIColor colorWithHexString:@"0x999999"];
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
        self.searchBar.delegate=self;
        [self registerForKeyboardNotifications];
    }
    
    [[_searchHistoryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.5)];
        view.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        [_searchHistoryView addSubview:view];
    }
    NSArray *array = [CSSearchModel getSearchHistory];
    CGFloat imageLeft = 12.0f;
    CGFloat textLeft = 34.0f;
    CGFloat height = 44.0f;
    
    _historyHeight=height*(array.count+1);
    //set history list
    [_searchHistoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@0);
        make.left.mas_equalTo(@0);
        make.width.mas_equalTo(kScreen_Width);
        make.height.mas_equalTo(_historyHeight);
    }];
    _searchHistoryView.contentSize = CGSizeMake(kScreen_Width, _historyHeight);

    
    for (int i = 0; i < array.count; i++) {
        
        UILabel *lblHistory = [[UILabel alloc] initWithFrame:CGRectMake(textLeft, i * height, kScreen_Width - textLeft, height)];
        lblHistory.userInteractionEnabled = YES;
        lblHistory.font = [UIFont systemFontOfSize:14];
        lblHistory.textColor = [UIColor colorWithHexString:@"0x222222"];
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
        view.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        
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
            view.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
            [_searchHistoryView addSubview:view];
        }
    }
    
}

#pragma mark - event
- (void)didClickedMoreHotkey:(UIGestureRecognizer *)sender {
    [self.searchBar resignFirstResponder];
    
    CSHotTopicPagesVC *vc = [CSHotTopicPagesVC new];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
    
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


#pragma mark -- goVC
- (void)goToProject:(Project *)project{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:project.project_path];
    [self.parentVC.navigationController pushViewController:vc animated:TRUE];
}

-(void)goToTweet:(Tweet *)tweet{
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
    vc.curTweet = tweet;
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToFileVC:(ProjectFile *)file{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:file.path];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToUserInfo:(User *)user{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:user.path];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToTask:(Task*)curTask{
    NSString *path=[NSString stringWithFormat:@"%@/task/%@",curTask.project.project_path,curTask.id];
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:path];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToTopic:(ProjectTopic*)curTopic{
    NSString *path=[NSString stringWithFormat:@"%@/topic/%@",curTopic.project.project_path,curTopic.id];
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:path];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToMRDetail:(MRPR *)curMR{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:curMR.path];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}


#pragma mark -
#pragma mark Search Data Request

- (void)refresh {
    if(_isLoading){
        [_searchTableView.infiniteScrollingView stopAnimating];
        return;
    }
    [self requestAll];
}

- (void)loadMore {
    if(_isLoading){
        [_searchTableView.infiniteScrollingView stopAnimating];
        return;
    }
    
    //判断分类
    int currentPage;
    int totalPage;
    
    switch (_curSearchType) {
        case eSearchType_Project:
            currentPage=[_searchPros.projects.page intValue];
            totalPage=[_searchPros.projects.totalPage intValue];
            break;
        case eSearchType_Tweet:
            currentPage=[_searchPros.tweets.page intValue];
            totalPage=[_searchPros.tweets.totalPage intValue];
            break;
        case eSearchType_Document:
            currentPage=[_searchPros.files.page intValue];
            totalPage=[_searchPros.files.totalPage intValue];
            break;
        case eSearchType_User:
            currentPage=[_searchPros.friends.page intValue];
            totalPage=[_searchPros.friends.totalPage intValue];
            break;
        case eSearchType_Task:
            currentPage=[_searchPros.tasks.page intValue];
            totalPage=[_searchPros.tasks.totalPage intValue];
            break;
        case eSearchType_Topic:
            currentPage=[_searchPros.project_topics.page intValue];
            totalPage=[_searchPros.project_topics.totalPage intValue];
            break;
        case eSearchType_Merge:
            currentPage=[_searchPros.merge_requests.page intValue];
            totalPage=[_searchPros.merge_requests.totalPage intValue];
            break;
        case eSearchType_Pull:
            currentPage=[_searchPros.pull_requests.page intValue];
            totalPage=[_searchPros.pull_requests.totalPage intValue];
            break;
        default:
            break;
    }
    
    if(currentPage >= totalPage)
    {
        [_searchTableView.infiniteScrollingView stopAnimating];
        return;
    }
    
    [self requestDataWithPage:currentPage + 1];
}

-(void)reloadDisplayData{
    [self.dateSource removeAllObjects];
    switch (_curSearchType) {
        case eSearchType_Project:
            [self.dateSource addObjectsFromArray:_searchPros.projects.list];
            break;
        case eSearchType_Tweet:
            [self.dateSource addObjectsFromArray:_searchPros.tweets.list];
            break;
        case eSearchType_Document:
            [self.dateSource addObjectsFromArray:_searchPros.files.list];
            break;
        case eSearchType_User:
            [self.dateSource addObjectsFromArray:_searchPros.friends.list];
            break;
        case eSearchType_Task:
            [self.dateSource addObjectsFromArray:_searchPros.tasks.list];
            break;
        case eSearchType_Topic:
            [self.dateSource addObjectsFromArray:_searchPros.project_topics.list];
            break;
        case eSearchType_Merge:
            [self.dateSource addObjectsFromArray:_searchPros.merge_requests.list];
            break;
        case eSearchType_Pull:
            [self.dateSource addObjectsFromArray:_searchPros.pull_requests.list];
            break;
        default:
            break;
    }
    
    __weak typeof(self) weakSelf = self;

    [_searchTableView configBlankPage:EaseBlankPageTypeProject_SEARCH hasData:[self noEmptyList] hasError:NO reloadButtonBlock:^(id sender) {
        [weakSelf requestAll];
    }];
    
    //空白页按钮事件
    _searchTableView.blankPageView.clickButtonBlock=^(EaseBlankPageType curType) {
        [weakSelf requestAll];
    };
    
    [self refreshHeaderTitle];
    _searchTableView.showsInfiniteScrolling = [self showTotalPage];
    [self.searchTableView reloadData];
}

//是否显示加载更多
-(BOOL)showTotalPage{
    switch (_curSearchType) {
        case eSearchType_Project:
            return  _searchPros.projects.page<_searchPros.projects.totalPage;
            break;
        case eSearchType_Tweet:
            return  _searchPros.tweets.page<_searchPros.tweets.totalPage;
            break;
        case eSearchType_Document:
            return  _searchPros.files.page<_searchPros.files.totalPage;
            break;
        case eSearchType_User:
            return  _searchPros.friends.page<_searchPros.friends.totalPage;
            break;
        case eSearchType_Task:
            return  _searchPros.tasks.page<_searchPros.tasks.totalPage;
            break;
        case eSearchType_Topic:
            return  _searchPros.project_topics.page<_searchPros.project_topics.totalPage;
            break;
        case eSearchType_Merge:
            return  _searchPros.merge_requests.page<_searchPros.merge_requests.totalPage;
            break;
        case eSearchType_Pull:
            return  _searchPros.pull_requests.page<_searchPros.pull_requests.totalPage;
            break;
        default:
            return NO;
            break;
    }
}

//判断是否空
-(BOOL)noEmptyList{
    switch (_curSearchType) {
        case eSearchType_Project:
            return  [_searchPros.projects.list count];
            break;
        case eSearchType_Tweet:
            return  [_searchPros.tweets.list count];
            break;
        case eSearchType_Document:
            return  [_searchPros.files.list count];
            break;
        case eSearchType_User:
            return  [_searchPros.friends.list count];
            break;
        case eSearchType_Task:
            return  [_searchPros.tasks.list count];
            break;
        case eSearchType_Topic:
            return  [_searchPros.project_topics.list count];
            break;
        case eSearchType_Merge:
            return  [_searchPros.merge_requests.list count];
            break;
        case eSearchType_Pull:
            return  [_searchPros.pull_requests.list count];
            break;
        default:
            return TRUE;
            break;
    }
}


//更新header数量和类型统计
- (void)refreshHeaderTitle{
    NSString *titleStr;
    switch (_curSearchType) {
        case eSearchType_Project:
            if ([_searchPros.projects.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的项目", [_searchPros.projects.totalRow longValue],self.searchBar.text];
            }
            break;
        case eSearchType_Tweet:
            if ([_searchPros.tweets.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的冒泡", [_searchPros.tweets.totalRow longValue],self.searchBar.text];
            }
            break;
        case eSearchType_Document:
            if ([_searchPros.files.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的文档", [_searchPros.files.totalRow longValue],self.searchBar.text];
            }
            break;
        case eSearchType_User:
            if ([_searchPros.friends.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的用户", [_searchPros.friends.totalRow longValue],self.searchBar.text];
            }
            break;
        case eSearchType_Task:
            if ([_searchPros.tasks.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的任务", [_searchPros.tasks.totalRow longValue],self.searchBar.text];
            }
            break;
        case eSearchType_Topic:
            if ([_searchPros.project_topics.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的讨论", [_searchPros.project_topics.totalRow longValue],self.searchBar.text];
            }
            break;
        case eSearchType_Merge:
            if ([_searchPros.merge_requests.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的合并请求", [_searchPros.merge_requests.totalRow longValue],self.searchBar.text];
            }
            break;
        case eSearchType_Pull:
            if ([_searchPros.pull_requests.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的 pull 请求", [_searchPros.pull_requests.totalRow longValue],self.searchBar.text];
            }
            break;
        default:
            break;
    }
    self.headerLabel.text=titleStr;
}

-(void)requestAll{
    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:@"全局搜索_全部(发起请求)"];
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"all" andPage:1 andBlock:^(id data, NSError *error) {
        if(data) {
            [weakSelf.dateSource removeAllObjects];
            weakSelf.searchPros = [NSObject objectOfClass:@"PublicSearchModel" fromJSON:data];
            NSDictionary *dataDic = (NSDictionary *)data;
            
            //topic 处理 content 关键字
            NSArray *resultTopic =[dataDic[@"project_topics"] objectForKey:@"list"] ;
            for (int i=0;i<[_searchPros.project_topics.list count];i++) {
                ProjectTopic *curTopic=[_searchPros.project_topics.list objectAtIndex:i];
                if ([resultTopic count]>i) {
                    curTopic.contentStr= [[[resultTopic objectAtIndex:i] objectForKey:@"content"] firstObject];
                }
            }
            
            //task 处理 description 关键字
            NSArray *resultTask =[dataDic[@"tasks"] objectForKey:@"list"] ;
            for (int i=0;i<[weakSelf.searchPros.tasks.list count];i++) {
                Task *curTask=[weakSelf.searchPros.tasks.list objectAtIndex:i];
                if ([resultTask count]>i) {
                    curTask.descript= [[[resultTask objectAtIndex:i] objectForKey:@"description"] firstObject];
                }
            }
            
            switch (weakSelf.curSearchType) {
                case eSearchType_Project:
                    [weakSelf.dateSource addObjectsFromArray:weakSelf.searchPros.projects.list];
                    break;
                case eSearchType_Tweet:
                    [weakSelf.dateSource addObjectsFromArray:weakSelf.searchPros.tweets.list];
                    break;
                case eSearchType_Document:
                    [weakSelf.dateSource addObjectsFromArray:weakSelf.searchPros.files.list];
                    break;
                case eSearchType_User:
                    [weakSelf.dateSource addObjectsFromArray:weakSelf.searchPros.friends.list];
                    break;
                case eSearchType_Task:
                    [weakSelf.dateSource addObjectsFromArray:weakSelf.searchPros.tasks.list];
                    break;
                case eSearchType_Topic:
                    [weakSelf.dateSource addObjectsFromArray:weakSelf.searchPros.project_topics.list];
                    break;
                case eSearchType_Merge:
                    [weakSelf.dateSource addObjectsFromArray:weakSelf.searchPros.merge_requests.list];
                    break;
                case eSearchType_Pull:
                    [weakSelf.dateSource addObjectsFromArray:weakSelf.searchPros.pull_requests.list];
                    break;
                default:
                    break;
            }
            
            [weakSelf.searchTableView configBlankPage:EaseBlankPageTypeProject_SEARCH hasData:[weakSelf noEmptyList] hasError:(error != nil) reloadButtonBlock:^(id sender) {
            }];
    
            [weakSelf.searchTableView reloadData];
            [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
            weakSelf.searchTableView.showsInfiniteScrolling = [weakSelf showTotalPage];
        }
        weakSelf.isLoading = NO;
        [self refreshHeaderTitle];
    }];
}

- (void)requestDataWithPage:(NSInteger)page {
    
    _isLoading = YES;
    
    __weak typeof(self) weakSelf = self;
    if (_curSearchType==eSearchType_Tweet) {
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"tweet" andPage:page andBlock:^(id data, NSError *error) {
            if(data) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSArray *resultA = [NSObject arrayFromJSON:dataDic[@"list"] ofObjects:@"Tweet"];
                [weakSelf.searchPros.tweets.list addObjectsFromArray:resultA];
                //更新page
                weakSelf.searchPros.tweets.page = dataDic[@"page"] ;
                weakSelf.searchPros.tweets.totalPage = dataDic[@"totalPage"] ;
                [weakSelf.dateSource addObjectsFromArray:resultA];
                [weakSelf.searchTableView reloadData];
                [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
                weakSelf.searchTableView.showsInfiniteScrolling = [weakSelf showTotalPage];
            }
            weakSelf.isLoading = NO;
        }];
    }else if(_curSearchType==eSearchType_Project){
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"project" andPage:page andBlock:^(id data, NSError *error) {
            if(data) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSArray *resultA = [NSObject arrayFromJSON:dataDic[@"list"] ofObjects:@"Project"];
                [weakSelf.searchPros.projects.list addObjectsFromArray:resultA];
                //更新page
                weakSelf.searchPros.projects.page = dataDic[@"page"] ;
                weakSelf.searchPros.projects.totalPage = dataDic[@"totalPage"] ;
                [weakSelf.dateSource addObjectsFromArray:resultA];
                [weakSelf.searchTableView reloadData];
                [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
                weakSelf.searchTableView.showsInfiniteScrolling = [weakSelf showTotalPage];
            }
            weakSelf.isLoading = NO;
        }];
    }else if(_curSearchType==eSearchType_Document){
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"file" andPage:page andBlock:^(id data, NSError *error) {
            if(data) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSArray *resultA = [NSObject arrayFromJSON:dataDic[@"list"] ofObjects:@"ProjectFile"];
                [weakSelf.searchPros.files.list addObjectsFromArray:resultA];
                //更新page
                weakSelf.searchPros.files.page = dataDic[@"page"] ;
                weakSelf.searchPros.files.totalPage = dataDic[@"totalPage"] ;
                [weakSelf.dateSource addObjectsFromArray:resultA];
                [weakSelf.searchTableView reloadData];
                [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
                weakSelf.searchTableView.showsInfiniteScrolling = [weakSelf showTotalPage];
            }
            weakSelf.isLoading = NO;
        }];
    }else if(_curSearchType==eSearchType_Merge){
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"mr" andPage:page andBlock:^(id data, NSError *error) {
            if(data) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSArray *resultA = [NSObject arrayFromJSON:dataDic[@"list"] ofObjects:@"MRPR"];
                [weakSelf.searchPros.merge_requests.list addObjectsFromArray:resultA];
                //更新page
                weakSelf.searchPros.merge_requests.page = dataDic[@"page"] ;
                weakSelf.searchPros.merge_requests.totalPage = dataDic[@"totalPage"] ;
                [weakSelf.dateSource addObjectsFromArray:resultA];
                [weakSelf.searchTableView reloadData];
                [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
                weakSelf.searchTableView.showsInfiniteScrolling = [weakSelf showTotalPage];
            }
            weakSelf.isLoading = NO;
        }];
    }else if(_curSearchType==eSearchType_Pull){
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"pr" andPage:page andBlock:^(id data, NSError *error) {
            if(data) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSArray *resultA = [NSObject arrayFromJSON:dataDic[@"list"] ofObjects:@"MRPR"];
                [weakSelf.searchPros.pull_requests.list addObjectsFromArray:resultA];
                //更新page
                weakSelf.searchPros.pull_requests.page = dataDic[@"page"] ;
                weakSelf.searchPros.pull_requests.totalPage = dataDic[@"totalPage"] ;
                [weakSelf.dateSource addObjectsFromArray:resultA];
                [weakSelf.searchTableView reloadData];
                [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
                weakSelf.searchTableView.showsInfiniteScrolling = [weakSelf showTotalPage];
            }
            weakSelf.isLoading = NO;
        }];
    }else if(_curSearchType==eSearchType_Task){
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"task" andPage:page andBlock:^(id data, NSError *error) {
            if(data) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSArray *resultA = [NSObject arrayFromJSON:dataDic[@"list"] ofObjects:@"Task"];
                
                //task 处理 description 关键字
                NSArray *resultTask =dataDic[@"list"];
                for (int i=0;i<[resultA count];i++) {
                    Task *curTask=[resultA objectAtIndex:i];
                    if ([resultTask count]>i) {
                        curTask.descript= [[[resultTask objectAtIndex:i] objectForKey:@"description"] firstObject];
                    }
                }

                [weakSelf.searchPros.tasks.list addObjectsFromArray:resultA];
                //更新page
                weakSelf.searchPros.tasks.page = dataDic[@"page"] ;
                weakSelf.searchPros.tasks.totalPage = dataDic[@"totalPage"] ;
                
                
                [weakSelf.dateSource addObjectsFromArray:resultA];
                [weakSelf.searchTableView reloadData];
                [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
                weakSelf.searchTableView.showsInfiniteScrolling = [weakSelf showTotalPage];
            }
            weakSelf.isLoading = NO;
        }];
    }else if(_curSearchType==eSearchType_User){
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"user" andPage:page andBlock:^(id data, NSError *error) {
            if(data) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSArray *resultA = [NSObject arrayFromJSON:dataDic[@"list"] ofObjects:@"User"];
                [weakSelf.searchPros.friends.list addObjectsFromArray:resultA];
                //更新page
                weakSelf.searchPros.friends.page = dataDic[@"page"] ;
                weakSelf.searchPros.friends.totalPage = dataDic[@"totalPage"] ;
                [weakSelf.dateSource addObjectsFromArray:resultA];
                [weakSelf.searchTableView reloadData];
                [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
                weakSelf.searchTableView.showsInfiniteScrolling = [weakSelf showTotalPage];
            }
            weakSelf.isLoading = NO;
        }];
    }else if(_curSearchType==eSearchType_Topic){
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"topic" andPage:page andBlock:^(id data, NSError *error) {
            if(data) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSArray *resultA = [NSObject arrayFromJSON:dataDic[@"list"] ofObjects:@"ProjectTopic"];
                
                //topic 处理 content 关键字
                NSArray *resultTopic =dataDic[@"list"];
                for (int i=0;i<[resultA count];i++) {
                    ProjectTopic *curTopic=[resultA objectAtIndex:i];
                    if ([resultTopic count]>i) {
                        curTopic.contentStr= [[[resultTopic objectAtIndex:i] objectForKey:@"content"] firstObject];
                    }
                }
                
                [weakSelf.searchPros.project_topics.list addObjectsFromArray:resultA];
                //更新page
                weakSelf.searchPros.project_topics.page = dataDic[@"page"] ;
                weakSelf.searchPros.project_topics.totalPage = dataDic[@"totalPage"] ;
                [weakSelf.dateSource addObjectsFromArray:resultA];
                [weakSelf.searchTableView reloadData];
                [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
                weakSelf.searchTableView.showsInfiniteScrolling = [weakSelf showTotalPage];
            }
            weakSelf.isLoading = NO;
        }];
    }else{
        [self.searchTableView.infiniteScrollingView stopAnimating];
        self.searchTableView.showsInfiniteScrolling = NO;
        self.isLoading=NO;
    }
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


- (void)registerForKeyboardNotifications
{
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
}

-(void)keyboardWasShown{
    if (_historyHeight+236>(kScreen_Height-64)) {
        [_searchHistoryView setHeight:kScreen_Height-236-64];
    }
}

-(void)keyboardWillBeHidden{
    if (_historyHeight+236>(kScreen_Height-64)) {
        [_searchHistoryView setHeight:_historyHeight];
    }
}

#pragma mark - UISearchBarDelegate Support

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [CSSearchModel addSearchHistory:searchBar.text];
    [self initSearchHistoryView];
    [self.searchBar resignFirstResponder];
    
    [self initSearchResultsTableView];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource Support

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_dateSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_curSearchType==eSearchType_Tweet) {
        TweetSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetSearchCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        Tweet *tweet = _dateSource[indexPath.row];
        cell.tweet = tweet;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if(_curSearchType==eSearchType_Project){
        ProjectAboutMeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectAboutMeListCell" forIndexPath:indexPath];
        cell.openKeywords=TRUE;
        Project *project=_dateSource[indexPath.row];
        [cell setProject:project hasSWButtons:NO hasBadgeTip:YES hasIndicator:NO];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if(_curSearchType==eSearchType_Document){
        FileSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileSearchCell" forIndexPath:indexPath];
        ProjectFile *file =_dateSource[indexPath.row];
        cell.file = file;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if(_curSearchType==eSearchType_User){
        UserSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserSearchCell" forIndexPath:indexPath];
        User *curUser = _dateSource[indexPath.row];
        cell.curUser = curUser;
        __weak typeof(self) weakSelf = self;
        cell.rightBtnClickedBlock=^(User *curUser) {
            ConversationViewController *vc = [[ConversationViewController alloc] init];
            User *copyUser=[curUser copy];
            copyUser.name=[NSString getStr:copyUser.name removeEmphasize:@"em"];
            copyUser.global_key=[NSString getStr:copyUser.global_key removeEmphasize:@"em"];
            copyUser.pinyinName=[NSString getStr:copyUser.pinyinName removeEmphasize:@"em"];
            vc.myPriMsgs = [PrivateMessages priMsgsWithUser:copyUser];
            [weakSelf.parentVC.navigationController pushViewController:vc animated:YES];
        };
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if(_curSearchType==eSearchType_Task){
        TaskSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskSearchCell" forIndexPath:indexPath];
        Task *task =_dateSource[indexPath.row];
        cell.task=task;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if(_curSearchType==eSearchType_Topic){
        TopicSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopicSearchCell" forIndexPath:indexPath];
        ProjectTopic *topic =_dateSource[indexPath.row];
        cell.curTopic = topic;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if(_curSearchType==eSearchType_Merge){
        PRMRSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PRMRSearchCell" forIndexPath:indexPath];
        MRPR *curMRPR =_dateSource[indexPath.row];
        cell.curMRPR = curMRPR;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if(_curSearchType==eSearchType_Pull){
        PRMRSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PRMRSearchCell" forIndexPath:indexPath];
        MRPR *curMRPR =_dateSource[indexPath.row];
        cell.curMRPR = curMRPR;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_curSearchType==eSearchType_Tweet) {
        Tweet *tweet = _dateSource[indexPath.row];
        return[TweetSearchCell cellHeightWithObj:tweet];
    }else if(_curSearchType==eSearchType_Project){
        return kProjectAboutMeListCellHeight;
    }else if(_curSearchType==eSearchType_Document){
        return kFileSearchCellHeight;
    }else if(_curSearchType==eSearchType_User){
        return kUserSearchCellHeight;
    }else if(_curSearchType==eSearchType_Task){
        Task *task = _dateSource[indexPath.row];
        return [TaskSearchCell cellHeightWithObj:task];
    }else if(_curSearchType==eSearchType_Topic){
        ProjectTopic *topic = _dateSource[indexPath.row];
        return [TopicSearchCell cellHeightWithObj:topic];
    }else if (_curSearchType==eSearchType_Pull){
        MRPR *mrpr = _dateSource[indexPath.row];
        return [PRMRSearchCell cellHeightWithObj:mrpr];
    }else if (_curSearchType==eSearchType_Merge){
        MRPR *mrpr = _dateSource[indexPath.row];
        return [PRMRSearchCell cellHeightWithObj:mrpr];
    }else{
        return 100;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(_curSearchType==eSearchType_Tweet) {
        [self goToTweet:_dateSource[indexPath.row]];
    }else if(_curSearchType==eSearchType_Project){
        [self goToProject:_dateSource[indexPath.row]];
    }else if (_curSearchType==eSearchType_Document){
        [self goToFileVC:_dateSource[indexPath.row]];
    }else if (_curSearchType==eSearchType_User){
        [self goToUserInfo:_dateSource[indexPath.row]];
    }else if (_curSearchType==eSearchType_Task){
        [self goToTask:_dateSource[indexPath.row]];
    }else if (_curSearchType==eSearchType_Topic){
        [self goToTopic:_dateSource[indexPath.row]];
    }else if (_curSearchType==eSearchType_Merge){
        [self goToMRDetail:_dateSource[indexPath.row]];
    }else if(_curSearchType==eSearchType_Pull){
        [self goToMRDetail:_dateSource[indexPath.row]];
    }
}



- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
//    [self setActive:TRUE];
    
    return TRUE;
}






@end
