//
//  CannotLoginViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/3/26.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CannotLoginViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Input_OnlyText_Cell.h"

#ifdef Target_Enterprise

@interface CannotLoginViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) CannotLoginMethodType medthodType;
@property (nonatomic, assign) NSUInteger stepIndex;
@property (strong, nonatomic) NSString *userStr, *phoneCode, *password, *confirm_password, *j_captcha;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn, *backBtn;
@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;
@end

@implementation CannotLoginViewController
+ (instancetype)vcWithMethodType:(CannotLoginMethodType)methodType stepIndex:(NSUInteger)stepIndex userStr:(NSString *)userStr{
    CannotLoginViewController *vc = [self new];
    vc.medthodType = methodType;
    vc.stepIndex = stepIndex;
    vc.userStr = userStr;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"找回密码";
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:self.phoneCodeCellIdentifier];
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
    self.myTableView.tableFooterView=[self customFooterView];
    self.myTableView.tableHeaderView = [self customHeaderView];
    [self setupBackBtn];
}

- (void)setupBackBtn{
    if (!_backBtn) {
        _backBtn = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, kSafeArea_Top, 44, 44)];
            button.tintColor = kColorLightBlue;
            [button setImage:[[UIImage imageNamed:@"back_green_Nav"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            button;
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44 + 60)];
    
    UILabel *headerL = [UILabel labelWithSystemFontSize:28 textColorHexString:@"0x272C33"];
    headerL.text = @"找回密码";
    [headerV addSubview:headerL];
    [headerL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerV).offset(20);
        make.bottom.equalTo(headerV);
        make.height.mas_equalTo(40);
    }];
    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    
    _footerBtn = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kLoginPaddingLeftWidth, 25, kScreen_Width-kLoginPaddingLeftWidth*2, 50)];
        button.backgroundColor = kColorDark4;
        button.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:[self footerBtnTitle] forState:UIControlStateNormal];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 2.0;
        [button addTarget:self action:@selector(footerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [footerV addSubview:_footerBtn];
    [RACObserve(self, footerBtn.enabled) subscribeNext:^(NSNumber *x) {
        [self.footerBtn setTitleColor:[UIColor colorWithWhite:1.0 alpha:x.boolValue? 1.0: .5] forState:UIControlStateNormal];
    }];
    if (_stepIndex == 0) {
        RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, userStr)]
                                                         reduce:^id(NSString *userStr){
                                                             return @([userStr isEmail] || [userStr isPhoneNo]);
                                                         }];
    }else{
        if (_medthodType == CannotLoginMethodPhone) {
            RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, userStr),
                                                                      RACObserve(self, phoneCode),
                                                                      RACObserve(self, password),
                                                                      RACObserve(self, confirm_password)]
                                                             reduce:^id(NSString *userStr, NSString *phoneCode, NSString *password, NSString *confirm_password){
                                                                 return @([userStr isPhoneNo] && phoneCode.length > 0 && password.length > 0 && confirm_password.length > 0);
                                                             }];
        }else{
            RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, userStr),
                                                                      RACObserve(self, j_captcha)]
                                                             reduce:^id(NSString *userStr, NSString *j_captcha){
                                                                 return @([userStr isEmail] && j_captcha.length > 0);
                                                             }];
        }
    }
    return footerV;
}

- (NSString *)footerBtnTitle{
    NSString *curStr = @"";
    if (_stepIndex == 0) {
        curStr = @"下一步";
    }else{
        curStr = _medthodType == CannotLoginMethodPhone? @"重置密码": @"发送重置密码邮件";
    }
    return curStr;
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _stepIndex == 0? 1: _medthodType == CannotLoginMethodPhone? 4: 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier;
    if (indexPath.row == 0) {
        cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Text;
    }else{
        if (_medthodType == CannotLoginMethodPhone) {
            if (indexPath.row == 3) {
                cellIdentifier = self.phoneCodeCellIdentifier;
            }else{
                cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Text;
            }
        }else{
            cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Captcha;
        }
    }
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.isBottomLineShow = YES;
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        [cell setPlaceholder:(_stepIndex == 0? @" 手机/邮箱": _medthodType == CannotLoginMethodPhone? @" 手机号": @" 邮箱") value:self.userStr];
        cell.textField.keyboardType = (_stepIndex == 0? UIKeyboardTypeDefault: _medthodType == CannotLoginMethodPhone? UIKeyboardTypeNumberPad: UIKeyboardTypeEmailAddress);
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.userStr = valueStr;
        };
    }else{
        if (_medthodType == CannotLoginMethodPhone) {
            if (indexPath.row == 1){
                cell.textField.secureTextEntry = YES;
                [cell setPlaceholder:@" 设置密码" value:self.password];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.password = valueStr;
                };
            }else if (indexPath.row == 2){
                cell.textField.secureTextEntry = YES;
                [cell setPlaceholder:@" 重复密码" value:self.confirm_password];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.confirm_password = valueStr;
                };
            }else{
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                [cell setPlaceholder:@" 手机验证码" value:self.phoneCode];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.phoneCode = valueStr;
                };
                cell.phoneCodeBtnClckedBlock = ^(PhoneCodeButton *btn){
                    [weakSelf phoneCodeBtnClicked:btn withCaptcha:nil];
                };
            }
        }else{
            [cell setPlaceholder:@" 验证码" value:self.j_captcha];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.j_captcha = valueStr;
            };
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0;
}

#pragma mark Btn Clicked
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender withCaptcha:(NSString *)captcha{
    if (![_userStr isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    sender.enabled = NO;
    NSMutableDictionary *params = @{@"account": _userStr,
                                    @"phoneCountryCode": @"+86"}.mutableCopy;
    if (captcha.length > 0) {
        params[@"j_captcha"] = captcha;
    }
    __weak typeof(self) weakSelf = self;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/password/forget" withParams:params withMethodType:Post autoShowError:captcha.length > 0 andBlock:^(id data, NSError *error) {
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


- (void)footerBtnClicked:(id)sender{
    if (_stepIndex == 0) {
        CannotLoginViewController *vc = [CannotLoginViewController vcWithMethodType:[_userStr isPhoneNo]? CannotLoginMethodPhone: CannotLoginMethodEamil stepIndex:1 userStr:_userStr];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if (_medthodType == CannotLoginMethodPhone) {
            if (![_password isEqualToString:_confirm_password]) {
                [NSObject showHudTipStr:@"两次输入密码不一致"];
                return;
            }
            [self.footerBtn startQueryAnimate];
            NSMutableDictionary *params = @{@"account": _userStr,
                                            @"password": [_password sha1Str],
                                            @"confirm": [_confirm_password sha1Str],
                                            @"code": _phoneCode}.mutableCopy;
            params[@"j_captcha"] = _j_captcha;
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/password/reset" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
                [self.footerBtn stopQueryAnimate];
                if (data) {
                    [NSObject showHudTipStr:@"密码设置成功"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }else{
            [self.footerBtn startQueryAnimate];
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/password/forget" withParams:@{@"account": _userStr, @"j_captcha": _j_captcha} withMethodType:Post andBlock:^(id data, NSError *error) {
                [self.footerBtn stopQueryAnimate];
                if (data) {
                    [NSObject showHudTipStr:@"重置密码邮件已经发送，请尽快去邮箱查看"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    }
}

@end

#else

@interface CannotLoginViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) CannotLoginMethodType medthodType;
@property (nonatomic, assign) NSUInteger stepIndex;
@property (strong, nonatomic) NSString *userStr, *phoneCode, *password, *confirm_password, *j_captcha;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;
@end

@implementation CannotLoginViewController
+ (instancetype)vcWithMethodType:(CannotLoginMethodType)methodType stepIndex:(NSUInteger)stepIndex userStr:(NSString *)userStr{
    CannotLoginViewController *vc = [self new];
    vc.medthodType = methodType;
    vc.stepIndex = stepIndex;
    vc.userStr = userStr;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    if ([Login isLogin] && self.userStr.length <= 0) {
        self.userStr = (self.medthodType == CannotLoginMethodEamil? [Login curLoginUser].email: [Login curLoginUser].phone);
    }
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [Login isLogin]? kColorTableSectionBg: kColorWhite;
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:self.phoneCodeCellIdentifier];
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
    self.myTableView.tableFooterView=[self customFooterView];
    self.myTableView.tableHeaderView = [self customHeaderView];
    
    [self addChangeBaseURLGesture];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

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
    UIAlertAction *confirmA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *newBaseURLStr = alertCtrl.textFields[0].text;
        if ([newBaseURLStr.uppercaseString isEqualToString:@"S"]) {
            newBaseURLStr = @"http://coding.codingprod.net/";
        }else if ([newBaseURLStr.uppercaseString isEqualToString:@"T"]){
            newBaseURLStr = @"http://coding.t.codingprod.net/";
        }
        [NSObject changeBaseURLStrTo:newBaseURLStr];
    }];
    [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"CODING 服务器地址";
        textField.text = [NSObject baseURLStr];
    }];
    [alertCtrl addAction:cancelA];
    [alertCtrl addAction:confirmA];
    [self presentViewController:alertCtrl animated:YES completion:nil];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, [Login isLogin]? 20: 60)];
    if (![Login isLogin]) {
        self.title = nil;
        UILabel *headerL = [UILabel labelWithFont:[UIFont systemFontOfSize:30] textColor:kColorDark2];
        headerL.text = [self p_titleStr];
        [headerV addSubview:headerL];
        [headerL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(kPaddingLeftWidth);
            make.bottom.offset(0);
            make.height.mas_equalTo(42);
        }];
    }else{
        self.title = [self p_titleStr];
    }
    return headerV;
}

- (NSString *)p_titleStr{
    return self.medthodType == CannotLoginMethodEamil? @"重置密码": self.stepIndex > 0? @"重置密码": @"找回密码";
}

- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:[self footerBtnTitle] andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, [Login isLogin]? 45: 50) target:self action:@selector(footerBtnClicked:)];
    [footerV addSubview:_footerBtn];
    
    if (_medthodType == CannotLoginMethodEamil) {
        RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, userStr),
                                                                  RACObserve(self, j_captcha)]
                                                         reduce:^id(NSString *userStr, NSString *j_captcha){
                                                             return @([userStr isEmail] && j_captcha.length > 0);
                                                         }];
    }else{
        if (_stepIndex == 0) {
            RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, userStr),
                                                                      RACObserve(self, phoneCode)]
                                                             reduce:^id(NSString *userStr, NSString *phoneCode){
                                                                 return @([userStr isPhoneNo] && phoneCode.length > 0);
                                                             }];
        }else{
            RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, userStr),
                                                                      RACObserve(self, phoneCode),
                                                                      RACObserve(self, password),
                                                                      RACObserve(self, confirm_password)]
                                                             reduce:^id(NSString *userStr, NSString *phoneCode, NSString *password, NSString *confirm_password){
                                                                 return @([userStr isPhoneNo] && phoneCode.length > 0 && password.length > 0 && confirm_password.length > 0);
                                                             }];
        }
    }
    if (_medthodType == CannotLoginMethodPhone && _stepIndex <= 0 &&
        (![Login isLogin] || [Login curLoginUser].email.length > 0)) {
        UIButton *emailBtn = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [button setTitleColor:kColorDark2 forState:UIControlStateNormal];
            [button setTitle:@"使用邮箱找回" forState:UIControlStateNormal];
            [footerV addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(120, 30));
                make.top.equalTo(_footerBtn.mas_bottom).offset(30);
                make.centerX.equalTo(footerV);
            }];
            button;
        });
        __weak typeof(self) weakSelf = self;
        [emailBtn bk_addEventHandler:^(id sender) {
            CannotLoginViewController *vc = [CannotLoginViewController vcWithMethodType:CannotLoginMethodEamil stepIndex:0 userStr:nil];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return footerV;
}

- (NSString *)footerBtnTitle{
    NSString *curStr = @"";
    if (_medthodType == CannotLoginMethodEamil) {
        curStr = @"发送重置密码邮件";
    }else{
        curStr = _stepIndex == 0? @"下一步": @"完成";
    }
    return curStr;
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier;
    if (_medthodType == CannotLoginMethodEamil) {
        cellIdentifier = indexPath.row == 0? kCellIdentifier_Input_OnlyText_Cell_Text: kCellIdentifier_Input_OnlyText_Cell_Captcha;
    }else if (_stepIndex <= 0){
        cellIdentifier = indexPath.row == 0? kCellIdentifier_Input_OnlyText_Cell_Text: self.phoneCodeCellIdentifier;
    }else{
        cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Text;
    }
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.isBottomLineShow = ![Login isLogin];
    
    __weak typeof(self) weakSelf = self;
    if (_medthodType == CannotLoginMethodEamil) {
        if (indexPath.row == 0) {
            [cell setPlaceholder:@" 电子邮箱" value:self.userStr];
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.userStr = valueStr;
            };
        }else{
            [cell setPlaceholder:@" 验证码" value:self.j_captcha];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.j_captcha = valueStr;
            };
        }
    }else if (_stepIndex <= 0){
        if (indexPath.row == 0) {
            [cell setPlaceholder:@" 手机号码" value:self.userStr];
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.userStr = valueStr;
            };
        }else{
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            [cell setPlaceholder:@" 验证码" value:self.phoneCode];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.phoneCode = valueStr;
            };
            cell.phoneCodeBtnClckedBlock = ^(PhoneCodeButton *btn){
                [weakSelf phoneCodeBtnClicked:btn withCaptcha:nil];
            };
        }
    }else{
        if (indexPath.row == 0) {
            cell.textField.secureTextEntry = YES;
            [cell setPlaceholder:@" 设置密码" value:self.password];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.password = valueStr;
            };
        }else{
            cell.textField.secureTextEntry = YES;
            [cell setPlaceholder:@" 重复密码" value:self.confirm_password];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.confirm_password = valueStr;
            };
        }
    }
    if ([Login isLogin]) {
        cell.backgroundColor = kColorWhite;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [Login isLogin]? 50: 65.0;
}

#pragma mark Btn Clicked
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender withCaptcha:(NSString *)captcha{
    if (![_userStr isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    sender.enabled = NO;
    NSMutableDictionary *params = @{@"account": _userStr,
                                    @"phoneCountryCode": @"+86"}.mutableCopy;
    if (captcha.length > 0) {
        params[@"j_captcha"] = captcha;
    }
    __weak typeof(self) weakSelf = self;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/password/forget" withParams:params withMethodType:Post autoShowError:captcha.length > 0 andBlock:^(id data, NSError *error) {
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


- (void)footerBtnClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    if (_medthodType == CannotLoginMethodEamil) {
        [self.footerBtn startQueryAnimate];
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/password/forget" withParams:@{@"account": _userStr, @"j_captcha": _j_captcha} withMethodType:Post andBlock:^(id data, NSError *error) {
            [weakSelf.footerBtn stopQueryAnimate];
            if (data) {
                [NSObject showHudTipStr:@"重置密码邮件已经发送，请尽快去邮箱查看"];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [weakSelf.myTableView reloadData];//主要是为了 刷新一下图片验证码
            }
        }];
    }else if (_stepIndex == 0){
        [self.footerBtn startQueryAnimate];
        NSDictionary *params = @{@"phone": _userStr,
                                 @"code": _phoneCode,
                                 @"phoneCountryCode": @"+86",
                                 @"type": @"reset"};
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/phone/code/check" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
            [self.footerBtn stopQueryAnimate];
            if (!error) {
                //通过校验
                CannotLoginViewController *vc = [CannotLoginViewController vcWithMethodType:CannotLoginMethodPhone stepIndex:1 userStr:_userStr];
                vc.phoneCode = weakSelf.phoneCode;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        }];
    }else{
        if (![_password isEqualToString:_confirm_password]) {
            [NSObject showHudTipStr:@"两次输入密码不一致"];
            return;
        }
        [self.footerBtn startQueryAnimate];
        NSMutableDictionary *params = @{@"account": _userStr,
                                        @"password": [_password sha1Str],
                                        @"confirm": [_confirm_password sha1Str],
                                        @"code": _phoneCode}.mutableCopy;
        params[@"j_captcha"] = _j_captcha;
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/password/reset" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
            [weakSelf.footerBtn stopQueryAnimate];
            if (data) {
                [NSObject showHudTipStr:@"密码设置成功"];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

@end

#endif
