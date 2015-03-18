//
//  TweetSendLocationDetailViewController.m
//  Coding_iOS
//
//  Created by Kevin on 3/15/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendLocationDetailViewController.h"
#import "TweetSendLocation.h"
#import "TweetSendLocaitonMapViewController.h"
#import "Tweets.h"

@interface TweetSendLocationDetailViewController ()

@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UILabel *headerLabel;
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) UILabel *footerLabel;

@end

@implementation TweetSendLocationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    self.view.backgroundColor = [UIColor colorWithRGBHex:0xF0F0F2];
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)headerView
{
    if (!_headerView) {
        CGRect frame = self.view.bounds;
        frame.size.height = 50;
        _headerView = [[UIView alloc]initWithFrame:frame];
        _headerView.backgroundColor = [UIColor clearColor];
        self.headerLabel = [[UILabel alloc] initWithFrame:_headerView.bounds];
        self.headerLabel.textAlignment = NSTextAlignmentCenter;
        self.headerLabel.font = [UIFont systemFontOfSize:16.0];
        self.headerLabel.text = self.tweet.location;
        [_headerView addSubview:self.headerLabel];
    }
    return _headerView;
}

- (UIView *)footerView
{
    if (!_footerView) {
        CGRect frame = self.view.bounds;
        frame.size.height = 44;
        _footerView = [[UIView alloc]initWithFrame:frame];
        _footerView.backgroundColor = [UIColor clearColor];
        self.footerLabel = [[UILabel alloc] initWithFrame:_footerView.bounds];
        self.footerLabel.textAlignment = NSTextAlignmentCenter;
        self.footerLabel.font = [UIFont systemFontOfSize:14.0];
        self.footerLabel.text = @"";
        
//      暂不显示
//        if (self.) {
//            self.footerLabel.text = @"此地点为用户创建";
//        } else {
//            self.footerLabel.text = @"";
//        }
        
        [_footerView addSubview:self.footerLabel];
    }
    return _footerView;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    }
    cell.textLabel.text = @"位置";
    
    cell.detailTextLabel.text = self.tweet.address;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    TweetSendLocaitonMapViewController *mapVC = [[TweetSendLocaitonMapViewController alloc]init];
    mapVC.tweet = self.tweet;
    [self.navigationController pushViewController:mapVC animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
