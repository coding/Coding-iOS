//
//  AboutViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-22.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColorTableSectionBg;
    self.title = @"关于Coding";
    
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
    logoLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    logoLabel.text = @"Coding-让开发更简单";
    [self.view addSubview:logoLabel];
    
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.font = [UIFont systemFontOfSize:12];
    versionLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.text = [NSString stringWithFormat:@"版本：V%@", kVersionBuild_Coding];
    [self.view addSubview:versionLabel];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.numberOfLines = 0;
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
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
    
    
    
    
//    UILabel *infoLabel1 = [[UILabel alloc] init];
//    infoLabel1.numberOfLines = 0;
//    infoLabel1.backgroundColor = [UIColor clearColor];
//    infoLabel1.font = [UIFont systemFontOfSize:12];
//    infoLabel1.textColor = [UIColor colorWithHexString:@"0x666666"];
//    infoLabel1.textAlignment = NSTextAlignmentRight;
//    infoLabel1.text = [NSString stringWithFormat:@"官网：\nE-mail：\n微博：\n微信："];
//    [self.view addSubview:infoLabel1];
//
//    UILabel *infoLabel2 = [[UILabel alloc] init];
//    infoLabel2.numberOfLines = 0;
//    infoLabel2.backgroundColor = [UIColor clearColor];
//    infoLabel2.font = [UIFont systemFontOfSize:12];
//    infoLabel2.textColor = [UIColor colorWithHexString:@"0x666666"];
//    infoLabel2.textAlignment = NSTextAlignmentLeft;
//    infoLabel2.text = [NSString stringWithFormat:@"https://coding.net \nlink@coding.net \nCoding \n扣钉Coding"];
//    [self.view addSubview:infoLabel2];


//    UILabel *copyrightLabel = [[UILabel alloc] init];
//    copyrightLabel.font = [UIFont systemFontOfSize:12];
//    copyrightLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
//    copyrightLabel.textAlignment = NSTextAlignmentCenter;
//    copyrightLabel.text = [NSString stringWithFormat:@"Copyright © 2015 Coding.net"];
//    [self.view addSubview:copyrightLabel];

//    [infoLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(copyrightLabel.mas_top).offset(-20);
//        make.left.mas_equalTo(self.view.mas_left);
//        make.right.equalTo(self.view.mas_centerX).offset(-20);
//        make.height.mas_equalTo(60);
//    }];
//
//    [infoLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(copyrightLabel.mas_top).offset(-20);
//        make.left.mas_equalTo(infoLabel1.mas_right);
//        make.right.equalTo(self.view.mas_right);
//        make.height.mas_equalTo(60);
//    }];

//    [copyrightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
//        make.left.right.equalTo(self.view);
//        make.height.mas_equalTo(20);
//    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
