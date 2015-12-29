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

@interface CannotLoginViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) PurposeType purposeType;
@property (nonatomic, assign) CannotLoginMethodType medthodType;
@property (nonatomic, assign) NSUInteger stepIndex;
@property (strong, nonatomic) NSString *userStr, *phoneCode, *password, *confirm_password, *j_captcha;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;
@property (assign, nonatomic) BOOL isFirstLoadCell;
@end

@implementation CannotLoginViewController

+ (instancetype)vcWithPurposeType:(PurposeType)purposeType methodType:(CannotLoginMethodType)methodType stepIndex:(NSUInteger)stepIndex userStr:(NSString *)userStr{
    CannotLoginViewController *vc = [self new];
    vc.purposeType = purposeType;
    vc.medthodType = methodType;
    vc.stepIndex = stepIndex;
    vc.userStr = userStr;
    return vc;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [self titleStr];
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    self.isFirstLoadCell = YES;
    
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
    self.myTableView.tableFooterView=[self customFooterView];
    self.myTableView.tableHeaderView = [self customHeaderView];
    
    [self addChangeBaseURLGesture];
    if ([NSObject baseURLStrIsTest]) {
        kTipAlert(@"在此页面连续点击屏幕 10 下切换到生产环境！");
    }
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
            [self changeToTest:![NSObject baseURLStrIsTest]];
        }
    }];
    tapGR.numberOfTapsRequired = 10.0;
    [self.view addGestureRecognizer:tapGR];
}

- (void)changeToTest:(BOOL)isTest{
    [NSObject changeBaseURLStrToTest:isTest];
    NSString *tipstr;
    if (isTest) {
        tipstr = @"你现在切换到了测试环境。\n若要重新切换回生产环境则需要按照如下步骤操作：\n\
                                                                                1. 进到 '登录' 页\n\
                                                                                2. 点击 '无法登陆' 按钮\n\
                                                                                3. 进入 '忘记密码？/未设置密码？' 页面\n\
                                                                                4. 单击屏幕 10 次";
    }else{
        tipstr = @"你已成功切换到了生产环境！";
    }
    kTipAlert(@"%@", tipstr);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (NSString *)titleStr{
    NSString *curStr = @"";
    if (_purposeType == PurposeToPasswordReset) {
        curStr = @"重置密码";
    }else if (_purposeType == PurposeToPasswordActivate){
        curStr = @"设置密码";
    }
    return curStr;
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.15*kScreen_Height)];
    headerV.backgroundColor = [UIColor clearColor];
    
    UILabel *headerLabel = [UILabel new];
    headerLabel.numberOfLines = 0;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *headerStr;
    if (_stepIndex > 0 && _medthodType == CannotLoginMethodPhone) {
        NSString *tempStr = [NSString stringWithFormat:@"我们已经发送了验证码到手机号\n%@", _userStr];
        headerStr = [[NSMutableAttributedString alloc] initWithString:tempStr attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                                                                           NSForegroundColorAttributeName: [UIColor colorWithHexString:@"0x999999"]}];
        [headerStr setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15],
                                   NSForegroundColorAttributeName: [UIColor colorWithHexString:@"0x3BBD79"],
                                   NSBaselineOffsetAttributeName: @(-10.0)} range:[tempStr rangeOfString:_userStr]];
        
    }else{
        NSString *tempStr = @"加入Coding，体验云端开发之美！";
        headerStr = [[NSMutableAttributedString alloc] initWithString:tempStr attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                                                                                           NSForegroundColorAttributeName: [UIColor colorWithHexString:@"0x222222"]}];
    }
    headerLabel.attributedText = headerStr;
    [headerV addSubview:headerLabel];
    [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headerV);
    }];
    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:[self footerBtnTitle] andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(footerBtnClicked:)];
    [footerV addSubview:_footerBtn];
    
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
                                                                      RACObserve(self, confirm_password),
                                                                      RACObserve(self, j_captcha)]
                                                             reduce:^id(NSString *userStr, NSString *phoneCode, NSString *password, NSString *confirm_password, NSString *j_captcha){
                                                                 return @([userStr isPhoneNo] && phoneCode.length > 0 && password.length > 0 && confirm_password.length > 0 && j_captcha.length > 0);
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
        if (_purposeType == PurposeToPasswordReset) {
            curStr = _medthodType == CannotLoginMethodPhone? @"重置密码": @"发送重置密码邮件";
        }else if (_purposeType == PurposeToPasswordActivate){
            curStr = _medthodType == CannotLoginMethodPhone? @"设置密码": @"重发激活邮件";
        }
    }
    return curStr;
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _stepIndex == 0? 1: _medthodType == CannotLoginMethodPhone? 4: 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier;
    if (_stepIndex == 0) {
        cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Text;
    }else{
        if (_medthodType == CannotLoginMethodPhone) {
            if (indexPath.row == 0) {
                cellIdentifier = self.phoneCodeCellIdentifier;
            }else if (indexPath.row <= 2){
                cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Text;
            }else{
                cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Captcha;
            }
        }else{
            if (indexPath.row == 0) {
                cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Text;
            }else{
                cellIdentifier = kCellIdentifier_Input_OnlyText_Cell_Captcha;
            }
        }
    }
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    if (_stepIndex == 0) {
        [cell setPlaceholder:@" 手机号/电子邮箱" value:self.userStr];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.userStr = valueStr;
        };
    }else{
        if (_medthodType == CannotLoginMethodPhone) {
            switch (indexPath.row) {
                case 0:{
                    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                    [cell setPlaceholder:@" 手机验证码" value:self.phoneCode];
                    cell.textValueChangedBlock = ^(NSString *valueStr){
                        weakSelf.phoneCode = valueStr;
                    };
                    cell.phoneCodeBtnClckedBlock = ^(PhoneCodeButton *btn){
                        [weakSelf phoneCodeBtnClicked:btn];
                    };
                    if (_isFirstLoadCell) {
                        [cell.verify_codeBtn startUpTimer];
                        _isFirstLoadCell = NO;
                    }
                    break;
                }
                case 1:{
                    cell.textField.secureTextEntry = YES;
                    [cell setPlaceholder:@" 密码" value:self.password];
                    cell.textValueChangedBlock = ^(NSString *valueStr){
                        weakSelf.password = valueStr;
                    };
                    break;
                }
                case 2:{
                    cell.textField.secureTextEntry = YES;
                    [cell setPlaceholder:@" 确认密码" value:self.confirm_password];
                    cell.textValueChangedBlock = ^(NSString *valueStr){
                        weakSelf.confirm_password = valueStr;
                    };
                    break;
                }
                default:{
                    [cell setPlaceholder:@" 验证码" value:self.j_captcha];
                    cell.textValueChangedBlock = ^(NSString *valueStr){
                        weakSelf.j_captcha = valueStr;
                    };
                    break;
                }
            }
        }else{
            if (indexPath.row == 0) {
                [cell setPlaceholder:@" 手机号/电子邮箱" value:self.userStr];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.userStr = valueStr;
                };
            }else{
                [cell setPlaceholder:@" 验证码" value:self.j_captcha];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.j_captcha = valueStr;
                };
            }
        }
    }
    
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

#pragma mark Btn Clicked
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender{
    if (![_userStr isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    sender.enabled = NO;
    [[Coding_NetAPIManager sharedManager] request_GeneratePhoneCodeWithPhone:_userStr type:_purposeType block:^(id data, NSError *error) {
        if (data) {
            [sender startUpTimer];
        }else{
            [sender invalidateTimer];
        }
    }];
}

- (void)footerBtnClicked:(id)sender{
    if (_stepIndex == 0) {
        if ([_userStr isPhoneNo]) {
            [self.footerBtn startQueryAnimate];
            [[Coding_NetAPIManager sharedManager] request_GeneratePhoneCodeWithPhone:_userStr type:_purposeType block:^(id data, NSError *error) {
                [self.footerBtn stopQueryAnimate];
                if (data) {
                    [NSObject showHudTipStr:@"验证码已发送"];
                    CannotLoginViewController *vc = [CannotLoginViewController vcWithPurposeType:_purposeType methodType:CannotLoginMethodPhone stepIndex:1 userStr:_userStr];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        }else{
            CannotLoginViewController *vc = [CannotLoginViewController vcWithPurposeType:_purposeType methodType:CannotLoginMethodEamil stepIndex:1 userStr:_userStr];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        if (_medthodType == CannotLoginMethodPhone) {
            if (![_password isEqualToString:_confirm_password]) {
                [NSObject showHudTipStr:@"两次输入密码不一致"];
                return;
            }
            [self.footerBtn startQueryAnimate];
            [[Coding_NetAPIManager sharedManager] request_SetPasswordWithPhone:_userStr code:_phoneCode password:_password captcha:_j_captcha type:_purposeType block:^(id data, NSError *error) {
                [self.footerBtn stopQueryAnimate];
                if (data) {
                    [NSObject showHudTipStr:@"密码设置成功"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }else{
            NSString *tipStr = _purposeType != PurposeToPasswordReset? @"激活邮件已经发送，请尽快去邮箱查看": @"重置密码邮件已经发送，请尽快去邮箱查看";
            [self.footerBtn startQueryAnimate];
            [[Coding_NetAPIManager sharedManager] request_SetPasswordWithEmail:_userStr captcha:_j_captcha type:_purposeType block:^(id data, NSError *error) {
                [self.footerBtn stopQueryAnimate];
                if (data) {
                    [NSObject showHudTipStr:tipStr];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    }
}

@end
