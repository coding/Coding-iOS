//
//  AboutViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-22.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "AboutViewController.h"
#import "TitleDisclosureCell.h"
#import "CodingShareView.h"

@interface AboutViewController ()<UITableViewDataSource, UITableViewDelegate>
@end

@implementation AboutViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColorTableSectionBg;
    self.title = @"关于我们";
    
    CGFloat logoViewTop, logoLabelTop, versionLabelTop, infoLabelBottom;
    NSString *icon_user_monkey;
    if (kDevice_Is_iPhone6Plus) {
        logoViewTop = 80;
        logoLabelTop = 40;
        versionLabelTop = 35;
        infoLabelBottom = 35;
        icon_user_monkey = @"icon_user_monkey_i6p";
    }else if (kDevice_Is_iPhone6){
        logoViewTop = 65;
        logoLabelTop = 25;
        versionLabelTop = 20;
        infoLabelBottom = 20;
        icon_user_monkey = @"icon_user_monkey_i6";
    }else{
        logoViewTop = 40;
        logoLabelTop = 20;
        versionLabelTop = 20;
        infoLabelBottom = 20;
        icon_user_monkey = @"icon_user_monkey";
    }
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon_user_monkey]];
    [self.view addSubview:logoView];
    
    UILabel *logoLabel = [[UILabel alloc] init];
    logoLabel.font = [UIFont boldSystemFontOfSize:17];
    logoLabel.textColor = kColor222;
    logoLabel.textAlignment = NSTextAlignmentCenter;
    logoLabel.text = @"Coding-让开发更简单";
    [self.view addSubview:logoLabel];
    
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.font = [UIFont systemFontOfSize:12];
    versionLabel.textColor = kColor666;
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.text = [NSString stringWithFormat:@"版本：V%@", kVersionBuild_Coding];
    [self.view addSubview:versionLabel];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.numberOfLines = 0;
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.textColor = kColor666;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.text = [NSString stringWithFormat:@"官网：https://coding.net \nE-mail：link@coding.net \n微博：Coding \n微信：扣钉Coding"];
    [self.view addSubview:infoLabel];
    
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(logoViewTop);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [logoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoView.mas_bottom).offset(logoLabelTop);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(logoLabel.font.pointSize);
    }];
    
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoLabel.mas_bottom).offset(versionLabelTop);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(versionLabel.font.pointSize);
    }];
    
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-infoLabelBottom);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(5*infoLabel.font.pointSize);
    }];

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.scrollEnabled = NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[TitleDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_TitleDisclosure];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(versionLabel.mas_bottom).offset(44);
    }];
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TitleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleDisclosure forIndexPath:indexPath];
    [cell setTitleStr:indexPath.row == 0? @"去评分": @"推荐 Coding"];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {//评分
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppReviewURL]];
    }else{//推荐 Coding
        [CodingShareView showShareViewWithObj:nil];
    }
}

@end
