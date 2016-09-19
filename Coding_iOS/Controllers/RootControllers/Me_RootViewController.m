//
//  Me_RootViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Me_RootViewController.h"
#import "Coding_NetAPIManager.h"
#import "UsersViewController.h"
#import "AddUserViewController.h"
#import "SettingViewController.h"
#import "SettingMineInfoViewController.h"
#import "UserInfoDetailViewController.h"
#import "ProjectListViewController.h"
#import "LocalFoldersViewController.h"
#import "PointRecordsViewController.h"
#import "AboutViewController.h"
#import "HelpViewController.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "ODRefreshControl.h"

#import "UserInfoIconCell.h"
#import "MeRootUserCell.h"
#import "MeRootServiceCell.h"

#import "UserServiceInfo.h"
#import "TeamListViewController.h"
#import "MeDisplayViewController.h"

@interface Me_RootViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

@property (strong, nonatomic) User *curUser;
@property (strong, nonatomic) UserServiceInfo *curServiceInfo;
@end

@implementation Me_RootViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        self.title = @"我";
        _curUser = [Login curLoginUser]? [Login curLoginUser]: [User userWithGlobalKey:@""];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addUserBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(goToAddUser)] animated:NO];
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UserInfoIconCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoIconCell];
        [tableView registerClass:[MeRootUserCell class] forCellReuseIdentifier:kCellIdentifier_MeRootUserCell];
        [tableView registerClass:[MeRootServiceCell class] forCellReuseIdentifier:kCellIdentifier_MeRootServiceCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
        tableView.contentInset = insets;
        tableView.scrollIndicatorInsets = insets;
        tableView;
    });
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)refresh{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_UserInfo_WithObj:_curUser andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curUser = data;
            [[Coding_NetAPIManager sharedManager] request_ServiceInfoBlock:^(id dataS, NSError *errorS) {
                if (dataS) {
                    weakSelf.curServiceInfo = dataS;
                }
                [weakSelf.myTableView reloadData];
                [weakSelf.refreshControl endRefreshing];
            }];
        }else{
            [weakSelf.refreshControl endRefreshing];
        }
    }];
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = (section ==0? 2:
                     section == 1? 1:
                     4);
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            MeRootUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MeRootUserCell forIndexPath:indexPath];
            cell.curUser = _curUser;
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
            return cell;
        }else{
            MeRootServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MeRootServiceCell forIndexPath:indexPath];
            cell.curServiceInfo = _curServiceInfo;
            ESWeak(self, weakSelf);
            cell.leftBlock = ^(){
                [weakSelf goToProjects];
            };
            cell.rightBlock = ^(){
                [weakSelf goToTeams];
            };
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
            return cell;
        }
    }else{
        UserInfoIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoIconCell forIndexPath:indexPath];
        (indexPath.section == 1? [cell setTitle:@"我的码币" icon:@"user_info_point"]:
         indexPath.row == 0? [cell setTitle:@"本地文件" icon:@"user_info_file"]:
         indexPath.row == 1? [cell setTitle:@"帮助与反馈" icon:@"user_info_help"]:
         indexPath.row == 2? [cell setTitle:@"设置" icon:@"user_info_setup"]:
         [cell setTitle:@"关于我们" icon:@"user_info_about"]);
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = indexPath.row == 0? [MeRootUserCell cellHeight]: [MeRootServiceCell cellHeight];
    }else{
        cellHeight = [UserInfoIconCell cellHeight];
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0/[UIScreen mainScreen].scale;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    headerView.backgroundColor = kColorTableSectionBg;
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {//个人主页
            [self goToMeDisplay];
        }
    }else if (indexPath.section == 1){//我的码币
        [self goToPoint];
    }else{
        if (indexPath.row == 0) {//本地文件
            [self goToLocalFolders];
        }else if (indexPath.row == 1){//帮助与反馈
            [self goToHelp];
        }else if (indexPath.row == 2){//设置
            [self goToSetting];
        }else{//关于我们
            [self goToAbout];
        }
    }
}

#pragma mark GoTo
- (void)goToAddUser{
    AddUserViewController *vc = [[AddUserViewController alloc] init];
    vc.type = AddUserTypeFollow;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToLocalFolders{
    LocalFoldersViewController *vc = [LocalFoldersViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToPoint{
    PointRecordsViewController *vc = [PointRecordsViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToSetting{
    SettingViewController *vc = [[SettingViewController alloc] init];
    vc.myUser = self.curUser;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToHelp{
    [self.navigationController pushViewController:[HelpViewController vcWithHelpStr] animated:YES];
}

- (void)goToAbout{
    [self.navigationController pushViewController:[AboutViewController new] animated:YES];
}

- (void)goToProjects{
    ProjectListViewController *vc = [[ProjectListViewController alloc] init];
    vc.curUser = _curUser;
    vc.isFromMeRoot = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToTeams{
    [self.navigationController pushViewController:[TeamListViewController new] animated:YES];
}

- (void)goToMeDisplay{
    MeDisplayViewController *vc = [MeDisplayViewController new];
    vc.curTweets = [Tweets tweetsWithUser:_curUser];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
