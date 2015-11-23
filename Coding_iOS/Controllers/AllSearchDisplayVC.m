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
#import "ProjectTaskListViewCell.h"


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
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) BOOL      isLoading;
@property (nonatomic, strong) UILabel   *headerLabel;
@property (nonatomic, strong) PublicSearchModel *searchPros;
@property (nonatomic, strong) UIScrollView  *searchHistoryView;

- (void)initSubViewsInContentView;
- (void)initSearchResultsTableView;
- (void)initSearchHistoryView;
- (void)didClickedMoreHotkey:(UIGestureRecognizer *)sender;
- (void)didCLickedCleanSearchHistory:(id)sender;
- (void)didClickedContentView:(UIGestureRecognizer *)sender;
- (void)didClickedHistory:(UIGestureRecognizer *)sender;

@end

@implementation AllSearchDisplayVC
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
    _currentPage = 1;
    _totalCount = 0;
    _totalPage = 0;
    
    if(!_searchTableView) {
        _searchTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:_contentView.frame style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[TweetSearchCell class] forCellReuseIdentifier:@"TweetSearchCell"];
            [tableView registerClass:[ProjectAboutMeListCell class] forCellReuseIdentifier:@"ProjectAboutMeListCell"];
            [tableView registerClass:[FileSearchCell class] forCellReuseIdentifier:@"FileSearchCell"];
            [tableView registerClass:[UserSearchCell class] forCellReuseIdentifier:@"UserSearchCell"];
            [tableView registerClass:[ProjectTaskListViewCell class] forCellReuseIdentifier:@"ProjectTaskListViewCell"];
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
    
    //set history list
    [_searchHistoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@0);
        make.left.mas_equalTo(@0);
        make.width.mas_equalTo(kScreen_Width);
        make.height.mas_equalTo(height*(array.count+1));
    }];
    _searchHistoryView.contentSize = CGSizeMake(kScreen_Width, 0);

    
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
        default:
            break;
    }
    [self refreshHeaderTitle];
    [self.searchTableView.infiniteScrollingView stopAnimating];
    [self.searchTableView reloadData];
}

//更新header数量和类型统计
- (void)refreshHeaderTitle{
    NSString *titleStr;
    switch (_curSearchType) {
        case eSearchType_Project:
            titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的项目", [_searchPros.projects.totalRow longValue],self.searchBar.text];
            break;
        case eSearchType_Tweet:
            titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的冒泡", [_searchPros.tweets.totalRow longValue],self.searchBar.text];
            break;
        case eSearchType_Document:
            titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的文档", [_searchPros.files.totalRow longValue],self.searchBar.text];
            break;
        case eSearchType_User:
            titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的用户", [_searchPros.friends.totalRow longValue],self.searchBar.text];
            break;
        case eSearchType_Task:
            titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的任务", [_searchPros.tasks.totalRow longValue],self.searchBar.text];
            break;
        default:
            break;
    }
    self.headerLabel.text=titleStr;
}

- (void)requestDataWithPage:(NSInteger)page {
    
    if(page < 1)
        page = 1;
    
    if(page == 1)
        self.headerLabel.text = @"";
    
    _isLoading = YES;
    
    __weak typeof(self) weakSelf = self;
//    if (_curSearchType==eSearchType_Tweet) {
//        [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"tweet" andPage:page andBlock:^(id data, NSError *error) {
//            
//            if(data) {
//                NSDictionary *dataDic = (NSDictionary *)data;
//                weakSelf.currentPage = [[dataDic valueForKey:@"page"] intValue];
//                weakSelf.totalPage = [[dataDic valueForKey:@"totalPage"] intValue];
//                weakSelf.totalCount = [[dataDic valueForKey:@"totalRow"] intValue];
//                NSArray *resultA = [NSObject arrayFromJSON:[dataDic objectForKey:@"list"] ofObjects:@"Tweet"];
//                [weakSelf.dateSource addObjectsFromArray:resultA];
//                [weakSelf.searchTableView reloadData];
//                [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
//                weakSelf.searchTableView.showsInfiniteScrolling = weakSelf.currentPage >= weakSelf.totalPage ? NO : YES;
//            }
//            
//            weakSelf.isLoading = NO;
//            weakSelf.headerLabel.text = [NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的冒泡", (long)weakSelf.totalCount, weakSelf.searchBar.text, nil];
//        }];
//    }else if(_curSearchType==eSearchType_Project){
//    [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"all" andPage:page andBlock:^(id data, NSError *error) {
//        if(data) {
//            PublicSearchModel *pros = [NSObject objectOfClass:@"PublicSearchModel" fromJSON:data];
//            [weakSelf.dateSource addObjectsFromArray:pros.projects.list];
//            [weakSelf.searchTableView reloadData];
//            [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
//        }
//        weakSelf.isLoading = NO;
//        weakSelf.headerLabel.text = [NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的项目", (long)weakSelf.totalCount, weakSelf.searchBar.text, nil];
//    }];
//    }
    
    [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"all" andPage:page andBlock:^(id data, NSError *error) {
        if(data) {
            _searchPros = [NSObject objectOfClass:@"PublicSearchModel" fromJSON:data];
            switch (_curSearchType) {
                case eSearchType_Project:
                    [weakSelf.dateSource addObjectsFromArray:_searchPros.projects.list];
                    break;
                case eSearchType_Tweet:
                    [weakSelf.dateSource addObjectsFromArray:_searchPros.tweets.list];
                    break;
                case eSearchType_Document:
                    [weakSelf.dateSource addObjectsFromArray:_searchPros.files.list];
                    break;
                case eSearchType_User:
                    [weakSelf.dateSource addObjectsFromArray:_searchPros.friends.list];
                    break;
                case eSearchType_Task:
                    [weakSelf.dateSource addObjectsFromArray:_searchPros.tasks.list];
                    break;
                default:
                    break;
            }
            [weakSelf.searchTableView reloadData];
            [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
        }
        weakSelf.isLoading = NO;
        [self refreshHeaderTitle];
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
        ProjectTaskListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectTaskListViewCell" forIndexPath:indexPath];
        Task *task =_dateSource[indexPath.row];
        cell.task=task;
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
        return [ProjectTaskListViewCell cellHeightWithObj:[_dateSource objectAtIndex:indexPath.row]];
    }else{
        return 100;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_curSearchType==eSearchType_Tweet) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self goToTweet:_dateSource[indexPath.row]];
    }else if(_curSearchType==eSearchType_Project){
        [self goToProject:_dateSource[indexPath.row]];
    }else if (_curSearchType==eSearchType_Document){
        [self goToFileVC:_dateSource[indexPath.row]];
    }else if (_curSearchType==eSearchType_User){
        [self goToUserInfo:_dateSource[indexPath.row]];
    }
}

@end
