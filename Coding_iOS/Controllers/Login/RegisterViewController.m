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
#import "LoginViewController.h"

@interface RegisterViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (nonatomic, assign) RegisterMethodType medthodType;

@property (nonatomic, strong) Register *myRegister;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) EaseInputTipsView *inputTipsView;

@property (assign, nonatomic) BOOL captchaNeeded;

@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;
@property (strong, nonatomic) NSDictionary *countryCodeDict;

@property (assign, nonatomic) NSInteger step;

@end

@implementation RegisterViewController

+ (instancetype)vcWithMethodType:(RegisterMethodType)methodType registerObj:(Register *)obj{
    RegisterViewController *vc = [self new];
    vc.medthodType = methodType;
    vc.myRegister = obj;
    vc.step = 0;
    return vc;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = kColorWhite;
    [self.navigationController.navigationBar setupClearBGStyle];

    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    _captchaNeeded = NO;
//    self.title = @"注册";
    if (!_myRegister) {
        self.myRegister = [Register new];
    }
    if (!_countryCodeDict) {
        _countryCodeDict = @{@"country": @"China",
                             @"country_code": @"86",
                             @"iso_code": @"cn"};
    }
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Password];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Phone];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:self.phoneCodeCellIdentifier];
//        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    [self setupNav];
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
    [self configBottomView];
}

- (void)refreshCaptchaNeeded{
    if (_medthodType == RegisterMethodPhone && _step <= 0) {
        self.captchaNeeded = NO;
        [self.myTableView reloadData];
    }else{
        //写死，APP 不需要
        self.captchaNeeded = NO;
        [self.myTableView reloadData];

//        __weak typeof(self) weakSelf = self;
//        [[Coding_NetAPIManager sharedManager] request_CaptchaNeededWithPath:@"api/captcha/register" andBlock:^(id data, NSError *error) {
//            if (data) {
//                NSNumber *captchaNeededResult = (NSNumber *)data;
//                if (captchaNeededResult) {
//                    weakSelf.captchaNeeded = captchaNeededResult.boolValue;
//                }
//                [weakSelf.myTableView reloadData];
//            }
//        }];
    }
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
    UIButton *bottomBtn = ({
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:kColorDark2 forState:UIControlStateNormal];
        [button setTitle:@"已有 Coding 账号？" forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [button bk_addEventHandler:^(id sender) {
            if (weakSelf.navigationController.viewControllers.count > 1) {
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }else{
                LoginViewController *vc = [[LoginViewController alloc] init];
                vc.showDismissButton = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [bottomView addSubview:bottomBtn];
    [bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(bottomView);
        make.height.mas_equalTo(25);
    }];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(50 + kSafeArea_Bottom);
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
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    UILabel *headerL = [UILabel labelWithFont:[UIFont systemFontOfSize:30] textColor:kColorDark2];
    headerL.text = self.step > 0? @"设置密码": @"注册";
    [headerV addSubview:headerL];
    [headerL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kPaddingLeftWidth);
        make.bottom.offset(0);
        make.height.mas_equalTo(42);
    }];
    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    //button
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:self.step > 0? @"注册": @"下一步" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 50) target:self action:@selector(sendRegister)];
    [footerV addSubview:_footerBtn];
    
    __weak typeof(self) weakSelf = self;
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.global_key),
                                                              RACObserve(self, myRegister.phone),
                                                              RACObserve(self, myRegister.email),
                                                              RACObserve(self, myRegister.password),
                                                              RACObserve(self, myRegister.confirm_password),
                                                              RACObserve(self, myRegister.code),
                                                              RACObserve(self, myRegister.j_captcha),
                                                              RACObserve(self, captchaNeeded)]
                                                     reduce:^id(NSString *global_key,
                                                                NSString *phone,
                                                                NSString *email,
                                                                NSString *password,
                                                                NSString *confirm_password,
                                                                NSString *code,
                                                                NSString *j_captcha,
                                                                NSNumber *captchaNeeded){
                                                         BOOL enabled;
                                                         if (weakSelf.medthodType == RegisterMethodEamil) {
                                                             enabled = (global_key.length > 0 &&
                                                                        password.length > 0 &&
                                                                        (!captchaNeeded.boolValue || j_captcha.length > 0) &&
                                                                        email.length > 0);
                                                         }else if (weakSelf.step > 0){
                                                             enabled = (global_key.length > 0 &&
                                                                        password.length > 0 &&
                                                                        confirm_password.length > 0 &&
//                                                                        [confirm_password isEqualToString:password] &&
                                                                        (!captchaNeeded.boolValue || j_captcha.length > 0) &&
                                                                        (phone.length > 0 && code.length > 0));
                                                         }else{
                                                             enabled = (global_key.length > 0 &&
                                                                        (!captchaNeeded.boolValue || j_captcha.length > 0) &&
                                                                        (phone.length > 0 && code.length > 0));
                                                         }
                                                         return @(enabled);
                                                     }];
    //label
    UITTTAttributedLabel *lineLabel = ({
        UITTTAttributedLabel *label = [[UITTTAttributedLabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = kColorDark2;
        label.numberOfLines = 0;
        label.linkAttributes = kLinkAttributes;
        label.activeLinkAttributes = kLinkAttributesActive;
        label.delegate = self;
        label;
    });
    NSString *tipStr = @"点击注册，即同意《Coding 服务条款》";
    lineLabel.text = tipStr;
    [lineLabel addLinkToTransitInformation:@{@"actionStr" : @"gotoServiceTermsVC"} withRange:[tipStr rangeOfString:@"《Coding 服务条款》"]];
    CGRect footerBtnFrame = _footerBtn.frame;
    lineLabel.frame = CGRectMake(CGRectGetMinX(footerBtnFrame), CGRectGetMaxY(footerBtnFrame) +15, CGRectGetWidth(footerBtnFrame), 15);
    [footerV addSubview:lineLabel];
    
    return footerV;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = _medthodType == RegisterMethodEamil? 3: _step > 0? 2: 3;
    return _captchaNeeded? num +1 : num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier;
    if (_medthodType == RegisterMethodEamil) {
        cellIdentifier = (indexPath.row == 3? kCellIdentifier_Input_OnlyText_Cell_Captcha:
                          indexPath.row == 2? kCellIdentifier_Input_OnlyText_Cell_Password:
                          kCellIdentifier_Input_OnlyText_Cell_Text);
    }else{
        if (_step > 0) {
            cellIdentifier = (indexPath.row == 2? kCellIdentifier_Input_OnlyText_Cell_Captcha:
                              kCellIdentifier_Input_OnlyText_Cell_Text);
        }else{
            cellIdentifier = (indexPath.row == 2? self.phoneCodeCellIdentifier:
                              indexPath.row == 1? kCellIdentifier_Input_OnlyText_Cell_Phone:
                              kCellIdentifier_Input_OnlyText_Cell_Text);
        }
    }
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.isBottomLineShow = YES;

    __weak typeof(self) weakSelf = self;
    if (_medthodType == RegisterMethodEamil) {
        if (indexPath.row == 0) {
            [cell setPlaceholder:@" 用户名" value:self.myRegister.global_key];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.global_key = [valueStr trimWhitespace];
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
        if (_step > 0) {
            if (indexPath.row == 0){
                [cell setPlaceholder:@" 设置密码" value:self.myRegister.password];
                cell.textField.secureTextEntry = YES;
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.password = valueStr;
                };
            }else if (indexPath.row == 1){
                [cell setPlaceholder:@" 重复密码" value:self.myRegister.password];
                cell.textField.secureTextEntry = YES;
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.confirm_password = valueStr;
                };
            }else{
                [cell setPlaceholder:@" 验证码" value:self.myRegister.j_captcha];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.j_captcha = valueStr;
                };
            }
        }else{
            if (indexPath.row == 0) {
                [cell setPlaceholder:@" 用户名" value:self.myRegister.global_key];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.global_key = [valueStr trimWhitespace];
                };
            }else if (indexPath.row == 1){
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                [cell setPlaceholder:@" 手机号码" value:self.myRegister.phone];
                cell.countryCodeL.text = [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]];
                cell.countryCodeBtnClickedBlock = ^(){
                    [weakSelf goToCountryCodeVC];
                };
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.phone = valueStr;
                };
            }else if (indexPath.row == 2){
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                [cell setPlaceholder:@" 手机验证码" value:self.myRegister.code];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.code = valueStr;
                };
                cell.phoneCodeBtnClckedBlock = ^(PhoneCodeButton *btn){
                    [weakSelf phoneCodeBtnClicked:btn withCaptcha:nil];
                };
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0;
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    [self gotoServiceTermsVC];
}
#pragma mark Btn Clicked
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender withCaptcha:(NSString *)captcha{
    if (![_myRegister.phone isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    sender.enabled = NO;
    NSMutableDictionary *params = @{@"phone": _myRegister.phone,
                                    @"phoneCountryCode": [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]]}.mutableCopy;
    if (captcha.length > 0) {
        params[@"j_captcha"] = captcha;
    }
    __weak typeof(self) weakSelf = self;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/register/generate_phone_code" withParams:params withMethodType:Post autoShowError:captcha.length > 0 andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"验证码发送成功"];
            [sender startUpTimer];
        }else{
            [sender invalidateTimer];
            if (error && error.userInfo[@"msg"] && [[error.userInfo[@"msg"] allKeys] containsObject:@"j_captcha_error"]) {
                [weakSelf p_showCaptchaAlert:sender];
            }else if (captcha.length <= 0){
                [NSObject showError:error];
            }
        }
    }];
}

- (void)p_showCaptchaAlert:(PhoneCodeButton *)sender{
    SDCAlertController *alertV = [SDCAlertController alertControllerWithTitle:@"提示" message:@"请输入图片验证码" preferredStyle:SDCAlertControllerStyleAlert];
    UITextField *textF = [UITextField new];
    textF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    textF.backgroundColor = [UIColor whiteColor];
    [textF doBorderWidth:0.5 color:nil cornerRadius:2.0];
    UIImageView *imageV = [YLImageView new];
    imageV.backgroundColor = [UIColor lightGrayColor];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    imageV.clipsToBounds = YES;
    imageV.userInteractionEnabled = YES;
    [textF doBorderWidth:0.5 color:nil cornerRadius:2.0];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/getCaptcha", [NSObject baseURLStr]]];
    [imageV sd_setImageWithURL:imageURL placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies)];
        
    [alertV.contentView addSubview:textF];
    [alertV.contentView addSubview:imageV];
    [textF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(alertV.contentView).offset(15);
        make.height.mas_equalTo(25);
        make.bottom.equalTo(alertV.contentView).offset(-10);
    }];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(alertV.contentView).offset(-15);
        make.left.equalTo(textF.mas_right).offset(10);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(25);
        make.centerY.equalTo(textF);
    }];
    //Action
    __weak typeof(imageV) weakImageV = imageV;
    [imageV bk_whenTapped:^{
        [weakImageV sd_setImageWithURL:imageURL placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies)];
    }];
    __weak typeof(self) weakSelf = self;
    [alertV addAction:[SDCAlertAction actionWithTitle:@"取消" style:SDCAlertActionStyleCancel handler:nil]];
    [alertV addAction:[SDCAlertAction actionWithTitle:@"确定" style:SDCAlertActionStyleDefault handler:nil]];
    alertV.shouldDismissBlock =  ^BOOL (SDCAlertAction *action){
        if (![action.title isEqualToString:@"取消"]) {
            [weakSelf phoneCodeBtnClicked:sender withCaptcha:textF.text];
        }
        return YES;
    };
    [alertV presentWithCompletion:^{
        [textF becomeFirstResponder];
    }];
}

- (void)sendRegister{
    NSString *tipStr = nil;
    if (![_myRegister.global_key isGK]) {
        tipStr = @"用户名仅支持英文字母、数字、横线(-)以及下划线(_)";
    }else if (_step > 0 && ![_myRegister.confirm_password isEqualToString:_myRegister.password]){
        tipStr = @"密码输入不一致";
    }
    if (tipStr) {
        [NSObject showHudTipStr:tipStr];
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (_medthodType == RegisterMethodPhone && _step <= 0) {
        [self.footerBtn startQueryAnimate];
        NSDictionary *gkP = @{@"key": _myRegister.global_key};
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/check" withParams:gkP withMethodType:Get andBlock:^(id data, NSError *error) {
            if (!error && [data[@"data"] boolValue]) {//用户名还未被注册
                NSDictionary *phoneCodeP = @{@"phone": _myRegister.phone,
                                             @"verifyCode": _myRegister.code,
                                             @"phoneCountryCode": [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]],
                                             };
                [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/register/check-verify-code" withParams:phoneCodeP withMethodType:Post andBlock:^(id data, NSError *error) {
                    [weakSelf.footerBtn stopQueryAnimate];
                    if (!error) {
                        //手机验证码通过校验
                        RegisterViewController *vc = [RegisterViewController new];
                        vc.medthodType = RegisterMethodPhone;
                        vc.myRegister = weakSelf.myRegister;
                        vc.step = 1;
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    }
                }];
            }else{
                [weakSelf.footerBtn stopQueryAnimate];
                if (!error) {
                    [NSObject showHudTipStr:@"用户名已存在"];
                }
            }
        }];
    }else{
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
