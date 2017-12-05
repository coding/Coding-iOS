//
//  SettingViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "SettingViewController.h"
#import "TitleDisclosureCell.h"
#import "TitleValueMoreCell.h"
#import "Login.h"
#import "AppDelegate.h"
#import "SettingAccountViewController.h"

@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置";
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_TitleDisclosure];
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _myTableView.tableFooterView = [self tableFooterView];
}

- (UIView*)tableFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 90)];
    UIButton *loginBtn = [UIButton buttonWithStyle:StrapWarningStyle andTitle:@"退出" andFrame:CGRectMake(10, 0, kScreen_Width-10*2, 45) target:self action:@selector(loginOutBtnClicked:)];
    [loginBtn setCenter:footerV.center];
    [footerV addSubview:loginBtn];
    return footerV;
}

#pragma mark TableM

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleDisclosure forIndexPath:indexPath];
        [(TitleDisclosureCell *)cell setTitleStr:@"账号设置"];

    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
        [(TitleValueMoreCell *)cell setTitleStr:@"清除缓存" valueStr:[self p_diskCacheSizeStr]];
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    headerView.backgroundColor = kColorTableSectionBg;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        SettingAccountViewController *vc = [[SettingAccountViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        __weak typeof(self) weakSelf = self;
        [[UIActionSheet bk_actionSheetCustomWithTitle:@"缓存数据有助于再次浏览或离线查看，你确定要清除缓存吗？" buttonTitles:nil destructiveTitle:@"确定清除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf clearDiskCache];
            }
        }] showInView:self.view];
    }
}

#pragma mark - Action

- (void)loginOutBtnClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    [[UIActionSheet bk_actionSheetCustomWithTitle:@"确定要退出当前账号吗？" buttonTitles:nil destructiveTitle:@"确定退出" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [weakSelf loginOutToLoginVC];
        }
    }] showInView:self.view];
}

- (void)clearDiskCache{
    [NSObject showHUDQueryStr:@"正在清除缓存..."];
    [NSObject deleteResponseCache];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        [NSObject hideHUDQuery];
        [NSObject showHudTipStr:@"清除缓存成功"];
        [self.myTableView reloadData];
    }];
}

- (NSString *)p_diskCacheSizeStr{
    NSUInteger size = [[SDImageCache sharedImageCache] getSize];
    size += [NSObject getResponseCacheSize];
    return [NSString stringWithFormat:@"%.2f M", size/ 1024.0/ 1024.0];
}

@end
