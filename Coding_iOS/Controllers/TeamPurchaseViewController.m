//
//  TeamPurchaseViewController.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "TeamPurchaseViewController.h"
#import "XTSegmentControl.h"
#import "ODRefreshControl.h"
#import "TeamPurchaseTopCell.h"
#import "TeamPurchaseOrderCell.h"
#import "TeamPurchaseBillingCell.h"
#import "Coding_NetAPIManager.h"

@interface TeamPurchaseViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong, readonly) UITableView *myTableView;
@property (nonatomic, strong, readonly) ODRefreshControl *refreshControl;
@property (strong, nonatomic) UIView *sectionHeaderView;

@property (assign, nonatomic) NSInteger dataIndex;
@property (strong, nonatomic) NSMutableDictionary *dataDict;
@property (strong, nonatomic, readonly) NSArray *dataList, *orderList, *billingList;

@end

@implementation TeamPurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"订购状态";
    __weak typeof(self) weakSelf = self;
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TeamPurchaseTopCell class] forCellReuseIdentifier:kCellIdentifier_TeamPurchaseTopCell];
        [tableView registerClass:[TeamPurchaseOrderCell class] forCellReuseIdentifier:kCellIdentifier_TeamPurchaseOrderCell];
        [tableView registerClass:[TeamPurchaseBillingCell class] forCellReuseIdentifier:kCellIdentifier_TeamPurchaseBillingCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    if (!_sectionHeaderView) {
        _sectionHeaderView = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44.0) Items:@[@"充值订单", @"账户流水"] selectedBlock:^(NSInteger index) {
            weakSelf.dataIndex = index;
        }];
        [_sectionHeaderView addLineUp:NO andDown:YES];
        _sectionHeaderView.backgroundColor = kColorTableBG;
    }
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    _dataDict = @{}.mutableCopy;
    self.dataIndex = 0;//set 方法里面带刷新了
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _curTeam.hasDismissWebTip = NO;
}

- (NSArray *)dataList{
    return _dataIndex == 0? self.orderList: self.billingList;
}

- (NSArray *)orderList{
//    return @[];
    return _dataDict[@(0)];
}

- (NSArray *)billingList{//不要你了
    return @[];
//    return _dataDict[@(1)];
}

- (void)setDataIndex:(NSInteger)dataIndex{
    _dataIndex = dataIndex;
    [self.myTableView reloadData];
    if (!_dataDict[@(_dataIndex)]) {
        [self refresh];
    }
}

- (void)refresh{
    __weak typeof(self) weakSelf = self;
    void (^queryFinishedBlock)(NSError *) = ^(NSError *error){
        if (weakSelf.orderList.count == 0 && weakSelf.billingList.count > 0) {
            [weakSelf setDataIndex:1];
        }
        [weakSelf.myTableView reloadData];
        [weakSelf.view endLoading];
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.view configBlankPage:EaseBlankPageTypeViewPurchase hasData:weakSelf.dataList.count > 0 hasError:(error != nil) offsetY:([TeamPurchaseTopCell cellHeightWithObj:_curTeam] + 15) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    };
    if (self.dataList.count <= 0) {
        [self.view beginLoading];
    }
    [[Coding_NetAPIManager sharedManager] request_OrderListOfTeam:_curTeam andBlock:^(id dataO, NSError *errorO) {
        if (dataO) {
            weakSelf.dataDict[@(0)] = dataO;
        }
        queryFinishedBlock(errorO);
//        if (dataO) {
//            weakSelf.dataDict[@(0)] = dataO;
//            [[Coding_NetAPIManager sharedManager] request_BillingListOfTeam:_curTeam andBlock:^(id dataB, NSError *errorB) {
//                if (dataB) {
//                    weakSelf.dataDict[@(1)] = dataB;
//                }
//                queryFinishedBlock(errorB);
//            }];
//        }else{
//            queryFinishedBlock(errorO);
//        }
    }];
}

#pragma mark TableM
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0 && self.orderList.count > 0 && self.billingList.count > 0) {
        return 15;
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        if (self.orderList.count > 0 && self.billingList.count > 0) {
            return self.sectionHeaderView;
        }else if (self.orderList.count > 0 || self.billingList.count > 0){
            UIView *headerV = [UIView new];
            headerV.backgroundColor = kColorTableSectionBg;
            UILabel *headerL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
            headerL.text = self.orderList.count > 0? @"充值订单": @"账户流水";
            [headerV addSubview:headerL];
            [headerL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(headerV).offset(kPaddingLeftWidth);
                make.right.equalTo(headerV).offset(-kPaddingLeftWidth);
                make.centerY.equalTo(headerV);
            }];
            UIView *lineV = [UIView lineViewWithPointYY:43.5];
            [headerV addSubview:lineV];
            return headerV;
        }
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (section == 1 && self.dataList.count > 0)? 44.0: 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0? 1: self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        TeamPurchaseTopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TeamPurchaseTopCell forIndexPath:indexPath];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
        cell.curTeam = _curTeam;
        cell.closeWebTipBlock = ^(){
            weakSelf.curTeam.hasDismissWebTip = YES;
            [weakSelf.myTableView reloadData];
            weakSelf.view.blankPageView.y = ([TeamPurchaseTopCell cellHeightWithObj:_curTeam] + 15);
        };
        return cell;
    } else {
        if (_dataIndex == 0) {
            TeamPurchaseOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TeamPurchaseOrderCell forIndexPath:indexPath];
            cell.curOrder = self.dataList[indexPath.row];
            return cell;
        }else{
            TeamPurchaseBillingCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TeamPurchaseBillingCell forIndexPath:indexPath];
            cell.curBilling = self.dataList[indexPath.row];
            cell.expandBlock = ^(TeamPurchaseBilling *billing){
                billing.isExpanded = !billing.isExpanded;
                [weakSelf.myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [TeamPurchaseTopCell cellHeightWithObj:_curTeam];
    } else {
        if (_dataIndex == 0) {
            return [TeamPurchaseOrderCell cellHeight];
        }else{
            return [TeamPurchaseBillingCell cellHeightWithObj:self.dataList[indexPath.row]];
        }
    }
}

@end
