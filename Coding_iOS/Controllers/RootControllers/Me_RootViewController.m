//
//  Me_RootViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kFourth_HeaderViewHeight 146.0
#define kCellIdentifier_TitleValue @"TitleValueCell"

#import "Me_RootViewController.h"
#import "Coding_NetAPIManager.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "TitleValueCell.h"
#import "SettingViewController.h"
#import "UsersViewController.h"
#import "UITapImageView.h"
#import "SettingMineInfoViewController.h"
#import "MJPhotoBrowser.h"
#import "ODRefreshControl.h"
#import "AddUserViewController.h"
#import "Helper.h"


@interface Me_RootViewController ()
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UIView *headerView, *headerBottomView, *headerBottomLine;
@property (strong, nonatomic) UITapImageView *headerImgView, *headerUserIconView, *headerUserSexIconView;
@property (strong, nonatomic) UILabel *headerUserLabel, *headerSloganLabel;
@property (strong, nonatomic) UIButton *headerFansCountBtn, *headerFollowsCountBtn;
@property (strong, nonatomic) User *myUser;
@property (nonatomic, strong) ODRefreshControl *refreshControl;


@end

@implementation Me_RootViewController

#pragma mark TabBar
- (void)tabBarItemClicked{
    if (_myTableView.contentOffset.y > 0) {
        [_myTableView setContentOffset:CGPointZero animated:YES];
    }else if (!self.refreshControl.isAnimating){
        [self.refreshControl beginRefreshing];
        [self.myTableView setContentOffset:CGPointMake(0, -44)];
        [self refresh];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我";
    _myUser = [Login curLoginUser]? [Login curLoginUser]: [User userWithGlobalKey:@""];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settingBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(settingBtnClicked:)] animated:NO];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addUserBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(addUserBtnClicked:)] animated:NO];
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleValueCell class] forCellReuseIdentifier:kCellIdentifier_TitleValue];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        {
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
            tableView.contentInset = insets;
            tableView.scrollIndicatorInsets = insets;
        }
        tableView;
    });
    _myTableView.tableHeaderView = [self configHeaderView];
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_UserInfo_WithObj:_myUser andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        if (data) {
            weakSelf.myUser = data;
            [weakSelf configHeaderView];
            [weakSelf.myTableView reloadData];
        }
    }];
}

- (UIView *)configHeaderView{
    if (!_headerView) {
        __weak typeof(self) weakSefl = self;
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kFourth_HeaderViewHeight)];
        _headerView.backgroundColor = kColorTableBG;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        headerView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [headerView addLineUp:NO andDown:YES];
        [_headerView addSubview:headerView];
        
        _headerImgView = [[UITapImageView alloc] initWithFrame:_headerView.bounds];
        [_headerImgView addTapBlock:^(id obj) {
            [weakSefl goToSettingMineInfo];
        }];
        [_headerView addSubview:_headerImgView];
        
        _headerUserIconView = [[UITapImageView alloc] initWithFrame:CGRectMake(10, 20+14, 54, 54)];
        [_headerUserIconView addTapBlock:^(id obj) {
            [weakSefl headerUserIconClicked];
        }];
        [_headerUserIconView doCircleFrame];
        [_headerView addSubview:_headerUserIconView];
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_info_arrow_left"]];
        [arrowImageView setCenter:CGPointMake(kScreen_Width-CGRectGetWidth(arrowImageView.frame)/2-kPaddingLeftWidth, 20+14+54/2)];

        [_headerView addSubview:arrowImageView];

        
        _headerUserSexIconView = [[UITapImageView alloc] initWithFrame:CGRectMake(50, 36, 18, 18)];
        [_headerView addSubview:_headerUserSexIconView];

        _headerUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, CGRectGetMidY(_headerUserIconView.frame) -20, (kScreen_Width - 120), 20)];
        _headerUserLabel.backgroundColor = [UIColor clearColor];
        _headerUserLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        _headerUserLabel.font = [UIFont boldSystemFontOfSize:17];
        [_headerView addSubview:_headerUserLabel];
        
        _headerSloganLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, CGRectGetMidY(_headerUserIconView.frame) +3, (kScreen_Width - 120), 20)];
        _headerSloganLabel.backgroundColor = [UIColor clearColor];
        _headerSloganLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        _headerSloganLabel.font = [UIFont systemFontOfSize:14];
        [_headerView addSubview:_headerSloganLabel];
        
        _headerBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kFourth_HeaderViewHeight-44, kScreen_Width, 44)];
        _headerBottomView.backgroundColor = [UIColor clearColor];
        [_headerBottomView addSubview:[UIView lineViewWithPointYY:0]];
        [_headerView addSubview:_headerBottomView];
        
        _headerFansCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _headerFansCountBtn.frame = CGRectMake(0, 0, kScreen_Width/2, 44);
        [_headerBottomView addSubview:_headerFansCountBtn];
        
        _headerFollowsCountBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width/2, 0, kScreen_Width/2, 44)];
        [_headerBottomView addSubview:_headerFollowsCountBtn];
        
        _headerBottomLine = [[UIView alloc] initWithFrame:CGRectMake(kScreen_Width/2-0.5, 15, 1, CGRectGetHeight(_headerBottomView.bounds)-30)];
        _headerBottomLine.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        [_headerBottomView addSubview:_headerBottomLine];
    }
    [_headerUserIconView sd_setImageWithURL:[_myUser.avatar urlImageWithCodePathResizeToView:_headerUserIconView] placeholderImage:kPlaceholderMonkeyRoundView(_headerUserIconView)];
    if (_myUser.sex.intValue == 0) {
        //        男
        [_headerUserSexIconView setImage:[UIImage imageNamed:@"sex_man_icon"]];
        _headerUserSexIconView.hidden = NO;
    }else if (_myUser.sex.intValue == 1){
        //        女
        [_headerUserSexIconView setImage:[UIImage imageNamed:@"sex_woman_icon"]];
        _headerUserSexIconView.hidden = NO;
    }else{
        //        未知
        _headerUserSexIconView.hidden = YES;
    }
    _headerUserLabel.text = _myUser.name;
    _headerSloganLabel.text = _myUser.slogan;
    [_headerFollowsCountBtn setAttributedTitle:[self getStringWithTitle:@"关注" andValue:_myUser.follows_count.stringValue]
                                      forState:UIControlStateNormal];
    [_headerFansCountBtn setAttributedTitle:[self getStringWithTitle:@"粉丝" andValue:_myUser.fans_count.stringValue]
                         forState:UIControlStateNormal];
    [_headerFansCountBtn addTarget:self action:@selector(fansCountBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerFollowsCountBtn addTarget:self action:@selector(followsCountBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return _headerView;
}

- (NSMutableAttributedString*)getStringWithTitle:(NSString *)title andValue:(NSString *)value{
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", title, value]];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],
                                 NSForegroundColorAttributeName : [UIColor blackColor]}
                         range:NSMakeRange(0, title.length)];
    
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x3bbd79"]}
                         range:NSMakeRange(title.length+1, value.length)];
    return  attriString;
}



#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (section == 0) {
        row = 3;
    }else if (section == 1){
        row = 3;
    }else if (section == 2){
        row = 1;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ;
    TitleValueCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValue forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    [cell setTitleStr:@"加入时间" valueStr:[_myUser.created_at string_yyyy_MM_dd]];
                    break;
                case 1:
                    [cell setTitleStr:@"最后活动" valueStr:[_myUser.last_activity_at string_yyyy_MM_dd]];
                    break;
                default:
                    [cell setTitleStr:@"个性后缀" valueStr:_myUser.global_key];
                    break;
            }
        }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell setTitleStr:@"公司" valueStr:_myUser.company];
                    break;
                case 1:
                    [cell setTitleStr:@"工作" valueStr:_myUser.job_str];
                    break;
                default:
                    [cell setTitleStr:@"地区" valueStr:_myUser.location];
                    break;
            }
            break;
        default:
            [cell setTitleStr:@"个性标签" valueStr:_myUser.tags_str];
            break;
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    if (section == 0) {
        [headerView addLineUp:YES andDown:NO andColor:tableView.separatorColor];
    }
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Btn Clicked
- (void)settingBtnClicked:(id)sender{
    SettingViewController *vc = [[SettingViewController alloc] init];
    vc.myUser = self.myUser;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addUserBtnClicked:(id)sender{
    AddUserViewController *vc = [[AddUserViewController alloc] init];
    vc.type = AddUserTypeFollow;
    [self.navigationController pushViewController:vc animated:YES];
}

 - (void)fansCountBtnClicked:(id)sender{
     UsersViewController *vc = [[UsersViewController alloc] init];
     vc.curUsers = [Users usersWithOwner:[Login curLoginUser] Type:UsersTypeFollowers];
     [self.navigationController pushViewController:vc animated:YES];
 }
 - (void)followsCountBtnClicked:(id)sender{
     UsersViewController *vc = [[UsersViewController alloc] init];
     vc.curUsers = [Users usersWithOwner:[Login curLoginUser] Type:UsersTypeFriends_Attentive];
     [self.navigationController pushViewController:vc animated:YES];
 }

- (void)goToSettingMineInfo{
    SettingMineInfoViewController *vc = [[SettingMineInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)headerUserIconClicked{
    //        显示大图
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.url = [[Login curLoginUser].avatar urlWithCodePath];
    photo.srcImageView = _headerUserIconView;
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = [NSArray arrayWithObject:photo]; // 设置所有的图片
    [browser show];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
