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
#import "Input_OnlyText_Cell.h"
#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"
#import "StartImagesManager.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import <UIImage+BlurredFrame/UIImage+BlurredFrame.h>
#import "UIImageView+WebCache.h"
#import "EaseInputTipsView.h"

#import "Ease_2FA.h"

@interface LoginViewController ()
@property (nonatomic, strong) Login *myLogin;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIView *bottomView;


@property (assign, nonatomic) BOOL captchaNeeded;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImageView *iconUserView, *bgBlurredView;
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

    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundView = self.bgBlurredView;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    
    self.myTableView.contentInset = UIEdgeInsetsMake(-kHigher_iOS_6_1_DIS(20), 0, 0, 0);
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
    [self configBottomView];
    [self showdismissButton:self.showDismissButton];
}

- (void)setCaptchaNeeded:(BOOL)captchaNeeded{
    _captchaNeeded = captchaNeeded;
    if (!captchaNeeded) {
        self.myLogin.j_captcha= nil;
    }
}

- (UIImageView *)bgBlurredView{
    if (!_bgBlurredView) {
        //背景图片
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:kScreen_Bounds];
        bgView.contentMode = UIViewContentModeScaleAspectFill;
        UIImage *bgImage = [[StartImagesManager shareManager] curImage].image;
        
        CGSize bgImageSize = bgImage.size, bgViewSize = bgView.frame.size;
        if (bgImageSize.width > bgViewSize.width && bgImageSize.height > bgViewSize.height) {
            bgImage = [bgImage scaleToSize:[bgView doubleSizeOfFrame] usingMode:NYXResizeModeAspectFill];
        }
        bgImage = [bgImage applyLightEffectAtFrame:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
        bgView.image = bgImage;
        //黑色遮罩
        UIColor *blackColor = [UIColor blackColor];
        [bgView addGradientLayerWithColors:@[(id)[blackColor colorWithAlphaComponent:0.3].CGColor,
                                             (id)[blackColor colorWithAlphaComponent:0.3].CGColor]
                                 locations:nil
                                startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)];
        _bgBlurredView = bgView;
    }
    return _bgBlurredView;
}


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
    [self refreshCaptchaNeeded];
    [self refreshIconUserImage];
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
                [weakSelf refreshIconUserImage];
                [weakSelf.myTableView reloadData];
            };
            UITableViewCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [tipsView setY:CGRectGetMaxY(cell.frame) - 0.5];
            
            [_myTableView addSubview:tipsView];
            tipsView;
        });
    }
}

- (void)showdismissButton:(BOOL)willShow{
    self.dismissButton.hidden = !willShow;
    if (!self.dismissButton && willShow) {
        self.dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 50, 50)];
        [self.dismissButton setImage:[UIImage imageNamed:@"text_clear_btn"] forState:UIControlStateNormal];
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
    return _is2FAUI? 1: _captchaNeeded? 3: 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Input_OnlyText_Cell";
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"Input_OnlyText_Cell" owner:self options:nil] firstObject];
    }
    cell.isForLoginVC = YES;
    __weak typeof(self) weakSelf = self;
    
    if (self.is2FAUI) {
        cell.isCaptcha = NO;
        [cell configWithPlaceholder:@" 动态验证码" andValue:self.otpCode];
        cell.textField.secureTextEntry = NO;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.otpCode = valueStr;
        };
        cell.editDidEndBlock = nil;
    }else{
        if (indexPath.row == 0) {
            cell.isCaptcha = NO;
            [cell configWithPlaceholder:@" 电子邮箱/个性后缀" andValue:self.myLogin.email];
            cell.textField.secureTextEntry = NO;
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.inputTipsView.valueStr = valueStr;
                weakSelf.inputTipsView.active = YES;
                weakSelf.myLogin.email = valueStr;
                [weakSelf.iconUserView setImage:[UIImage imageNamed:@"icon_user_monkey"]];
            };
            cell.editDidEndBlock = ^(NSString *textStr){
                weakSelf.inputTipsView.active = NO;
                [weakSelf refreshIconUserImage];
            };
        }else if (indexPath.row == 1){
            cell.isCaptcha = NO;
            [cell configWithPlaceholder:@" 密码" andValue:self.myLogin.password];
            cell.textField.secureTextEntry = YES;
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myLogin.password = valueStr;
            };
            cell.editDidEndBlock = nil;
        }else{
            cell.isCaptcha = YES;
            [cell configWithPlaceholder:@" 验证码" andValue:self.myLogin.j_captcha];
            cell.textField.secureTextEntry = NO;
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myLogin.j_captcha = valueStr;
            };
            cell.editDidEndBlock = nil;
        }
    }
    return cell;
}

- (void)refreshIconUserImage{
    NSString *textStr = self.myLogin.email;
    if (textStr) {
        User *curUser = [Login userWithGlobaykeyOrEmail:textStr];
        if (curUser && curUser.avatar) {
            [self.iconUserView sd_setImageWithURL:[curUser.avatar urlImageWithCodePathResizeToView:self.iconUserView] placeholderImage:[UIImage imageNamed:@"icon_user_monkey"]];
        }
    }
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    CGFloat iconUserViewWidth;
    if (kDevice_Is_iPhone6Plus) {
        iconUserViewWidth = 100;
    }else if (kDevice_Is_iPhone6){
        iconUserViewWidth = 90;
    }else{
        iconUserViewWidth = 75;
    }
    
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height/3)];
    
    _iconUserView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconUserViewWidth, iconUserViewWidth)];
    _iconUserView.contentMode = UIViewContentModeScaleAspectFit;
    _iconUserView.layer.masksToBounds = YES;
    _iconUserView.layer.cornerRadius = _iconUserView.frame.size.width/2;
    _iconUserView.layer.borderWidth = 2;
    _iconUserView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [headerV addSubview:_iconUserView];
    [_iconUserView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(iconUserViewWidth, iconUserViewWidth));
        make.centerX.equalTo(headerV);
        make.centerY.equalTo(headerV).offset(30);
    }];
    [_iconUserView setImage:[UIImage imageNamed:@"icon_user_monkey"]];
    return headerV;
}

- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 100)];
    _loginBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"登录" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(sendLogin)];
    [footerV addSubview:_loginBtn];
    
    
    RAC(self, loginBtn.enabled) = [RACSignal combineLatest:@[
                                                             RACObserve(self, myLogin.email),
                                                             RACObserve(self, myLogin.password),
                                                             RACObserve(self, myLogin.j_captcha),
                                                             RACObserve(self, captchaNeeded),
                                                             RACObserve(self, is2FAUI),
                                                             RACObserve(self, otpCode)
                                                             ]
                                                    reduce:^id(
                                                               NSString *email,
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
    return footerV;
}

#pragma mark BottomView
- (void)configBottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 60, kScreen_Width, 60)];
        _bottomView.backgroundColor = [UIColor clearColor];
        UIButton *registerBtn = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
            
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [button setTitle:@"新用户" forState:UIControlStateNormal];
            [_bottomView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100, 300));
                make.centerY.equalTo(_bottomView);
                make.right.equalTo(_bottomView).offset(-kLoginPaddingLeftWidth);
            }];
            button;
        });

        UIButton *cannotLoginBtn = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
            
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [button setTitle:@"无法登录？" forState:UIControlStateNormal];
            [_bottomView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100, 300));
                make.centerY.equalTo(_bottomView);
                make.left.equalTo(_bottomView).offset(kLoginPaddingLeftWidth);
            }];
            button;
        });
        
        [registerBtn addTarget:self action:@selector(goRegisterVC:) forControlEvents:UIControlEventTouchUpInside];
        [cannotLoginBtn addTarget:self action:@selector(cannotLoginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_bottomView];
    }
}

#pragma mark Btn Clicked
- (void)sendLogin{
    NSString *tipMsg = self.is2FAUI? [self goToLoginTipWith2FA]: [_myLogin goToLoginTipWithCaptcha:_captchaNeeded];
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
        [[Coding_NetAPIManager sharedManager] request_Login_WithParams:[self.myLogin toParams] andBlock:^(id data, NSError *error) {
            weakSelf.loginBtn.enabled = YES;
            [weakSelf.activityIndicator stopAnimating];
            if (data) {
                [Login setPreUserEmail:self.myLogin.email];//记住登录账号
                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
            }else{
                NSString *global_key = error.userInfo[@"msg"][@"two_factor_auth_code_not_empty"];
                if (global_key.length > 0) {
                    [weakSelf changeUITo2FAWithGK:global_key];
                }else{
                    [self showError:error];
                    [weakSelf refreshCaptchaNeeded];
                }
            }
        }];
    }
}

- (IBAction)cannotLoginBtnClicked:(id)sender {
    [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"找回密码", @"重发激活邮件"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index <= 1) {
            [self goToCannotLoginWithIndex:index];
        }
    }] showInView:self.view];
}

- (void)goToCannotLoginWithIndex:(NSInteger)index{
    CannotLoginViewController *vc = [[CannotLoginViewController alloc] init];
    vc.type = index;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)goRegisterVC:(id)sender {
    RegisterViewController *vc = [[RegisterViewController alloc] init];    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dismissButtonClicked{
    if (self.is2FAUI) {
        self.is2FAUI = NO;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
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
    if (!_is2FAUI) {
        self.otpCode = nil;
    }
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:_is2FAUI? UITableViewRowAnimationLeft: UITableViewRowAnimationRight];
}

- (NSString *)goToLoginTipWith2FA{
    NSString *tipStr = nil;
    if (self.otpCode.length <= 0) {
        tipStr = @"动态验证码不能为空";
    }else if (![self.otpCode isPureInt] || self.otpCode.length != 6){
        tipStr = @"动态验证码必须是一个6位数字";
    }
    return tipStr;
}
@end
