//
//  LoginViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "Input_OnlyText_Cell.h"
#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"

@interface LoginViewController ()
@property (assign, nonatomic) BOOL captchaNeeded;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
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
    [self.navigationController setNavigationBarHidden:YES];

}

- (void)loadView{
    [super loadView];
    
    self.view = [[UIView alloc] initWithFrame:kScreen_Bounds];
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        tableView;
    });

    self.myTableView.backgroundColor = [UIColor colorWithHexString:@"0xfafafa"];
    UIView *upBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    upBgView.backgroundColor =[UIColor colorWithHexString:@"0x29333f"];
    [upBgView setY:-CGRectGetHeight(upBgView.bounds)];
    [self.myTableView addSubview:upBgView];
    
    self.myTableView.contentInset = UIEdgeInsetsMake(-kHigher_iOS_6_1_DIS(20), 0, 0, 0);
    self.myTableView.tableFooterView=[self customFooterView];
    self.myTableView.tableHeaderView = [self customHeaderView];
    
    [self configBottomView];

    self.myLogin = [[Login alloc] init];
    _captchaNeeded = NO;
    [self refreshCaptchaNeeded];
}


- (void)refreshCaptchaNeeded{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CaptchaNeededWithBlock:^(id data, NSError *error) {
        if (data) {
            NSNumber *captchaNeededResult = (NSNumber *)data;
            if (captchaNeededResult.boolValue != weakSelf.captchaNeeded) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _captchaNeeded? 3 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Input_OnlyText_Cell";
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"Input_OnlyText_Cell" owner:self options:nil] firstObject];
    }
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        cell.isCaptcha = NO;
        [cell configWithPlaceholder:@" 电子邮箱/个性后缀" andValue:self.myLogin.email];
        cell.textField.secureTextEntry = NO;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myLogin.email = valueStr;
        };
    }else if (indexPath.row == 1){
        cell.isCaptcha = NO;
        [cell configWithPlaceholder:@" 密码" andValue:self.myLogin.password];
        cell.textField.secureTextEntry = YES;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myLogin.password = valueStr;
        };
    }else{
        cell.isCaptcha = YES;
        [cell configWithPlaceholder:@" 验证码" andValue:self.myLogin.j_captcha];
        cell.textField.secureTextEntry = NO;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myLogin.j_captcha = valueStr;
        };
    }
    return cell;
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 180)];
    UIImageView *loginLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo"]];
    CGFloat loginLogoHeight = CGRectGetHeight(loginLogo.bounds)*kScreen_Width/CGRectGetWidth(loginLogo.bounds);
    if (loginLogoHeight > 180) {
        [headerV setHeight:loginLogoHeight];
    }
    loginLogo.frame = CGRectMake(0, 0, kScreen_Width, loginLogoHeight);
    [headerV addSubview:loginLogo];

    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 100)];
    _loginBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"登录" andFrame:CGRectMake(18, kScreen_Width > 320? 20: 20, kScreen_Width-18*2, 45) target:self action:@selector(sendLogin)];
    [footerV addSubview:_loginBtn];
    return footerV;
}

#pragma mark BottomView
- (void)configBottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 60, kScreen_Width, 60)];
        _bottomView.backgroundColor = [UIColor clearColor];
        UIButton *registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        [registerBtn setCenter:CGPointMake(CGRectGetMidX(_bottomView.bounds), CGRectGetMidY(_bottomView.bounds))];
        [registerBtn setImage:[UIImage imageNamed:@"register_arrow"] forState:UIControlStateNormal];
        [registerBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [registerBtn setTitle:@"注册账号" forState:UIControlStateNormal];
        [registerBtn setTitleColor:[UIColor colorWithHexString:@"0x8092a8"] forState:UIControlStateNormal];
        [registerBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [registerBtn addTarget:self action:@selector(goRegisterVC:) forControlEvents:UIControlEventTouchUpInside];
        registerBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 65, 0, -65);
        registerBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
        [_bottomView addSubview:registerBtn];
        [self.view addSubview:_bottomView];
    }
}

#pragma mark Btn Clicked
- (void)sendLogin{
    NSString *tipMsg = [_myLogin goToLoginTipWithCaptcha:_captchaNeeded];
    if (tipMsg) {
        kTipAlert(@"%@", tipMsg);
        return;
    }
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
    [[Coding_NetAPIManager sharedManager] request_Login_WithParams:[self.myLogin toParams] andBlock:^(id data, NSError *error) {
        weakSelf.loginBtn.enabled = YES;
        [weakSelf.activityIndicator stopAnimating];

        if (data) {
            [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
        }else{
            [weakSelf refreshCaptchaNeeded];
        }
    }];
}

- (IBAction)goRegisterVC:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:kNetPath_Code_Base delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"去Safari中注册", nil];
    [actionSheet showInView:kKeyWindow];
//    DebugLog(@"goRegisterVC");
//    RegisterViewController *vc = [[RegisterViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kNetPath_Code_Base]];
    }
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}
@end
