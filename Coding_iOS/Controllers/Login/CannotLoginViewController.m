//
//  CannotLoginViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/3/26.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CannotLoginViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "Input_OnlyText_Cell.h"

@interface CannotLoginViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@end

@implementation CannotLoginViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [self titleStr];
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
    self.myTableView.tableFooterView=[self customFooterView];
    self.myTableView.tableHeaderView = [self customHeaderView];
    
    [self addChangeBaseURLGesture];
    if ([NSObject baseURLStrIsTest]) {
        kTipAlert(@"在此页面连续点击屏幕 10 下切换到生产环境！");
    }
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
                                                                                3. 进入 '找回密码/重发激活邮件' 页\n\
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
    if (_type == CannotLoginTypeResetPassword) {
        curStr = @"找回密码";
    }else if (_type == CannotLoginTypeActivate){
        curStr = @"重发激活邮件";
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
    headerLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
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
                                                              RACObserve(self, j_captcha)]
                                                     reduce:^id(NSString *email, NSString *j_captcha){
                                                         return @((email && email.length > 0) && (j_captcha && j_captcha.length > 0));
                                                     }];
    return footerV;
}

- (NSString *)footerBtnTitle{
    NSString *curStr = @"";
    if (_type == CannotLoginTypeResetPassword) {
        curStr = @"发送重置密码邮件";
    }else if (_type == CannotLoginTypeActivate){
        curStr = @"重发激活邮件";
    }
    return curStr;
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Input_OnlyText_Cell forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        [cell configWithPlaceholder:@" 电子邮箱" andValue:self.email];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.email = valueStr;
        };
    }else{
        cell.isCaptcha = YES;
        [cell configWithPlaceholder:@" 验证码" andValue:self.j_captcha];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.j_captcha = valueStr;
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
    if (_type == CannotLoginTypeResetPassword) {
        curStr = @"api/resetPassword";
    }else if (_type == CannotLoginTypeActivate){
        curStr = @"api/activate";
    }
    return curStr;
}

- (void)footerBtnClicked:(id)sender{
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
    [[Coding_NetAPIManager sharedManager] request_SendMailToPath:[self requestPath] email:_email j_captcha:_j_captcha andBlock:^(id data, NSError *error) {
        weakSelf.footerBtn.enabled = YES;
        [weakSelf.activityIndicator stopAnimating];
        if (data) {
            [weakSelf popToRootVC];//返回登录页面
        }else{
            [weakSelf.myTableView reloadData];//更新验证码
        }
    }];
}

- (void)popToRootVC{
    [NSObject showHudTipStr:@"已发送邮件"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
