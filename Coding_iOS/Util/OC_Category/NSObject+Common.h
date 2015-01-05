//
//  NSObject+Common.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Common)

#pragma mark Tip M
- (NSString *)tipFromError:(NSError *)error;
- (void)showError:(NSError *)error;
- (void)showHudTipStr:(NSString *)tipStr;
- (void)showStatusBarQueryStr:(NSString *)tipStr;
- (void)showStatusBarSuccessStr:(NSString *)tipStr;
- (void)showStatusBarError:(NSError *)error;
- (void)showStatusBarProgress:(CGFloat)progress;
- (void)hideStatusBarProgress;

#pragma mark File M
//获取fileName的完整地址
+ (NSString* )pathInCacheDirectory:(NSString *)fileName;
//创建缓存文件夹
+ (BOOL)createDirInCache:(NSString *)dirName;

//图片
+ (BOOL)saveImage:(UIImage *)image imageName:(NSString *)imageName;
+ (NSData*)loadImageDataWithName:( NSString *)imageName;
+ (BOOL)deleteImageCache;

//网络请求
+ (BOOL)saveResponseData:(NSDictionary *)data toPath:(NSString *)requestPath;//缓存请求回来的json对象
+ (id)loadResponseWithPath:(NSString *)requestPath;//返回一个NSDictionary类型的json数据
+ (BOOL)deleteResponseCache;

#pragma mark NetError
-(id)handleResponse:(id)responseJSON;


@end
