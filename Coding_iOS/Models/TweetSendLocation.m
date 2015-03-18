//
//  TweetSendLocation.m
//  Coding_iOS
//
//  Created by Kevin on 3/11/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendLocation.h"
#import "Login.h"
#import "User.h"

NSString * const kBaiduGeotableId= @"95955";
NSString * const kBaiduAK = @"9d1fee393e06554e155f797dc71d00f0";

NSString * const kBaiduAPIPlacePath = @"place/v2/search";
NSString * const kBaiduAPIGeosearchPath = @"geosearch/v3/nearby";
NSString * const kBaiduAPIGeosearchPathCreate = @"geodata/v3/poi/create";

NSString * const kBaiduAPIUrl = @"http://api.map.baidu.com/";

@implementation TweetSendCreateLocation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ak = kBaiduAK;
        self.geotable_id = kBaiduGeotableId;
        self.coord_type = @"3";
        self.filter = @"";
        self.query = @"";
        self.radius = @(2000);
        self.page_size = @20;
        self.page_index = @0;
        User *user = [Login curLoginUser]? [Login curLoginUser]: [User userWithGlobalKey:@""];
        self.user_id = user.id;

    }
    return self;
}


- (NSDictionary *)toCreateParams
{
    return @{@"ak":self.ak,@"geotable_id":self.geotable_id,@"coord_type":self.coord_type,@"radius":self.radius,@"address":self.address,@"latitude":self.latitude,@"longitude":self.longitude,@"title":self.title,@"user_id":self.user_id};

}

- (NSDictionary *)toSearchParams
{
    //百度的格式很奇葩需要表示为:user_id:[user_id],afnetworking无法转义，所以需要使用转码
    self.filter = [NSString stringWithFormat:@"%@%%3A%%5B%@%%5D",@"user_id",self.user_id];
    NSString *location = [NSString stringWithFormat:@"%@,%@",self.longitude,self.latitude];
    return @{@"ak":self.ak,@"geotable_id":self.geotable_id,@"coord_type":self.coord_type,@"q":self.query,@"radius":self.radius,@"filter":self.filter,@"page_index":self.page_index,@"page_size":self.page_size,@"location":location};
}

@end

@implementation TweetSendLocationRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ak = kBaiduAK;
        self.query = @"公司企业$美食$生活服务$道路$旅游景点$医疗$休闲娱乐$宾馆";
        self.page_num = @(0);
        self.page_size = @(20);
        self.scope = @"1";
        self.radius = @(2000);
        self.output = @"json";
    }
    return self;
}

- (NSDictionary *)toParams
{
    NSString *locationStr = [NSString stringWithFormat:@"%@,%@",self.lat,self.lng];
    return @{@"ak":self.ak,@"output":self.output,@"query":self.query,@"page_size":self.page_size,@"page_num":self.page_num,@"scope":self.scope,@"location":locationStr,@"radius":self.radius};
}

@end

@implementation TweetSendLocationResponse

- (NSString *)displayLocaiton
{
    NSString *locationStr = @"";
    if([self.cityName containsString:@"市"]){
        self.cityName = [self.cityName substringToIndex:([self.cityName length]-1)];
    }
    
    if (self.title.length > 0) {
        locationStr = [NSString stringWithFormat:@"%@·%@",self.cityName,self.title];
    }else{
        locationStr = self.cityName;
    }
    if (locationStr.length > 16) {
        locationStr = [locationStr substringWithRange:NSMakeRange(0, 15)];
        locationStr = [locationStr stringByAppendingString:@"…"];
    }
    
    return locationStr;
}


@end

@implementation TweetSendLocationClient

+ (TweetSendLocationClient *)sharedJsonClient
{
    static TweetSendLocationClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TweetSendLocationClient alloc] initWithBaseURL:[NSURL URLWithString:kBaiduAPIUrl]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.responseSerializer = [AFJSONResponseSerializer serializer];
//    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", nil];
//    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return self;
}

- (void)requestPlaceAPIWithParams:(TweetSendLocationRequest *)obj andBlock:(void (^)(id data, NSError *error))block
{
    [self GET:kBaiduAPIPlacePath parameters:[obj toParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIPlacePath, responseObject);
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIPlacePath, error);
        [self showError:error];
        block(nil, error);
    }];
}

- (void)requestGeodataCreateWithParams:(TweetSendCreateLocation *)obj andBlock:(void (^)(id data, NSError *error))block
{
    [self POST:kBaiduAPIGeosearchPathCreate parameters:[obj toCreateParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPathCreate, responseObject);
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPathCreate, error);
        [self showError:error];
        block(nil, error);
    }];
}

- (void)requestGeodataSearchCustomerWithParams:(TweetSendCreateLocation *)obj andBlock:(void (^)(id data, NSError *error))block
{
    [self GET:kBaiduAPIGeosearchPath parameters:[obj toSearchParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPath, responseObject);
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPath, error);
        [self showError:error];
        block(nil, error);
    }];
}

@end


