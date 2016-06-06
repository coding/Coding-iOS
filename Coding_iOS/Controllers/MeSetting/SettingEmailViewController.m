//
//  SettingEmailViewController.m
//  Coding_iOS
//
//  Created by Ease on 16/5/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "SettingEmailViewController.h"
#import "Input_OnlyText_Cell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "Login.h"
#import "Ease_2FA.h"

@interface SettingEmailViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;

@property (assign, nonatomic) BOOL is2FAOpen;
@property (strong, nonatomic) NSString *email, *j_captcha, *two_factor_code;
@end

@implementation SettingEmailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"绑定邮箱";
    self.email = [Login curLoginUser].email;
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Password];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _myTableView.tableFooterView = [self customFooterView];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneBtnClicked:)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh2FA];
}

- (void)refresh2FA{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] get_is2FAOpenBlock:^(BOOL data, NSError *error) {
        if (!error) {
            weakSelf.is2FAOpen = data;
            weakSelf.two_factor_code = data? [OTPListViewController otpCodeWithGK:[Login curLoginUser].global_key]: @"";
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark TableM

- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"发送验证邮箱" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(doneBtnClicked:)];
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, email),
                                                              RACObserve(self, j_captcha),
                                                              RACObserve(self, two_factor_code)]
                                                     reduce:^id(NSString *email, NSString *j_captcha, NSString *two_factor_code){
                                                         return @(email.length > 0 && j_captcha.length > 0 && two_factor_code.length > 0);
                                                     }];

    [footerV addSubview:_footerBtn];
    return footerV;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = (indexPath.row == 0? kCellIdentifier_Input_OnlyText_Cell_Text:
                            indexPath.row == 1?  (!_is2FAOpen? kCellIdentifier_Input_OnlyText_Cell_Password:
                                                  kCellIdentifier_Input_OnlyText_Cell_Text):
                            kCellIdentifier_Input_OnlyText_Cell_Captcha);
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        [cell setPlaceholder:@" 邮箱" value:self.email];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.email = valueStr;
        };
    }else if (indexPath.row == 1){
        [cell setPlaceholder:!_is2FAOpen? @" 输入密码": @" 输入两步验证码" value:_two_factor_code];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.two_factor_code = valueStr;
        };
    }else{
        [cell setPlaceholder:@" 验证码" value:self.j_captcha];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.j_captcha = valueStr;
        };
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
    NSString *tipStr;
    if (![_email isEmail]) {
        tipStr = @"邮箱格式有误";
    }else if (_two_factor_code.length <= 0){
        tipStr = !_is2FAOpen? @"请填写密码": @"请填写两步验证码";
    }else if (_j_captcha.length <= 0){
        tipStr = @"请填写验证码";
    }
    if (tipStr.length > 0) {
        [NSObject showHudTipStr:tipStr];
        return;
    }
    NSDictionary *params = @{@"email": _email,
                                    @"j_captcha": _j_captcha,
                                    @"two_factor_code": !_is2FAOpen? [_two_factor_code sha1Str]: _two_factor_code};
    __weak typeof(self) weakSelf = self;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/email/change/send" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"发送验证邮件成功"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
