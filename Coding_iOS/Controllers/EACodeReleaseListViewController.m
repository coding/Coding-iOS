//
//  EACodeReleaseListViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EACodeReleaseListViewController.h"
#import "EACodeReleases.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "Coding_NetAPIManager.h"
#import "EACodeReleaseListCell.h"
#import "EACodeReleaseViewController.h"

@interface EACodeReleaseListViewController ()<UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@property (strong, nonatomic) EACodeReleases *myCodeReleases;
@property (strong, nonatomic) NSArray *dataList;
@end

@implementation EACodeReleaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发布管理";
    self.view.backgroundColor = kColorTableSectionBg;
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerNib:[UINib nibWithNibName:[EACodeReleaseListCell nameOfClass] bundle:nil] forCellReuseIdentifier:[EACodeReleaseListCell nameOfClass]];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
        tableView.contentInset = insets;
        tableView.scrollIndicatorInsets = insets;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore:YES];
    }];
    [self refresh];
}

- (void)setMyProject:(Project *)myProject{
    _myProject = myProject;
    _myCodeReleases = [EACodeReleases new];
    _myCodeReleases.curPro = _myProject;
}

#pragma Data
- (void)refresh{
    [self refreshMore:NO];
}
- (void)refreshMore:(BOOL)willLoadMore{
    if (_myCodeReleases.isLoading) {
        return;
    }
    if (willLoadMore && !_myCodeReleases.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _myCodeReleases.willLoadMore = willLoadMore;
    [self sendRequest];
}

- (void)sendRequest{
    if (_myCodeReleases.list.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CodeReleases_WithObj:_myCodeReleases andBlock:^(EACodeReleases *data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myCodeReleases configWithObj:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myCodeReleases.canLoadMore;
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.myCodeReleases.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refreshMore:NO];
        }];
    }];
}

#pragma mark TableM
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _myCodeReleases.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EACodeReleaseListCell *cell = [tableView dequeueReusableCellWithIdentifier:[EACodeReleaseListCell nameOfClass] forIndexPath:indexPath];
    cell.curCodeRelease = self.myCodeReleases.list[indexPath.row];
    cell.delegate = self;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EACodeReleaseViewController *vc = [EACodeReleaseViewController new];
    vc.curRelease = self.myCodeReleases.list[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    EACodeRelease *curR = self.myCodeReleases.list[indexPath.row];
    __weak typeof(self) weakSelf = self;
    [[UIAlertController ea_actionSheetCustomWithTitle:[NSString stringWithFormat:@"请确认是否删除版本 %@ ？", curR.tag_name] buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 0) {
            [weakSelf deleteRelease:curR];
        }
    }] showInView:self.view];
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    return YES;
}

- (void)deleteRelease:(EACodeRelease *)curR{
    __weak typeof(self) weakSelf = self;
    [NSObject showHUDQueryStr:@"请稍等..."];
    [[Coding_NetAPIManager sharedManager] request_DeleteCodeRelease:curR andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"删除成功"];
//            [weakSelf.myCodeReleases.list removeObject:curR];
//            [weakSelf.myTableView reloadData];
            [weakSelf refresh];
        }
    }];
}

@end
