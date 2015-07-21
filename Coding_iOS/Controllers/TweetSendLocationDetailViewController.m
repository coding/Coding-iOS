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
#import "TweetSendDetailLoctionCell.h"

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
    self.view.backgroundColor = kColorTableSectionBg;
    
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
        _headerView = [[UIView alloc]initWithFrame:self.view.bounds];
        UIFont *font = [UIFont boldSystemFontOfSize:17.0];
        NSArray *array = [self.tweet.location componentsSeparatedByString:@"·"];
        NSString *address = self.tweet.location;
        if (array.count == 2) {
            address = array[1];
        }
        CGSize size = CGSizeMake(CGRectGetWidth(self.view.bounds)- 44, CGFLOAT_MAX);
        CGRect rect = [address boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:font.fontName size:font.pointSize]} context:nil];
        CGRect viewFrame = _headerView.frame;
        viewFrame.size.height = CGRectGetHeight(rect) + 30;
        
        [_headerView setFrame:viewFrame];
        
        _headerView.backgroundColor = [UIColor clearColor];
        viewFrame.origin.y = 15;
        viewFrame.size.height = viewFrame.size.height - 30;
        viewFrame.origin.x = 22;
        viewFrame.size.width = viewFrame.size.width -44;
        self.headerLabel = [[UILabel alloc] initWithFrame:viewFrame];
        self.headerLabel.textAlignment = NSTextAlignmentCenter;
        self.headerLabel.font = font;
        self.headerLabel.numberOfLines = 0;
        self.headerLabel.text = address;
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
        self.footerLabel.font = [UIFont systemFontOfSize:12.0];
        self.footerLabel.text = @"";
        self.footerLabel.textColor = [UIColor colorWithRGBHex:0x888888];
        
        NSArray *array = [self.tweet.coord componentsSeparatedByString:@","];
        NSString *isCustomerCreate = @"0";
        if (array.count == 3) {
            isCustomerCreate = array[2];
        }
        if ([isCustomerCreate isEqualToString:@"1"]) {
            self.footerLabel.text = @"此地点为用户创建";
        } else {
            self.footerLabel.text = @"";
        }
        [_footerView addSubview:self.footerLabel];
    }
    return _footerView;
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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
    TweetSendDetailLoctionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TweetSendDetailLoctionCell" owner:self options:nil] firstObject];
    }
    cell.addressLabel.text = self.tweet.address;
    
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
