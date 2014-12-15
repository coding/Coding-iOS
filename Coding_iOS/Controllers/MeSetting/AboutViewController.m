//
//  AboutViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-22.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (strong, nonatomic) UIImageView *logoView;
@property (strong, nonatomic) UILabel *logoLabel, *versionLabel, *infoLabel;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView{
    CGRect frame = [UIView frameWithOutNav];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.title = @"关于Coding";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    
    _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_about"]];
    [_logoView setCenter:CGPointMake(kScreen_Width/2, 36+CGRectGetMidY(_logoView.bounds))];
    [self.view addSubview:_logoView];
    
    _logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_logoView.frame), kScreen_Width, 30)];
    _logoLabel.backgroundColor = [UIColor clearColor];
    _logoLabel.font = [UIFont boldSystemFontOfSize:17];
    _logoLabel.textColor = [UIColor colorWithHexString:@"0x000000"];
    _logoLabel.textAlignment = NSTextAlignmentCenter;
    _logoLabel.text = @"coding-让开发更简单";
    [self.view addSubview:_logoLabel];
    
    _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_logoLabel.frame), kScreen_Width, 20)];
    _versionLabel.backgroundColor = [UIColor clearColor];
    _versionLabel.font = [UIFont systemFontOfSize:12];
    _versionLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    _versionLabel.textAlignment = NSTextAlignmentCenter;
    _versionLabel.text = [NSString stringWithFormat:@"版本：V%@", kVersion_Coding];
    [self.view addSubview:_versionLabel];
    
//    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, kScreen_Height-100, kScreen_Width, 100)];
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, kScreen_Height-180, kScreen_Width, 100)];
    _infoLabel.numberOfLines = 0;
    _infoLabel.backgroundColor = [UIColor clearColor];
    _infoLabel.font = [UIFont systemFontOfSize:12];
    _infoLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    _infoLabel.text = [NSString stringWithFormat:@"官网：https://coding.net \nE-mail：link@coding.net \n微博：Coding \n微信：扣钉Coding"];
    [self.view addSubview:_infoLabel];

}
@end
