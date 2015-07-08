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

@interface RegisterViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (assign, nonatomic) BOOL captchaNeeded;
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *bottomView;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) EaseInputTipsView *inputTipsView;

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
        [tableView registerNib:[UINib nibWithNibName:kCellIdentifier_Input_OnlyText_Cell bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell];
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
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
    [self configBottomView];
    if (self.navigationController.childViewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(dismissSelf)];
    }
}

- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _captchaNeeded? 3 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Input_OnlyText_Cell forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        [cell configWithPlaceholder:@" 电子邮箱" andValue:self.myRegister.email];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.inputTipsView.valueStr = valueStr;
            weakSelf.inputTipsView.active = YES;
            weakSelf.myRegister.email = valueStr;
        };
        cell.editDidEndBlock = ^(NSString *textStr){
            weakSelf.inputTipsView.active = NO;
        };
    }else if (indexPath.row == 1){
        [cell configWithPlaceholder:@" 个性后缀" andValue:self.myRegister.global_key];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.global_key = valueStr;
        };
    }else{
        cell.isCaptcha = YES;
        [cell configWithPlaceholder:@" 验证码" andValue:self.myRegister.j_captcha];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.j_captcha = valueStr;
        };
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
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
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"立即体验" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(sendRegister)];
    [footerV addSubview:_footerBtn];
    
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.email), RACObserve(self, myRegister.global_key), RACObserve(self, myRegister.j_captcha), RACObserve(self, captchaNeeded)] reduce:^id(NSString *email, NSString *global_key, NSString *j_captcha, NSNumber *captchaNeeded){
        if ((captchaNeeded && captchaNeeded.boolValue) && (!j_captcha || j_captcha.length <= 0)) {
            return @(NO);
        }else{
            return @((email && email.length > 0) && (global_key && global_key.length > 0));
        }
    }];
    
    
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

    NSString *tipStr = @"点击立即体验，即表示同意《coding服务条款》";
    lineLabel.text = tipStr;
    [lineLabel addLinkToTransitInformation:@{@"actionStr" : @"gotoServiceTermsVC"} withRange:[tipStr rangeOfString:@"《coding服务条款》"]];
    
    CGRect footerBtnFrame = _footerBtn.frame;
    lineLabel.frame = CGRectMake(CGRectGetMinX(footerBtnFrame), CGRectGetMaxY(footerBtnFrame) +12, CGRectGetWidth(footerBtnFrame), 12);
    [footerV addSubview:lineLabel];
    
    return footerV;
}

#pragma mark BottomView
- (void)configBottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor clearColor];

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
        
        [_bottomView addSubview:bottomLabel];
        [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_bottomView);
        }];
        
        [self.view addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(60);
        }];
    }
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
- (void)sendRegister{
    
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
    [[Coding_NetAPIManager sharedManager] request_Register_WithParams:[self.myRegister toParams] andBlock:^(id data, NSError *error) {
        weakSelf.footerBtn.enabled = YES;
        [weakSelf.activityIndicator stopAnimating];
        if (data) {
            [Login setPreUserEmail:self.myRegister.email];//记住登录账号
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

- (void)gotoCannotLoginVC{
    CannotLoginViewController *vc = [[CannotLoginViewController alloc] init];
    vc.type = CannotLoginTypeActivate;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
