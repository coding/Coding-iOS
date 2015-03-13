//
//  NProjectViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/3/11.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "NProjectViewController.h"
#import "ProjectInfoCell.h"
#import "ProjectItemsCell.h"
#import "ProjectDescriptionCell.h"
#import "ProjectViewController.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"

@interface NProjectViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

@end

@implementation NProjectViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"项目首页";
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ProjectInfoCell class] forCellReuseIdentifier:kCellIdentifier_ProjectInfoCell];
        [tableView registerClass:[ProjectItemsCell class] forCellReuseIdentifier:kCellIdentifier_ProjectItemsCell_Private];
        [tableView registerClass:[ProjectItemsCell class] forCellReuseIdentifier:kCellIdentifier_ProjectItemsCell_Public];
        [tableView registerClass:[ProjectDescriptionCell class] forCellReuseIdentifier:kCellIdentifier_ProjectDescriptionCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });

    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    [self refresh];
}


- (void)refresh{
    if (_myProject.isLoadingDetail) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:_myProject andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        if (data) {
            weakSelf.myProject = data;
            [weakSelf.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

#pragma mark Table M

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger section = 0;
    if (_myProject.is_public) {
        section = _myProject.is_public.boolValue? 2: 1;
    }
    return section;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    footerView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    [footerView addLineUp:YES andDown:NO andColor:tableView.separatorColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == _myProject.is_public.boolValue? 1: 0) {
        return 0;
    }
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_myProject.is_public) {
        switch (section) {
            case 0:
                row = 2;
                break;
            case 1:
            default:
                row = _myProject.is_public.boolValue? 1: 0;
                break;
        }
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_myProject.is_public.boolValue) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                ProjectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectInfoCell forIndexPath:indexPath];
                cell.curProject = _myProject;
                return cell;
            }else{
                ProjectDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectDescriptionCell forIndexPath:indexPath];
                cell.curProject = _myProject;
                cell.gitButtonClickedBlock = ^(NSInteger index){
                    [self gitButtonClicked:index];
                };
                return cell;
            }
        }else{
            ProjectItemsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectItemsCell_Public forIndexPath:indexPath];
            cell.curProject = _myProject;
            cell.itemClickedBlock = ^(NSInteger index){
                [self goToIndex:index];
            };
            return cell;
        }
    }else{
        if (indexPath.row == 0) {
            ProjectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectInfoCell forIndexPath:indexPath];
            cell.curProject = _myProject;
            return cell;
        }else{
            ProjectItemsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectItemsCell_Private forIndexPath:indexPath];
            cell.curProject = _myProject;
            cell.itemClickedBlock = ^(NSInteger index){
                [self goToIndex:index];
            };
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (_myProject.is_public.boolValue) {
        if (indexPath.section == 0) {
            cellHeight = indexPath.row == 0? [ProjectInfoCell cellHeight]: [ProjectDescriptionCell cellHeightWithObj:_myProject];
        }else{
            cellHeight = [ProjectItemsCell cellHeightWithObj:_myProject];
        }
    }else{
        cellHeight = indexPath.row == 0? [ProjectInfoCell cellHeight]: [ProjectItemsCell cellHeightWithObj:_myProject];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark goTo VC
- (void)goToIndex:(NSInteger)index{
    ProjectViewController *vc = [[ProjectViewController alloc] init];
    vc.myProject = self.myProject;
    vc.curIndex = index;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark Git_Btn
- (void)gitButtonClicked:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    switch (index) {
        case 0://Star
        {
            if (!_myProject.isStaring) {
                [[Coding_NetAPIManager sharedManager] request_StarProject:_myProject andBlock:^(id data, NSError *error) {
                    [weakSelf.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }
        }
            break;
        case 1://Watch
        {
            if (!_myProject.isWatching) {
                [[Coding_NetAPIManager sharedManager] request_WatchProject:_myProject andBlock:^(id data, NSError *error) {
                    [weakSelf.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }
        }
            break;
        default://Fork
        {
            if (_myProject.forked.boolValue
                || [_myProject.owner_user_name isEqualToString:[Login curLoginUser].global_key]) {
                return;
            }else{
                
                [[Coding_NetAPIManager sharedManager] request_ForkProject:_myProject andBlock:^(id data, NSError *error) {
                    [weakSelf.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    if (data) {
                        NProjectViewController *vc = [[NProjectViewController alloc] init];
                        vc.myProject = data;
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    }
                }];
            }
        }
            break;
    }
}

@end
