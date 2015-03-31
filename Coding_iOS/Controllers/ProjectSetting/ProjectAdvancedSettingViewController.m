//
//  ProjectAdvancedSettingViewController.m
//  Coding_iOS
//
//  Created by isaced on 15/3/31.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectAdvancedSettingViewController.h"
#import "Coding_NetAPIManager.h"

@interface ProjectAdvancedSettingViewController ()<UIAlertViewDelegate>

@end

@implementation ProjectAdvancedSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
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

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"需要验证密码" message:@"这是一个危险的操作，请提供登录密码确认！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // 确定
        NSString *password = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (password > 0) {
            // 删除项目
            [[Coding_NetAPIManager sharedManager] request_DeleteProject_WithObj:self.project password:password andBlock:^(Project *data, NSError *error) {
                if (!error) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                
            }];
        }
    }
}

@end
