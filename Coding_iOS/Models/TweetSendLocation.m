//
//  TweetSendLocation.m
//  Coding_iOS
//
//  Created by Kevin on 3/11/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendLocation.h"

NSString * const kBaiduGeotableId= @"95955";
NSString * const kBaiduAK = @"9d1fee393e06554e155f797dc71d00f0";

NSString * const kBaiduAPIPlacePath = @"place/v2/search";
NSString * const kBaiduAPIGeosearchPath = @"geosearch/v3/nearby";

NSString * const kBaiduAPIUrl = @"http://api.map.baidu.com/";

@implementation TweetSendLocationRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ak = kBaiduAK;
        self.query = @"酒店$餐馆$楼盘$公司$道路$小区";
        self.page_num = @(0);
        self.page_size = @(20);
        self.scope = @"1";
        self.radius = @(1000);
        self.output = @"json";
    }
    return self;
}

- (NSDictionary *)toParams
{
    NSString *locationStr = [NSString stringWithFormat:@"%@,%@",self.lat,self.lng];
    return @{@"ak":kBaiduAK,@"output":self.output,@"query":self.query,@"page_size":self.page_size,@"page_num":self.page_num,@"scope":self.scope,@"location":locationStr,@"radius":self.radius};
}

@end

@implementation TweetSendLocationResponse

- (NSString *)displayLocaiton
{
    NSString *locationStr = @"";
    
    if (self.address.length > 0) {
        locationStr = [NSString stringWithFormat:@"%@・%@",self.cityName,self.address];
    }else{
        locationStr = self.cityName;
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
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", nil];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
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

@end


