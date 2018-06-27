//
//  PointRecordsViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "PointRecordsViewController.h"
#import "WebViewController.h"
#import "ShopViewController.h"
#import "Coding_NetAPIManager.h"

#import "SVPullToRefresh.h"
#import "ODRefreshControl.h"

#import "PointTopCell.h"
#import "PointShopCell.h"
#import "PointRecordCell.h"

#import "AboutPointViewController.h"

@interface PointRecordsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) PointRecords *curRecords;

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (assign, nonatomic) BOOL isShowingTip;
@property (strong, nonatomic) UIView *tipContainerV;
@property (strong, nonatomic) UIImageView *tipBGV;
@property (strong, nonatomic) UILabel *tipL;
@end

@implementation PointRecordsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的码币";
    self.curRecords = [PointRecords new];
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[PointTopCell class] forCellReuseIdentifier:kCellIdentifier_PointTopCell];
        [tableView registerClass:[PointShopCell class] forCellReuseIdentifier:kCellIdentifier_PointShopCell];
        [tableView registerClass:[PointRecordCell class] forCellReuseIdentifier:kCellIdentifier_PointRecordCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tip_normal_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)];
    self.isShowingTip = NO;
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
    [self refresh];
}

- (void)refresh{
    if (_curRecords.isLoading) {
        return;
    }
    _curRecords.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore{
    if (_curRecords.isLoading || !_curRecords.canLoadMore) {
        return;
    }
    _curRecords.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest{
    if (_curRecords.list.count <= 0 && !_curRecords.points_left) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_PointRecords:_curRecords andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.view endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.curRecords configWithObj:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.curRecords.canLoadMore;
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.curRecords.list.count > 0 || weakSelf.curRecords.points_left) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _curRecords.list.count <= 0? 1:2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0? 2: self.curRecords.list.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            PointTopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_PointTopCell forIndexPath:indexPath];
            cell.pointLeftStr = _curRecords.points_left? [NSString stringWithFormat:@"%.2f", _curRecords.points_left.floatValue]: @"--";
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0 hasSectionLine:NO];
            return cell;
        }else{
            PointShopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_PointShopCell forIndexPath:indexPath];
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
            return cell;
        }
    }else{
        PointRecord *record = [_curRecords.list objectAtIndex:indexPath.row];
        PointRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_PointRecordCell forIndexPath:indexPath];
        cell.curRecord = record;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = indexPath.row == 0? [PointTopCell cellHeight]: [PointShopCell cellHeight];
    }else{
        cellHeight = [PointRecordCell cellHeight];
    }
    return cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section == 0? 20.0 : 0.5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [UIView new];
    footerView.backgroundColor = kColorTableSectionBg;
    return footerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = kColorTableSectionBg;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.section == 0 && indexPath.row == 1) {
//        //商城入口
//        ShopViewController *shopvc = [[ShopViewController alloc] init];
//        [self.navigationController pushViewController:shopvc animated:YES];
//    }
}

#pragma mark rightNavBtn
- (void)rightNavBtnClicked{
    AboutPointViewController *vc = [AboutPointViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
