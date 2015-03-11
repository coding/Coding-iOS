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
    }
    return self;
}

- (NSDictionary *)toParams
{
    return @{@"ak":kBaiduAK,@"output":@"json",@"query":@"餐馆",@"page_size":@10,@"page_num":@0,@"scope":@1,@"location":@"39.915,116.404",@"radius":@"2000"};
}

@end

@implementation TweetSendLocationResponse

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


