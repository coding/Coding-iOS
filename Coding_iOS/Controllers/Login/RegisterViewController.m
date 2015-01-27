//
//  RegisterViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "RegisterViewController.h"
#import "Input_LeftImgage_Cell.h"
#import "Input_GlobalKey_Cell.h"
#import "Input_OnlyText_Cell.h"

#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"
#import "UIUnderlinedButton.h"
#import "TPKeyboardAvoidingTableView.h"
#import "WebViewController.h"

@interface RegisterViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (assign, nonatomic) BOOL captchaNeeded;
@property (strong, nonatomic) UIButton *registerBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"注册";
    self.myRegister = [[Register alloc] init];
    _captchaNeeded = NO;
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _captchaNeeded? 3 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Input_OnlyText_Cell";
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"Input_OnlyText_Cell" owner:self options:nil] firstObject];
    }
    cell.isRegister = YES;
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        cell.isCaptcha = NO;
        [cell configWithPlaceholder:@" 电子邮箱" andValue:self.myRegister.email];
        cell.textField.secureTextEntry = NO;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.email = valueStr;
        };
        cell.editDidEndBlock = ^(NSString *textStr){
        };
    }else if (indexPath.row == 1){
        cell.isCaptcha = NO;
        [cell configWithPlaceholder:@" 个性后缀" andValue:self.myRegister.global_key];
        cell.textField.secureTextEntry = NO;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.global_key = valueStr;
        };
        cell.editDidEndBlock = ^(NSString *textStr){
        };
    }else{
        cell.isCaptcha = YES;
        [cell configWithPlaceholder:@" 验证码" andValue:self.myRegister.j_captcha];
        cell.textField.secureTextEntry = NO;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.j_captcha = valueStr;
        };
        cell.editDidEndBlock = nil;
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:18];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.15*kScreen_Height)];
    headerV.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"加入Coding，体验云端开发之美！";
    [headerLabel setCenter:headerV.center];
    [headerV addSubview:headerLabel];
    
    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    _registerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"立即体验" andFrame:CGRectMake(18, 20, kScreen_Width-18*2, 45) target:self action:@selector(sendRegister)];
    [footerV addSubview:_registerBtn];
    
    RAC(self, registerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.email), RACObserve(self, myRegister.global_key), RACObserve(self, myRegister.j_captcha), RACObserve(self, captchaNeeded)] reduce:^id(NSString *email, NSString *global_key, NSString *j_captcha, NSNumber *captchaNeeded){
        if ((captchaNeeded && captchaNeeded.boolValue) && (!j_captcha || j_captcha.length <= 0)) {
            return @(NO);
        }else{
            return @((email && email.length > 0) && (global_key && global_key.length > 0));
        }
    }];
    
    
    TTTAttributedLabel *lineLabel = [[TTTAttributedLabel alloc] init];
    lineLabel.textAlignment = NSTextAlignmentCenter;
    lineLabel.font = [UIFont systemFontOfSize:12];
    lineLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
    lineLabel.numberOfLines = 0;
    lineLabel.linkAttributes = kLinkAttributes;
    lineLabel.activeLinkAttributes = kLinkAttributesActive;
    lineLabel.delegate = self;
    NSString *tipStr = @"点击立即体验，即表示同意《coding服务条款》";
    lineLabel.text = tipStr;
    [lineLabel addLinkToTransitInformation:@{@"actionStr" : @"gotoServiceTermsVC"} withRange:[tipStr rangeOfString:@"《coding服务条款》"]];
    
    CGRect registerBtnFrame = _registerBtn.frame;
    lineLabel.frame = CGRectMake(CGRectGetMinX(registerBtnFrame), CGRectGetMaxY(registerBtnFrame) +12, CGRectGetWidth(registerBtnFrame), 12);
    [footerV addSubview:lineLabel];
    
    return footerV;
}
#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    if ([[components objectForKey:@"actionStr"] isEqualToString:@"gotoServiceTermsVC"]) {
        [self gotoServiceTermsVC];
    }
}
#pragma mark Btn Clicked
- (void)sendRegister{
    
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        CGSize captchaViewSize = _registerBtn.bounds.size;
        _activityIndicator.hidesWhenStopped = YES;
        [_activityIndicator setCenter:CGPointMake(captchaViewSize.width/2, captchaViewSize.height/2)];
        [_registerBtn addSubview:_activityIndicator];
    }
    [_activityIndicator startAnimating];
    
    self.registerBtn.enabled = NO;

    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Register_WithParams:[self.myRegister toParams] andBlock:^(id data, NSError *error) {
        weakSelf.registerBtn.enabled = YES;
        [weakSelf.activityIndicator stopAnimating];
        
        if (data) {
            [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
            kTipAlert(@"欢迎注册 Coding，请尽快去邮箱查收邮件并激活账号。如若在收件箱中未看到激活邮件，请留意一下垃圾邮件箱(T_T)。");
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


@end
