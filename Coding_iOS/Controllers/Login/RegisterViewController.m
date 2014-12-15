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

#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"
#import "UIUnderlinedButton.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"注册";
    self.tableView.tableFooterView=[self customFooterView];
    self.tableView.tableHeaderView = [self customHeaderView];
    self.tableView.backgroundView = nil;
    self.myRegister = [[Register alloc] init];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MailCellIdentifier = @"Input_LeftImgage_Cell";
    static NSString *KeyCellIdentifier = @"Input_GlobalKey_Cell";

    
    if (indexPath.section == 0) {
        Input_LeftImgage_Cell *cell = [tableView dequeueReusableCellWithIdentifier:MailCellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"Input_LeftImgage_Cell" owner:self options:nil] firstObject];
        }
        [cell configWithImgName:@"login_email" andPlaceholder:@"电子邮箱" andValue:self.myRegister.email];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            self.myRegister.email = valueStr;
        };
        return cell;
    }else{
        Input_GlobalKey_Cell *cell = [tableView dequeueReusableCellWithIdentifier:KeyCellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"Input_GlobalKey_Cell" owner:self options:nil] firstObject];
        }
        [cell configWithImgName:@"login_suffix" andPlaceholder:@"个性后缀" andValue:self.myRegister.global_key];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            self.myRegister.global_key = valueStr;
        };
        return cell;
    }
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 80)];
    headerV.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:18];
    headerLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"加入Coding，体验云端开发之美！";
    [headerLabel setCenter:headerV.center];
    [headerV addSubview:headerLabel];
    
    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 100)];
    UIButton *registerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"立即体验" andFrame:CGRectMake(kPaddingLeftWidth, 0, kScreen_Width-kPaddingLeftWidth*2, 45) target:self action:@selector(sendRegister)];
    [footerV addSubview:registerBtn];
    
    UIUnderlinedButton *activateBtn = [UIUnderlinedButton buttonWithTitle:@"已经注册？重发激活邮件" andFont:[UIFont systemFontOfSize:14] andColor:[UIColor colorWithRed:66/255.0 green:139/255.0 blue:202/255.0 alpha:1]];
    CGRect frame = activateBtn.frame;
    frame.origin.y = 50;
    frame.origin.x = (kScreen_Width -frame.size.width)/2;
    activateBtn.frame = frame;
    [activateBtn addTarget:self action:@selector(reActivate) forControlEvents:UIControlEventTouchUpInside];
    [footerV addSubview:activateBtn];
    return footerV;
}

#pragma mark Btn Clicked
- (void)sendRegister{
    [[Coding_NetAPIManager sharedManager] request_Register_WithParams:[self.myRegister toParams] andBlock:^(id data, NSError *error) {
        if (data) {
            [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
        }
    }];
}

- (void)reActivate{
    DebugLog(@"reActivate");
}


@end
