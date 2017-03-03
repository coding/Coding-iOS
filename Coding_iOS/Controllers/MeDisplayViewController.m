//
//  MeDisplayViewController.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "MeDisplayViewController.h"
#import "EaseUserHeaderView.h"
#import "StartImagesManager.h"
#import "Login.h"
#import "UsersViewController.h"
#import "MJPhotoBrowser.h"
#import <APParallaxHeader/UIScrollView+APParallaxHeader.h>
#import "XTSegmentControl.h"
#import "CSHotTopicView.h"
#import "CSTopicDetailVC.h"
#import "SVPullToRefresh.h"
#import "Coding_NetAPIManager.h"
#import "SettingMineInfoViewController.h"
#import "EaseUserInfoCell.h"
#import "UserActiveGraphCell.h"

@interface MeDisplayViewController ()
@property (strong, nonatomic) EaseUserHeaderView *eaV;
@property (strong, nonatomic) UIView *sectionHeaderView;

@property (strong, nonatomic) User *curUser;
@property (assign, nonatomic) NSInteger dataIndex;
@property (strong, nonatomic) NSMutableArray *dataList;//特指「话题列表」的数据
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (nonatomic, assign) NSInteger curPage;
@property (nonatomic, strong) EaseUserInfoCell *userInfoCell;
@property (nonatomic, strong) ActivenessModel *activenessModel;
@end

@implementation MeDisplayViewController

- (void)viewDidLoad{
    _dataIndex = 0;
    _dataList = @[].mutableCopy;
    _canLoadMore = YES;
    _willLoadMore = _isLoading = NO;
    _curPage = 0;
    
    [super viewDidLoad];
    self.title = @"个人主页";
    [self.myTableView registerClass:[CSTopicCell class] forCellReuseIdentifier:kCellIdentifier_TopicCell];
     [self.myTableView registerClass:[UserActiveGraphCell class] forCellReuseIdentifier:kCellIdentifier_UserActiveGraphCell];
    [self setupHeaderV];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _curUser = [Login curLoginUser];
    [self.myTableView reloadData];

}

- (void)setupHeaderV{
    __weak typeof(self) weakSelf = self;
    _userInfoCell = [[EaseUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier_EaseUserInfoCell];
    _userInfoCell.userIconClicked = ^(){
        [weakSelf userIconClicked]; //用户头像点击
    };
    _userInfoCell.fansCountBtnClicked = ^(){
        [weakSelf fansCountBtnClicked]; //粉丝
    };
    _userInfoCell.followsCountBtnClicked = ^(){
        [weakSelf followsCountBtnClicked]; //关注
    };
    _userInfoCell.editButtonClicked = ^(){
        [weakSelf goToSettingInfo]; //编辑
    };
    
    [[Coding_NetAPIManager sharedManager] request_Users_activenessWithGlobalKey:_curUser.global_key andBlock:^(ActivenessModel *data, NSError *error) {
        weakSelf.activenessModel = data;
        [weakSelf.myTableView reloadData];
    }];

    
    if (!_sectionHeaderView) {
        _sectionHeaderView = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44.0) Items:@[@"冒泡", @"话题"] selectedBlock:^(NSInteger index) {
            weakSelf.dataIndex = index;
        }];
        _sectionHeaderView.backgroundColor = kColorTableBG;
    }
    [self.myTableView bringSubviewToFront:self.refreshControl];
}

- (void)setDataIndex:(NSInteger)dataIndex{
    _dataIndex = dataIndex;
    [self.myTableView reloadData];
    if ((_dataIndex == 0 && self.curTweets.list.count <= 0) ||
        (_dataIndex == 1 && _dataList.count <= 0)) {
        [self refresh];
    }
}

#pragma mark Refresh M

- (void)refresh{
    if (_dataIndex == 0) {
        _curUser = [Login curLoginUser];
        [self.myTableView reloadData];
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_Users_activenessWithGlobalKey:_curUser.global_key andBlock:^(ActivenessModel *data, NSError *error) {
            weakSelf.activenessModel = data;
            [weakSelf.myTableView reloadData];
        }];
        [super refresh];
    }else{
        if (!_isLoading) {
            [self requestTopicsMore:NO];
        }
    }
}

- (void)refreshMore{
    if (_dataIndex == 0) {
        [super refreshMore];
    }else{
        if (!_isLoading && _canLoadMore) {
            [self requestTopicsMore:YES];
        }else{
            [self.myTableView.infiniteScrollingView stopAnimating];
        }
    }
}

- (void)requestTopicsMore:(BOOL)loadMore{
    _willLoadMore = loadMore;
    _curPage = _willLoadMore? _curPage + 1: 0;
   
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_JoinedTopicsWithUserGK:_curUser.global_key page:weakSelf.curPage block:^(id data, BOOL hasMoreData, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.view endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            if (weakSelf.willLoadMore) {
                [weakSelf.dataList addObjectsFromArray:data[@"list"]];
            }else{
                weakSelf.dataList = data[@"list"]? [data[@"list"] mutableCopy]: @[].mutableCopy;
            }
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = hasMoreData;
        }
        
        CGFloat offsetY = _userInfoCell.frame.size.height + [UserActiveGraphCell cellHeight] + 80;
        [weakSelf.view configBlankPage:EaseBlankPageTypeMyJoinedTopic hasData:weakSelf.dataList.count > 0 hasError:error != nil offsetY:offsetY reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];

    }];
}

#pragma mark headerV
- (void)fansCountBtnClicked{
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.curUsers = [Users usersWithOwner:_curUser Type:UsersTypeFollowers];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)followsCountBtnClicked{
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.curUsers = [Users usersWithOwner:_curUser Type:UsersTypeFriends_Attentive];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)userIconClicked{
    //        显示大图
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.url = [_curUser.avatar urlWithCodePath];
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0;
    browser.photos = [NSArray arrayWithObject:photo];
    [browser show];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.myTableView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat originalHeight = [_eaV originalHeight];
        CGRect eaFrame = CGRectMake(0, MIN(0, offsetY), _eaV.width, MAX(originalHeight, originalHeight - offsetY));
        _eaV.frame = eaFrame;
    }
}

#pragma mark TableM
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section < 2) {
        return 0.0;
    }
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section < 2) {
        return [UIView new];
    }
    return self.sectionHeaderView;

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section < 2) {
        return 20;
    }else{
        if (_dataIndex == 0) {
            return 0;
        }else{
            return _dataList.count == 0? self.view.height - self.sectionHeaderView.height: 0;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section < 2) {
        return 1;
    }
    if (_dataIndex == 0) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }else{
        return _dataList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        EaseUserInfoCell *cell = self.userInfoCell;
        cell.user = _curUser;
        return cell;
    } else if (indexPath.section == 1) {
        UserActiveGraphCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserActiveGraphCell forIndexPath:indexPath];
        cell.activenessModel = _activenessModel;
        return cell;
        
    } else if (_dataIndex == 0) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else{
        NSDictionary *topic = _dataList[indexPath.row];
        CSTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicCell forIndexPath:indexPath];
        [cell updateDisplayByTopic:topic];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [tableView cellHeightForIndexPath:indexPath model:_curUser keyPath:@"user" cellClass:[EaseUserInfoCell class] contentViewWidth:kScreen_Width];
        
    } else if (indexPath.section == 1) {
        return [UserActiveGraphCell cellHeight];
    } else if (_dataIndex == 0) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        NSDictionary *topic = _dataList[indexPath.row];
        return [CSTopicCell cellHeightWithData:topic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < 2) {
        return;
    }
    if (_dataIndex == 0) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }else{
        NSDictionary *topic = _dataList[indexPath.row];
        [self goToTopic:topic];
    }
}

#pragma mark goTo
- (void)goToTopic:(NSDictionary*)topic{
    CSTopicDetailVC *vc = [[CSTopicDetailVC alloc] init];
    vc.topicID = [topic[@"id"] intValue];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToSettingInfo{
    SettingMineInfoViewController *vc = [[SettingMineInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
