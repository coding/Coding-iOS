//
//  CSTopiclistView.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSTopiclistView.h"
#import "ProjectListTaCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "SVPullToRefresh.h"

#import "Login.h"

#import "CSHotTopicView.h"


#define kCellIdentifier_TopicList @"TopicListCell"

@interface CSTopiclistView()<SWTableViewCellDelegate>
@property (nonatomic, strong) NSDictionary *myTopic;
@property (nonatomic , copy) TopicListViewBlock block;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSMutableArray *dataList;

//根据不同的type，走不同而数据更新逻辑,外界不传值进来
@property (nonatomic,assign)CSMyTopicsType type;
@property (nonatomic, strong) NSString *globalKey;

@property (nonatomic,assign)BOOL isLodding;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSInteger curPage;

@end

@implementation CSTopiclistView

- (id)initWithFrame:(CGRect)frame globalKey:(NSString *)key type:(CSMyTopicsType )type block:(TopicListViewBlock)block {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _dataList = [[NSMutableArray alloc] init];
        _globalKey = key == nil ? [[Login curLoginUser].global_key copy] : [key copy];
        _type = type;
        _block = block;
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] init];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[CSTopicCell class] forCellReuseIdentifier:kCellIdentifier_TopicCell];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            {
                __weak typeof(self) weakSelf = self;
                [tableView addInfiniteScrollingWithActionHandler:^{
                    [weakSelf loadMore];
                }];
            }
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
//            if (tabBarHeight != 0 && projects.type < ProjectsTypeTaProject) {
//                UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, tabBarHeight, 0);
//                tableView.contentInset = insets;
//                tableView.scrollIndicatorInsets = insets;
//            }
            tableView;
        });
        
//        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
//        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
        self.hasMore = YES;
        self.curPage = 1;
        
        if (_myTopic.count > 0) {
            [_myTableView reloadData];
        }else{
            [self sendRequest];
        }
    }
    return self;
}
- (void)setTopics:(id )topics{
    
    self.myTopic = topics;
    [self setupDataList];
}

- (void)setupDataList{
//    if (!_dataList) {
//        _dataList = [[NSMutableArray alloc] initWithCapacity:2];
//    }
//    [_dataList removeAllObjects];
//    if (_myProjects.type < ProjectsTypeToChoose) {
//        NSArray *pinList = _myProjects.pinList, *noPinList = _myProjects.noPinList;
//        if (pinList.count > 0) {
//            [_dataList addObject:@{kTitleKey : @"常用项目",
//                                   kValueKey : pinList}];
//        }
//        if (noPinList.count > 0) {
//            [_dataList addObject:@{kTitleKey : @"一般项目",
//                                   kValueKey : noPinList}];
//        }
//    }else{
//        NSArray *list = [self updateFilteredContentForSearchString:self.mySearchBar.text];
//        if (list.count > 0) {
//            [_dataList addObject:@{kTitleKey : @"一般项目",
//                                   kValueKey : list}];
//        }
//    }
}

- (void)refresh{
    if (self.isLodding) {
        return;
    }
    [self sendRequest];
}

- (void)loadMore {

    if(self.isLodding) {
        return;
    }
    
    ++self.curPage;
    [self sendRequest];
}

- (void)sendRequest{
    if (_dataList.count <= 0) {
        [self beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    
    if (_type == CSMyTopicsTypeWatched) {
        [[Coding_NetAPIManager sharedManager] request_WatchedTopicsWithUserGK:weakSelf.globalKey page:weakSelf.curPage block:^(id data, BOOL hasMoreData, NSError *error) {
            weakSelf.hasMore = hasMoreData;
            [weakSelf doAfterGotResultWithData:data error:error];
        }];
    }else{
        [[Coding_NetAPIManager sharedManager] request_JoinedTopicsWithUserGK:weakSelf.globalKey page:weakSelf.curPage block:^(id data, BOOL hasMoreData, NSError *error) {
            weakSelf.hasMore = hasMoreData;
            [weakSelf doAfterGotResultWithData:data error:error];
        }];
    }
}

- (void)doAfterGotResultWithData:(id) data error:(NSError*)error {
    
    [self.myTableView.infiniteScrollingView stopAnimating];
    [self.myRefreshControl endRefreshing];
    [self endLoading];
    if (data) {
        [_dataList addObjectsFromArray:[data[@"list"] copy]];
        self.myTableView.showsInfiniteScrolling = self.hasMore;
        [self.myTableView reloadData];
    }
    EaseBlankPageType blankPageType;
    
    if (_type == CSMyTopicsTypeWatched) {
        if (_isMe) {
            blankPageType = EaseBlankPageTypeMyWatchedTopic;
        }else{
            blankPageType = EaseBlankPageTypeOthersWatchedTopic;
        }
        
        
    }else{
        if(_isMe){
            blankPageType = EaseBlankPageTypeMyJoinedTopic;
        }else{
            blankPageType = EaseBlankPageTypeOthersJoinedTopic;
        }
        
    }
    
    
    
    [self configBlankPage:blankPageType hasData:(self.dataList.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
        [self refresh];
    }];
}

- (void)refreshToQueryData {
    
}

#pragma mark Table M

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *topic = _dataList[indexPath.row];
    CSTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicCell forIndexPath:indexPath];
    [cell updateDisplayByTopic:topic];

    cell.delegate = self;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *topic = _dataList[indexPath.row];
    return [CSTopicCell cellHeightWithData:topic];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *topic = _dataList[indexPath.row];
    if (_block) {
        _block(topic);
    }
}


@end


