//
//  SettingPasswordViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "SettingPasswordViewController.h"
#import "InputOnlyTextPlainCell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"


@interface SettingPasswordViewController ()
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;

@end

@implementation SettingPasswordViewController

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
    self.title = @"密码设置";
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[InputOnlyTextPlainCell class] forCellReuseIdentifier:kCellIdentifier_InputOnlyTextPlain];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneBtnClicked:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _myUser.curPassword = nil;
    _myUser.resetPassword = nil;
    _myUser.resetPasswordConfirm = nil;
}

#pragma mark TableM

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 3;
    return row;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InputOnlyTextPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_InputOnlyTextPlain forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
        {
            [cell configWithPlaceholder:@"请输入当前密码" valueStr:self.myUser.curPassword secureTextEntry:YES];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                self.myUser.curPassword = valueStr;
            };
        }
            break;
        case 1:
        {
            [cell configWithPlaceholder:@"请输入新密码" valueStr:self.myUser.resetPassword secureTextEntry:YES];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                self.myUser.resetPassword = valueStr;
            };
        }
            break;
        default:
        {
            [cell configWithPlaceholder:@"请确认新密码" valueStr:self.myUser.resetPasswordConfirm secureTextEntry:YES];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                self.myUser.resetPasswordConfirm = valueStr;
            };
        }
            break;
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
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
}

#pragma mark DoneBtn Clicked
- (void)doneBtnClicked:(id)sender{
    [self.view endEditing:YES];
    NSString *tipStr = [_myUser changePasswordTips];
    if (tipStr) {
        [NSObject showHudTipStr:tipStr];
        return;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[Coding_NetAPIManager sharedManager] request_ResetPassword_WithObj:_myUser andBlock:^(id data, NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (data) {
            __weak typeof(self) weakSelf = self;
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示" message:@"修改密码成功，您需要重新登陆哦～"];
            [alertView bk_setCancelButtonWithTitle:@"知道了" handler:nil];
            [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
                [weakSelf loginOutToLoginVC];
            }];
            [alertView show];
        }
    }];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
