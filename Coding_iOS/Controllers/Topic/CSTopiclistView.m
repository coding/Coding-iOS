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

#define kCellIdentifier_TopicList @"TopicListCell"

@interface CSTopiclistView()<SWTableViewCellDelegate>
@property (nonatomic, strong) NSDictionary *myTopic;
@property (nonatomic , copy) TopicListViewBlock block;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSMutableArray *dataList;

@end

@implementation CSTopiclistView

- (id)initWithFrame:(CGRect)frame topics:(id )topic block:(TopicListViewBlock)block tabBarHeight:(CGFloat)tabBarHeight {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myTableView = topic;
        _block = block;
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] init];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[CSTopiclistCell class] forCellReuseIdentifier:kCellIdentifier_TopicList];
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
//    if (_myProjects.isLoading) {
//        return;
//    }
//    [self sendRequest];
}

- (void)sendRequest{
//    if (_myTopic.list.count <= 0) {
//        [self beginLoading];
//    }
    __weak typeof(self) weakSelf = self;
//    [[Coding_NetAPIManager sharedManager] request_Projects_WithObj:_myProjects andBlock:^(Projects *data, NSError *error) {
//        [weakSelf.myRefreshControl endRefreshing];
//        [self endLoading];
//        if (data) {
//            [weakSelf.myProjects configWithProjects:data];
//            [weakSelf setupDataList];
//            [weakSelf.myTableView reloadData];
//        }
//        EaseBlankPageType blankPageType;
//        if (weakSelf.myProjects.type < ProjectsTypeTaProject
//            || [weakSelf.myProjects.curUser.global_key isEqualToString:[Login curLoginUser].global_key]) {
//            blankPageType = EaseBlankPageTypeProject;
//        }else{
//            blankPageType = EaseBlankPageTypeProjectOther;
//        }
//        [weakSelf configBlankPage:blankPageType hasData:(weakSelf.myProjects.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
//            [weakSelf refresh];
//        }];
//    }];
}

- (void)refreshToQueryData {
    
}

#pragma mark Table M

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return _dataList.count > 1? kScaleFrom_iPhone5_Desgin(24): 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *headerStr = [self titleForSection:section];
    return [tableView getHeaderViewWithStr:headerStr andBlock:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_dataList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self valueForSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Project *curPro = [[self valueForSection:indexPath.section] objectAtIndex:indexPath.row];
    
    if (_myProjects.type < ProjectsTypeTaProject) {
        ProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectList forIndexPath:indexPath];
        if (self.myProjects.type == ProjectsTypeToChoose) {
            [cell setProject:curPro hasSWButtons:NO hasBadgeTip:NO hasIndicator:NO];
        }else{
            [cell setProject:curPro hasSWButtons:YES hasBadgeTip:YES hasIndicator:YES];
        }
        cell.delegate = self;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        ProjectListTaCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectListTaCell forIndexPath:indexPath];
        cell.project = curPro;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_myProjects.type < ProjectsTypeTaProject) {
        return [ProjectListCell cellHeight];
    }else{
        return [ProjectListTaCell cellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_block) {
        _block([[self valueForSection:indexPath.section] objectAtIndex:indexPath.row]);
    }
}


@end

@implementation CSTopiclistCell



@end
