//
//  TweetSendLocationViewController.m
//  Coding_iOS
//
//  Created by Kevin on 3/10/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendLocationViewController.h"
#import "TweetSendLocation.h"
#import <CoreLocation/CoreLocation.h>

@interface TweetSendLocationViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;

@property (nonatomic, strong) NSMutableArray *locationArray;
@property (nonatomic, strong) NSArray *searchArray;

@property (nonatomic, strong) UIView *locationFooterView;
@property (nonatomic, strong) UIView *searchingFooterView;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSString *cityName;

@property (nonatomic) NSInteger locationTotal;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) TweetSendLocationRequest *locationRequest;

@end

@implementation TweetSendLocationViewController

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
    
    self.title = @"所在位置";
    
    [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(cancelBtnClicked:)] animated:YES];
    [self configLocationManager];
    [self configData];
    [self configSearchBar];
    
    self.tableView.tableFooterView = self.locationFooterView;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingHeading];
}

- (void)configLocationManager
{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100;
    [self.locationManager requestAlwaysAuthorization];//iOS 8 添加这句
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingHeading];
}

- (void)configData
{
    self.locationArray = [NSMutableArray new];
//    self.locationArray = @[@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""];
    self.searchArray = [NSArray new];
}

- (void)configSearchBar
{
    CGRect frame = self.tableView.bounds;
    frame.size.height = 44;
    self.mySearchBar = [[UISearchBar alloc]initWithFrame:frame];
    self.mySearchBar.delegate = self;
    self.mySearchBar.placeholder = @"搜索附近位置";
    self.mySearchBar.tintColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.mySearchBar;
    
    self.mySearchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:self.mySearchBar contentsController:self];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    
}

#pragma mark- property

- (TweetSendLocationRequest *)locationRequest
{
    if (!_locationRequest) {
        _locationRequest= [[TweetSendLocationRequest alloc]init];
    }
    return _locationRequest;
}


#pragma mark- LocationDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = (CLLocation *)[locations lastObject];

    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    __weak typeof (self)weakSelf = self;
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             //获取城市
             NSString *city = placemark.locality;
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             weakSelf.cityName = city;
             [weakSelf.tableView reloadData];
             
             weakSelf.locationRequest.lat = [NSString stringWithFormat:@"%f",weakSelf.location.coordinate.latitude];
             weakSelf.locationRequest.lng = [NSString stringWithFormat:@"%f",weakSelf.location.coordinate.longitude];
             
             [weakSelf requestWithObj:weakSelf.locationRequest];
             
             NSLog(@"city = %@", city);
         }
         else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }
         else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
        //访问被拒绝
    }
    if ([error code] == kCLErrorLocationUnknown) {
        //无法获取位置信息
    }
}

- (void)requestWithObj:(TweetSendLocationRequest *)obj
{
    __weak typeof (self)weakSelf = self;
    [[TweetSendLocationClient sharedJsonClient] requestPlaceAPIWithParams:obj andBlock:^(id data, NSError *error) {
        NSDictionary *dict = (NSDictionary *)data;
        [weakSelf.locationArray addObjectsFromArray:dict[@"results"]];
        weakSelf.locationTotal = [dict[@"total"] integerValue];
        //如果当前数据源总数和查询总数一致，则移除footerView
        if (weakSelf.locationTotal <= weakSelf.locationArray.count) {
            weakSelf.tableView.tableFooterView = nil;
        }else{
            weakSelf.tableView.tableFooterView = self.locationFooterView;
        }
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark Nav Btn M
- (void)cancelBtnClicked:(id)sender{
    [self dismissSelf];
}

- (void)dismissSelf{
//    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
//        [self.view endEditing:YES];
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}

- (void)dealloc
{

}

#pragma mark- SearchDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.mySearchDisplayController setActive:YES animated:YES];
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"clcik");
}


- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"clcik");
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{

}
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{

}
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{

}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return NO;
}


- (UIView *)locationFooterView
{
    if (!_locationFooterView) {
        _locationFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 50)];
        _locationFooterView.backgroundColor = [UIColor clearColor];
        NSString *str = @"查看更多的位置信息";
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:_locationFooterView.bounds];
        [btn setTitle:str forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [btn setTitleColor:[UIColor colorWithHexString:@"0x222222"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(locationFooterClick:) forControlEvents:UIControlEventTouchUpInside];
        [_locationFooterView addSubview:btn];
        
        CGRect lineFrame = _locationFooterView.bounds;
        lineFrame.size.height = 0.5;
        
        UIView *topLine = [[UIView alloc]initWithFrame:lineFrame];
        topLine.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        
        lineFrame.origin.y = CGRectGetMaxY(_locationFooterView.bounds) - 0.5;
        UIView *bottomLine = [[UIView alloc]initWithFrame:lineFrame];
        bottomLine.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        
        [_locationFooterView addSubview:topLine];
        [_locationFooterView addSubview:bottomLine];
    }
    
    return _locationFooterView;
}

- (UIView *)searchingFooterView
{
    if (!_searchingFooterView) {
        _searchingFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 50)];
        _searchingFooterView.backgroundColor = [UIColor clearColor];
        NSString *str = @"正在搜索附近的位置";
        UIFont *font = [UIFont systemFontOfSize:14.0];
        CGSize size = CGSizeMake(CGFLOAT_MAX, 50);
        CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:font.fontName size:font.pointSize]} context:nil];
        
        CGRect buttonFrame = CGRectZero;
        buttonFrame.size.height = CGRectGetHeight(rect);
        buttonFrame.size.width = CGRectGetWidth(rect);

        UILabel *label = [[UILabel alloc]initWithFrame:buttonFrame];
        label.backgroundColor = [UIColor clearColor];
        label.text = str;
        label.font = font;
        label.textColor = [UIColor colorWithHexString:@"0x222222"];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.center = _searchingFooterView.center;
        [_searchingFooterView addSubview:label];
        
        CGPoint indicatorCenter = CGPointZero;
        indicatorCenter.x = CGRectGetMinX(label.frame) - 20;
        indicatorCenter.y = label.center.y;

        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = indicatorCenter;
        indicator.hidesWhenStopped = YES;
        [_searchingFooterView addSubview:indicator];
        [indicator startAnimating];
        
        CGRect lineFrame = _locationFooterView.bounds;
        lineFrame.size.height = 0.5;
        
        UIView *topLine = [[UIView alloc]initWithFrame:lineFrame];
        topLine.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        
        lineFrame.origin.y = CGRectGetMaxY(_searchingFooterView.bounds) - 0.5;
        UIView *bottomLine = [[UIView alloc]initWithFrame:lineFrame];
        bottomLine.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        
        [_searchingFooterView addSubview:topLine];
        [_searchingFooterView addSubview:bottomLine];
    }
    
    return _searchingFooterView;
}

#pragma mark- tableviewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        NSString *DefaultCellIdentifier = @"DefaultTableIdentifier";
        NSString *SubtitleCellIdentifier = @"SubtitleTableIdentifier";
        
        NSString *CellIdentifier = @"";
        
        if (indexPath.row == 0 || indexPath.row == 1) {
            CellIdentifier = DefaultCellIdentifier;
        }
        else{
            CellIdentifier = SubtitleCellIdentifier;
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                 CellIdentifier];
        //第一行，『不显示位置』
        if((indexPath.row == 0  || indexPath.row == 1) && cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        }else if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"不显示位置";
            cell.textLabel.textColor = [UIColor colorWithHexString:@"0x3bbd79"];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.tintColor = [UIColor colorWithHexString:@"0x3bbd79"];
        }else if (indexPath.row == 1) {
            cell.textLabel.text = self.cityName;
        }else {
            cell.textLabel.text = self.locationArray[indexPath.row - 2][@"name"];
            cell.detailTextLabel.text = self.locationArray[indexPath.row - 2][@"address"];
        }
        
        return cell;
    }
    else
    {
        return [self searchResultTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
}

- (UITableViewCell *)searchResultTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = @"Search Controller";
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return  10 ;//self.searchArray.count;
    }
    else
    {
        if (self.cityName.length <= 0) {
            return 1;
        }
        
        return 2 + self.locationArray.count;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    if (tableView != self.tableView) {
        [self.mySearchDisplayController setActive:NO animated:YES];
    }
    
}

#pragma mark- Action

- (void)locationFooterClick:(id)sender
{
    self.tableView.tableFooterView = self.searchingFooterView;
    
    self.locationRequest.page_num = @([self.locationRequest.page_num integerValue] + 1);
    [self requestWithObj:self.locationRequest];
}

@end
