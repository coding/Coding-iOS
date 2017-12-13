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
    
    self.title = @"找回密码";
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    
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
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"更改服务器 URL" message:@"空白值可切换回生产环境\n（地址末尾务必加上「/」）" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *newBaseURLStr = alertCtrl.textFields[0].text;
        if ([newBaseURLStr.uppercaseString isEqualToString:@"S"]) {
            newBaseURLStr = @"http://coding.codingprod.net/";
        }
        [NSObject changeBaseURLStrTo:newBaseURLStr];
    }];
    [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Coding 服务器地址";
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
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    headerV.backgroundColor = [UIColor clearColor];
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
    
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
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
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/password/forget" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"验证码发送成功"];
            [sender startUpTimer];
        }else{
            [sender invalidateTimer];
            if (error && error.userInfo[@"msg"] && [[error.userInfo[@"msg"] allKeys] containsObject:@"j_captcha_error"]) {
                [weakSelf p_showCaptchaAlert:sender];
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
    UIImageView *imageV = [UIImageView new];
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
