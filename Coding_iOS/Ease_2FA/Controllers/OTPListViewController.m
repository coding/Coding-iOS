//
//  OTPListViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/7/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "OTPListViewController.h"
#import "ZXScanCodeViewController.h"
#import "OTPTableViewCell.h"

#import "OTPAuthURL.h"
#import <SSKeychain/SSKeychain.h>

static NSString *const kOTPKeychainEntriesArray = @"OTPKeychainEntries";

@interface OTPListViewController ()<UITableViewDataSource, UITableViewDelegate>

//Welcome
@property (strong, nonatomic) UIImageView *tipImageView;
@property (strong, nonatomic) UILabel *tipLabel;
@property (strong, nonatomic) UIButton *beginButton;

//Data List
@property (strong, nonatomic) UITableView *myTableView;

//Data
@property (nonatomic, strong) NSMutableArray *authURLs;

@end

@implementation OTPListViewController

+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account{
    if (serviceName.length <= 0 || account.length <= 0) {
        return nil;
    }
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    [query fetch:nil];
    return query.passwordData;
}

+ (NSMutableArray *)loadKeychainAuthURLs{
    NSArray *otpAccountList = [SSKeychain accountsForService:kOTPService];
    NSMutableArray *authURLs = [NSMutableArray arrayWithCapacity:otpAccountList.count];
    for (NSDictionary *otpAccount in otpAccountList) {
        NSData *passwordData = [self passwordDataForService:kOTPService account:otpAccount[(__bridge id)kSecAttrAccount]];
        if (passwordData) {
            NSMutableDictionary *tempDict = [otpAccount mutableCopy];
            tempDict[(__bridge id)kSecValueData] = passwordData;
            OTPAuthURL *authURL = [OTPAuthURL ease_authURLWithKeychainDictionary:tempDict];
            if (authURL) {
                [authURLs addObject:authURL];
            }
        }
    }
    return authURLs;
}

+ (NSString *)otpCodeWithGK:(NSString *)global_key{
    NSString *otpCode = nil;
    if (global_key.length > 0) {
        NSMutableArray *authURLs = [self loadKeychainAuthURLs];
        for (OTPAuthURL *authURL in authURLs) {
            NSString *cur_issure = authURL.issuer;
            NSString *cur_global_key = [[authURL.name componentsSeparatedByString:@"@"] firstObject];
            if ([cur_issure isEqualToString:@"Coding"] &&
                [cur_global_key isEqualToString:global_key]) {
                otpCode = authURL.otpCode;
                break;
            }
        }
    }
    return otpCode;
}

+ (BOOL)handleScanResult:(NSString *)resultStr ofVC:(UIViewController *)vc{
    //解析结果
    OTPAuthURL *authURL = [OTPAuthURL authURLWithURL:[NSURL URLWithString:resultStr] secret:nil];
    if ([authURL isKindOfClass:[TOTPAuthURL class]]) {
        OTPListViewController *nextVC = [OTPListViewController new];
        [vc.navigationController pushViewController:nextVC animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [nextVC addOneAuthURL:authURL];
        });
        return YES;
    }
    return NO;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"身份验证器";
    self.authURLs = [[self class] loadKeychainAuthURLs];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self configUI];
}

#pragma mark p_M

- (void)configUI{
    if (self.authURLs.count > 0) {
        
        [self.tipImageView removeFromSuperview];
        self.tipImageView = nil;

        [self.tipLabel removeFromSuperview];
        self.tipLabel = nil;
        
        [self.beginButton removeFromSuperview];
        self.beginButton = nil;
        
        if (!_myTableView) {
            //    添加myTableView
            _myTableView = ({
                UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
                tableView.backgroundColor = kColorTableSectionBg;
                tableView.dataSource = self;
                tableView.delegate = self;
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                [tableView registerClass:[TOTPTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOTPAuthURL class])];
                [tableView registerClass:[HOTPTableViewCell class] forCellReuseIdentifier:NSStringFromClass([HOTPAuthURL class])];
                [self.view addSubview:tableView];
                [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view);
                }];
                tableView;
            });
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(beginButtonClicked:)] animated:YES];
        }
        [self.myTableView reloadData];
    }else{
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self.myTableView removeFromSuperview];
        self.myTableView = nil;
        
        UIImage *tipImage = [UIImage imageNamed:@"tip_2FA"];
        if (!_tipImageView) {
            _tipImageView = [[UIImageView alloc] initWithImage:tipImage];
            [self.view addSubview:_tipImageView];
        }
        if (!_tipLabel) {
            _tipLabel = [UILabel new];
            _tipLabel.numberOfLines = 0;
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.textColor = kColor222;
            _tipLabel.text = @"启用两步验证后，登录 Coding 账户或进行敏感操作时都将需要输入密码和本客户端生成的验证码。";
            [self.view addSubview:_tipLabel];
        }
        if (!_beginButton) {
            _beginButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"开始验证" andFrame:CGRectMake(kPaddingLeftWidth, CGRectGetHeight(self.view.frame)- 20 - 45, kScreen_Width-kPaddingLeftWidth*2, 45) target:self action:@selector(beginButtonClicked:)];
            [self.view addSubview:_beginButton];
            [_beginButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kScreen_Width-kPaddingLeftWidth*2, 45));
                make.centerX.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-20);
            }];
        }
        CGSize tipImageSize = tipImage.size;
        CGFloat imageScale = 1.0, labelScale = 1.0;
        if (kDevice_Is_iPhone6Plus) {
            imageScale = 0.85;
            labelScale = 0.75;
            _tipLabel.font = [UIFont systemFontOfSize:17];
        }else if (kDevice_Is_iPhone6){
            imageScale = 0.75;
            labelScale = 0.75;
            _tipLabel.font = [UIFont systemFontOfSize:16];
        }else{
            _tipLabel.font = [UIFont systemFontOfSize:15];
            imageScale = 0.65;
            labelScale = 0.75;
        }
        tipImageSize = CGSizeMake(ceil(tipImageSize.width *imageScale), ceil(tipImageSize.height *imageScale));
        
        [_tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.mas_equalTo(ceil(kScreen_Height/7));
            make.size.mas_equalTo(tipImageSize);
        }];
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(_tipImageView.mas_bottom).offset(40);
            make.width.mas_equalTo(kScreen_Width * labelScale);
        }];
    }
}

- (void)beginButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    ZXScanCodeViewController *vc = [ZXScanCodeViewController new];
    vc.scanResultBlock = ^(ZXScanCodeViewController *vc, NSString *resultStr){
        [weakSelf dealWithScanResult:resultStr ofVC:vc];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealWithScanResult:(NSString *)resultStr ofVC:(ZXScanCodeViewController *)vc{
    //解析结果
    OTPAuthURL *authURL = [OTPAuthURL authURLWithURL:[NSURL URLWithString:resultStr] secret:nil];
    if ([authURL isKindOfClass:[TOTPAuthURL class]]) {
        [self addOneAuthURL:authURL];
        [vc.navigationController popViewControllerAnimated:YES];
    }else{
        NSString *tipStr;
        if (authURL) {
            tipStr = @"目前仅支持 TOTP 类型的身份验证令牌";
        }else{
            tipStr = [NSString stringWithFormat:@"条码「%@」不是有效的身份验证令牌条码", resultStr];
        }
        UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"无效条码" message:tipStr];
        [alertV bk_addButtonWithTitle:@"重试" handler:^{
            if (![vc isScaning]) {
                [vc startScan];
            }
        }];
        [alertV show];
    }
}

- (void)addOneAuthURL:(OTPAuthURL *)authURL{
    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:@"2FA_扫描成功"];

    BOOL alreadyHave = NO;
    for (OTPAuthURL *item in self.authURLs) {
        if ([authURL.name isEqualToString:item.name]) {
            alreadyHave = YES;
            if ([authURL.otpCode isEqualToString:item.otpCode]) {
                kTipAlert(@"该二维码已被保存为账户名：\n%@", authURL.name);
            }else{
                UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"账户名：%@ 已存在\n选择 '更新' 覆盖原账户。", authURL.name]];
                [alertV bk_setCancelButtonWithTitle:@"取消" handler:nil];
                [alertV bk_addButtonWithTitle:@"更新" handler:nil];
                @weakify(self);
                alertV.bk_didDismissBlock = ^(UIAlertView *alertView, NSInteger buttonIndex){
                    if (buttonIndex == 1) {
                        @strongify(self);
                        if ([authURL saveToKeychain]) {
                            if ([self.authURLs indexOfObject:item] != NSNotFound) {
                                [self.authURLs replaceObjectAtIndex:[self.authURLs indexOfObject:item] withObject:authURL];
                                [self configUI];
                                [NSObject showHudTipStr:@"更新成功"];
                            }
                        }else{
                            kTipAlert(@"保存过程中发生了异常，请重新扫描");
                        }

                    }
                };
                [alertV show];
            }
            break;
        }
    }
    if (!alreadyHave) {
        if ([authURL saveToKeychain]) {
            [self.authURLs addObject:authURL];
            [self configUI];
            kTipAlert(@"添加账户成功：\n%@", authURL.name);
        }else{
            kTipAlert(@"保存过程中发生了异常，请重新扫描");
        }
    }
}

- (void)deleteOneAuthURL:(OTPAuthURL *)authURL{
    [authURL removeFromKeychain];
    [self.authURLs removeObject:authURL];
    [self configUI];
}

#pragma mark table_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.authURLs count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = nil;
    OTPAuthURL *authURL = self.authURLs[indexPath.section];
    if ([authURL isKindOfClass:[TOTPAuthURL class]]) {
        cellIdentifier = NSStringFromClass([TOTPAuthURL class]);
    }else{
        cellIdentifier = NSStringFromClass([HOTPAuthURL class]);
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [(OTPTableViewCell *)cell setAuthURL:authURL];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [OTPTableViewCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kScaleFrom_iPhone5_Desgin(20);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OTPAuthURL *authURL = self.authURLs[indexPath.section];
    if (authURL.otpCode.length > 0) {
        [[UIPasteboard generalPasteboard] setString:authURL.otpCode];
        [NSObject showHudTipStr:@"已复制"];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        OTPAuthURL *authURL = self.authURLs[indexPath.section];
        __weak typeof(self) weakSelf = self;
        UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"删除此账户不会停用两步验证" message:@"\n您可能会因此无法登录自己的账户\n在删除该账户前，请先停用两步验证，或者确保您可以通过其它方法生成验证码。"];
        [alertV bk_setCancelButtonWithTitle:@"取消" handler:^{
            [weakSelf configUI];
        }];
        [alertV bk_addButtonWithTitle:@"确认删除" handler:^{
            [weakSelf deleteOneAuthURL:authURL];
        }];
        [alertV show];
    }
}

@end
