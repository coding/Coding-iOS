//
//  PasswordViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/3/26.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "PasswordViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "Input_OnlyText_Cell.h"

@interface PasswordViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@end

@implementation PasswordViewController
+ (id)passwordVCWithType:(PasswordType)type email:(NSString *)email andKey:(NSString *)key{
    PasswordViewController *vc = [[PasswordViewController alloc] init];
    vc.type = type;
    vc.email = email;
    vc.key = key;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [self titleStr];
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
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
}

- (NSString *)titleStr{
    NSString *curStr = @"";
    if (_type == PasswordReset){
        curStr = @"重置密码";
    }else if (_type == PasswordActivate) {
        curStr = @"用户激活";
    }
    return curStr;
}

#pragma mark - Table view Header Footer
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
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:[self footerBtnTitle] andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(footerBtnClicked:)];
    [footerV addSubview:_footerBtn];
    
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, email),
                                                              RACObserve(self, password),
                                                              RACObserve(self, confirm_password)]
                                                     reduce:^id(NSString *email, NSString *password, NSString *confirm_password){
                                                         return @((email && email.length > 0) && (password && password.length > 0) && (confirm_password && confirm_password.length > 0));
                                                     }];
    return footerV;
}

- (NSString *)footerBtnTitle{
    NSString *curStr = @"";
    if (_type == PasswordReset) {
        curStr = @"确定";
    }else if (_type == PasswordActivate){
        curStr = @"完成注册";
    }
    return curStr;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text forIndexPath:indexPath];

    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        [cell setPlaceholder:@" 电子邮箱" value:self.email];
        cell.textField.userInteractionEnabled = NO;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.email = valueStr;
        };
    }else if (indexPath.row == 1) {
        [cell setPlaceholder:@" 密码" value:self.password];
        cell.textField.secureTextEntry = YES;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.password = valueStr;
        };
    }else{
        [cell setPlaceholder:@" 确认密码" value:self.confirm_password];
        cell.textField.secureTextEntry = YES;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.confirm_password = valueStr;
        };
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

#pragma mark Btn Clicked
- (NSString *)requestPath{
    NSString *curStr = @"";
    if (_type == PasswordReset) {
        curStr = @"api/resetPassword";
    }else if (_type == PasswordActivate){
        curStr = @"api/activate";
    }
    return curStr;
}

- (void)footerBtnClicked:(id)sender{
    NSString *tipStr = nil;
    if (![self.password isEqualToString:self.confirm_password]){
        tipStr = @"两次输入的密码不一致";
    }else if (self.password.length < 6){
        tipStr = @"新密码不能少于6位";
    }else if (self.password.length > 64){
        tipStr = @"新密码不得长于64位";
    }
    if (tipStr) {
        [NSObject showHudTipStr:tipStr];
        return;
    }
    [self.view endEditing:YES];
    NSDictionary *params = @{@"email": _email,
                             @"key": _key? _key: @"",
                             @"password": [_password sha1Str],
                             @"confirm_password": [_confirm_password sha1Str]};

    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        CGSize captchaViewSize = _footerBtn.bounds.size;
        _activityIndicator.hidesWhenStopped = YES;
        [_activityIndicator setCenter:CGPointMake(captchaViewSize.width/2, captchaViewSize.height/2)];
        [_footerBtn addSubview:_activityIndicator];
    }
    [_activityIndicator startAnimating];
    
    self.footerBtn.enabled = NO;
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_SetPasswordToPath:[self requestPath] params:params andBlock:^(id data, NSError *error) {
        weakSelf.footerBtn.enabled = YES;
        [weakSelf.activityIndicator stopAnimating];
        if (data) {
            if (weakSelf.successBlock) {
                weakSelf.successBlock(weakSelf, data);
            }
        }
    }];
}

@end
