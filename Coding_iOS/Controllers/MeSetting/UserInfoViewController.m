//
//  UserInfoViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-3.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kUserInfo_HeaderViewHeight 180.0
#define kCellIdentifier_TitleValue @"TitleValueCell"


#import "UserInfoViewController.h"
#import "Coding_NetAPIManager.h"
#import "TitleValueCell.h"
#import "UITapImageView.h"
#import "UsersViewController.h"
#import "ConversationViewController.h"
#import "UserTweetsViewController.h"
#import "MJPhotoBrowser.h"

@interface UserInfoViewController ()
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UIView *headerView, *headerBottomView;
@property (strong, nonatomic) UITapImageView *headerUserIconView, *headerUserSexIconView;
@property (strong, nonatomic) UILabel *headerUserLabel, *headerSloganLabel;
@property (strong, nonatomic) UIButton *headerFansCountBtn, *headerFollowsCountBtn, *headerTweetsCountBtn, *headerMsgBtn, *headerFollowBtn;
@end

@implementation UserInfoViewController

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
    self.title = _curUser.name;
    
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
        tableView;
    });
    _myTableView.tableHeaderView = [self configHeaderView];
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_UserInfo_WithObj:_curUser andBlock:^(id data, NSError *error) {
        weakSelf.curUser = data;
        weakSelf.title = _curUser.name;
        [weakSelf configHeaderView];
        [weakSelf.myTableView reloadData];
    }];
}


- (UIView *)configHeaderView{
    if (!_headerView) {
        __weak typeof(self) weakSefl = self;
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kUserInfo_HeaderViewHeight)];
        _headerView.backgroundColor = kColorTableBG;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        headerView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [headerView addLineUp:NO andDown:YES];
        [_headerView addSubview:headerView];
        
        _headerUserIconView = [[UITapImageView alloc] initWithFrame:CGRectMake(10, 34, 54, 54)];
        [_headerUserIconView addTapBlock:^(id obj) {
            [weakSefl headerUserIconClicked];
        }];
        [_headerUserIconView doCircleFrame];
        [_headerView addSubview:_headerUserIconView];
        
        
        _headerUserSexIconView = [[UITapImageView alloc] initWithFrame:CGRectMake(50, 36, 18, 18)];
        [_headerView addSubview:_headerUserSexIconView];

        _headerUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, CGRectGetMidY(_headerUserIconView.frame) -20, (kScreen_Width - 120), 20)];
        _headerUserLabel.backgroundColor = [UIColor clearColor];
        _headerUserLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        _headerUserLabel.font = [UIFont boldSystemFontOfSize:17];
        [_headerView addSubview:_headerUserLabel];
        
        _headerSloganLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, CGRectGetMidY(_headerUserIconView.frame) +1, (kScreen_Width - 120), 20)];
        _headerSloganLabel.backgroundColor = [UIColor clearColor];
        _headerSloganLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        _headerSloganLabel.font = [UIFont systemFontOfSize:14];
        [_headerView addSubview:_headerSloganLabel];
        
        _headerBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kUserInfo_HeaderViewHeight-44, kScreen_Width, 44)];
        _headerBottomView.backgroundColor = [UIColor clearColor];
        [_headerBottomView addSubview:[UIView lineViewWithPointYY:0]];
        [_headerView addSubview:_headerBottomView];
        
        _headerFansCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _headerFansCountBtn.frame = CGRectMake(0, 12, kScreen_Width/3, 20);
        [_headerBottomView addSubview:_headerFansCountBtn];
        
        _headerFollowsCountBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width/3, 12, kScreen_Width/3, 20)];
        [_headerBottomView addSubview:_headerFollowsCountBtn];
        
        _headerTweetsCountBtn = [[UIButton alloc] initWithFrame:CGRectMake(2*kScreen_Width/3, 12, kScreen_Width/3, 20)];
        [_headerBottomView addSubview:_headerTweetsCountBtn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kScreen_Width/3-0.5, 15, 1, CGRectGetHeight(_headerBottomView.bounds)-30)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        [_headerBottomView addSubview:lineView];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(2* kScreen_Width/3-0.5, 15, 1, CGRectGetHeight(_headerBottomView.bounds)-30)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        [_headerBottomView addSubview:lineView];
        
        
        _headerMsgBtn = [UIButton btnPriMsgWithUser:_curUser];
        _headerMsgBtn.frame = CGRectMake(80, CGRectGetMaxY(_headerSloganLabel.frame) +10, 80, 32);
        [_headerMsgBtn addTarget:self action:@selector(headerMsgBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_headerMsgBtn];
        
        _headerFollowBtn = [UIButton btnFollowWithUser:_curUser];
        _headerFollowBtn.frame = CGRectMake(80+CGRectGetMaxX(_headerMsgBtn.bounds) +8, CGRectGetMaxY(_headerSloganLabel.frame) +10, 80, 32);
        [_headerFollowBtn addTarget:self action:@selector(headerFollowBtnClicked) forControlEvents:UIControlEventTouchUpInside];

        [_headerView addSubview:_headerFollowBtn];
    }
    [_headerUserIconView sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResizeToView:_headerUserIconView] placeholderImage:kPlaceholderMonkeyRoundView(_headerUserIconView)];
    _headerUserLabel.text = _curUser.name;
    _headerSloganLabel.text = _curUser.slogan;
    [_headerFansCountBtn setAttributedTitle:[self getStringWithTitle:@"粉丝" andValue:_curUser.fans_count.stringValue] forState:UIControlStateNormal];
    [_headerFollowsCountBtn setAttributedTitle:[self getStringWithTitle:@"关注" andValue:_curUser.follows_count.stringValue] forState:UIControlStateNormal];
    [_headerTweetsCountBtn setAttributedTitle:[self getStringWithTitle:@"冒泡" andValue:_curUser.tweets_count.stringValue] forState:UIControlStateNormal];
    
    [_headerFollowBtn configFollowBtnWithUser:_curUser fromCell:NO];
    [_headerMsgBtn configPriMsgBtnWithUser:_curUser fromCell:NO];
    
    if (_curUser.sex.intValue == 0) {
        //        男
        [_headerUserSexIconView setImage:[UIImage imageNamed:@"sex_man_icon"]];
        _headerUserSexIconView.hidden = NO;
    }else if (_curUser.sex.intValue == 1){
        //        女
        [_headerUserSexIconView setImage:[UIImage imageNamed:@"sex_woman_icon"]];
        _headerUserSexIconView.hidden = NO;
    }else{
        //        未知
        _headerUserSexIconView.hidden = YES;
    }
    
    [_headerFansCountBtn addTarget:self action:@selector(fansCountBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerFollowsCountBtn addTarget:self action:@selector(followsCountBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerTweetsCountBtn addTarget:self action:@selector(tweetsCountBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (_curUser.id.intValue == [Login curLoginUser].id.intValue) {
        _headerFollowBtn.hidden = YES;
        _headerMsgBtn.hidden = YES;
    }else{
        _headerFollowBtn.hidden = NO;
        _headerMsgBtn.hidden = NO;
    }
    
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
                    [cell setTitleStr:@"加入时间" valueStr:[_curUser.created_at string_yyyy_MM_dd]];
                    break;
                case 1:
                    [cell setTitleStr:@"最后活动" valueStr:[_curUser.last_activity_at string_yyyy_MM_dd]];
                    break;
                default:
                    [cell setTitleStr:@"个性后缀" valueStr:_curUser.global_key];
                    break;
            }
        }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell setTitleStr:@"公司" valueStr:_curUser.company];
                    break;
                case 1:
                    [cell setTitleStr:@"工作" valueStr:_curUser.job_str];
                    break;
                default:
                    [cell setTitleStr:@"地区" valueStr:_curUser.location];
                    break;
            }
            break;
        default:
            [cell setTitleStr:@"个性标签" valueStr:_curUser.tags_str];
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
- (void)fansCountBtnClicked:(id)sender{
    if (_curUser.id.integerValue == 93) {//Coding官方账号
        return;
    }
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.curUsers = [Users usersWithOwner:_curUser Type:UsersTypeFollowers];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)followsCountBtnClicked:(id)sender{
    if (_curUser.id.integerValue == 93) {//Coding官方账号
        return;
    }
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.curUsers = [Users usersWithOwner:_curUser Type:UsersTypeFriends_Attentive];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)tweetsCountBtnClicked:(id)sender{
    UserTweetsViewController *vc = [[UserTweetsViewController alloc] init];
    vc.curTweets = [Tweets tweetsWithUser:_curUser];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)headerUserIconClicked{
    //        显示大图
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.url = [_curUser.avatar urlWithCodePath];
    photo.srcImageView = _headerUserIconView;
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = [NSArray arrayWithObject:photo]; // 设置所有的图片
    [browser show];
}

- (void)headerMsgBtnClicked{
    ConversationViewController *vc = [[ConversationViewController alloc] init];
    vc.myPriMsgs = [PrivateMessages priMsgsWithUser:_curUser];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)headerFollowBtnClicked{
    [[Coding_NetAPIManager sharedManager] request_FollowedOrNot_WithObj:_curUser andBlock:^(id data, NSError *error) {
        if (data) {
            _curUser.followed = [NSNumber numberWithBool:!_curUser.followed.boolValue];
            [_headerFollowBtn configFollowBtnWithUser:_curUser fromCell:NO];
            [_headerMsgBtn configPriMsgBtnWithUser:_curUser fromCell:NO];
            if (_followChanged) {
                _followChanged(self.curUser);
            }
        }
    }];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}


@end
