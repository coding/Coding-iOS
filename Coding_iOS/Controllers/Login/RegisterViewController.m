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

#import "StartImagesManager.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import <UIImage+BlurredFrame/UIImage+BlurredFrame.h>
#import "TPKeyboardAvoidingTableView.h"


@interface RegisterViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (assign, nonatomic) BOOL captchaNeeded;
@property (strong, nonatomic) UIButton *registerBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadView{
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:[UIView frameWithOutNav]];
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
        tableView;
    });
    self.myTableView.tableFooterView=[self customFooterView];
    self.myTableView.tableHeaderView = [self customHeaderView];
}

- (UIImageView *)bgBlurredView{
    if (!_bgBlurredView) {
        //背景图片
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:kScreen_Bounds];
        bgView.contentMode = UIViewContentModeScaleAspectFill;
        UIImage *bgImage = [[StartImagesManager shareManager] curImage].image;
        
        CGSize bgImageSize = bgImage.size, bgViewSize = [bgView doubleSizeOfFrame];
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
    
//    UIUnderlinedButton *activateBtn = [UIUnderlinedButton buttonWithTitle:@"已经注册？重发激活邮件" andFont:[UIFont systemFontOfSize:14] andColor:[UIColor colorWithHexString:@"0x3bbd79"]];
//    CGRect frame = activateBtn.frame;
//    frame.origin.y = CGRectGetMaxY(_registerBtn.frame) +12;
//    frame.origin.x = (kScreen_Width -frame.size.width)/2;
//    activateBtn.frame = frame;
//    [activateBtn addTarget:self action:@selector(reActivate) forControlEvents:UIControlEventTouchUpInside];
//    [footerV addSubview:activateBtn];
    return footerV;
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

- (void)reActivate{
    DebugLog(@"reActivate");
}


@end
