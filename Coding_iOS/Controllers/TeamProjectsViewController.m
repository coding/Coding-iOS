//
//  TeamProjectsViewController.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TeamProjectsViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "ProjectListCell.h"
#import "NProjectViewController.h"
#import "Login.h"
#import <SDCAlertController.h>
#import <SDCAlertView.h>
#import <UIView+SDCAutoLayout.h>
#import "ProjectDeleteAlertControllerVisualStyle.h"

#import "Ease_2FA.h"

@interface TeamProjectsViewController ()<UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UITextFieldDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSArray *joinedList, *unjoinedList;
@property (strong, nonatomic) SDCAlertController *alert;

@end

@implementation TeamProjectsViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"项目管理";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ProjectListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectList];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)refresh{
    if (_joinedList.count + _unjoinedList.count <= 0) {
        [self.view beginLoading];
    }
    ESWeak(self, weakSelf);
    void (^requestFinishedBlock)(NSError *) = ^(NSError *error){
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.myTableView reloadData];
        [weakSelf.myTableView configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.joinedList.count + weakSelf.unjoinedList.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    };
    
    [[Coding_NetAPIManager sharedManager] request_ProjectsInTeam:_curTeam isJoined:YES andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.joinedList = data;
        }
        if ([weakSelf needToShowUnjoined]) {
            [[Coding_NetAPIManager sharedManager] request_ProjectsInTeam:weakSelf.curTeam isJoined:NO andBlock:^(id dataU, NSError *errorU) {
                if (dataU) {
                    weakSelf.unjoinedList = dataU;
                }
                requestFinishedBlock(errorU);
            }];
        }else{
            weakSelf.unjoinedList = nil;
            requestFinishedBlock(error);
        }
    }];
}

- (BOOL)needToShowUnjoined{
    return _curTeam.current_user_role_id.integerValue > 80;
}

#pragma mark Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self needToShowUnjoined]? 2: 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0? _joinedList.count > 0? 30: 0: _unjoinedList.count > 0? 30: 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [tableView getHeaderViewWithStr:section == 0? @"我参与的": @"我未参与的" andBlock:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0? _joinedList.count: _unjoinedList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectList forIndexPath:indexPath];
    Project *curPro = indexPath.section == 0? _joinedList[indexPath.row]: _unjoinedList[indexPath.row];
    [cell setProject:curPro hasSWButtons:NO hasBadgeTip:NO hasIndicator:NO];
    cell.hasDeleteBtn = YES;
    cell.delegate = self;
    cell.backgroundColor = kColorTableBG;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [NSObject showHudTipStr:@"无权进行此操作"];
        return;
    }
    Project *curPro = indexPath.section == 0? _joinedList[indexPath.row]: _unjoinedList[indexPath.row];
    NProjectViewController *vc = [NProjectViewController new];
    vc.myProject = curPro;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark SWTableViewCellDelegate

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    [cell hideUtilityButtonsAnimated:YES];
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    Project *curPro = indexPath.section == 0? _joinedList[indexPath.row]: _unjoinedList[indexPath.row];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_VerifyTypeWithBlock:^(VerifyType type, NSError *error) {
        if (!error) {
            [weakSelf showDeleteAlertWithType:type toDeletePro:curPro];
        }
    }];
}

- (void)showDeleteAlertWithType:(VerifyType)type toDeletePro:(Project *)toDeletePro{
    if (self.alert) {//正在显示
        return;
    }
    
    NSString *title, *message, *placeHolder;
    if (type == VerifyTypePassword) {
        title = @"需要密码验证";
        message = @"这是一个危险操作，需要进行身份验证";
        placeHolder = @"请输入密码";
    }else if (type == VerifyTypeTotp){
        title = @"需要动态验证码";
        message = @"这是一个危险操作，需要进行身份验证";
        placeHolder = @"请输入动态验证码";
    }else{//不知道啥类型，不处理
        return;
    }
    
    _alert = [SDCAlertController alertControllerWithTitle:title message:message preferredStyle:SDCAlertControllerStyleAlert];
    
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, 240.0, 30.0)];
    passwordTextField.font = [UIFont systemFontOfSize:13];
    passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    passwordTextField.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6].CGColor;
    passwordTextField.layer.borderWidth = 1;
    passwordTextField.secureTextEntry = (type == VerifyTypePassword);
    passwordTextField.backgroundColor = [UIColor whiteColor];
    passwordTextField.placeholder = placeHolder;
    if (type == VerifyTypeTotp) {
        passwordTextField.text = [OTPListViewController otpCodeWithGK:[Login curLoginUser].global_key];
    }
    passwordTextField.delegate = self;
    
    [_alert.contentView addSubview:passwordTextField];
    
    NSDictionary* passwordViews = NSDictionaryOfVariableBindings(passwordTextField);
    
    [_alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[passwordTextField]-(>=14)-|" options:0 metrics:nil views:passwordViews]];
    
    // Style
    _alert.visualStyle = [ProjectDeleteAlertControllerVisualStyle new];
    
    // 添加密码框
    //    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    //        textField.secureTextEntry = YES;
    //    }];
    
    // 添加按钮
    @weakify(self);
    _alert.actionLayout = SDCAlertControllerActionLayoutHorizontal;
    [_alert addAction:[SDCAlertAction actionWithTitle:@"取消" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        @strongify(self);
        self.alert = nil;
    }]];
    [_alert addAction:[SDCAlertAction actionWithTitle:@"确定" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        @strongify(self);
        self.alert = nil;
        NSString *passCode = passwordTextField.text;
        if ([passCode length] > 0) {
            // 删除项目
            [[Coding_NetAPIManager sharedManager] request_DeleteProject_WithObj:toDeletePro passCode:passCode type:type andBlock:^(Project *data, NSError *error) {
                @strongify(self);
                if (!error) {
                    [NSObject showHudTipStr:@"删除项目成功"];
                    [self refresh];
                }
            }];
        }
    }]];
    
    [_alert presentWithCompletion:^{
        [passwordTextField becomeFirstResponder];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
