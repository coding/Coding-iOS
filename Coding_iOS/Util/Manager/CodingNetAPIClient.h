//
//  CodingNetAPIClient.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "APIUrl.h"

typedef enum {
	Get = 0,
	Post,
	Put,
    Delete
} NetworkMethod;


@interface CodingNetAPIClient : AFHTTPRequestOperationManager

+ (id)sharedJsonClient;
+ (void)saveCookieData;
+ (void)removeCookieData;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(int)NetworkMethod
                       andBlock:(void (^)(id data, NSError *error))block;

- (void)uploadImage:(UIImage *)image path:(NSString *)path name:(NSString *)name
       successBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
      progerssBlock:(void (^)(CGFloat progressValue))progress;
@end
