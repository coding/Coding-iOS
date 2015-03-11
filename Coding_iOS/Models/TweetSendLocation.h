//
//  TweetSendLocation.h
//  Coding_iOS
//
//  Created by Kevin on 3/11/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface TweetSendLocationRequest : NSObject

@property (nonatomic, strong) NSString *query;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *output;
@property (nonatomic, strong) NSString *scope;
@property (nonatomic, strong) NSString *filter;
@property (nonatomic, strong) NSNumber *page_size;
@property (nonatomic, strong) NSNumber *page_num;

@property (nonatomic, strong) NSString *ak;

@end


@interface TweetSendLocationResponse : NSObject

@end


@interface TweetSendLocationClient : AFHTTPRequestOperationManager

+ (TweetSendLocationClient *)sharedJsonClient;

- (void)requestPlaceAPIWithParams:(TweetSendLocationRequest *)obj andBlock:(void (^)(id data, NSError *error))block;

@end