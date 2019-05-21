//
//  LoginViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "CannotLoginViewController.h"
#import "ActivateViewController.h"
#import "Input_OnlyText_Cell.h"
#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"
#import "StartImagesManager.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import <UIImage+BlurredFrame/UIImage+BlurredFrame.h>
#import "UIImageView+WebCache.h"
#import "EaseInputTipsView.h"
#import "Close2FAViewController.h"

#import "Ease_2FA.h"
#import "Login2FATipCell.h"

#import <UMSocialCore/UMSocialCore.h>

#ifdef Target_Enterprise

typedef NS_ENUM(NSUInteger, LoginStep) {
    LoginStepCompany = 0,
    LoginStepPassword,
    LoginStep2FA,
};

@interface LoginViewController ()
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *backBtn, *rightNavBtn, *nextBtn, *cannotLoginBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (assign, nonatomic) LoginStep step;
@property (nonatomic, strong) Login *myLogin;
@property (strong, nonatomic) NSString *otpCode;
@property (assign, nonatomic) BOOL captchaNeeded;
@property (assign, nonatomic, readonly) BOOL isPrivateCloud;
@end


@implementation LoginViewController

#pragma mark Life
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"登录";
    if (_step == LoginStepCompany) {
        self.myLogin.company = self.isPrivateCloud? [NSObject privateCloud]: ([Login curLoginCompany].global_key ?: [NSObject baseCompany]);
        [self addChangeBaseURLGesture];
    }else if (_step == LoginStepPassword){
        self.myLogin.email = [Login preUserEmail];
        [self refreshCaptchaNeeded];
    }else if (_step == LoginStep2FA){
        self.otpCode = [OTPListViewController otpCodeWithGK:self.myLogin.email];
        if (self.otpCode) {//发送登录请求
            [self loginBtnClicked];
        }
    }
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
    [self.navigationController addFullscreenPopGesture];
    [self setupNavBtn];
    
#if DEBUG
    if (self.isPrivateCloud) {
        self.myLogin.email = @"ce-admin";
        self.myLogin.company = @"http://pd.codingprod.net";
        self.myLogin.password = @"123123";
    }
#endif
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.myTableView reloadData];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)setupNavBtn{
    if (_step > LoginStepCompany || self.showDismissButton) {
        [self backBtn];
    }
    [self rightNavBtn];
}

- (void)refreshCaptchaNeeded{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CaptchaNeededWithPath:@"api/captcha/login" andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.captchaNeeded = ((NSNumber *)data).boolValue;
        }
    }];
}

#pragma mark Get Set
- (Login *)myLogin{
    if (!_myLogin) {
        _myLogin = [Login new];
    }
    return _myLogin;
}

- (BOOL)isPrivateCloud{
    return [NSObject isPrivateCloud].boolValue;
}

- (void)setCaptchaNeeded:(BOOL)captchaNeeded{
    _captchaNeeded = captchaNeeded;
    if (!captchaNeeded) {
        self.myLogin.j_captcha = nil;
    }
    [self.myTableView reloadData];
}

- (TPKeyboardAvoidingTableView *)myTableView{
    if (!_myTableView) {
        _myTableView = ({
            TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
            [tableView registerClass:[Login2FATipCell class] forCellReuseIdentifier:kCellIdentifier_Login2FATipCell];
            [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
            [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
            [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Company];
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self.view addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            tableView;
        });
    }
    return _myTableView;
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, kSafeArea_Top, 44, 44)];
            [button setImage:[UIImage imageNamed:@"back_green_Nav"] forState:UIControlStateNormal];
            button.tintColor = kColorLightBlue;
            [button setImage:[[UIImage imageNamed:@"back_green_Nav"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            button;
        });
    }
    return _backBtn;
}

- (UIButton *)rightNavBtn{
    if (!_rightNavBtn) {
        if (!_rightNavBtn) {
            _rightNavBtn = ({
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 130, kSafeArea_Top, 120, 50)];
                button.backgroundColor = [UIColor whiteColor];
                [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
                [button setTitleColor:kColorLightBlue forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorWithHexString:@"0x0060FF" andAlpha:.5] forState:UIControlStateHighlighted];
                button.tintColor = kColorBrandBlue;
                [button addTarget:self action:@selector(rightNavBtnClicked) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:button];
                button;
            });
        }
        if (_step == LoginStep2FA) {
            [_rightNavBtn setTitle:@"关闭两步验证" forState:UIControlStateNormal];
            [_rightNavBtn setImage:nil forState:UIControlStateNormal];
            _rightNavBtn.hidden = [NSObject isPrivateCloud].boolValue;
        }else{
            [_rightNavBtn setTitle:@"  两步验证" forState:UIControlStateNormal];
            [_rightNavBtn setImage:[[UIImage imageNamed:@"twoFABtn_Nav"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        }
    }
    return _rightNavBtn;
}

- (UIActivityIndicatorView *)activityIndicator{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
        _activityIndicator.hidesWhenStopped = YES;
        [_nextBtn addSubview:_activityIndicator];
    }
    [_activityIndicator setCenter:CGPointMake(_nextBtn.width/2 - 40, _nextBtn.height/2)];
    return _activityIndicator;
}

#pragma mark - Table Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44 + (_step == LoginStepPassword? 100: 60))];
    UILabel *headerL = [UILabel labelWithSystemFontSize:28 textColorHexString:@"0x272C33"];
    if (_step == LoginStepPassword) {
        [headerL ea_setText:[NSString stringWithFormat:@"登录到\n%@", [NSURL URLWithString:[NSObject baseURLStr]].host] lineSpacing:5];
    }else{
        headerL.text = (_step == LoginStepCompany? (self.isPrivateCloud? @"私有部署账号登录":
                                                    @"企业账号登录"):
                        @"两步验证");
    }
    [headerV addSubview:headerL];
    [headerL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerV).offset(20);
        make.bottom.equalTo(headerV);
        make.height.mas_equalTo(_step == LoginStepPassword? 80: 40);
    }];
    return headerV;
}

- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 100)];
    _nextBtn = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kLoginPaddingLeftWidth, (_step == LoginStepPassword? 50: 25), kScreen_Width-kLoginPaddingLeftWidth*2, 50)];
        button.backgroundColor = kColorDark4;
        button.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:(_step == LoginStepCompany? @"下一步": @"登录") forState:UIControlStateNormal];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 2.0;
        [button addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [footerV addSubview:button];
        button;
    });
    [RACObserve(self, nextBtn.enabled) subscribeNext:^(NSNumber *x) {
        [self.nextBtn setTitleColor:[UIColor colorWithWhite:1.0 alpha:x.boolValue? 1.0: .5] forState:UIControlStateNormal];
    }];
    RAC(self, nextBtn.alpha) = [RACObserve(self, nextBtn.enabled) map:^id(NSNumber *value) {
        return @(value.boolValue? 1.0: .99);
    }];
    if (_step == LoginStepCompany) {
        RAC(self, nextBtn.enabled) = [RACObserve(self, myLogin.company) map:^id(NSString *value) {
            return @(value.length > 0);
        }];
    }else if (_step == LoginStepPassword){
        _cannotLoginBtn = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 120, 10, 100, 30)];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setTitleColor:kColorLightBlue forState:UIControlStateNormal];
            [button setTitle:@"忘记密码？" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(cannotLoginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [footerV addSubview:button];
            button;
        });
        RAC(self, nextBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myLogin.email),
                                                                RACObserve(self, myLogin.password),
                                                                RACObserve(self, myLogin.j_captcha),
                                                                RACObserve(self, captchaNeeded)]
                                                       reduce:^id(NSString *email,
                                                                  NSString *password,
                                                                  NSString *j_captcha,
                                                                  NSNumber *captchaNeeded){
                                                           return @(email.length > 0 && password.length > 0 && (j_captcha.length > 0 || !captchaNeeded.boolValue));
                                                       }];
    }else if (_step == LoginStep2FA){
        RAC(self, nextBtn.enabled) = [RACObserve(self, otpCode) map:^id(NSString *value) {
            return @(value.length > 0);
        }];
    }
    return footerV;
}

#pragma mark - Table Data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (_step == LoginStepCompany? 1:
            _step == LoginStepPassword? (_captchaNeeded? 3: 2):
            _step == LoginStep2FA? 2:
            0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    if (_step == LoginStep2FA && row == 0) {
        Login2FATipCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Login2FATipCell forIndexPath:indexPath];
        cell.tipLabel.text = @"您的账户开启了两步验证，请输入动态验证码登录";
        return cell;
    }else{
        NSString *identifier = (_step == LoginStepCompany? (self.isPrivateCloud? kCellIdentifier_Input_OnlyText_Cell_Text:
                                                            kCellIdentifier_Input_OnlyText_Cell_Company):
                                _step == LoginStepPassword? (row < 2? kCellIdentifier_Input_OnlyText_Cell_Text:
                                                             kCellIdentifier_Input_OnlyText_Cell_Captcha):
                                kCellIdentifier_Input_OnlyText_Cell_Text);
        Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.isBottomLineShow = YES;
        __weak typeof(self) weakSelf = self;
        if (_step == LoginStepCompany) {
            [cell setPlaceholder:self.isPrivateCloud? @" 请输入私有部署域名": @" 请输入企业域名前缀" value:self.myLogin.company];
            if (!self.isPrivateCloud) {
                cell.companySuffixL.text = [NSString stringWithFormat:@".%@", [NSObject baseCompanySuffixStr]];
            }else{
                cell.textField.keyboardType = UIKeyboardTypeURL;
            }
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myLogin.company = valueStr;
            };
        }else if (_step == LoginStepPassword){
            if (row == 0) {
                cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                [cell setPlaceholder:@" 邮箱或用户名" value:self.myLogin.email];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myLogin.email = valueStr;
                };
            }else if (row == 1){
                [cell setPlaceholder:@" 密码" value:self.myLogin.password];
                cell.textField.secureTextEntry = YES;
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myLogin.password = valueStr;
                };
            }else{
                [cell setPlaceholder:@" 验证码" value:self.myLogin.j_captcha];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myLogin.j_captcha = valueStr;
                };
            }
        }else if (_step == LoginStep2FA){
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            [cell setPlaceholder:@" 动态验证码" value:self.otpCode];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.otpCode = valueStr;
            };
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0;
}

#pragma mark Btn Clicked

- (void)backBtnClicked{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)rightNavBtnClicked{
    if (_step == LoginStep2FA) {
        __weak typeof(self) weakSelf = self;
        UIViewController *vc = [Close2FAViewController vcWithPhone:self.myLogin.email sucessBlock:^(UIViewController *vc) {
            [weakSelf.navigationController popToViewController:weakSelf.navigationController.viewControllers[1] animated:YES];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        OTPListViewController *vc = [OTPListViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)cannotLoginBtnClicked{
    UIViewController *vc = [CannotLoginViewController vcWithMethodType:CannotLoginMethodEamil stepIndex:1 userStr:[self.myLogin.email isEmail]? self.myLogin.email: nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginBtnClicked{
    [self.view endEditing:YES];
    [self.activityIndicator startAnimating];
    _nextBtn.enabled = NO;
    __weak typeof(self) weakSelf = self;
    void (^endLoadingBlock)() = ^(){
        [weakSelf.activityIndicator stopAnimating];
        weakSelf.nextBtn.enabled = YES;
    };
    if (_step == LoginStepCompany) {
        [NSObject changeBaseCompanyTo:self.myLogin.company];
        [[Coding_NetAPIManager sharedManager] request_CompanyExist:[NSObject baseCompany] andBlock:^(id data, NSError *error) {
            endLoadingBlock();
            if (error) {
                if (error.code == 1){//企业不存在
                    [NSObject showHudTipStr:weakSelf.isPrivateCloud? @"请正确填写私有部署域名": @"请正确填写企业域名"];
                }else{
                    [NSObject showError:error];
                }
            }else{
                NSDictionary *dataBody = [data objectForKey:@"data"];
                NSDictionary *settings = [dataBody objectForKey:@"settings"];
                BOOL ssoEnabled = [[settings objectForKey:@"ssoEnabled"] boolValue];
                NSString *ssoType = [settings objectForKey:@"ssoType"];
                self.myLogin.ssoType = ssoType;
                self.myLogin.ssoEnabled = ssoEnabled;
                [weakSelf goToNextStep];
            }
        }];
    }else if (_step == LoginStepPassword){
        [[Coding_NetAPIManager sharedManager] request_Login_WithPath:[self.myLogin toPath] Params:[self.myLogin toParams] andBlock:^(id data, NSError *error) {
            endLoadingBlock();
            if (data) {
                [Login setPreUserEmail:weakSelf.myLogin.email];//记住登录账号
                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
            }else{
                NSString *global_key = error.userInfo[@"msg"][@"two_factor_auth_code_not_empty"];
                if (global_key.length > 0) {
                    weakSelf.myLogin.email = global_key;
                    [weakSelf goToNextStep];
                }else if (error.userInfo[@"msg"][@"user_need_activate"]){
                    [NSObject showError:error];
                    ActivateViewController *vc = [ActivateViewController new];
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    [NSObject showError:error];
                    [weakSelf refreshCaptchaNeeded];
                }
            }
        }];
    }else if (_step == LoginStep2FA){
        [[Coding_NetAPIManager sharedManager] request_Login_With2FA:self.otpCode andBlock:^(id data, NSError *error) {
            endLoadingBlock();
            if (data) {
                [Login setPreUserEmail:self.myLogin.email];//记住登录账号
                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
            }else{
                NSString *status_expired = error.userInfo[@"msg"][@"user_login_status_expired"];
                if (status_expired.length > 0) {//登录状态过期了，返回上个页面重新密码登录
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
        }];
    }else{
        endLoadingBlock();
    }
}

- (void)goToNextStep{
    LoginViewController *vc = [LoginViewController new];
    vc.myLogin = _myLogin;
    vc.step = _step + 1;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 切换服务器手势 - 不停地 tap

- (void)addChangeBaseURLGesture{
    @weakify(self);
    UITapGestureRecognizer *tapGR = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self);
        if (state == UIGestureRecognizerStateRecognized) {
            [self changeBaseURLTip];
        }
    }];
    tapGR.numberOfTapsRequired = 10.0;
    [self.view addGestureRecognizer:tapGR];
}

- (void)changeBaseURLTip{
    if ([UIDevice currentDevice].systemVersion.integerValue < 8) {
        [NSObject showHudTipStr:@"需要 8.0 以上系统才能切换服务器地址"];
        return;
    }
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"更改服务器 URL" message:@"空白值可切换回生产环境\n" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *confirmA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *newBaseCompanySuffixStr = alertCtrl.textFields[0].text;
        if ([newBaseCompanySuffixStr.uppercaseString isEqualToString:@"S"]) {
            newBaseCompanySuffixStr = @"coding.codingprod.net";
        }
        [NSObject changeBaseCompanySuffixStrTo:newBaseCompanySuffixStr];
        [weakSelf.myTableView reloadData];
    }];
    [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"CODING 服务器地址";
        textField.text = [NSObject baseCompanySuffixStr];
    }];
    [alertCtrl addAction:cancelA];
    [alertCtrl addAction:confirmA];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

@end

#else


@interface LoginViewController ()
@property (nonatomic, strong) Login *myLogin;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIView *bottomView;


@property (assign, nonatomic) BOOL captchaNeeded;
@property (strong, nonatomic) UIButton *loginBtn, *buttonFor2FA, *underLoginBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
//@property (strong, nonatomic) UIImageView *iconUserView, *bgBlurredView;
@property (strong, nonatomic) EaseInputTipsView *inputTipsView;
@property (strong, nonatomic) UIButton *dismissButton;

@property (assign, nonatomic) BOOL is2FAUI;
@property (strong, nonatomic) NSString *otpCode;
@end

@implementation LoginViewController

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
    
    self.myLogin = [[Login alloc] init];
    self.myLogin.email = [Login preUserEmail];
    _captchaNeeded = NO;
    self.view.backgroundColor = kColorWhite;
    [self.navigationController.navigationBar setupClearBGStyle];
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Login2FATipCell class] forCellReuseIdentifier:kCellIdentifier_Login2FATipCell];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
        
        //        tableView.backgroundView = self.bgBlurredView;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kSafeArea_Top, 0, 0, 0));
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
    [self configBottomView];
    [self showdismissButton:self.showDismissButton];
    [self buttonFor2FA];
    
    [self refreshCaptchaNeeded];
    //    [self refreshIconUserImage];
}

- (UIButton *)buttonFor2FA{
    if (!_buttonFor2FA) {
        _buttonFor2FA = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 115, kSafeArea_Top, 100, 50)];
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [button setTitleColor:kColorBrandBlue forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHexString:@"0x0060FF" andAlpha:.5] forState:UIControlStateHighlighted];
            button.tintColor = kColorBrandBlue;
            [button setTitle:@"  两步验证" forState:UIControlStateNormal];
            [button setImage:[[UIImage imageNamed:@"twoFABtn_Nav"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            button;
        });
        [_buttonFor2FA addTarget:self action:@selector(goTo2FAVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_buttonFor2FA];
    }
    return _buttonFor2FA;
}

- (void)setCaptchaNeeded:(BOOL)captchaNeeded{
    _captchaNeeded = captchaNeeded;
    if (!captchaNeeded) {
        self.myLogin.j_captcha = nil;
    }
}

//- (UIImageView *)bgBlurredView{
//    if (!_bgBlurredView) {
//        //背景图片
//        UIImageView *bgView = [[UIImageView alloc] initWithFrame:kScreen_Bounds];
//        bgView.contentMode = UIViewContentModeScaleAspectFill;
//        UIImage *bgImage = [[StartImagesManager shareManager] curImage].image;
//
//        CGSize bgImageSize = bgImage.size, bgViewSize = bgView.frame.size;
//        if (bgImageSize.width > bgViewSize.width && bgImageSize.height > bgViewSize.height) {
//            bgImage = [bgImage scaleToSize:bgViewSize usingMode:NYXResizeModeAspectFill];
//        }
//        bgImage = [bgImage applyLightEffectAtFrame:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
//        bgView.image = bgImage;
//        //黑色遮罩
//        UIColor *blackColor = [UIColor blackColor];
//        [bgView addGradientLayerWithColors:@[(id)[blackColor colorWithAlphaComponent:0.3].CGColor,
//                                             (id)[blackColor colorWithAlphaComponent:0.3].CGColor]
//                                 locations:nil
//                                startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)];
//        _bgBlurredView = bgView;
//    }
//    return _bgBlurredView;
//}


- (void)refreshCaptchaNeeded{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CaptchaNeededWithPath:@"api/captcha/login" andBlock:^(id data, NSError *error) {
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_inputTipsView) {
        _inputTipsView = ({
            EaseInputTipsView *tipsView = [EaseInputTipsView tipsViewWithType:EaseInputTipsViewTypeLogin];
            tipsView.valueStr = nil;
            
            __weak typeof(self) weakSelf = self;
            tipsView.selectedStringBlock = ^(NSString *valueStr){
                [weakSelf.view endEditing:YES];
                weakSelf.myLogin.email = valueStr;
                //                [weakSelf refreshIconUserImage];
                [weakSelf.myTableView reloadData];
            };
            UITableViewCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [tipsView setY:CGRectGetMaxY(cell.frame)];
            
            [_myTableView addSubview:tipsView];
            tipsView;
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)showdismissButton:(BOOL)willShow{
    self.dismissButton.hidden = !willShow;
    if (!self.dismissButton && willShow) {
        self.dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kSafeArea_Top, 50, 50)];
        self.dismissButton.tintColor = kColorBrandBlue;
        [self.dismissButton setImage:[[UIImage imageNamed:@"back_green_Nav"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.dismissButton addTarget:self action:@selector(dismissButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.dismissButton];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _is2FAUI? 2: _captchaNeeded? 3: 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.is2FAUI && indexPath.row == 0) {
        Login2FATipCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Login2FATipCell forIndexPath:indexPath];
        return cell;
    }
    
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:(indexPath.row > 1? kCellIdentifier_Input_OnlyText_Cell_Captcha: kCellIdentifier_Input_OnlyText_Cell_Text) forIndexPath:indexPath];
    //    cell.isForLoginVC = YES;
    cell.isBottomLineShow = YES;
    __weak typeof(self) weakSelf = self;
    if (self.is2FAUI) {
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 动态验证码" value:self.otpCode];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.otpCode = valueStr;
        };
    }else{
        if (indexPath.row == 0) {
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            [cell setPlaceholder:@" 手机 / 邮箱 / 用户名" value:self.myLogin.email];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.inputTipsView.valueStr = valueStr;
                weakSelf.inputTipsView.active = YES;
                weakSelf.myLogin.email = valueStr;
                //                [weakSelf refreshIconUserImage];
            };
            cell.editDidBeginBlock = ^(NSString *valueStr){
                weakSelf.inputTipsView.valueStr = valueStr;
                weakSelf.inputTipsView.active = YES;
            };
            cell.editDidEndBlock = ^(NSString *textStr){
                weakSelf.inputTipsView.active = NO;
            };
        }else if (indexPath.row == 1){
            [cell setPlaceholder:@" 密码" value:self.myLogin.password];
            cell.textField.secureTextEntry = YES;
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myLogin.password = valueStr;
            };
        }else{
            [cell setPlaceholder:@" 验证码" value:self.myLogin.j_captcha];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myLogin.j_captcha = valueStr;
            };
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.is2FAUI && indexPath.row == 0) {
        return 40;
    }
    return 65;
}

//- (void)refreshIconUserImage{
//    NSString *textStr = self.myLogin.email;
//    if (textStr) {
//        User *curUser = [Login userWithGlobaykeyOrEmail:textStr];
//        if (curUser && curUser.avatar) {
//            [self.iconUserView sd_setImageWithURL:[curUser.avatar urlImageWithCodePathResizeToView:self.iconUserView] placeholderImage:[UIImage imageNamed:@"icon_user_monkey"]];
//            return;
//        }
//    }
//    [self.iconUserView setImage:[UIImage imageNamed:@"icon_user_monkey"]];
//}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 110)];
    UILabel *headerL = [UILabel labelWithFont:[UIFont systemFontOfSize:30] textColor:kColorDark2];
    headerL.text = self.is2FAUI? @"两步验证": @"登录";
    [headerV addSubview:headerL];
    [headerL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kPaddingLeftWidth);
        make.bottom.offset(0);
        make.height.mas_equalTo(42);
    }];
    return headerV;
}

- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 200)];
    _loginBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"登录" andFrame:CGRectMake(kLoginPaddingLeftWidth, 55, kScreen_Width-kLoginPaddingLeftWidth*2, 50) target:self action:@selector(sendLogin)];
    [footerV addSubview:_loginBtn];
    RAC(self, loginBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myLogin.email),
                                                             RACObserve(self, myLogin.password),
                                                             RACObserve(self, myLogin.j_captcha),
                                                             RACObserve(self, captchaNeeded),
                                                             RACObserve(self, is2FAUI),
                                                             RACObserve(self, otpCode)]
                                                    reduce:^id(NSString *email,
                                                               NSString *password,
                                                               NSString *j_captcha,
                                                               NSNumber *captchaNeeded,
                                                               NSNumber *is2FAUI,
                                                               NSString *otpCode){
                                                        if (is2FAUI && is2FAUI.boolValue) {
                                                            return @(otpCode.length > 0);
                                                        }else{
                                                            if ((captchaNeeded && captchaNeeded.boolValue) && (!j_captcha || j_captcha.length <= 0)) {
                                                                return @(NO);
                                                            }else{
                                                                return @((email && email.length > 0) && (password && password.length > 0));
                                                            }
                                                        }
                                                    }];
    _underLoginBtn = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitleColor:kColorDark2 forState:UIControlStateNormal];
        button.tintColor = kColorDark2;
        [button setTitle:@"  微信登录" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"login_wechat"] forState:UIControlStateNormal];
        
        [footerV addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
            make.centerX.equalTo(footerV);
            make.top.equalTo(_loginBtn.mas_bottom).offset(20);
        }];
        button;
    });
    [_underLoginBtn addTarget:self action:@selector(underLoginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _underLoginBtn.hidden = ![self p_canOpenWeiXin];
    
    UIButton *cannotLoginBtn = ({
        UIButton *button = [UIButton new];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitleColor:kColorDark4 forState:UIControlStateNormal];
        
        [button setTitle:@"忘记密码？" forState:UIControlStateNormal];
        [footerV addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(90, 30));
            make.top.offset(15);
            make.right.offset(-kPaddingLeftWidth);
        }];
        button;
    });
    [cannotLoginBtn addTarget:self action:@selector(cannotLoginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return footerV;
}

#pragma mark BottomView
- (void)configBottomView{
    if (!_bottomView) {
        _bottomView = [UIView new];
        
        UIButton *registerBtn = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [button setTitleColor:kColorDark2 forState:UIControlStateNormal];
            
            [button setTitle:@"注册新账号" forState:UIControlStateNormal];
            [_bottomView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100, 30));
                make.top.equalTo(_bottomView);
                make.centerX.equalTo(_bottomView);
            }];
            button;
        });
        [registerBtn addTarget:self action:@selector(goRegisterVC:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.offset(-kSafeArea_Bottom);
            make.height.mas_equalTo(55);
        }];
    }
}

#pragma mark Btn Clicked
- (void)sendLogin{
    NSString *tipMsg = self.is2FAUI? [self loginTipFor2FA]: [_myLogin goToLoginTipWithCaptcha:_captchaNeeded];
    if (tipMsg) {
        kTipAlert(@"%@", tipMsg);
        return;
    }
    
    [self.view endEditing:YES];
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        CGSize captchaViewSize = _loginBtn.bounds.size;
        _activityIndicator.hidesWhenStopped = YES;
        [_activityIndicator setCenter:CGPointMake(captchaViewSize.width/2, captchaViewSize.height/2)];
        [_loginBtn addSubview:_activityIndicator];
    }
    [_activityIndicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    _loginBtn.enabled = NO;
    
    if (self.is2FAUI) {
        [[Coding_NetAPIManager sharedManager] request_Login_With2FA:self.otpCode andBlock:^(id data, NSError *error) {
            weakSelf.loginBtn.enabled = YES;
            [weakSelf.activityIndicator stopAnimating];
            if (data) {
                [Login setPreUserEmail:self.myLogin.email];//记住登录账号
                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
            }else{
                NSString *status_expired = error.userInfo[@"msg"][@"user_login_status_expired"];
                if (status_expired.length > 0) {
                    [weakSelf changeUITo2FAWithGK:nil];
                }
            }
        }];
    }else{
        [[Coding_NetAPIManager sharedManager] request_Login_WithPath:[self.myLogin toPath] Params:[self.myLogin toParams] andBlock:^(id data, NSError *error) {
            weakSelf.loginBtn.enabled = YES;
            [weakSelf.activityIndicator stopAnimating];
            if (data) {
                [Login setPreUserEmail:self.myLogin.email];//记住登录账号
                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
                [self doSomethingAfterLogin];
            }else{
                NSString *global_key = error.userInfo[@"msg"][@"two_factor_auth_code_not_empty"];
                if (global_key.length > 0) {
                    [weakSelf changeUITo2FAWithGK:global_key];
                }else if (error.userInfo[@"msg"][@"user_need_activate"]){
                    [NSObject showError:error];
                    ActivateViewController *vc = [ActivateViewController new];
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    [NSObject showError:error];
                    [weakSelf refreshCaptchaNeeded];
                }
            }
        }];
    }
}

- (void)doSomethingAfterLogin{
    User *curUser = [Login curLoginUser];
    if (curUser.email.length > 0 && !curUser.email_validation.boolValue) {
        [[UIAlertController ea_alertViewWithTitle:@"激活邮箱" message:@"该邮箱尚未激活，请尽快去邮箱查收邮件并激活账号。如果在收件箱中没有看到，请留意一下垃圾邮件箱子（T_T）" buttonTitles:@[@"重发激活邮件"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
            if (index == 0) {
                [self sendActivateEmail];
            }
        }] show];
    }
}
- (void)sendActivateEmail{
    [[Coding_NetAPIManager sharedManager] request_SendActivateEmail:[Login curLoginUser].email block:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"邮件已发送"];
        }
    }];
}

- (IBAction)cannotLoginBtnClicked:(id)sender {
    CannotLoginViewController *vc = [CannotLoginViewController vcWithMethodType:CannotLoginMethodPhone stepIndex:0 userStr:([self.myLogin.email isPhoneNo]? self.myLogin.email: nil)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goRegisterVC:(id)sender {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        RegisterViewController *vc = [RegisterViewController vcWithMethodType:RegisterMethodPhone registerObj:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)dismissButtonClicked{
    if (self.is2FAUI) {
        self.is2FAUI = NO;
    }else{
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark 2FA
- (void)changeUITo2FAWithGK:(NSString *)global_key{
    self.otpCode = [OTPListViewController otpCodeWithGK:global_key];
    self.is2FAUI = global_key.length > 0;
    if (self.otpCode) {
        [self sendLogin];
    }
}

- (void)setIs2FAUI:(BOOL)is2FAUI{
    _is2FAUI = is2FAUI;
    UILabel *headerL = self.myTableView.tableHeaderView.subviews.firstObject;
    headerL.text = self.is2FAUI? @"两步验证": @"登录";
    if (!_is2FAUI) {
        self.otpCode = nil;
        [_buttonFor2FA setTitle:@"  两步验证" forState:UIControlStateNormal];
        [_buttonFor2FA setImage:[[UIImage imageNamed:@"twoFABtn_Nav"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }else{
        [_buttonFor2FA setTitle:@"关闭两步验证" forState:UIControlStateNormal];
        [_buttonFor2FA setImage:nil forState:UIControlStateNormal];
    }
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:_is2FAUI? UITableViewRowAnimationLeft: UITableViewRowAnimationRight];
}

- (NSString *)loginTipFor2FA{
    NSString *tipStr = nil;
    if (self.otpCode.length <= 0) {
        tipStr = @"动态验证码不能为空";
    }else if (![self.otpCode isPureInt] || self.otpCode.length != 6){
        tipStr = @"动态验证码必须是一个6位数字";
    }
    return tipStr;
}

- (void)goTo2FAVC{
    if (_is2FAUI) {
        Close2FAViewController *vc = [Close2FAViewController vcWithPhone:self.myLogin.email sucessBlock:^(UIViewController *vc) {
            self.is2FAUI = NO;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        OTPListViewController *vc = [OTPListViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark thridPlatform
- (void)underLoginBtnClicked:(UIButton *)sender {
    UMSocialPlatformType platformType = UMSocialPlatformType_WechatSession;
    if (platformType != UMSocialPlatformType_UnKnown) {
        __weak typeof(self) weakSelf = self;
        [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:self completion:^(id result, NSError *error) {
            UMSocialResponse *resp = result;
            if (!error) {
                [weakSelf p_thridPlatformLogin:resp];
            }else if (error){
                [NSObject showHudTipStr:@"授权失败"];
                DebugLog(@"%@", error);
            }
        }];
    }
}

- (void)p_thridPlatformLogin:(UMSocialResponse *)resp{
    [self.view endEditing:YES];
    
    __weak typeof(self) weakSelf = self;
    [NSObject showHUDQueryStr:@"正在登录..."];
    [[Coding_NetAPIManager sharedManager] request_Login_With_UMSocialResponse:resp andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
            [weakSelf doSomethingAfterLogin];
        }else if (error){
            if (error.userInfo[@"msg"][@"oauth_account_not_bound"]) {
                kTipAlert(@"抱歉，你还未绑定微信，请前往 Coding 主站完成微信绑定操作");
            }else{
                [NSObject showError:error];
            }
        }
    }];
}

#pragma mark - app url
- (BOOL)p_canOpenWeiXin{
    return [self p_canOpen:@"weixin://"];
}

- (BOOL)p_canOpen:(NSString*)url{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
}

@end

#endif

