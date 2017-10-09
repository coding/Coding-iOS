//
//  CodingSearchDisplayView.m
//  Coding_iOS
//
//  Created by Ease on 2016/12/15.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "CodingSearchDisplayView.h"
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


@interface CodingSearchDisplayView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) UILabel   *headerLabel;

@property (nonatomic, strong) NSMutableArray *dateSource;
@property (nonatomic, assign) BOOL      isLoading;


@end

@implementation CodingSearchDisplayView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _searchTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
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
            
            [self addSubview:tableView];
            
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
    return self;
}

- (void)setSearchPros:(PublicSearchModel *)searchPros{
    _searchPros = searchPros;
    self.dateSource = @[].mutableCopy;
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
        if (weakSelf.refreshAllBlock) {
            weakSelf.refreshAllBlock();
        }
    }];
    
    //空白页按钮事件
    _searchTableView.blankPageView.clickButtonBlock=^(EaseBlankPageType curType) {
        if (weakSelf.refreshAllBlock) {
            weakSelf.refreshAllBlock();
        }
    };
    
    [self refreshHeaderTitle];
    [self.searchTableView reloadData];
    [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
    _searchTableView.showsInfiniteScrolling = [self showTotalPage];
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

- (void)requestDataWithPage:(NSInteger)page {
    
    _isLoading = YES;
    
    __weak typeof(self) weakSelf = self;
    if (_curSearchType==eSearchType_Tweet) {
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:_searchBarText typeStr:@"tweet" andPage:page andBlock:^(id data, NSError *error) {
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
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:_searchBarText typeStr:@"project" andPage:page andBlock:^(id data, NSError *error) {
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
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:_searchBarText typeStr:@"file" andPage:page andBlock:^(id data, NSError *error) {
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
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:_searchBarText typeStr:@"mr" andPage:page andBlock:^(id data, NSError *error) {
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
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:_searchBarText typeStr:@"pr" andPage:page andBlock:^(id data, NSError *error) {
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
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:_searchBarText typeStr:@"task" andPage:page andBlock:^(id data, NSError *error) {
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
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:_searchBarText typeStr:@"user" andPage:page andBlock:^(id data, NSError *error) {
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
        [[Coding_NetAPIManager sharedManager] requestWithSearchString:_searchBarText typeStr:@"topic" andPage:page andBlock:^(id data, NSError *error) {
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

//更新header数量和类型统计
- (void)refreshHeaderTitle{
    NSString *titleStr;
    switch (_curSearchType) {
        case eSearchType_Project:
            if ([_searchPros.projects.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的项目", [_searchPros.projects.totalRow longValue],_searchBarText];
            }
            break;
        case eSearchType_Tweet:
            if ([_searchPros.tweets.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的冒泡", [_searchPros.tweets.totalRow longValue],_searchBarText];
            }
            break;
        case eSearchType_Document:
            if ([_searchPros.files.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的文档", [_searchPros.files.totalRow longValue],_searchBarText];
            }
            break;
        case eSearchType_User:
            if ([_searchPros.friends.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的用户", [_searchPros.friends.totalRow longValue],_searchBarText];
            }
            break;
        case eSearchType_Task:
            if ([_searchPros.tasks.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的任务", [_searchPros.tasks.totalRow longValue],_searchBarText];
            }
            break;
        case eSearchType_Topic:
            if ([_searchPros.project_topics.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的讨论", [_searchPros.project_topics.totalRow longValue],_searchBarText];
            }
            break;
        case eSearchType_Merge:
            if ([_searchPros.merge_requests.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的合并请求", [_searchPros.merge_requests.totalRow longValue],_searchBarText];
            }
            break;
        case eSearchType_Pull:
            if ([_searchPros.pull_requests.totalRow longValue]==0) {
                titleStr=nil;
            }else{
                titleStr=[NSString stringWithFormat:@"共搜索到 %ld 个与\"%@\"相关的 Pull 请求", [_searchPros.pull_requests.totalRow longValue],_searchBarText];
            }
            break;
        default:
            break;
    }
    self.headerLabel.text=titleStr;
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
            if (weakSelf.goToConversationBlock) {
                weakSelf.goToConversationBlock(curUser);
            }
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
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
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
    if (_cellClickedBlock) {
        _cellClickedBlock(_dateSource[indexPath.row], _curSearchType);
    }
}

@end
