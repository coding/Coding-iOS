//
//  EACodeBranchListViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EACodeBranchListViewController.h"
#import "EACodeBranches.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "Coding_NetAPIManager.h"
#import "EACodeBranchListCell.h"
#import "ProjectViewController.h"

@interface EACodeBranchListViewController ()<UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@property (strong, nonatomic) EACodeBranches *myCodeBranches;

@end

@implementation EACodeBranchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"分支管理";
    self.view.backgroundColor = kColorTableSectionBg;
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        [tableView registerClass:[EACodeBranchListCell class] forCellReuseIdentifier:[EACodeBranchListCell nameOfClass]];
        [tableView registerNib:[UINib nibWithNibName:[EACodeBranchListCell nameOfClass] bundle:nil] forCellReuseIdentifier:[EACodeBranchListCell nameOfClass]];
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
    _myCodeBranches = [EACodeBranches new];
    _myCodeBranches.curPro = _myProject;
}

#pragma Data
- (void)refresh{
    [self refreshMore:NO];
}
- (void)refreshMore:(BOOL)willLoadMore{
    if (_myCodeBranches.isLoading) {
        return;
    }
    if (willLoadMore && !_myCodeBranches.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _myCodeBranches.willLoadMore = willLoadMore;
    [self sendRequest];
}

- (void)sendRequest{
    if (_myCodeBranches.list.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CodeBranches_WithObj:_myCodeBranches andBlock:^(EACodeBranches *data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myCodeBranches configWithObj:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myCodeBranches.canLoadMore;
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.myCodeBranches.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refreshMore:NO];
        }];
    }];
}

#pragma mark TableM
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _myCodeBranches.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EACodeBranchListCell *cell = [tableView dequeueReusableCellWithIdentifier:[EACodeBranchListCell nameOfClass] forIndexPath:indexPath];
    cell.curBranch = self.myCodeBranches.list[indexPath.row];
    cell.delegate = self;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CodeBranchOrTag *curB = self.myCodeBranches.list[indexPath.row];
    ProjectViewController *vc = [ProjectViewController codeVCWithCodeRef:curB.name andProject:self.myProject];
    vc.hideBranchTagButton = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    CodeBranchOrTag *curB = self.myCodeBranches.list[indexPath.row];
    __weak typeof(self) weakSelf = self;
    [[UIAlertController ea_actionSheetCustomWithTitle:[NSString stringWithFormat:@"请确认是否要删除分支 %@ ？", curB.name] buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 0) {
            [weakSelf deleteBranch:curB];
        }
    }] showInView:self.view];
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    CodeBranchOrTag *curB = self.myCodeBranches.list[indexPath.row];
    return !curB.is_default_branch.boolValue;
}

- (void)deleteBranch:(CodeBranchOrTag *)curB{
    __weak typeof(self) weakSelf = self;
    [NSObject showHUDQueryStr:@"请稍等..."];
    [[Coding_NetAPIManager sharedManager] request_DeleteCodeBranch:curB inProject:_myProject andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"删除成功"];
//            [weakSelf.myCodeBranches.list removeObject:curB];
//            [weakSelf.myTableView reloadData];
            [weakSelf refresh];
        }
    }];
}

@end
