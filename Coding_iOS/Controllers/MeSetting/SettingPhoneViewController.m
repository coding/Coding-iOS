//
//  SettingPhoneViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/12/28.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "SettingPhoneViewController.h"
#import "Input_OnlyText_Cell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "Login.h"
#import "CountryCodeListViewController.h"
#import "Ease_2FA.h"

@interface SettingPhoneViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) NSString *phone, *code, *phone_country_code, *verifyStr;
@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;
@property (assign, nonatomic) VerifyType verifyType;
@end

@implementation SettingPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"绑定手机号码";
    self.phone = [Login curLoginUser].phone;
    self.phone_country_code = [Login curLoginUser].phone_country_code.length > 0? [Login curLoginUser].phone_country_code: @"+86";
    
    //    添加myTableView
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Phone];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Password];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:self.phoneCodeCellIdentifier];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneBtnClicked:)];

    self.verifyType = VerifyTypePassword;
    [[Coding_NetAPIManager sharedManager] request_VerifyTypeWithBlock:^(VerifyType type, NSError *error) {
        if (!error) {
            self.verifyType = type;
            self.verifyStr = type == VerifyTypeTotp? [OTPListViewController otpCodeWithGK:[Login curLoginUser].global_key]: @"";
            [self.myTableView reloadData];
        }
    }];
}
#pragma mark TableM

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = (indexPath.row == 0? kCellIdentifier_Input_OnlyText_Cell_Phone:
                            indexPath.row == 1? self.phoneCodeCellIdentifier:
                            _verifyType == VerifyTypePassword? kCellIdentifier_Input_OnlyText_Cell_Password:
                            kCellIdentifier_Input_OnlyText_Cell_Text);
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 手机号码" value:self.phone];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.phone = valueStr;
        };
        cell.countryCodeL.text = _phone_country_code;
        cell.countryCodeBtnClickedBlock = ^(){
            [weakSelf goToCountryCodeVC];
        };
    }else if (indexPath.row == 1){
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 手机验证码" value:self.code];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.code = valueStr;
        };
        cell.phoneCodeBtnClckedBlock = ^(PhoneCodeButton *btn){
            [weakSelf phoneCodeBtnClicked:btn];
        };
    }else{
        [cell setPlaceholder:_verifyType == VerifyTypePassword? @" 输入密码": @" 输入两步验证码" value:_verifyStr];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.verifyStr = valueStr;
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

#pragma mark CodeBtn
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender{
    if (![_phone isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    sender.enabled = NO;
    [[Coding_NetAPIManager sharedManager] request_GeneratePhoneCodeToResetPhone:_phone phoneCountryCode:_phone_country_code block:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"验证码发送成功"];
            [sender startUpTimer];
        }else{
            [sender invalidateTimer];
        }
    }];
}

#pragma mark DoneBtn Clicked
- (void)doneBtnClicked:(id)sender{
    NSString *tipStr;
    if (![_phone isPhoneNo]) {
        tipStr = @"手机号码格式有误";
    }else if (_code.length <= 0){
        tipStr = @"请填写手机验证码";
    }else if (_verifyStr.length <= 0){
        tipStr = _verifyType == VerifyTypePassword? @"请填写密码": @"请填写两步验证码";
    }
    if (tipStr.length > 0) {
        [NSObject showHudTipStr:tipStr];
        return;
    }
    NSMutableDictionary *params = @{@"phone": _phone,
                                    @"code": _code,
                                    @"phoneCountryCode": _phone_country_code,
                                    @"two_factor_code": _verifyType == VerifyTypePassword? [_verifyStr sha1Str]: _verifyStr}.mutableCopy;
    __weak typeof(self) weakSelf = self;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/phone/change" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"手机号码绑定成功"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - VC
- (void)goToCountryCodeVC{
    __weak typeof(self)  weakSelf = self;
    CountryCodeListViewController *vc = [CountryCodeListViewController new];
    vc.selectedBlock = ^(NSDictionary *countryCodeDict){
        weakSelf.phone_country_code = [NSString stringWithFormat:@"+%@", countryCodeDict[@"country_code"]];
        [weakSelf.myTableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

@end
