//
//  MRPRListViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kMRPRListViewController_BottomViewHeight 49.0

#import "PRListViewController.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "MRPRS.h"
#import "Coding_NetAPIManager.h"
#import "MRPRListCell.h"
#import "PRDetailViewController.h"

@interface PRListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSMutableDictionary *dataDict;
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UISegmentedControl *mySegmentedControl;
@end

@implementation PRListViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = kColorTableBG;
    self.title = @"Pull Requests";
    _dataDict = [NSMutableDictionary new];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[MRPRListCell class] forCellReuseIdentifier:kCellIdentifier_MRPRListCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, kMRPRListViewController_BottomViewHeight, 0);
        tableView.contentInset = insets;
        tableView.scrollIndicatorInsets = insets;
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore:YES];
    }];
    [self configBottomView];

    self.selectedIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
    if (self.mySegmentedControl.selectedSegmentIndex != _selectedIndex) {
        [self.mySegmentedControl setSelectedSegmentIndex:_selectedIndex];
    }
    [self.myTableView reloadData];
    
    __weak typeof(self) weakSelf = self;
    [self.view configBlankPage:EaseBlankPageTypeView hasData:YES hasError:NO reloadButtonBlock:^(id sender) {
        [weakSelf refreshMore:NO];
    }];
    
    if ([self curMRPRS].list.count <= 0) {
        [self refresh];
    }else{
        self.myTableView.showsInfiniteScrolling = [self curMRPRS].canLoadMore;
    }
}

- (MRPRS *)curMRPRS{
    MRPRS *curMRPRS = [_dataDict objectForKey:@(_selectedIndex)];
    if (!curMRPRS) {
        curMRPRS = [[MRPRS alloc] initWithType:MRPRSTypePR statusIsOpen:_selectedIndex == 0 userGK:_curProject.owner_user_name projectName:_curProject.name];
        [_dataDict setObject:curMRPRS forKey:@(_selectedIndex)];
    }
    return curMRPRS;
}

- (void)refresh{
    [self refreshMore:NO];
}
- (void)refreshMore:(BOOL)willLoadMore{
    MRPRS *curMRPRS = [self curMRPRS];
    if (curMRPRS.isLoading) {
        return;
    }
    if (willLoadMore && !curMRPRS.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    curMRPRS.willLoadMore = willLoadMore;
    [self sendRequest:curMRPRS];
}

- (void)sendRequest:(MRPRS *)curMRPRS{
    if (curMRPRS.list.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(curMRPRS) weakMRPRS = curMRPRS;
    [[Coding_NetAPIManager sharedManager] request_MRPRS_WithObj:curMRPRS andBlock:^(MRPRS *data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakMRPRS configWithMRPRS:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = [weakSelf curMRPRS].canLoadMore;
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:([weakSelf curMRPRS].list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refreshMore:NO];
        }];
    }];
}

#pragma mark Segment
- (void)configBottomView{
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = self.view.backgroundColor;
        [_bottomView addLineUp:YES andDown:NO];
        [self.view addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(kMRPRListViewController_BottomViewHeight);
        }];
    }
    if (!_mySegmentedControl) {
        _mySegmentedControl = ({
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Open", @"Closed"]];
            segmentedControl.tintColor = [UIColor colorWithHexString:@"0x3bbd79"];
            [segmentedControl setTitleTextAttributes:@{
                                                       NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                                       }
                                            forState:UIControlStateSelected];
            [segmentedControl setTitleTextAttributes:@{
                                                       NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                       NSForegroundColorAttributeName: [UIColor colorWithHexString:@"0x3bbd79"]
                                                       } forState:UIControlStateNormal];
            [segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
            segmentedControl;
        });
        _mySegmentedControl.frame = CGRectMake(kPaddingLeftWidth, (kMRPRListViewController_BottomViewHeight - 30)/2, kScreen_Width - 2*kPaddingLeftWidth, 30);
        [_bottomView addSubview:_mySegmentedControl];
    }
}

- (void)segmentedControlSelected:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.selectedIndex = segmentedControl.selectedSegmentIndex;
}

#pragma mark TableM
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self curMRPRS].list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MRPR *curMRPR = [[self curMRPRS].list objectAtIndex:indexPath.row];
    MRPRListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRPRListCell forIndexPath:indexPath];
    cell.curMRPR = curMRPR;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MRPRListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MRPR *curMRPR = [[self curMRPRS].list objectAtIndex:indexPath.row];
    PRDetailViewController *vc = [PRDetailViewController new];
    vc.curMRPR = curMRPR;
    vc.curProject = _curProject;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
