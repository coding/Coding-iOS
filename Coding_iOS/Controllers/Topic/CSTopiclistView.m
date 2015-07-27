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

#import "Login.h"

#import "CSHotTopicVC.h"


#define kCellIdentifier_TopicList @"TopicListCell"

@interface CSTopiclistView()<SWTableViewCellDelegate>
@property (nonatomic, strong) NSDictionary *myTopic;
@property (nonatomic , copy) TopicListViewBlock block;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSMutableArray *dataList;

//根据不同的type，走不同而数据更新逻辑,外界不传值进来
@property (nonatomic,assign)CSMyTopicsType type;

@property (nonatomic,assign)BOOL isLodding;

@end

@implementation CSTopiclistView

- (id)initWithFrame:(CGRect)frame type:(CSMyTopicsType )type block:(TopicListViewBlock)block {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _block = block;
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] init];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[CSTopicCell class] forCellReuseIdentifier:kCellIdentifier_TopicCell];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
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
    [self refreshUI];
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

- (void)sendRequest{
    if (_dataList.count <= 0) {
        [self beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    
    if (_type == CSMyTopicsTypeJoined) {
        [[Coding_NetAPIManager sharedManager] request_WatchedTopicsWithUserGK:[Login curLoginUser].global_key block:^(id data, NSError *error) {
            [weakSelf doAfterGotResultWithData:data error:error];
        }];
    }else{
        [[Coding_NetAPIManager sharedManager] request_JoinedTopicsWithUserGK:[Login curLoginUser].global_key block:^(id data, NSError *error) {
             [weakSelf doAfterGotResultWithData:data error:error];
        }];
    }
}

- (void)doAfterGotResultWithData:(id) data error:(NSError*)error{
    [self.myRefreshControl endRefreshing];
    [self endLoading];
    if (data) {
        _dataList = data[@"list"];
        [self.myTableView reloadData];
    }
//    EaseBlankPageType blankPageType;
//    if (weakSelf.myProjects.type < ProjectsTypeTaProject
//        || [weakSelf.myProjects.curUser.global_key isEqualToString:[Login curLoginUser].global_key]) {
//        blankPageType = EaseBlankPageTypeProject;
//    }else{
//        blankPageType = EaseBlankPageTypeProjectOther;
//    }
//    [weakSelf configBlankPage:blankPageType hasData:(weakSelf.myProjects.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
//        [weakSelf refresh];
//    }];
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
    return 94;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *topic = _dataList[indexPath.row];
    if (_block) {
        _block(topic);
    }
}


@end


