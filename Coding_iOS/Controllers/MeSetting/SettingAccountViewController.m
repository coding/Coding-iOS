//
//  SettingAccountViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "SettingAccountViewController.h"
#import "TitleValueCell.h"
#import "TitleDisclosureCell.h"
#import "TitleValueMoreCell.h"

#import "SettingPasswordViewController.h"
#import "SettingPhoneViewController.h"
#import "Coding_NetAPIManager.h"
#import "Login.h"
#import "Close2FAViewController.h"
#import "SettingEmailViewController.h"

@interface SettingAccountViewController ()
@property (strong, nonatomic) User *myUser;
@property (strong, nonatomic) UITableView *myTableView;
@property (assign, nonatomic) BOOL is2FAOpen;
@end

@implementation SettingAccountViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"账号信息";
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleValueCell class] forCellReuseIdentifier:kCellIdentifier_TitleValue];
        [tableView registerClass:[TitleDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_TitleDisclosure];
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.myUser = [Login curLoginUser];
    [self.myTableView reloadData];
    [self refresh2FA];
}

- (void)refresh2FA{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] get_is2FAOpenBlock:^(BOOL data, NSError *error) {
        if (!error) {
            weakSelf.is2FAOpen = data;
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark TableM

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _is2FAOpen? 4: 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = (section == 1? 2: 1);
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TitleValueCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValue forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setTitleStr:@"个性后缀" valueStr:self.myUser.global_key];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            
            TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
            
            NSString *valueStr = (self.myUser.email.length <= 0? @"未绑定":
                                  self.myUser.email_validation.boolValue? self.myUser.email:
                                  [NSString stringWithFormat:@"%@ 未验证",self.myUser.email]);
            [cell setTitleStr:@"邮箱" valueStr:valueStr];
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
            return cell;
        }else{
            TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
            [cell setTitleStr:@"手机号码" valueStr:self.myUser.phone.length > 0 ? self.myUser.phone: @"未绑定"];
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
            return cell;
        }
    }else{
        TitleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleDisclosure forIndexPath:indexPath];
        [cell setTitleStr:indexPath.section == 2? @"修改密码": @"关闭两步验证"];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    headerView.backgroundColor = kColorTableSectionBg;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (!self.myUser.email_validation.boolValue && self.myUser.email.length > 0) {
                UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"激活邮箱" message:@"该邮箱尚未激活，请尽快去邮箱查收邮件并激活账号。如果在收件箱中没有看到，请留意一下垃圾邮件箱子（T_T）"];
                [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
                [alertView bk_addButtonWithTitle:@"重发激活邮件" handler:nil];
                [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
                    if (index == 1) {
                        [self sendActivateEmail];
                    }
                }];
                [alertView show];
            }else{
                SettingEmailViewController *vc = [SettingEmailViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else{
            SettingPhoneViewController *vc = [[SettingPhoneViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 2){
        SettingPasswordViewController *vc = [[SettingPasswordViewController alloc] init];
        vc.myUser = self.myUser;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 3){
        Close2FAViewController *vc = [Close2FAViewController vcWithPhone:_myUser.phone sucessBlock:^(UIViewController *vcc) {
            [vcc.navigationController popToRootViewControllerAnimated:YES];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)sendActivateEmail{
    [[Coding_NetAPIManager sharedManager] request_SendActivateEmail:self.myUser.email block:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"邮件已发送"];
        }
    }];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}
@end
