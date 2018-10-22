//
//  TeamViewController.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TeamViewController.h"
#import "ODRefreshControl.h"
#import "TeamTopCell.h"
#import "Coding_NetAPIManager.h"

#import "TeamProjectsViewController.h"
#import "TeamMembersViewController.h"
#import "UserInfoIconCell.h"
#import "TeamSettingViewController.h"
#import "UIImageView+WebCache.h"
#import "TeamPurchaseViewController.h"
#import "TeamSupportViewController.h"

@interface TeamViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) EATeamHeaderView *tableHeaderV;
@end

@implementation TeamViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[TeamTopCell class] forCellReuseIdentifier:kCellIdentifier_TeamTopCell];
        [tableView registerClass:[UserInfoIconCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoIconCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    
    {//tableHeaderV
        _tableHeaderV = [EATeamHeaderView new];
        _tableHeaderV.curTeam = _curTeam;
        _myTableView.tableHeaderView = _tableHeaderV;
    }
    {//UINavigationBar
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, kSafeArea_Top, kScreen_Width, 44)];
        navBar.shadowImage = [UIImage new];
        navBar.tintColor = [UIColor whiteColor];
        [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        UINavigationItem *item = [UINavigationItem new];
//        UIBarButtonItem *backSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        backSpace.width = -7;
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_T_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(leftNavBtnClicked)];
//        item.leftBarButtonItems = @[backSpace, backItem];
        item.leftBarButtonItems = @[backItem];
        item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settingBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)];
        [navBar pushNavigationItem:item animated:NO];
        [self.view addSubview:navBar];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh];
    
    [self.navigationController addFullscreenPopGesture];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.navigationController removeFullscreenPopGesture];
}

- (void)refresh{
    ESWeak(self, weakSelf);
    [[Coding_NetAPIManager sharedManager] request_InfoOfTeam:_curTeam andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.curTeam = [Login curLoginCompany];
            weakSelf.curTeam.info = data;
            weakSelf.tableHeaderV.curTeam = weakSelf.curTeam;
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark Action
- (void)leftNavBtnClicked{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightNavBtnClicked{
    TeamSettingViewController *vc = [TeamSettingViewController new];
    vc.curTeam = _curTeam;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark Scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [_tableHeaderV.bgV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_tableHeaderV).offset(scrollView.contentOffset.y);
        }];
    }
}

#pragma mark Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0? 0: 15;
    //    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0? 1: section == 1? 2: 1;
    //    return section == 0? 0: 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TeamTopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TeamTopCell forIndexPath:indexPath];
        cell.curTeam = _curTeam;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if (indexPath.section == 1){
        UserInfoIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoIconCell forIndexPath:indexPath];
        (indexPath.row == 0? [cell setTitle:@"项目管理" icon:@"team_info_pro"]:
         [cell setTitle:@"成员管理" icon:@"team_info_mem"]);
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        UserInfoIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoIconCell forIndexPath:indexPath];
        [cell setTitle:@"售后支持" icon:@"team_info_sup"];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0? [NSObject isPrivateCloud].boolValue? 0: [TeamTopCell cellHeight]: [UserInfoIconCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        TeamPurchaseViewController *vc = [TeamPurchaseViewController new];
        vc.curTeam = _curTeam;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            TeamProjectsViewController *vc = [TeamProjectsViewController new];
            vc.curTeam = _curTeam;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            TeamMembersViewController *vc = [TeamMembersViewController new];
            vc.curTeam = _curTeam;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        [self.navigationController pushViewController:[TeamSupportViewController new] animated:YES];
    }
}

@end

@interface EATeamHeaderView ()
@property (strong, nonatomic) UIImageView *iconV;
@property (strong, nonatomic) UILabel *titleL;
@end

@implementation EATeamHeaderView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, kScreen_Width, 212);
        _bgV = [UIImageView new];
        _bgV.backgroundColor = [UIColor colorWithHexString:@"0x425063"];
        //        _bgV.image = [[UIImage imageNamed:@"team_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 0, 200, 0) resizingMode:UIImageResizingModeStretch];
        [self addSubview:_bgV];
        [_bgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(self);
        }];
        
        _iconV = [YLImageView new];
        [_iconV doBorderWidth:0 color:nil cornerRadius:75.0/2];
        [self addSubview:_iconV];
        _titleL = [UILabel labelWithSystemFontSize:17 textColorHexString:@"0xFFFFFF"];
        _titleL.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleL];
        
        [_iconV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(75, 75));
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(-90);
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(_iconV.mas_bottom).offset(20);
        }];
    }
    return self;
}

- (void)setCurTeam:(Team *)curTeam{
    _curTeam = curTeam;
    [_iconV sd_setImageWithURL:[_curTeam.avatar urlImageWithCodePathResize:75 * 2] placeholderImage:kPlaceholderMonkeyRoundWidth(50.0)];
    _titleL.text = _curTeam.name;
}

@end
