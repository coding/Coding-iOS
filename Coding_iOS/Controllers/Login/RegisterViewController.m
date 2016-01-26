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
#import "UIViewController+BackButtonHandler.h"

@interface RegisterViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (nonatomic, assign) RegisterMethodType medthodType;
@property (nonatomic, assign) NSUInteger stepIndex;

@property (nonatomic, strong) Register *myRegister;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) EaseInputTipsView *inputTipsView;

@property (assign, nonatomic) BOOL captchaNeeded;

@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;
@end

@implementation RegisterViewController

+ (instancetype)vcWithMethodType:(RegisterMethodType)methodType stepIndex:(NSUInteger)stepIndex registerObj:(Register *)obj{
    RegisterViewController *vc = [self new];
    vc.medthodType = methodType;
    vc.stepIndex = stepIndex;
    vc.myRegister = obj;
    return vc;
}

- (void)viewDidLoad
{
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
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
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
    [self configTopView];
    [self configBottomView];
}

- (BOOL)navigationShouldPopOnBackButton{
    if (_medthodType == RegisterMethodPhone && _stepIndex >= 2 && _myRegister.password.length > 0) {//顺序来到的第二步，不允许直接返回
        [[UIActionSheet bk_actionSheetCustomWithTitle:@"完成激活后才能正常使用 Coding，是否返回？" buttonTitles:nil destructiveTitle:@"确认返回" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }] showInView:self.view];
        return NO;
    }
    return YES;
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
    if (_medthodType == RegisterMethodEamil || _stepIndex == 1) {
        [self refreshCaptchaNeeded];
    }
    if (_medthodType == RegisterMethodPhone && _stepIndex >= 2 && _myRegister.password.length > 0) {//顺序来到的第二步，不允许直接返回
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
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
            UITableViewCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
    if (_stepIndex == 0) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:_medthodType == RegisterMethodPhone? @"邮箱注册": @"手机注册" target:self action:@selector(rightBarItemClicked:)];
    }
}
- (void)rightBarItemClicked:(UIBarButtonItem *)item{
    if (_medthodType == RegisterMethodPhone) {
        RegisterViewController *vc = [RegisterViewController vcWithMethodType:RegisterMethodEamil stepIndex:0 registerObj:_myRegister];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Top Bottom Header Footer
- (void)configTopView{
    if (_medthodType == RegisterMethodEamil) {
        return;
    }
    if (_medthodType == RegisterMethodPhone && _stepIndex >= 2 && _myRegister.password.length <= 0) {//跳着来到的第二步，只为激活，不需要显示步骤导航条
        return;
    }
    UIView *topView = [UIView new];
    topView.backgroundColor = kColorTableBG;
    NSArray *stepLabelList = @[[UILabel new], [UILabel new], [UILabel new]];
    [stepLabelList enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
        obj.textAlignment = NSTextAlignmentCenter;
        obj.font = [UIFont systemFontOfSize:13];
        obj.textColor = [UIColor colorWithHexString:self.stepIndex >= idx? @"0x3BBD79": @"0x999999"];
        obj.text = idx == 0? @"1 验证手机": idx == 1? @"2 设置密码": @"3 激活账号";
        [topView addSubview:obj];
    }];
    NSArray *stepImageVList = @[[UIImageView new], [UIImageView new]];
    [stepImageVList enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL *stop) {
        obj.contentMode = UIViewContentModeCenter;
        obj.image = [UIImage imageNamed:self.stepIndex >= idx? @"register_step_ed": @"register_step_un"];
        [topView addSubview:obj];
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(((UIView *)stepLabelList[idx]).mas_right);
            make.right.equalTo(((UIView *)stepLabelList[idx + 1]).mas_left);
            make.size.mas_equalTo(20);
        }];
    }];
    [self.view addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(stepLabelList.firstObject);
        make.right.equalTo(stepLabelList.lastObject);
        make.centerY.equalTo([stepLabelList arrayByAddingObjectsFromArray:stepImageVList]);
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    [stepLabelList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(stepLabelList);
    }];
    
}
- (void)configBottomView{
    if (_medthodType == RegisterMethodPhone) {
        return;
    }
    UIView *bottomView = [UIView new];
    UITTTAttributedLabel *bottomLabel = ({
        UITTTAttributedLabel *label = [[UITTTAttributedLabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:@"0x999999"];
        label.numberOfLines = 0;
        label.linkAttributes = kLinkAttributes;
        label.activeLinkAttributes = kLinkAttributesActive;
        label.delegate = self;
        label;
    });
    NSString *tipStr = @"已经注册？重发激活邮件";
    bottomLabel.text = tipStr;
    [bottomLabel addLinkToTransitInformation:@{@"actionStr" : @"gotoCannotLoginVC"} withRange:[tipStr rangeOfString:@"重发激活邮件"]];
    [bottomView addSubview:bottomLabel];
    [self.view addSubview:bottomView];
    
    [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomView);
    }];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
}
- (UIView *)customHeaderView{
    UIView *headerV;
    if (_medthodType == RegisterMethodPhone) {
        headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
        headerV.backgroundColor = [UIColor clearColor];
    }else{
        headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.15*kScreen_Height)];
        headerV.backgroundColor = [UIColor clearColor];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:18];
        headerLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = @"加入Coding，体验云端开发之美！";
        [headerLabel setCenter:headerV.center];
        [headerV addSubview:headerLabel];
    }
    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:[self footerBtnTitle] andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(sendRegister)];
    [footerV addSubview:_footerBtn];
    if (_medthodType == RegisterMethodEamil) {
        RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.email), RACObserve(self, myRegister.global_key), RACObserve(self, myRegister.j_captcha), RACObserve(self, captchaNeeded)] reduce:^id(NSString *email, NSString *global_key, NSString *j_captcha, NSNumber *captchaNeeded){
            if ((captchaNeeded && captchaNeeded.boolValue) && (!j_captcha || j_captcha.length <= 0)) {
                return @(NO);
            }else{
                return @((email && email.length > 0) && (global_key && global_key.length > 0));
            }
        }];
    }else{
        if (_stepIndex == 0) {
            RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.phone), RACObserve(self, myRegister.code)] reduce:^id(NSString *phone, NSString *code){
                return @(phone.length > 0 && code.length > 0);
            }];
        }else if (_stepIndex == 1){
            RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.phone), RACObserve(self, myRegister.code), RACObserve(self, myRegister.password), RACObserve(self, myRegister.confirm_password), RACObserve(self, myRegister.j_captcha), RACObserve(self, captchaNeeded)] reduce:^id(NSString *phone, NSString *code, NSString *password, NSString *confirm_password, NSString *j_captcha, NSNumber *captchaNeeded){
                if ((captchaNeeded && captchaNeeded.boolValue) && (!j_captcha || j_captcha.length <= 0)) {
                    return @(NO);
                }else{
                    return @(phone.length > 0 && code.length > 0 && password.length > 0 && confirm_password.length > 0);
                }
            }];
        }else{
            RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.email), RACObserve(self, myRegister.global_key)] reduce:^id(NSString *email, NSString *global_key){
                return @(email.length > 0 && global_key.length > 0);
            }];
        }
    }
    if (_medthodType != RegisterMethodPhone || _stepIndex >= 2) {
        UITTTAttributedLabel *lineLabel = ({
            UITTTAttributedLabel *label = [[UITTTAttributedLabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor colorWithHexString:@"0x999999"];
            label.numberOfLines = 0;
            label.linkAttributes = kLinkAttributes;
            label.activeLinkAttributes = kLinkAttributesActive;
            label.delegate = self;
            label;
        });
        NSString *tipStr = @"点击立即体验，即表示同意《Coding 服务条款》";
        lineLabel.text = tipStr;
        [lineLabel addLinkToTransitInformation:@{@"actionStr" : @"gotoServiceTermsVC"} withRange:[tipStr rangeOfString:@"《Coding 服务条款》"]];
        CGRect footerBtnFrame = _footerBtn.frame;
        lineLabel.frame = CGRectMake(CGRectGetMinX(footerBtnFrame), CGRectGetMaxY(footerBtnFrame) +12, CGRectGetWidth(footerBtnFrame), 12);
        [footerV addSubview:lineLabel];
    }
    return footerV;
}
- (NSString *)footerBtnTitle{
    NSString *curStr = @"";
    if (_medthodType == RegisterMethodEamil) {
        curStr = @"立即体验";
    }else if (_medthodType == RegisterMethodPhone){
        curStr = _stepIndex == 0? @"下一步": _stepIndex == 1? @"完成注册": @"激活";
    }
    return curStr;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _captchaNeeded? 3 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if (indexPath.row >= 2) {
        cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Captcha;
    }else if (_medthodType == RegisterMethodPhone && _stepIndex == 0 && indexPath.row == 1){
        cellIdentifier = self.phoneCodeCellIdentifier;
        NSLog(@"cellIdentifier : %@", cellIdentifier);
    }else{
        cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Text;
    }
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row >= 2) {
        [cell setPlaceholder:@" 验证码" value:self.myRegister.j_captcha];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.j_captcha = valueStr;
        };
    }else{
        if (_medthodType == RegisterMethodEamil) {
            if (indexPath.row == 0) {
                cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                [cell setPlaceholder:@" 电子邮箱" value:self.myRegister.email];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.inputTipsView.valueStr = valueStr;
                    weakSelf.inputTipsView.active = YES;
                    weakSelf.myRegister.email = valueStr;
                };
                cell.editDidEndBlock = ^(NSString *textStr){
                    weakSelf.inputTipsView.active = NO;
                };
            }else{
                [cell setPlaceholder:@" 个性后缀（仅支持数字和字母）" value:self.myRegister.global_key];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.global_key = valueStr;
                };
            }
        }else{
            if (_stepIndex == 0) {
                if (indexPath.row == 0) {
                    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                    [cell setPlaceholder:@" 手机号码" value:self.myRegister.phone];
                    cell.textValueChangedBlock = ^(NSString *valueStr){
                        weakSelf.myRegister.phone = valueStr;
                    };
                }else{
                    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                    [cell setPlaceholder:@" 手机验证码" value:self.myRegister.code];
                    cell.textValueChangedBlock = ^(NSString *valueStr){
                        weakSelf.myRegister.code = valueStr;
                    };
                    cell.phoneCodeBtnClckedBlock = ^(PhoneCodeButton *btn){
                        [weakSelf phoneCodeBtnClicked:btn];
                    };
                }
            }else if (_stepIndex == 1){
                if (indexPath.row == 0) {
                    cell.textField.secureTextEntry = YES;
                    [cell setPlaceholder:@" 密码" value:self.myRegister.password];
                    cell.textValueChangedBlock = ^(NSString *valueStr){
                        weakSelf.myRegister.password = valueStr;
                    };
                }else{
                    cell.textField.secureTextEntry = YES;
                    [cell setPlaceholder:@" 确认密码" value:self.myRegister.confirm_password];
                    cell.textValueChangedBlock = ^(NSString *valueStr){
                        weakSelf.myRegister.confirm_password = valueStr;
                    };
                }
            }else{
                if (indexPath.row == 0) {
                    cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                    [cell setPlaceholder:@" 电子邮箱" value:self.myRegister.email];
                    cell.textValueChangedBlock = ^(NSString *valueStr){
                        weakSelf.inputTipsView.valueStr = valueStr;
                        weakSelf.inputTipsView.active = YES;
                        weakSelf.myRegister.email = valueStr;
                    };
                    cell.editDidEndBlock = ^(NSString *textStr){
                        weakSelf.inputTipsView.active = NO;
                    };
                }else{
                    [cell setPlaceholder:@" 个性后缀（仅支持数字和字母）" value:self.myRegister.global_key];
                    cell.textValueChangedBlock = ^(NSString *valueStr){
                        weakSelf.myRegister.global_key = valueStr;
                    };
                }
            }
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
    if ([[components objectForKey:@"actionStr"] isEqualToString:@"gotoServiceTermsVC"]) {
        [self gotoServiceTermsVC];
    }else if ([[components objectForKey:@"actionStr"] isEqualToString:@"gotoCannotLoginVC"]){
        [self gotoCannotLoginVC];
    }
}
#pragma mark Btn Clicked
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender{
    if (![_myRegister.phone isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    sender.enabled = NO;
    [[Coding_NetAPIManager sharedManager] request_GeneratePhoneCodeWithPhone:_myRegister.phone type:PurposeToRegister block:^(id data, NSError *error) {
        if (data) {
            [sender startUpTimer];
        }else{
            [sender invalidateTimer];
        }
    }];
}

- (void)sendRegister{
    __weak typeof(self) weakSelf = self;
    if (_medthodType == RegisterMethodPhone) {
        if (_stepIndex == 0) {
            [self.footerBtn startQueryAnimate];
            [[Coding_NetAPIManager sharedManager] request_CheckPhoneCodeWithPhone:_myRegister.phone code:_myRegister.code type:PurposeToRegister block:^(id data, NSError *error) {
                [self.footerBtn stopQueryAnimate];
                if (data) {
                    RegisterViewController *vc = [RegisterViewController vcWithMethodType:RegisterMethodPhone stepIndex:1 registerObj:weakSelf.myRegister];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        }else if (_stepIndex == 1){
            if (![_myRegister.password isEqualToString:_myRegister.confirm_password]) {
                [NSObject showHudTipStr:@"两次输入密码不一致"];
                return;
            }
            [self.footerBtn startQueryAnimate];
            [[Coding_NetAPIManager sharedManager] request_SetPasswordWithPhone:_myRegister.phone code:_myRegister.code password:_myRegister.password captcha:_myRegister.j_captcha type:PurposeToRegister block:^(id data, NSError *error) {
                [self.footerBtn stopQueryAnimate];
                if (data) {
                    RegisterViewController *vc = [RegisterViewController vcWithMethodType:RegisterMethodPhone stepIndex:2 registerObj:weakSelf.myRegister];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        }else{
            [self.footerBtn startQueryAnimate];
            [[Coding_NetAPIManager sharedManager] request_ActiveByPhone:_myRegister.phone setEmail:_myRegister.email global_key:_myRegister.global_key block:^(id data, NSError *error) {
                [self.footerBtn stopQueryAnimate];
                if (data) {
                    [Login setPreUserEmail:self.myRegister.phone];//记住登录账号
                    [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
                    kTipAlert(@"欢迎注册 Coding，请尽快去邮箱查收邮件并验证邮箱。邮箱验证后即可使用邮箱登录。");
                }
            }];
        }
    }else{
        [self.footerBtn startQueryAnimate];
        [[Coding_NetAPIManager sharedManager] request_Register_WithParams:[self.myRegister toParams] andBlock:^(id data, NSError *error) {
            [self.footerBtn stopQueryAnimate];
            if (data) {
                [Login setPreUserEmail:self.myRegister.email];//记住登录账号
                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
                kTipAlert(@"欢迎注册 Coding，请尽快去邮箱查收邮件并激活账号。如若在收件箱中未看到激活邮件，请留意一下垃圾邮件箱(T_T)。");
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

- (void)gotoCannotLoginVC{
    CannotLoginViewController *vc = [CannotLoginViewController vcWithPurposeType:PurposeToPasswordActivate methodType:0 stepIndex:0 userStr:self.myRegister.email];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
