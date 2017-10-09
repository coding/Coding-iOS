//
//  ActivateViewController.m
//  Coding_iOS
//
//  Created by Ease on 16/2/18.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "ActivateViewController.h"
#import "Input_OnlyText_Cell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"

@interface ActivateViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) NSString *global_key;
@end

@implementation ActivateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置用户名";
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
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    headerV.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    headerLabel.textColor = kColor999;
    headerLabel.numberOfLines = 0;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"您还未设置过用户名（个性后缀）\n设置后才能正常登录！";
    [headerLabel setCenter:headerV.center];
    [headerV addSubview:headerLabel];
    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    //button
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"马上设置" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(sendActivate)];
    [footerV addSubview:_footerBtn];
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, global_key)] reduce:^id(NSString *global_key){
        return @(global_key.length > 0);
    }];
    return footerV;
}

- (void)sendActivate{
    [self.footerBtn startQueryAnimate];
    [[Coding_NetAPIManager sharedManager] request_ActivateBySetGlobal_key:_global_key block:^(id data, NSError *error) {
        [self.footerBtn stopQueryAnimate];
        if (data) {
            [Login setPreUserEmail:self.global_key];//记住登录账号
            [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
        }
    }];
}
#pragma matk Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    [cell setPlaceholder:@" 用户名（个性后缀）" value:self.global_key];
    cell.textValueChangedBlock = ^(NSString *valueStr){
        weakSelf.global_key = valueStr;
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}
@end
