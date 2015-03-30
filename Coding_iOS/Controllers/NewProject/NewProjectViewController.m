//
//  NewProjectViewController.m
//  Coding_iOS
//
//  Created by isaced on 15/3/30.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "NewProjectViewController.h"
#import "NewProjectTypeViewController.h"

@interface NewProjectViewController ()<NewProjectTypeDelegate>

@property (nonatomic, assign) NewProjectType projectType;

@end

@implementation NewProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    self.tableView.tableFooterView = [UIView new];
    
    //
    self.descTextView.placeholder = @"填写项目描述...";
    
    //
    self.projectImageView.layer.cornerRadius = 5;
    self.projectImageView.image = [UIImage imageNamed:@"AppIcon120x120"];
    
    // 添加 “完成” 按钮
    UIBarButtonItem *submitButtonItem = [UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(submit)];
    self.navigationItem.rightBarButtonItem = submitButtonItem;
    
    // 默认类型
    self.projectType = NewProjectTypePrivate;
}

-(void)submit{

    NSString *projectName = [self.projectNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([projectName length] < 2 || [projectName length] > 31) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入2 ~ 31位以内的项目名称" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil] show];
    }else{
        if ([self projectNameVerification:projectName]) {
            
            // 效验完成，开始发送请求创建项目
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"项目名只允许字母、数字或者下划线(_)、中划线(-)，必须以字母或者数字开头,且不能以.git结尾" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil] show];
        }
    }

}

-(BOOL)projectNameVerification:(NSString *)projectName{
    NSString * regex = @"^[a-zA-Z0-9][a-zA-Z0-9_-]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:projectName];
    return isMatch;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == 0) {
        // 类型
        NewProjectTypeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NewProjectTypeVC"];
        vc.projectType = self.projectType;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark NewProjectTypeViewController Delegate

-(void)newProjectType:(NewProjectTypeViewController *)newProjectVC didSelectType:(NewProjectType)type{
    [newProjectVC.navigationController popViewControllerAnimated:YES];
    
    //
    self.projectType = type;
    
    if (self.projectType == NewProjectTypePublic) {
        self.projectTypeLabel.text = @"公开";
    }else{
        self.projectTypeLabel.text = @"私有";
    }
}

@end
