//
//  RegisterViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "RegisterViewController.h"
#import "Input_OnlyText_Cell.h"

#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"
#import "UIUnderlinedButton.h"
#import "TPKeyboardAvoidingTableView.h"
#import "WebViewController.h"
#import "CannotLoginViewController.h"
#import "EaseInputTipsView.h"
#import "CountryCodeListViewController.h"

@interface RegisterViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (nonatomic, assign) RegisterMethodType medthodType;

@property (nonatomic, strong) Register *myRegister;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) EaseInputTipsView *inputTipsView;

@property (assign, nonatomic) BOOL captchaNeeded;

@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;
@property (strong, nonatomic) NSDictionary *countryCodeDict;

@end

@implementation RegisterViewController

+ (instancetype)vcWithMethodType:(RegisterMethodType)methodType registerObj:(Register *)obj{
    RegisterViewController *vc = [self new];
    vc.medthodType = methodType;
    vc.myRegister = obj;
    return vc;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    _captchaNeeded = NO;
    self.title = @"注册";
    if (!_myRegister) {
        self.myRegister = [Register new];
    }
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Password];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Phone];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:self.phoneCodeCellIdentifier];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    [self setupNav];
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
    [self configBottomView];
}

- (void)refreshCaptchaNeeded{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CaptchaNeededWithPath:@"api/captcha/register" andBlock:^(id data, NSError *error) {
        if (data) {
            NSNumber *captchaNeededResult = (NSNumber *)data;
            if (captchaNeededResult) {
                weakSelf.captchaNeeded = captchaNeededResult.boolValue;
            }
            [weakSelf.myTableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self refreshCaptchaNeeded];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (EaseInputTipsView *)inputTipsView{
    if (!_inputTipsView) {
        _inputTipsView = ({
            EaseInputTipsView *tipsView = [EaseInputTipsView tipsViewWithType:EaseInputTipsViewTypeRegister];
            tipsView.valueStr = nil;
            
            __weak typeof(self) weakSelf = self;
            tipsView.selectedStringBlock = ^(NSString *valueStr){
                [weakSelf.view endEditing:YES];
                weakSelf.myRegister.email = valueStr;
                [weakSelf.myTableView reloadData];
            };
            UITableViewCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            [tipsView setY:CGRectGetMaxY(cell.frame)];
            
            [_myTableView addSubview:tipsView];
            tipsView;
        });
    }
    return _inputTipsView;
}

#pragma mark - Nav
- (void)setupNav{
    if (self.navigationController.childViewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(dismissSelf)];
    }
}

- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Top Bottom Header Footer
- (void)configBottomView{
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = self.myTableView.backgroundColor;

    UIButton *bottomBtn = ({
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:kColorBrandGreen forState:UIControlStateNormal];
        [button setTitle:_medthodType == RegisterMethodEamil? @"手机号注册": @"邮箱注册" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changeMethodType) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [bottomView addSubview:bottomBtn];
    [bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomView).insets(UIEdgeInsetsMake(0, 0, 30, 0));
    }];
    
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
}

- (void)changeMethodType{
    if (_medthodType == RegisterMethodPhone) {
        RegisterViewController *vc = [RegisterViewController vcWithMethodType:RegisterMethodEamil registerObj:_myRegister];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.15*kScreen_Height)];
    headerV.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.textColor = kColor222;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"加入Coding，体验云端开发之美！";
    [headerLabel setCenter:headerV.center];
    [headerV addSubview:headerLabel];
    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    //button
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"注册" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(sendRegister)];
    [footerV addSubview:_footerBtn];
    
    __weak typeof(self) weakSelf = self;
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.global_key),
                                                              RACObserve(self, myRegister.phone),
                                                              RACObserve(self, myRegister.email),
                                                              RACObserve(self, myRegister.password),
                                                              RACObserve(self, myRegister.code),
                                                              RACObserve(self, myRegister.j_captcha),
                                                              RACObserve(self, captchaNeeded)]
                                                     reduce:^id(NSString *global_key,
                                                                NSString *phone,
                                                                NSString *email,
                                                                NSString *password,
                                                                NSString *code,
                                                                NSString *j_captcha,
                                                                NSNumber *captchaNeeded){
                                                         BOOL enabled = (global_key.length > 0 &&
                                                                         password.length > 0 &&
                                                                         (!captchaNeeded.boolValue || j_captcha.length > 0) &&
                                                                         ((weakSelf.medthodType == RegisterMethodEamil && email.length > 0) ||
                                                                          (weakSelf.medthodType == RegisterMethodPhone && phone.length > 0 && code.length > 0)));
                                                         return @(enabled);
                                                     }];
    //label
    UITTTAttributedLabel *lineLabel = ({
        UITTTAttributedLabel *label = [[UITTTAttributedLabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = kColor999;
        label.numberOfLines = 0;
        label.linkAttributes = kLinkAttributes;
        label.activeLinkAttributes = kLinkAttributesActive;
        label.delegate = self;
        label;
    });
    NSString *tipStr = @"注册 Coding 账号表示您已同意《Coding 服务条款》";
    lineLabel.text = tipStr;
    [lineLabel addLinkToTransitInformation:@{@"actionStr" : @"gotoServiceTermsVC"} withRange:[tipStr rangeOfString:@"《Coding 服务条款》"]];
    CGRect footerBtnFrame = _footerBtn.frame;
    lineLabel.frame = CGRectMake(CGRectGetMinX(footerBtnFrame), CGRectGetMaxY(footerBtnFrame) +12, CGRectGetWidth(footerBtnFrame), 12);
    [footerV addSubview:lineLabel];
    
    return footerV;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = _medthodType == RegisterMethodEamil? 3: 4;
    return _captchaNeeded? num +1 : num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier;
    if (_medthodType == RegisterMethodEamil) {
        cellIdentifier = (indexPath.row == 3? kCellIdentifier_Input_OnlyText_Cell_Captcha:
                          indexPath.row == 2? kCellIdentifier_Input_OnlyText_Cell_Password:
                          kCellIdentifier_Input_OnlyText_Cell_Text);
    }else{
        cellIdentifier = (indexPath.row == 4? kCellIdentifier_Input_OnlyText_Cell_Captcha:
                          indexPath.row == 3? self.phoneCodeCellIdentifier:
                          indexPath.row == 2? kCellIdentifier_Input_OnlyText_Cell_Password:
                          indexPath.row == 1? kCellIdentifier_Input_OnlyText_Cell_Phone:
                          kCellIdentifier_Input_OnlyText_Cell_Text);
    }
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    __weak typeof(self) weakSelf = self;
    if (_medthodType == RegisterMethodEamil) {
        if (indexPath.row == 0) {
            [cell setPlaceholder:@" 用户名（个性后缀）" value:self.myRegister.global_key];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.global_key = valueStr;
            };
        }else if (indexPath.row == 1){
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            [cell setPlaceholder:@" 邮箱" value:self.myRegister.email];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.inputTipsView.valueStr = valueStr;
                weakSelf.inputTipsView.active = YES;
                weakSelf.myRegister.email = valueStr;
            };
            cell.editDidEndBlock = ^(NSString *textStr){
                weakSelf.inputTipsView.active = NO;
            };
        }else if (indexPath.row == 2){
            [cell setPlaceholder:@" 设置密码" value:self.myRegister.password];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.password = valueStr;
            };
        }else{
            [cell setPlaceholder:@" 验证码" value:self.myRegister.j_captcha];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.j_captcha = valueStr;
            };
        }
    }else{
        if (indexPath.row == 0) {
            [cell setPlaceholder:@" 用户名（个性后缀）" value:self.myRegister.global_key];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.global_key = valueStr;
            };
        }else if (indexPath.row == 1){
            if (!_countryCodeDict) {
                _countryCodeDict = @{@"country": @"China",
                                     @"country_code": @"86",
                                     @"iso_code": @"cn"};
            }
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            [cell setPlaceholder:@" 手机号" value:self.myRegister.phone];
            cell.countryCodeL.text = [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]];
            cell.countryCodeBtnClickedBlock = ^(){
                [weakSelf goToCountryCodeVC];
            };
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.phone = valueStr;
            };
        }else if (indexPath.row == 2){
            [cell setPlaceholder:@" 设置密码" value:self.myRegister.password];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.password = valueStr;
            };
        }else if (indexPath.row == 3){
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            [cell setPlaceholder:@" 手机验证码" value:self.myRegister.code];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.code = valueStr;
            };
            cell.phoneCodeBtnClckedBlock = ^(PhoneCodeButton *btn){
                [weakSelf phoneCodeBtnClicked:btn];
            };
        }else{
            [cell setPlaceholder:@" 验证码" value:self.myRegister.j_captcha];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.j_captcha = valueStr;
            };
        }
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    [self gotoServiceTermsVC];
}
#pragma mark Btn Clicked
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender{
    if (![_myRegister.phone isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    sender.enabled = NO;
    NSDictionary *params = @{@"phone": _myRegister.phone,
                             @"phoneCountryCode": [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]]};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/register/generate_phone_code" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"验证码发送成功"];
            [sender startUpTimer];
        }else{
            [sender invalidateTimer];
        }
    }];
}

- (void)sendRegister{
    if (![_myRegister.global_key isGK]) {
        [NSObject showHudTipStr:@"个性后缀仅支持英文字母、数字、横线(-)以及下划线(_)"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = @{@"channel": [Register channel],
                                    @"global_key": _myRegister.global_key,
                                    @"password": [_myRegister.password sha1Str],
                                    @"confirm": [_myRegister.password sha1Str]}.mutableCopy;
    if (_medthodType == RegisterMethodEamil) {
        params[@"email"] = _myRegister.email;
    }else{
        params[@"phone"] = _myRegister.phone;
        params[@"code"] = _myRegister.code;
        params[@"country"] = _countryCodeDict[@"iso_code"];
        params[@"phoneCountryCode"] = [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]];
    }
    if (_captchaNeeded) {
        params[@"j_captcha"] = _myRegister.j_captcha;
    }
    [self.footerBtn startQueryAnimate];
    [[Coding_NetAPIManager sharedManager] request_Register_V2_WithParams:params andBlock:^(id data, NSError *error) {
        [weakSelf.footerBtn stopQueryAnimate];
        if (data) {
            [self.view endEditing:YES];
            [Login setPreUserEmail:self.myRegister.global_key];//记住登录账号
            [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
            if (weakSelf.medthodType == RegisterMethodEamil) {
                kTipAlert(@"欢迎注册 Coding，请尽快去邮箱查收邮件并激活账号。如若在收件箱中未看到激活邮件，请留意一下垃圾邮件箱(T_T)。");
            }
        }else{
            [weakSelf refreshCaptchaNeeded];
        }
    }];
}

#pragma mark VC
- (void)gotoServiceTermsVC{
    NSString *pathForServiceterms = [[NSBundle mainBundle] pathForResource:@"service_terms" ofType:@"html"];
    WebViewController *vc = [WebViewController webVCWithUrlStr:pathForServiceterms];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToCountryCodeVC{
    __weak typeof(self)  weakSelf = self;
    CountryCodeListViewController *vc = [CountryCodeListViewController new];
    vc.selectedBlock = ^(NSDictionary *countryCodeDict){
        weakSelf.countryCodeDict = countryCodeDict;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

@end
