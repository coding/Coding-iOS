//
//  TweetSendLocationViewController.m
//  Coding_iOS
//
//  Created by Kevin on 3/10/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendLocationViewController.h"
#import "TweetSendLocation.h"
#import "LocationHelper.h"
#import <CoreLocation/CoreLocation.h>
#import "TweetSendLocationCell.h"
#import "TweetSendViewController.h"
#import "TweetSendCreateLocationViewController.h"

@interface TweetSendLocationViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;

@property (nonatomic, strong) NSMutableArray *locationArray;
@property (nonatomic, strong) NSMutableArray *searchArray;

//locationFooterView不知为何不能重用，待验证
@property (nonatomic, strong) UIView *searchDisplayFooterView;
@property (nonatomic, strong) UIView *searchDisplayLoadingFooterView;

@property (nonatomic, strong) UIView *locationFooterView;
@property (nonatomic, strong) UIView *searchingFooterView;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *district;

@property (nonatomic, strong) NSString *searchingStr;

@property (nonatomic) NSInteger locationTotal;

@property (nonatomic, strong) NSString *selectedTitle;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic) CLLocationCoordinate2D bdCoordinate;

@property (nonatomic, strong) TweetSendLocationRequest *locationRequest;

@property (nonatomic, strong) TweetSendLocationRequest *searchingRequest;

@property (nonatomic, strong) TweetSendCreateLocation *locatioCreateRequest;

@property (nonatomic, strong) TweetSendCreateLocation *searchingCreateRequest;


@property (nonatomic) BOOL isRepeatRemoved;

@end

@implementation TweetSendLocationViewController

-(void)dealloc
{
    self.tableView.delegate = nil;
    self.mySearchDisplayController.delegate = nil;
    self.mySearchBar.delegate = nil;
    self.locationManager.delegate = nil;
}

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
    
    self.tableView.tableFooterView = self.searchingFooterView;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void)configLocationManager
{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {//iOS 8
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

- (void)configData
{
    if (self.responseData) {
        BOOL checked = NO;
        if (self.responseData.detailed) {
            checked = YES;
            NSMutableDictionary *dict = [self.responseData.detailed mutableCopy];
            [dict setValue:@"YES" forKey:@"checkmark"];
            [self.locationArray addObject:dict];
        }
        else if (self.responseData.cityName.length > 0) {
            NSString *result = @"NO";
            if (!checked) {
                result = @"YES";
            }
            [self.locationArray addObject:@{@"cityName":self.responseData.cityName,@"checkmark":result,@"cellType":@"defualt",@"location":@{@"lat":self.responseData.lat,@"lng":self.responseData.lng}}];
        }
    }
    else
    {
        self.locationArray[0] = @{@"title":@"不显示位置",@"cellType":@"defualt",@"checkmark":@"YES"};
    }
}

- (void)configSearchBar
{
    CGRect frame = self.tableView.bounds;
    frame.size.height = 44;
    self.mySearchBar = [[UISearchBar alloc]initWithFrame:frame];
    self.mySearchBar.delegate = self;
    self.mySearchBar.placeholder = @"搜索附近位置";
    self.mySearchBar.tintColor = [UIColor whiteColor];
    self.mySearchBar.userInteractionEnabled = NO;
    self.tableView.tableHeaderView = self.mySearchBar;
    
    self.mySearchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:self.mySearchBar contentsController:self];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    
}


#pragma mark - Orientations
- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark- property

- (NSMutableArray *)searchArray
{
    if (!_searchArray) {
        _searchArray = [@[@{@"nodata":@"YES"}] mutableCopy];
    }
    return _searchArray;
}

- (NSMutableArray *)locationArray
{
    if (!_locationArray) {
        _locationArray = [@[@{@"title":@"不显示位置",@"cellType":@"defualt"}] mutableCopy];
    }
    return _locationArray;
}

- (TweetSendLocationRequest *)locationRequest
{
    if (!_locationRequest) {
        _locationRequest = [[TweetSendLocationRequest alloc]init];
    }
    return _locationRequest;
}

- (TweetSendLocationRequest *)searchingRequest
{
    if (!_searchingRequest) {
        _searchingRequest = [[TweetSendLocationRequest alloc]init];
    }
    return _searchingRequest;
}

- (TweetSendCreateLocation *)locatioCreateRequest
{
    if (!_locatioCreateRequest) {
        _locatioCreateRequest = [[TweetSendCreateLocation alloc]init];
    }
    return _locatioCreateRequest;
}

- (TweetSendCreateLocation *)searchingCreateRequest
{
    if (!_searchingCreateRequest) {
        _searchingCreateRequest = [[TweetSendCreateLocation alloc]init];
    }
    return _searchingCreateRequest;
}

#pragma mark- LocationDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = (CLLocation *)[locations lastObject];
    self.bdCoordinate = [LocationHelper ggToBDEncrypt:self.location.coordinate];
    
//    测试位置
//    CLLocation *tempLocation = [[CLLocation alloc]initWithLatitude:31.21463 longitude:121.526068];
    
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
             weakSelf.district = placemark.subLocality;
             weakSelf.locationRequest.lat = [NSString stringWithFormat:@"%f",weakSelf.bdCoordinate .latitude];
             weakSelf.locationRequest.lng = [NSString stringWithFormat:@"%f",weakSelf.bdCoordinate .longitude];
             weakSelf.searchingRequest.lat = weakSelf.locationRequest.lat;
             weakSelf.searchingRequest.lng = weakSelf.locationRequest.lng;
             
             weakSelf.locatioCreateRequest.longitude = weakSelf.locationRequest.lng;
             weakSelf.locatioCreateRequest.latitude = weakSelf.locationRequest.lat;
             
             weakSelf.searchingCreateRequest.longitude = weakSelf.locationRequest.lng;
             weakSelf.searchingCreateRequest.latitude = weakSelf.locationRequest.lat;
             
             weakSelf.mySearchBar.userInteractionEnabled = YES;
             if (weakSelf.locationArray.count > 1) {
                 NSString *cityName = weakSelf.locationArray[1][@"cityName"];
                 NSString *checkmark = weakSelf.locationArray[1][@"checkmark"];
                 if (cityName.length > 0) {
                     [weakSelf.locationArray replaceObjectAtIndex:1 withObject:@{@"cityName":city,@"location":@{@"lat":weakSelf.locationRequest.lat,@"lng":weakSelf.locationRequest.lng},@"cellType":@"defualt",@"checkmark":checkmark}];
                 }else{
                     [weakSelf.locationArray insertObject:@{@"cityName":city,@"location":@{@"lat":weakSelf.locationRequest.lat,@"lng":weakSelf.locationRequest.lng},@"cellType":@"defualt",@"checkmark":@"NO"} atIndex:1];
                 }
             }else if(weakSelf.locationArray){
                 [weakSelf.locationArray insertObject:@{@"cityName":city,@"location":@{@"lat":weakSelf.locationRequest.lat,@"lng":weakSelf.locationRequest.lng},@"cellType":@"defualt",@"checkmark":@"NO"} atIndex:1];
             }
             
             [weakSelf.tableView reloadData];
             
             [weakSelf requestLocationWithObj:weakSelf.locationRequest];
             
             DebugLog(@"city = %@", city);
         }
         else if (error == nil && [array count] == 0)
         {
             DebugLog(@"No results were returned.");
         }
         else if (error != nil)
         {
             DebugLog(@"An error occurred = %@", error);
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
    self.tableView.tableFooterView = self.locationFooterView;

}

- (void)requestCustomerLocationWithObj:(TweetSendCreateLocation *)obj complete:(void(^)())block
{
    __weak typeof (self)weakSelf = self;
    [[TweetSendLocationClient sharedJsonClient] requestGeodataSearchCustomerWithParams:obj andBlock:^(id data, NSError *error) {
        
        DebugLog(@"obj:%@",data[@"contents"]);
        
        NSDictionary *dict = (NSDictionary *)data;
        
        if (error || [dict[@"status"] integerValue] != 0) {
            
            if (!self.isRepeatRemoved) {
                [self removeRepeat];
            }
            if (block) {
                block();
            }
            [weakSelf.tableView reloadData];

            return;
        }
        
        obj.page_index = @([obj.page_index integerValue] + 1);
        
        [weakSelf.locationArray addObjectsFromArray:dict[@"contents"]];

        if (!self.isRepeatRemoved) {
            [self removeRepeat];
        }
        if (block) {
            block();
        }
        [weakSelf.tableView reloadData];
    }];
}

- (void)requestSearchingCustomerLocationWithObj:(TweetSendCreateLocation *)obj  complete:(void(^)())block
{
    __weak typeof (self)weakSelf = self;
    [[TweetSendLocationClient sharedJsonClient] requestGeodataSearchCustomerWithParams:obj andBlock:^(id data, NSError *error) {

        DebugLog(@"obj:%@",data[@"contents"]);
        
        NSDictionary *dict = (NSDictionary *)data;
        
        if (error || [dict[@"status"] integerValue] != 0) {
            if (![self isContainTitle] && weakSelf.mySearchDisplayController.searchResultsTableView.tableFooterView != self.searchDisplayFooterView) {
                [weakSelf.searchArray addObject:@{@"notfound":@"YES"}];
            }
            if (block) {
                block();
            }
            [weakSelf.mySearchDisplayController.searchResultsTableView reloadData];
            
            return;
        }
        obj.page_index = @([obj.page_index integerValue] + 1);
        [weakSelf.searchArray addObjectsFromArray:dict[@"contents"]];
        if (block) {
            block();
        }
        if (![self isContainTitle] && weakSelf.mySearchDisplayController.searchResultsTableView.tableFooterView != self.searchDisplayFooterView) {
            [weakSelf.searchArray addObject:@{@"notfound":@"YES"}];
        }

        [weakSelf.mySearchDisplayController.searchResultsTableView reloadData];
    }];
}

- (void)requestSearchingWithObj:(TweetSendLocationRequest *)obj isAddMore:(BOOL)result
{
    __weak typeof (self)weakSelf = self;
    [[TweetSendLocationClient sharedJsonClient] requestPlaceAPIWithParams:obj andBlock:^(id data, NSError *error) {
        DebugLog(@"obj:%@",data[@"message"]);
        
        NSDictionary *dict = (NSDictionary *)data;
        
        if (error || [dict[@"status"] integerValue] != 0) {
            weakSelf.mySearchDisplayController.searchResultsTableView.tableFooterView = self.searchDisplayFooterView;
            
            if ([obj.page_num integerValue] > 1) {
                obj.page_num = @([obj.page_num integerValue] - 1);
            }
            return;
        }
        if (result) {
            [weakSelf.searchArray addObjectsFromArray: dict[@"results"]];
        }else {
            weakSelf.searchArray = [dict[@"results"] mutableCopy];
        }
        NSInteger total = [dict[@"total"] integerValue];

        weakSelf.searchingCreateRequest.query = weakSelf.searchingStr;

        [self requestSearchingCustomerLocationWithObj:weakSelf.searchingCreateRequest complete:^{
            //如果当前数据源总数和查询总数一致，则移除footerView
            if (total <= weakSelf.searchArray.count ) {
                weakSelf.mySearchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
                
            }else{
                weakSelf.mySearchDisplayController.searchResultsTableView.tableFooterView = self.searchDisplayFooterView;
            }
        }];
        
//        [weakSelf.mySearchDisplayController.searchResultsTableView reloadData];
    }];
}

- (void)requestLocationWithObj:(TweetSendLocationRequest *)obj
{
    __weak typeof (self)weakSelf = self;
    [[TweetSendLocationClient sharedJsonClient] requestPlaceAPIWithParams:obj andBlock:^(id data, NSError *error) {
        DebugLog(@"obj:%@",data[@"message"]);
        
        NSDictionary *dict = (NSDictionary *)data;
        
        if (error || [dict[@"status"] integerValue] != 0) {
            weakSelf.tableView.tableFooterView = self.locationFooterView;
            if ([obj.page_num integerValue] > 1) {
                obj.page_num = @([obj.page_num integerValue] - 1);
            }
            return;
        }
        [weakSelf.locationArray addObjectsFromArray:dict[@"results"]];
        weakSelf.locationTotal = [dict[@"total"] integerValue];
        
        [weakSelf requestCustomerLocationWithObj:weakSelf.locatioCreateRequest complete:^{
            //如果当前数据源总数和查询总数一致，则移除footerView
            if (weakSelf.locationTotal <= weakSelf.locationArray.count) {
                weakSelf.tableView.tableFooterView = [UIView new];
            }else{
                weakSelf.tableView.tableFooterView = self.locationFooterView;
            }
        }];
        
//        [weakSelf.tableView reloadData];
    }];
}

- (void)removeRepeat
{
    if (self.responseData.detailed){
        
        for(int i = 3; i< self.locationArray.count;i++){
            if ([self.locationArray[i][@"title"] isEqualToString:self.responseData.title] || [self.locationArray[i][@"name"] isEqualToString:self.responseData.title]) {
                [self.locationArray removeObjectAtIndex:i];
                self.isRepeatRemoved = YES;
                return;
            }
        }
    }
}

- (BOOL)isContainTitle
{
    BOOL result = NO;
    for (int i = 0; i < self.searchArray.count; i++) {

        result = [self.searchArray[i][@"title"] isEqualToString:self.searchingStr];
        
        if (result) {
            return YES;
        }
    }
    return result;
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


#pragma mark- SearchDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar insertBGColor:kColorNavBG];
    [self.mySearchDisplayController setActive:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [searchBar insertBGColor:nil];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length <= 0) {
        [self clearSearchingTableView];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchingStr = searchBar.text;
    self.searchingRequest.query = searchBar.text;
    self.searchingRequest.page_num = @(0);
    self.searchingCreateRequest.query = searchBar.text;
    self.searchingCreateRequest.page_index = @(0);
    [self requestSearchingWithObj:self.searchingRequest isAddMore:NO];
    
    [self.mySearchDisplayController.searchResultsTableView reloadData];
    self.mySearchDisplayController.searchResultsTableView.tableFooterView = self.searchDisplayLoadingFooterView;

}
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //iOS 7以上快速点击searchbar会造成searchbar消失，该操作解决该bug
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
    }
    [self clearSearchingTableView];
}

- (void)clearSearchingTableView
{
    self.searchingStr = @"";
    self.searchArray = nil;
    self.searchingRequest.tag = @"";
    self.mySearchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
    [self.mySearchDisplayController.searchResultsTableView reloadData];
}

- (UIView *)searchDisplayLoadingFooterView
{
    if (!_searchDisplayLoadingFooterView) {
        _searchDisplayLoadingFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 50)];
        _searchDisplayLoadingFooterView.backgroundColor = [UIColor clearColor];
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
        label.textColor = kColor222;
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.center = _searchDisplayLoadingFooterView.center;
        [_searchDisplayLoadingFooterView addSubview:label];
        
        CGPoint indicatorCenter = CGPointZero;
        indicatorCenter.x = CGRectGetMinX(label.frame) - 20;
        indicatorCenter.y = label.center.y;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = indicatorCenter;
        indicator.hidesWhenStopped = YES;
        [_searchDisplayLoadingFooterView addSubview:indicator];
        [indicator startAnimating];
        
        CGRect lineFrame = _searchDisplayLoadingFooterView.bounds;
        lineFrame.size.height = 0.5;
        
        UIView *topLine = [[UIView alloc]initWithFrame:lineFrame];
        topLine.backgroundColor = kColorDDD;
        
        lineFrame.origin.y = CGRectGetMaxY(_searchDisplayLoadingFooterView.bounds) - 0.5;
        UIView *bottomLine = [[UIView alloc]initWithFrame:lineFrame];
        bottomLine.backgroundColor = kColorDDD;
        
        [_searchDisplayLoadingFooterView addSubview:topLine];
        [_searchDisplayLoadingFooterView addSubview:bottomLine];
    }
    
    return _searchDisplayLoadingFooterView;
}

- (UIView *)searchDisplayFooterView
{
    if (!_searchDisplayFooterView) {
        _searchDisplayFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 50)];
        _searchDisplayFooterView.backgroundColor = [UIColor clearColor];
        NSString *str = @"查看更多的位置信息";
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:_searchDisplayFooterView.bounds];
        [btn setTitle:str forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [btn setTitleColor:kColor222 forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(locationFooterClick:) forControlEvents:UIControlEventTouchUpInside];
        [_searchDisplayFooterView addSubview:btn];
        
        CGRect lineFrame = _locationFooterView.bounds;
        lineFrame.size.height = 0.5;
        
        UIView *topLine = [[UIView alloc]initWithFrame:lineFrame];
        topLine.backgroundColor = kColorDDD;
        
        lineFrame.origin.y = CGRectGetMaxY(_searchDisplayFooterView.bounds) - 0.5;
        UIView *bottomLine = [[UIView alloc]initWithFrame:lineFrame];
        bottomLine.backgroundColor = kColorDDD;
        
        [_searchDisplayFooterView addSubview:topLine];
        [_searchDisplayFooterView addSubview:bottomLine];
    }
    
    return _searchDisplayFooterView;
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
        [btn setTitleColor:kColor222 forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(locationFooterClick:) forControlEvents:UIControlEventTouchUpInside];
        [_locationFooterView addSubview:btn];
        
        CGRect lineFrame = _locationFooterView.bounds;
        lineFrame.size.height = 0.5;
        
        UIView *topLine = [[UIView alloc]initWithFrame:lineFrame];
        topLine.backgroundColor = kColorDDD;
        
        lineFrame.origin.y = CGRectGetMaxY(_locationFooterView.bounds) - 0.5;
        UIView *bottomLine = [[UIView alloc]initWithFrame:lineFrame];
        bottomLine.backgroundColor = kColorDDD;
        
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
        label.textColor = kColor222;
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
        
        CGRect lineFrame = _searchingFooterView.bounds;
        lineFrame.size.height = 0.5;
        
        UIView *topLine = [[UIView alloc]initWithFrame:lineFrame];
        topLine.backgroundColor = kColorDDD;
        
        lineFrame.origin.y = CGRectGetMaxY(_searchingFooterView.bounds) - 0.5;
        UIView *bottomLine = [[UIView alloc]initWithFrame:lineFrame];
        bottomLine.backgroundColor = kColorDDD;
        
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
        
        if ([self.locationArray[indexPath.row][@"cellType"] isEqualToString:@"defualt"]) {
            CellIdentifier = DefaultCellIdentifier;
        }
        else{
            CellIdentifier = SubtitleCellIdentifier;
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //第一行，『不显示位置』
        if([self.locationArray[indexPath.row][@"cellType"] isEqualToString:@"defualt"] && cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = kColor222;
        }else if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.detailTextLabel.textColor = kColor999;
        }
        cell.tintColor = kColorBrandGreen;
        //如果为自定义数据
        if([self.locationArray[indexPath.row][@"cellType"] isEqualToString:@"defualt"])
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = self.locationArray[indexPath.row][@"title"];
                    cell.textLabel.textColor = kColorBrandGreen;
                    if ([self.locationArray[indexPath.row][@"checkmark"] isEqualToString:@"YES"]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    break;
                case 1:
                    cell.textLabel.text = self.locationArray[indexPath.row][@"cityName"];
                    if ([self.locationArray[indexPath.row][@"checkmark"] isEqualToString:@"YES"]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    break;
                default:
                    break;
            }
        }else {
            if ([self.locationArray[indexPath.row][@"checkmark"] isEqualToString:@"YES"]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            //判断是否为自定义数据
            if (self.locationArray[indexPath.row][@"user_id"]) {
                cell.textLabel.text = self.locationArray[indexPath.row][@"title"];
                cell.detailTextLabel.text = self.locationArray[indexPath.row][@"address"];
            }else{
                cell.textLabel.text = self.locationArray[indexPath.row][@"name"];
                cell.detailTextLabel.text = self.locationArray[indexPath.row][@"address"];
            }
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
    NSString *SearchDefaultCellIdentifier = @"SearchDefaultCellIdentifier";
    NSString *NotFoundCellIdentifier = @"NotFoundCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchDefaultCellIdentifier];
    //当没有数据时插入一条空数据进入，防止searchbar 在打字时显示 『无数据』
    if ([self.searchArray[indexPath.row][@"nodata"] isEqualToString:@"YES"]) {
        NSString *NodataCellIdentifier = @"NodataCellIdentifier";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NodataCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    else
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    //判断为最后一条数据时插入该特殊cell
    if ([self.searchArray[indexPath.row][@"notfound"] isEqualToString:@"YES"]) {
        
        TweetSendSearchingNotFoundCell *cell = [tableView dequeueReusableCellWithIdentifier:NotFoundCellIdentifier];
        
        if (cell == nil) {
            cell = [[TweetSendSearchingNotFoundCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NotFoundCellIdentifier];
        }
        cell.locationLabel.text = [NSString stringWithFormat:@"创建新的位置：%@",self.searchingStr];
        
        return cell;
    }
    //正常处理cell
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SearchDefaultCellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.detailTextLabel.textColor = kColor999;
    }
    
    //判断是否为自定义数据
    if (self.searchArray[indexPath.row][@"user_id"]) {
        cell.textLabel.text = self.searchArray[indexPath.row][@"title"];
        cell.detailTextLabel.text = self.searchArray[indexPath.row][@"address"];
    }else{
        cell.textLabel.text = self.searchArray[indexPath.row][@"name"];
        cell.detailTextLabel.text = self.searchArray[indexPath.row][@"address"];
    }

    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return  self.searchArray.count;
    }else {
        return self.locationArray.count;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    NSDictionary *dict = [NSDictionary new];
    
    if (tableView != self.tableView) {
        if ([self.searchArray[indexPath.row][@"notfound"] isEqualToString:@"YES"])
        {
            TweetSendLocationResponse *myObj = [[TweetSendLocationResponse alloc]init];
            myObj.cityName = self.cityName;
            if (self.district.length > 0) {
                myObj.region = self.district;
            }else{
                myObj.region = @"";
            }
            myObj.lat = self.locationRequest.lat;
            myObj.lng = self.locationRequest.lng;
            myObj.title = self.searchingStr;
            
            TweetSendCreateLocationViewController *createVC = [[TweetSendCreateLocationViewController alloc]initWithStyle:UITableViewStyleGrouped];
            createVC.locationResponse = myObj;
            [self.navigationController pushViewController:createVC animated:YES];
            
            return;
        }else{
            [self.mySearchDisplayController setActive:NO animated:YES];
            dict = self.searchArray[indexPath.row];
        }
    }
    else
    {
        dict = self.locationArray[indexPath.row];
    }

    TweetSendViewController *tweetVC = (TweetSendViewController *)((UINavigationController *)self.presentingViewController).topViewController;
    if (dict[@"user_id"]) {
        TweetSendLocationResponse *obj = [[TweetSendLocationResponse alloc]init];
        obj.cityName = self.cityName;
        obj.region = self.district;
        obj.title = dict[@"title"];
        obj.lat = dict[@"location"][1];
        obj.lng = dict[@"location"][0];
        obj.address = dict[@"address"];
        obj.detailed = dict;
        obj.isCustomLocaiton = YES;
        tweetVC.locationData = obj;
    }else if(dict[@"location"]){
        TweetSendLocationResponse *obj = [[TweetSendLocationResponse alloc]init];
        obj.cityName = self.cityName;
        obj.region = self.district;
        obj.title = dict[@"name"];
        obj.lat = dict[@"location"][@"lat"];
        obj.lng = dict[@"location"][@"lng"];
        obj.address = dict[@"address"];
        obj.detailed = dict;
        obj.isCustomLocaiton = NO;
        tweetVC.locationData = obj;
    }else{
        tweetVC.locationData = nil;
    }

    [self dismissSelf];
}

#pragma mark- UIScrollView Delegate


//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    // 下拉到最底部时显示更多数据
//    if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
//    {
//        [self locationFooterClick:nil];
//    }
//}

#pragma mark- Action

- (void)locationFooterClick:(id)sender
{
    if (self.mySearchDisplayController.active) {
        
        self.mySearchDisplayController.searchResultsTableView.tableFooterView = self.searchDisplayLoadingFooterView;
        self.searchingRequest.page_num = @([self.searchingRequest.page_num integerValue] + 1);
        [self requestSearchingWithObj:self.searchingRequest isAddMore:YES];
    }else {
        self.tableView.tableFooterView = self.searchingFooterView;
        self.locationRequest.page_num = @([self.locationRequest.page_num integerValue] + 1);
        [self requestLocationWithObj:self.locationRequest];
    }
}

@end
