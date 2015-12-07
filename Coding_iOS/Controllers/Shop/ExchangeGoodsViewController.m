    
//  Created by liaoyp on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ExchangeGoodsViewController.h"
#import "ShopOrderViewController.h"

#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "MBProgressHUD+Add.h"
#import "ShopOrderTextFieldCell.h"
#import "ShopGoodsInfoView.h"
#import "UIView+Common.h"

#define kCellIdentifier_ShopOrderTextFieldCell @"ShopOrderTextFieldCell.h"

@interface ExchangeGoodsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
}

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *shopOrderBtn;

@end

@implementation ExchangeGoodsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)orderCommitAction:(UIButton *)button
{
    ShopOrderTextFieldCell *receiveName = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    if ([receiveName.textField.text isEmpty]) {
        [NSObject showHudTipStr:@"收货人名字很重要"];
        return;
    }
    
    ShopOrderTextFieldCell *address = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    if ([address.textField.text isEmpty]) {
        [NSObject showHudTipStr:@"详细地址也很重要"];
        return;
    }
    
    ShopOrderTextFieldCell *phone = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    if ([phone.textField.text isEmpty]) {
        [NSObject showHudTipStr:@"联系电话非常重要"];
        return;
    }
    // alert
    [self showPwdAlertView];
        
}

#pragma mark-
#pragma mark---------------------- ControllerLife ---------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"提交订单";
    
    self.view.backgroundColor = kColorTableSectionBg;
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ShopOrderTextFieldCell class] forCellReuseIdentifier:kCellIdentifier_ShopOrderTextFieldCell];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = [UIColor colorWithHexString:@"0xFFDDDDDD"];
        tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    ShopGoodsInfoView *goodInfoView = [[ShopGoodsInfoView alloc] initWithFrame:CGRectZero];
    [goodInfoView configViewWithModel:_shopGoods];
    UIView *headView = [[UIView alloc] initWithFrame:goodInfoView.bounds];
    [headView addSubview:goodInfoView];
    headView.backgroundColor = [UIColor whiteColor];
    _myTableView.tableHeaderView = headView;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_myTableView.frame), 136/2)];
    _shopOrderBtn = ({
        UIButton *orderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [orderBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xFF3BBD79"]] forState:UIControlStateNormal];
        [orderBtn addTarget:self action:@selector(orderCommitAction:) forControlEvents:UIControlEventTouchUpInside];
        [orderBtn setTitle:@"提交订单" forState:UIControlStateNormal];
        [orderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        orderBtn.layer.masksToBounds = YES;
        orderBtn.layer.cornerRadius = 44/2;
        [footView addSubview:orderBtn];
        [orderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@44);
            make.left.equalTo(footView.mas_left).offset(16);
            make.right.equalTo(footView.mas_right).offset(-16);
            make.centerX.centerY.equalTo(footView);
        }];
        orderBtn;
    });
    _myTableView.tableFooterView = footView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 4;
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ShopOrderTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ShopOrderTextFieldCell forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
        {
            cell.nameLabel.text = @"收货人 *";
            cell.textField.placeholder  = @"小王";
            break;
        }
        case 1:
        {
            cell.nameLabel.text = @"详细地址 *";
            cell.textField.placeholder  = @"省，市，县（镇），街道";
            break;
        }
        case 2:
        {
            cell.nameLabel.text = @"联系电话 *";
            cell.textField.placeholder  = @"电话";
            break;
        }
        case 3:
        {
            cell.nameLabel.text = @"备注";
            cell.textField.placeholder  = @"备注信息如:衣服码数XXL";
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"填写并核对订单信息";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ShopOrderTextFieldCell cellHeight];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0) {
        return YES;
    }
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 42;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField
{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}


#pragma mark-
#pragma mark---------------------- AlertView ---------------------------

- (void)showPwdAlertView
{
    UIAlertView *_pwdAlertView = [[UIAlertView alloc] initWithTitle:@"确认订单" message:@"请输入密码已确认兑换" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    _pwdAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [_pwdAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.firstOtherButtonIndex == buttonIndex) {
        UITextField *field = [alertView textFieldAtIndex:0];
        if ([field.text isEmpty]) {
            [NSObject showHudTipStr:@"密码不能为空"];
            return;
        }
        
        [self exchangeActionRquest:field.text];

    }
}

- (void)exchangeActionRquest:(NSString *)pwd
{
    __weak typeof(self) weakSelf = self;
    [self.view beginLoading];
    [[Coding_NetAPIManager sharedManager] request_shop_check_passwordWithpwd:pwd andBlock:^(id data, NSError *error) {
        if (!error) {
            
            ShopOrderTextFieldCell *nameCell = [weakSelf.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            ShopOrderTextFieldCell *addressCell = [weakSelf.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
            ShopOrderTextFieldCell *phoneCell = [weakSelf.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
            ShopOrderTextFieldCell *remarkCell = [weakSelf.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];

            NSString *receiverName = nameCell.textField.text;
            NSString *receiverAddress = addressCell.textField.text;
            NSString *receiverPhone = phoneCell.textField.text;
            NSString *remark = remarkCell.textField.text;
            NSMutableDictionary *mparms = [NSMutableDictionary dictionary];
            if (![receiverName isEmpty]) {
                [mparms setObject:receiverName forKey:@"receiverName"];
            }
            if (![receiverAddress isEmpty]) {
                [mparms setObject:receiverAddress forKey:@"receiverAddress"];
            }
            if (![receiverPhone isEmpty]) {
                [mparms setObject:receiverPhone forKey:@"receiverPhone"];
            }
            if (![remark isEmpty]) {
                [mparms setObject:remark forKey:@"remark"];
            }else
                [mparms setObject:@"" forKey:@"remark"];
            
            if (![_shopGoods.giftId isEmpty]) {
                [mparms setObject:_shopGoods.id forKey:@"giftId"];
            }
            if (![pwd isEmpty]) {
                [mparms setObject:[pwd sha1Str] forKey:@"password"];
            }

            [[Coding_NetAPIManager sharedManager] request_shop_exchangeWithParms:mparms andBlock:^(id data, NSError *error) {
                [self.view endLoading];
                if (!error) {
                    [NSObject showHudTipStr:@"恭喜你，提交订单成功!"];
//                    [self.navigationController popViewControllerAnimated:YES];
                    ShopOrderViewController *orderViewController = [[ShopOrderViewController alloc] init];
                    [self.navigationController pushViewController:orderViewController animated:YES];
                    
                }else
                {
                    [self.view endLoading];

                    [NSObject showError:error];
                }
            }];
        }else
        {
            [self.view endLoading];

            [NSObject showHudTipStr:@"密码不正确"];
        }
    }];
}

- (void)dealloc
{
    _myTableView.dataSource  = nil;
    _myTableView.delegate = nil;
}

@end

