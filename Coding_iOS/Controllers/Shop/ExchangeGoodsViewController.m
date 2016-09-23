    
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
#import "LocationViewController.h"
#import "ShopMutileValueCell.h"
#import "ActionSheetStringPicker.h"

#define kCellIdentifier_ShopOrderTextFieldCell @"ShopOrderTextFieldCell.h"

@interface ExchangeGoodsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
}

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *shopOrderBtn;

@property (strong, nonatomic) NSString *receiverName, *receiverAddress, *receiverPhone, *remark;
@property (strong, nonatomic) NSArray *locations;
@property (strong, nonatomic) ShopGoodsOption *option;
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
    if ([_receiverName isEmpty]) {
        [NSObject showHudTipStr:@"收货人名字很重要"];
        return;
    }
    if (_locations.count == 0) {
        [NSObject showHudTipStr:@"请选择所在地"];
        return;
    }
    if ([_receiverAddress isEmpty]) {
        [NSObject showHudTipStr:@"详细地址也很重要"];
        return;
    }
    if ([_receiverPhone isEmpty]) {
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
        [tableView registerNib:[UINib nibWithNibName:kCellIdentifier_ShopMutileValueCell bundle:nil] forCellReuseIdentifier:kCellIdentifier_ShopMutileValueCell];
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
        [orderBtn setBackgroundImage:[UIImage imageWithColor:kColorBrandGreen] forState:UIControlStateNormal];
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
    NSInteger row = self.shopGoods.options.count > 0? 6: 5;
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 || indexPath.row == 5) {
        ShopMutileValueCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ShopMutileValueCell forIndexPath:indexPath];
        if (indexPath.row == 1) {
            cell.titleL.text = @"所在地 *";
            cell.valueF.text = [[self.locations valueForKey:@"name"] componentsJoinedByString:@" - "];
        }else{
            cell.titleL.text = @"选项";
            cell.valueF.text = self.option.name;
        }
        return cell;
    }
    else{
        ShopOrderTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ShopOrderTextFieldCell forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
            {
                cell.nameLabel.text = @"收货人 *";
                cell.textField.placeholder  = @"小王";
                cell.textField.text = self.receiverName;
                RAC(self, receiverName) = [cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal];
                break;
            }
            case 2:
            {
                cell.nameLabel.text = @"详细地址 *";
                cell.textField.placeholder  = @"街道地址";
                cell.textField.text = self.receiverAddress;
                RAC(self, receiverAddress) = [cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal];
                break;
            }
            case 3:
            {
                cell.nameLabel.text = @"联系电话 *";
                cell.textField.placeholder  = @"电话";
                cell.textField.text = self.receiverPhone;
                RAC(self, receiverPhone) = [cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal];
                break;
            }
            case 4:
            {
                cell.nameLabel.text = @"备注";
                cell.textField.placeholder  = @"备注信息如:衣服码数XXL";
                cell.textField.text = self.remark;
                RAC(self, remark) = [cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal];
                break;
            }
            default:
                break;
        }
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"填写并核对订单信息";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 || indexPath.row == 5) {
        return [ShopMutileValueCell cellHeight];
    }else{
        return [ShopOrderTextFieldCell cellHeight];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 42;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        [self goToLocationVC];
    }else if (indexPath.row == 5){
        NSArray *rows = [self.shopGoods.options valueForKey:@"name"];
        NSInteger index = self.option? [self.shopGoods.options indexOfObject:self.option]: 0;
        __weak typeof(self) weakSelf = self;
        [ActionSheetStringPicker showPickerWithTitle:nil rows:@[rows] initialSelection:@[@(index)] doneBlock:^(ActionSheetStringPicker *picker, NSArray *selectedIndex, NSArray *selectedValue) {
            NSInteger newIndex = [(NSNumber *)selectedIndex.firstObject integerValue];
            if (weakSelf.shopGoods.options.count > newIndex) {
                weakSelf.option = weakSelf.shopGoods.options[newIndex];
                [weakSelf.myTableView reloadData];
            }
        } cancelBlock:nil origin:self.view];
    }
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

#pragma mark location

- (void)goToLocationVC{
    LocationViewController *vc = [LocationViewController new];
    vc.originalSelectedList = [_locations valueForKey:@"id"];
    
    __weak typeof(self) weakSelf = self;
    vc.complateBlock = ^(NSArray *selectedList){
        weakSelf.locations = selectedList;
        [weakSelf.myTableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark-
#pragma mark---------------------- AlertView ---------------------------

- (void)showPwdAlertView
{
    UIAlertView *_pwdAlertView = [[UIAlertView alloc] initWithTitle:@"确认订单" message:@"请输入密码以确认兑换" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    _pwdAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [_pwdAlertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
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
            NSMutableDictionary *mparms = @{}.mutableCopy;
            mparms[@"receiverName"] = _receiverName;
            if (_locations.count >= 2) {
                mparms[@"province"] = _locations[0][@"id"];
                mparms[@"city"] = _locations[1][@"id"];
                mparms[@"district"] = _locations.count >= 3? _locations[2][@"id"]: nil;
            }else{
                mparms[@"province"] =
                mparms[@"city"] =
                mparms[@"district"] = nil;
            }
            if (self.option.id) {
                mparms[@"option_id"] = self.option.id;
            }

            mparms[@"receiverAddress"] = _receiverAddress;
            mparms[@"receiverPhone"] = _receiverPhone;
            mparms[@"remark"] = _remark;
            mparms[@"giftId"] = _shopGoods.id;
            mparms[@"password"] = [pwd sha1Str];

            [[Coding_NetAPIManager sharedManager] request_shop_exchangeWithParms:mparms andBlock:^(id data, NSError *error) {
                [weakSelf.view endLoading];
                if (!error) {
                    [NSObject showHudTipStr:@"恭喜你，提交订单成功!"];
                    ShopOrderViewController *orderViewController = [[ShopOrderViewController alloc] init];
                    [weakSelf.navigationController pushViewController:orderViewController animated:YES];
                    
                }
            }];
        }else{
            [weakSelf.view endLoading];
        }
    }];
}

- (void)dealloc
{
    _myTableView.dataSource  = nil;
    _myTableView.delegate = nil;
}

@end

