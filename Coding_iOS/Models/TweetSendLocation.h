//
//  TweetSendLocation.h
//  Coding_iOS
//
//  Created by Kevin on 3/11/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@interface TweetSendCreateLocation : NSObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;
@property (nonatomic,strong) NSString *coord_type;
@property (nonatomic,strong) NSString *geotable_id;
@property (nonatomic,strong) NSString *ak;

@property (nonatomic,strong) NSString *filter;
@property (nonatomic,strong) NSString *sortby;
@property (nonatomic,strong) NSString *query;
@property (nonatomic,strong) NSString *province;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *district;
@property (nonatomic,strong) NSString *tags;
@property (nonatomic,strong) NSArray *location;
@property (nonatomic,strong) NSNumber *radius;
@property (nonatomic, strong) NSNumber *page_size;
@property (nonatomic, strong) NSNumber *page_index;

@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSNumber *user_id;

- (NSDictionary *)toCreateParams;

- (NSDictionary *)toSearchParams;

@end


@interface TweetSendLocationRequest : NSObject

@property (nonatomic, strong) NSString *query;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *output;
@property (nonatomic, strong) NSString *scope;
@property (nonatomic, strong) NSString *filter;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSNumber *page_size;
@property (nonatomic, strong) NSNumber *page_num;
@property (nonatomic, strong) NSNumber *radius;

@property (nonatomic, strong) NSString *ak;

@end


@interface TweetSendLocationResponse : NSObject

@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *region;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSDictionary *detailed;

//@property (nonatomic, strong, readonly) NSString *displayLocaiton;
- (NSString *)displayLocaiton;
/**
 *  是否用户自定义位置
 */
@property (nonatomic) BOOL isCustomLocaiton;

@end


@interface TweetSendLocationClient : AFHTTPRequestOperationManager

+ (TweetSendLocationClient *)sharedJsonClient;
/**
 *  请求百度API获取周边信息
 *
 *  @param obj
 *  @param block
 */
- (void)requestPlaceAPIWithParams:(TweetSendLocationRequest *)obj andBlock:(void (^)(id data, NSError *error))block;
/**
 *  请求创建位置
 *  status:0 成功，其他为失败
 *
 *  @param obj
 *  @param block
 */
- (void)requestGeodataCreateWithParams:(TweetSendCreateLocation *)obj andBlock:(void (^)(id data, NSError *error))block;

/**
 *  查找自定义位置
 *
 *  @param obj
 *  @param block 
 */
- (void)requestGeodataSearchCustomerWithParams:(TweetSendCreateLocation *)obj andBlock:(void (^)(id data, NSError *error))block;


//- (NSString *)CodingQueryStringFromParametersWithEncoding:(NSDictionary *)parameters encoding: (NSStringEncoding)stringEncoding;

@end