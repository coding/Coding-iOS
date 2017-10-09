//
//  ForkTreeViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/9/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ForkTreeViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "ForkTreeCell.h"
#import "NProjectViewController.h"

@interface ForkTreeViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSArray *forkList;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@end

@implementation ForkTreeViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"Fork项目的人";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ForkTreeCell class] forCellReuseIdentifier:kCellIdentifier_ForkTreeCell];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = kColor666;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)refresh{
    if (_isLoading) {
        return;
    }
    if (!_forkList) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    weakSelf.isLoading = YES;
    [[Coding_NetAPIManager sharedManager] request_ForkTreeWithOwner:_project_owner_user_name project:_project_name andBlock:^(id data, NSError *error) {
        weakSelf.isLoading = NO;
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.view endLoading];
        if (data) {
            weakSelf.forkList = data;
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark T
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _forkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ForkTreeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ForkTreeCell forIndexPath:indexPath];
    cell.project = _forkList[indexPath.row];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ForkTreeCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Project *pro = _forkList[indexPath.row];
    pro.owner_user_name = pro.owner.global_key;
                 
    NProjectViewController *vc = [NProjectViewController new];
    vc.myProject = pro;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
