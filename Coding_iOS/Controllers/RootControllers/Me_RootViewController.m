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
#import "EditTopicViewController.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "ODRefreshControl.h"

#import "UserInfoIconCell.h"
#import "MeRootUserCell.h"
#import "MeRootServiceCell.h"

#import "UserServiceInfo.h"
#import "TeamListViewController.h"
#import "MeDisplayViewController.h"

#import "FunctionTipsManager.h"
#import "ShopViewController.h"

#import "MeRootCompanyCell.h"
#import "TeamViewController.h"



#ifdef Target_Enterprise

@interface Me_RootViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

@property (strong, nonatomic) User *curUser;
@property (strong, nonatomic) Team *curTeam;
@end

@implementation Me_RootViewController

- (void)tabBarItemClicked{
    [super tabBarItemClicked];
    if (_myTableView.contentOffset.y > 0) {
        [_myTableView setContentOffset:CGPointZero animated:YES];
    }else if (!self.refreshControl.isAnimating){
        [self.refreshControl beginRefreshing];
        [self.myTableView setContentOffset:CGPointMake(0, -44)];
        [self refresh];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我";
    _curUser = [Login curLoginUser] ?: [User userWithGlobalKey:@""];
    _curTeam = [Login curLoginCompany] ?: [Team teamWithGK:[NSObject baseCompany]];
    //        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addUserBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(goToAddUser)] animated:NO];
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UserInfoIconCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoIconCell];
        [tableView registerClass:[MeRootUserCell class] forCellReuseIdentifier:kCellIdentifier_MeRootUserCell];
        [tableView registerClass:[MeRootCompanyCell class] forCellReuseIdentifier:kCellIdentifier_MeRootCompanyCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
        tableView.contentInset = insets;
        tableView.scrollIndicatorInsets = insets;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
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
            [[Coding_NetAPIManager sharedManager] request_UpdateIsAdministratorBlock:^(id dataI, NSError *errorI) {
                if (dataI) {
                    weakSelf.curUser.isAdministrator = dataI;
                    [[Coding_NetAPIManager sharedManager] request_UpdateCompanyInfoBlock:^(id dataC, NSError *errorC) {
                        if (dataC) {
                            weakSelf.curTeam = dataC;
                        }
                        [weakSelf.myTableView reloadData];
                        [weakSelf.refreshControl endRefreshing];
                    }];
                }else{
                    [weakSelf.myTableView reloadData];
                    [weakSelf.refreshControl endRefreshing];
                }
            }];
        }else{
            [weakSelf.refreshControl endRefreshing];
        }
    }];
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = (section ==0? 1:
                     section == 1? _curUser.isAdministrator.boolValue? 1: 0:
                     section == 2? 1:
                     3);
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        MeRootUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MeRootUserCell forIndexPath:indexPath];
        cell.curUser = _curUser;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
        return cell;
    }else if (indexPath.section == 1){
        MeRootCompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MeRootCompanyCell forIndexPath:indexPath];
        cell.curCompany = _curTeam;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
        return cell;
    }else{
        UserInfoIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoIconCell forIndexPath:indexPath];
        (indexPath.section == 2? [cell setTitle:@"本地文件" icon:@"user_info_file"]:
         indexPath.row == 0? [cell setTitle:@"帮助中心" icon:@"user_info_help"]:
         indexPath.row == 1? [cell setTitle:@"设置" icon:@"user_info_setup"]:
         [cell setTitle:@"关于我们" icon:@"user_info_about"]);
        cell.clipsToBounds = YES;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = [MeRootUserCell cellHeight];
    }else if (indexPath.section == 1){
        cellHeight = [MeRootCompanyCell cellHeight];
    }else{
        cellHeight = [UserInfoIconCell cellHeight];
        //        cellHeight = (indexPath.section == 3 && indexPath.row == 0)? 0: [UserInfoIconCell cellHeight];
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return kLine_MinHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 || (section == 1 && !_curUser.isAdministrator.boolValue)? 1.0/[UIScreen mainScreen].scale: 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 15)];
    headerView.backgroundColor = kColorTableSectionBg;
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self goToMeDisplay];
    }else if (indexPath.section == 1){
        if (_curUser.isAdministrator.boolValue) {
            TeamViewController *vc = [TeamViewController new];
            vc.curTeam = _curTeam;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 2){
        [self goToLocalFolders];
    }else{
        if (indexPath.row == 0) {
            [self goToHelp];
        }else if (indexPath.row == 1){
            [self goToSetting];
        }else{
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
    SettingMineInfoViewController *vc = [[SettingMineInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

#else

@interface Me_RootViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

@property (strong, nonatomic) User *curUser;
@property (strong, nonatomic) UserServiceInfo *curServiceInfo;

@property (assign, nonatomic) BOOL isHeaderClosed;
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
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self configHeader];
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
                [weakSelf configHeader];
                [weakSelf.myTableView reloadData];
                [weakSelf.refreshControl endRefreshing];
            }];
        }else{
            [weakSelf.refreshControl endRefreshing];
        }
    }];
}

- (BOOL)p_isHeaderNeedToShow{
    
    return (!_isHeaderClosed && (_curUser.canUpgradeByCompleteUserInfo || _curUser.willExpired));
}
- (void)configHeader{
    BOOL isHeaderNeedToShow = [self p_isHeaderNeedToShow];
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, !isHeaderNeedToShow? 1: 40)];
    headerV.backgroundColor = !isHeaderNeedToShow? [UIColor clearColor]: [UIColor colorWithHexString:@"0xECF9FF"];
    if (isHeaderNeedToShow) {
        __weak typeof(self) weakSelf = self;
        UIButton *closeBtn = [UIButton new];
        [closeBtn setImage:[UIImage imageNamed:@"button_tip_close"] forState:UIControlStateNormal];
        [closeBtn bk_addEventHandler:^(id sender) {
            weakSelf.isHeaderClosed = YES;
            [weakSelf configHeader];
        } forControlEvents:UIControlEventTouchUpInside];
        [headerV addSubview:closeBtn];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(headerV);
            make.width.equalTo(closeBtn.mas_height);
        }];
        UIImageView *noticeV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_tip_notice"]];
        noticeV.contentMode = UIViewContentModeCenter;
        [headerV addSubview:noticeV];
        [noticeV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(headerV);
            make.width.equalTo(noticeV.mas_height);
        }];
        UILabel *tipL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:[UIColor colorWithHexString:@"0x136BFB"]];
        tipL.adjustsFontSizeToFitWidth = YES;
        tipL.minimumScaleFactor = .5;
        tipL.userInteractionEnabled = YES;
        //        tipL.text = _curUser.canUpgradeByCompleteUserInfo? @"完善个人信息，即可升级银牌会员": [NSString stringWithFormat:@"会员过期将自动降级到%@", _curUser.isUserInfoCompleted? @"银牌会员": @"普通会员"];
        tipL.text = _curUser.canUpgradeByCompleteUserInfo? @"完善个人信息，即可升级银牌会员": @"会员过期后将会自动降级";
        [tipL bk_whenTapped:^{
            if (weakSelf.curUser.canUpgradeByCompleteUserInfo) {
                SettingMineInfoViewController *vc = [SettingMineInfoViewController new];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else{
                kTipAlert(@"请前往 Coding 网页版进行升级操作");
            }
        }];
        [headerV addSubview:tipL];
        [tipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(headerV);
            make.left.equalTo(noticeV.mas_right);
            make.right.equalTo(closeBtn.mas_left);
        }];
    }
    self.myTableView.tableHeaderView = headerV;
    [self.myTableView reloadData];
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = (section ==0? 2:
                     section == 1? 2:
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
                [weakSelf goToProjectsForPrivate:YES];
            };
            cell.rightBlock = ^(){
                [weakSelf goToProjectsForPrivate:NO];
            };
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
            return cell;
        }
    }else{
        UserInfoIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoIconCell forIndexPath:indexPath];
        (indexPath.section == 1? (indexPath.row == 0? [cell setTitle:@"我的码币" icon:@"user_info_point"]:
                                  [cell setTitle:@"商城" icon:@"user_info_shop"]):
         indexPath.row == 0? [cell setTitle:@"本地文件" icon:@"user_info_file"]:
//         indexPath.row == 1? [cell setTitle:@"帮助与反馈" icon:@"user_info_help"]:
         indexPath.row == 1? [cell setTitle:@"意见反馈" icon:@"user_info_help"]:
         indexPath.row == 2? [cell setTitle:@"设置" icon:@"user_info_setup"]:
         [cell setTitle:@"关于我们" icon:@"user_info_about"]);
        
        NSInteger pointTag = 101;
        [cell.contentView removeViewWithTag:pointTag];
        if (indexPath.section == 1 && indexPath.row == 0) {
            UILabel *pointL = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:kColorLightBlue];
            pointL.text = _curServiceInfo.point_left? [NSString stringWithFormat:@"%.2f 码币", _curServiceInfo.point_left.floatValue]: @"-- 码币";
            pointL.tag = pointTag;
            [cell.contentView addSubview:pointL];
            [pointL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell.contentView);
                make.right.offset(-kPaddingLeftWidth);
            }];
        }
        //        if (indexPath.section == 1 && indexPath.row == 1 && [[FunctionTipsManager shareManager] needToTip:kFunctionTipStr_Me_Shop]) {
        ////            cell.accessoryType = UITableViewCellAccessoryNone;
        //            CGFloat pointX = kScreen_Width - 40;
        //            CGFloat pointY = [UserInfoIconCell cellHeight]/2;
        //            [cell.contentView addBadgeTip:kBadgeTipStr withCenterPosition:CGPointMake(pointX, pointY)];
        //        }else{
        ////            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //            [cell.contentView removeBadgeTips];
        //        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = indexPath.row == 0? [MeRootUserCell cellHeight]: [MeRootServiceCell cellHeight];
    }else{
        if (indexPath.section == 2 && indexPath.row == 1) {
            cellHeight = 0;
        }else{
            cellHeight = [UserInfoIconCell cellHeight];
        }
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return kLine_MinHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (section == 0 && [self p_isHeaderNeedToShow])? kLine_MinHeight: 15;
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
        if (indexPath.row == 0) {
            [self goToPoint];
        }else{
            [self goToShop];
        }
    }else{
        if (indexPath.row == 0) {//本地文件
            [self goToLocalFolders];
        }else if (indexPath.row == 1){//帮助与反馈
//            [self goToHelp];
            [self goToFeedBack];
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

- (void)goToShop{
    if ([[FunctionTipsManager shareManager] needToTip:kFunctionTipStr_Me_Shop]) {
        [[FunctionTipsManager shareManager] markTiped:kFunctionTipStr_Me_Shop];
        [self.myTableView reloadData];
    }
    ShopViewController *shopvc = [ShopViewController new];
    [self.navigationController pushViewController:shopvc animated:YES];
}

- (void)goToSetting{
    SettingViewController *vc = [[SettingViewController alloc] init];
    vc.myUser = self.curUser;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToHelp{
    [self.navigationController pushViewController:[HelpViewController vcWithHelpStr] animated:YES];
}

- (void)goToFeedBack{
    EditTopicViewController *vc = [[EditTopicViewController alloc] init];
    vc.curProTopic = [ProjectTopic feedbackTopic];
    vc.type = TopicEditTypeFeedBack;
    vc.topicChangedBlock = nil;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToAbout{
    [self.navigationController pushViewController:[AboutViewController new] animated:YES];
}

- (void)goToProjectsForPrivate:(BOOL)isForPrivateProjects{
    ProjectListViewController *vc = [[ProjectListViewController alloc] init];
    vc.curUser = _curUser;
    vc.isFromMeRoot = YES;
    vc.isForPrivateProjects = isForPrivateProjects;
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)goToProjects{
//    ProjectListViewController *vc = [[ProjectListViewController alloc] init];
//    vc.curUser = _curUser;
//    vc.isFromMeRoot = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (void)goToTeams{
//    [self.navigationController pushViewController:[TeamListViewController new] animated:YES];
//}

- (void)goToMeDisplay{
    MeDisplayViewController *vc = [MeDisplayViewController new];
    vc.curTweets = [Tweets tweetsWithUser:_curUser];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

#endif


