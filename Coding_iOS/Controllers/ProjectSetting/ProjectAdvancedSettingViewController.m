//
//  ProjectAdvancedSettingViewController.m
//  Coding_iOS
//
//  Created by isaced on 15/3/31.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectAdvancedSettingViewController.h"
#import "Coding_NetAPIManager.h"

#import <SDCAlertController.h>
#import <SDCAlertView.h>
#import <UIView+SDCAutoLayout.h>
#import "ProjectDeleteAlertControllerVisualStyle.h"

@interface ProjectAdvancedSettingViewController ()

@end

@implementation ProjectAdvancedSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (NSLayoutConstraint *cons in self.lines) {
        cons.constant = 0.5;
    }
    
    self.title = @"高级设置";
    self.tableView.tableFooterView = [UIView new];
    [self.tableView setSeparatorColor:[UIColor colorWithRGBHex:0xe5e5e5]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITableView

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
        return;
    }
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    static NSString *title = @"需要验证密码";
    static NSString *message = @"这是一个危险的操作，请提供登录密码确认！";
    
    SDCAlertController *alert = [SDCAlertController alertControllerWithTitle:title message:message preferredStyle:SDCAlertControllerStyleAlert];
    
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, 240.0, 30.0)];
    passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    passwordTextField.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6].CGColor;
    passwordTextField.layer.borderWidth = 1;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.backgroundColor = [UIColor whiteColor];
    
    [alert.contentView addSubview:passwordTextField];
    
    NSDictionary* passwordViews = NSDictionaryOfVariableBindings(passwordTextField);
    
    [alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[passwordTextField]-(>=14)-|" options:0 metrics:nil views:passwordViews]];
    
    [passwordTextField becomeFirstResponder];
    
    // Style
    alert.visualStyle = [ProjectDeleteAlertControllerVisualStyle new];
    
    // 添加密码框
//    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.secureTextEntry = YES;
//    }];
    
    // 添加按钮
    alert.actionLayout = SDCAlertControllerActionLayoutHorizontal;
    [alert addAction:[SDCAlertAction actionWithTitle:@"取消" style:SDCAlertActionStyleDefault handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"确定" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        
        NSString *password = [passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([password length] > 0) {
            // 删除项目
            [[Coding_NetAPIManager sharedManager] request_DeleteProject_WithObj:self.project password:password andBlock:^(Project *data, NSError *error) {
                if (!error) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                
            }];
        }
    }]];

    [alert presentWithCompletion:nil];
}

@end
