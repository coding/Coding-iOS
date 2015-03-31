//
//  ProjectSettingViewController.m
//  Coding_iOS
//
//  Created by isaced on 15/3/31.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectSettingViewController.h"
#import "Projects.h"
#import "UIImageView+WebCache.h"

@interface ProjectSettingViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *submitButtonItem;

@end

@implementation ProjectSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    self.tableView.tableFooterView = [UIView new];
    
    self.projectNameTextField.text = self.project.name;
    //
    self.descTextView.placeholder = @"填写项目描述...";
    self.descTextView.text = self.project.description_mine;
    self.descTextView.delegate = self;
    
    //
    self.projectImageView.layer.cornerRadius = 5;
    [self.projectImageView sd_setImageWithURL:[self.project.icon urlImageWithCodePathResizeToView:self.projectImageView]];
    
    // 添加 “完成” 按钮
    self.submitButtonItem = [UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(submit)];
    self.submitButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.submitButtonItem;
    
}

-(void)submit{

}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if ([string isEqualToString:self.project.description_mine]) {
        self.submitButtonItem.enabled = NO;
    }else{
        self.submitButtonItem.enabled = YES;
    }
    
    return YES;
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
    //
    if (indexPath.section == 0 && indexPath.row == 0) {
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *vc = segue.destinationViewController;
//    [vc setValue:nil forKey:@""];
}

@end
