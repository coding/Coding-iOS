//
//  TweetSendCreateLocationViewController.m
//  Coding_iOS
//
//  Created by Kevin on 3/15/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendCreateLocationViewController.h"
#import "TweetSendCreateLocationCell.h"
#import "TweetSendLocation.h"
#import "User.h"
#import "Login.h"
#import "TweetSendViewController.h"

@interface TweetSendCreateLocationViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) NSArray *datasorceArray;
@property (nonatomic,strong) User *myUser;
@end

@implementation TweetSendCreateLocationViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.datasorceArray = @[[@{@"title":@"位置名称",@"value":@""}mutableCopy]
                                ,[@{@"title":@"地区名称",@"value":@""}mutableCopy]
                                ,[@{@"title":@"详细地址",@"value":@""}mutableCopy]];
        self.view.backgroundColor = kColorTableSectionBg;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建位置";

     _myUser = [Login curLoginUser]? [Login curLoginUser]: [User userWithGlobalKey:@""];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"创建" style:UIBarButtonItemStylePlain target:self action:@selector(createLocaiton:)] animated:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLocationResponse:(TweetSendLocationResponse *)locationResponse
{
    _locationResponse = locationResponse;
    self.datasorceArray[0][@"value"] = locationResponse.title;
    self.datasorceArray[1][@"value"] = [self.locationResponse.cityName stringByAppendingFormat:@" %@",self.locationResponse.region];

}

- (void)createLocaiton:(id)sender {
    
    TweetSendCreateLocation *obj = [[TweetSendCreateLocation alloc]init];
    obj.title = self.datasorceArray[0][@"value"];
    
    obj.address = self.datasorceArray[2][@"value"];
    if (obj.address.length <= 0) {
        obj.address = [self.locationResponse.cityName stringByAppendingFormat:@",%@",self.locationResponse.region];
    }
    obj.user_id = self.myUser.id;
    obj.latitude = self.locationResponse.lat;
    obj.longitude = self.locationResponse.lng;

    __weak typeof (self)weakSelf = self;
    
    [[TweetSendLocationClient sharedJsonClient] requestGeodataCreateWithParams:obj andBlock:^(id data, NSError *error) {
        
        if (error) {

            return ;
        }
        DebugLog(@"obj:%@",data[@"message"]);
        
        NSDictionary *dict = (NSDictionary *)data;
        
        if ([dict[@"status"] integerValue] != 0) {

            return;
        }

        TweetSendViewController *tweetVC = (TweetSendViewController *)((UINavigationController *)self.presentingViewController).topViewController;
        weakSelf.locationResponse.title = obj.title;
        weakSelf.locationResponse.address = obj.address;
        weakSelf.locationResponse.isCustomLocaiton = YES;
        weakSelf.locationResponse.detailed = @{@"name":obj.title,@"location":@{@"lat":weakSelf.locationResponse.lat,@"lng":weakSelf.locationResponse.lng},@"address":obj.address};
        tweetVC.locationData = weakSelf.locationResponse;
        
        [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];

}

- (BOOL)checkTextEdit {
    
    return YES;
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.datasorceArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"reuseIdentifier";
    TweetSendCreateLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TweetSendCreateLocationCell" owner:self options:nil] firstObject];
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.editTextField addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventEditingChanged];
    }
    cell.titleLabel.text = self.datasorceArray[indexPath.row][@"title"];
    cell.editTextField.delegate = self;
    cell.editTextField.enabled = YES;
    cell.editTextField.text = self.datasorceArray[indexPath.row][@"value"];
    cell.editTextField.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.editTextField.placeholder = @"填写位置名称";
    }else if (indexPath.row == 1){
        cell.editTextField.enabled = NO;
//        cell.editTextField.textColor = [UIColor grayColor];
        cell.editTextField.font = [UIFont boldSystemFontOfSize:15.0];
    }else if (indexPath.row == 2){
        cell.editTextField.placeholder = @"街道门牌信息";
    }
    
    return cell;
}

- (void)changeValue:(id)sender
{
    UITextField *tf = (UITextField *)sender;
    NSInteger i = tf.tag;
    self.datasorceArray[i][@"value"] = tf.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

@end
