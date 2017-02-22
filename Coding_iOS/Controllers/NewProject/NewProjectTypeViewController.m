//
//  NewProjectTypeViewController.m
//  Coding_iOS
//
//  Created by isaced on 15/3/30.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "NewProjectTypeViewController.h"

@interface NewProjectTypeViewController ()

@property (nonatomic, strong) NSIndexPath *checkedIndexPath;
@property (nonatomic, strong) UIView *helpView;

@end

@implementation NewProjectTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView setSeparatorColor:[UIColor colorWithRGBHex:0xe5e5e5]];
    self.tableView.backgroundColor = kColorTableSectionBg;

    // 添加右上角按钮
//    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
//    [submitButton addTarget:self action:@selector(showHelpView) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *submitButtonItem = [[UIBarButtonItem alloc] initWithCustomView:submitButton];
//    self.navigationItem.rightBarButtonItem = submitButtonItem;
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(showHelpView)] animated:NO];

}

-(void)showHelpView{
    if (!self.helpView) {
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        
        self.helpView = [[UIView alloc] initWithFrame:screenBounds];
        self.helpView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 80, CGRectGetWidth(screenBounds) - 36, 200)];
        textLabel.text = @"公开项目是完全公开的，包括源码，项目讨论，质量控制等，只有项目成员可以编辑该项目，但任何用户都可以进行 fork，关注，收藏等操作。\n私有项目只对项目成员可见，并不会公开展示于项目成员的个人页面上。只有项目创建者才能添加项目成员，项目的所有内容和更新都只有项目上的成员可以进行操作和查看。";
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont systemFontOfSize:15.0];
        textLabel.textColor = [UIColor whiteColor];
        [self.helpView addSubview:textLabel];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHelpView)];
        [self.helpView addGestureRecognizer:tapGestureRecognizer];
        
        self.helpView.alpha = 0;
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.helpView];
    
    // Animation
    [UIView animateWithDuration:0.3 animations:^{
        self.helpView.alpha = 1;
    }];
    
}

-(void)hideHelpView{
    
    // Animation
    [UIView animateWithDuration:0.3 animations:^{
        self.helpView.alpha = 0;
    }completion:^(BOOL finished) {
        [self.helpView removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSInteger row = indexPath.row;
    
    if (row == 0) {
        cell.textLabel.text = @"私有";
        
        if (self.projectType == NewProjectTypePrivate) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else{
        cell.textLabel.text = @"公开";
        
        if (self.projectType == NewProjectTypePublic) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat padding = kPaddingLeftWidth;
    cell.indentationLevel = 1;
    cell.indentationWidth = indexPath.row == 0? 0 : padding;
    cell.separatorInset = UIEdgeInsetsMake(0, indexPath.row == 0? padding: 0, 0, 0);

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
    
    // Checkmark
    if (self.checkedIndexPath){
        if ([self.checkedIndexPath isEqual:indexPath]) return;
        UITableViewCell *uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
        [uncheckCell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    self.checkedIndexPath = indexPath;
    
    
    // 回调
    NewProjectType type;
    
    if (indexPath.row == 0) {
        type = NewProjectTypePrivate;
    }else{
        type = NewProjectTypePublic;
    }
    
    [self.delegate newProjectType:self didSelectType:type];
    
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate{
    return UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
