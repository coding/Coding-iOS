//
//  Close2FAViewController.m
//  Coding_iOS
//
//  Created by Ease on 16/3/15.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "Close2FAViewController.h"
#import "Coding_NetAPIManager.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Input_OnlyText_Cell.h"

@interface Close2FAViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *phone, *phoneCode;
@property (copy, nonatomic) void (^sucessBlock)(UIViewController *vc);

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;
@end

@implementation Close2FAViewController
+ (id)vcWithPhone:(NSString *)phone sucessBlock:(void (^)(UIViewController *vc))block{
    Close2FAViewController *vc = [self new];
    vc.phone = [phone isPhoneNo]? phone: nil;
    vc.sucessBlock = block;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"关闭两步验证";
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
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
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 100)];
    headerV.backgroundColor = [UIColor clearColor];
    UILabel *tipL = [UILabel new];
    tipL.font = [UIFont systemFontOfSize:14];
    tipL.textColor = kColor999;
    tipL.text = @"关闭两步验证，请先验证您的注册手机";
    [headerV addSubview:tipL];
    [tipL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headerV);
    }];
    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"关闭两步验证" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(footerBtnClicked:)];
    [footerV addSubview:_footerBtn];
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, phone),
                                                              RACObserve(self, phoneCode)]
                                                     reduce:^id(NSString *phone, NSString *phoneCode){
                                                         return @([phone isPhoneNo] && phoneCode.length > 0);
                                                     }];
    return footerV;
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = indexPath.row == 1? self.phoneCodeCellIdentifier: kCellIdentifier_Input_OnlyText_Cell_Text;
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        [cell setPlaceholder:@" 手机号" value:self.phone];
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.phone = valueStr;
        };
    }else{
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 手机验证码" value:self.phoneCode];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.phoneCode = valueStr;
        };
        cell.phoneCodeBtnClckedBlock = ^(PhoneCodeButton *btn){
            [weakSelf phoneCodeBtnClicked:btn];
        };
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
    return cell;
}

#pragma mark Btn Clicked
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender{
    if (![_phone isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    sender.enabled = NO;
    [[Coding_NetAPIManager sharedManager] post_Close2FAGeneratePhoneCode:self.phone block:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"验证码发送成功"];
            [sender startUpTimer];
        }else{
            [sender invalidateTimer];
        }
    }];
}
- (void)footerBtnClicked:(id)sender{
    [self.footerBtn startQueryAnimate];
    [[Coding_NetAPIManager sharedManager] post_Close2FAWithPhone:self.phone code:self.phoneCode block:^(id data, NSError *error) {
        [self.footerBtn stopQueryAnimate];
        if (data) {
            [NSObject showHudTipStr:@"两步验证已关闭"];
            if (self.sucessBlock) {
                self.sucessBlock(self);
            }
        }
    }];
}
@end
