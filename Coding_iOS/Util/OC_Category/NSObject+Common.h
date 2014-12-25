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
-(NSString* )pathInCacheDirectory:(NSString *)fileName;
//创建缓存文件夹
-(BOOL) createDirInCache:(NSString *)dirName;

//图片
- (BOOL) saveImage:(UIImage *)image imageName:(NSString *)imageName;
-(NSData*) loadImageDataWithName:( NSString *)imageName;
- (BOOL) deleteImageCache;

//网络请求
- (BOOL) saveResponseData:(NSDictionary *)data toPath:(NSString *)requestPath;//缓存请求回来的json对象
- (id) loadResponseWithPath:(NSString *)requestPath;//返回一个NSDictionary类型的json数据
- (BOOL) deleteResponseCache;

//存放图片尺寸的plist管理
- (BOOL)saveImageSizeDict:(NSDictionary *)dict;
- (NSMutableDictionary *)loadImageSizeDict;

//尺寸调整
- (CGSize)sizeWithImageH_W:(CGFloat)height_width originalWidth:(CGFloat)originalWidth;

- (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight;
- (CGSize)sizeWithImage:(UIImage *)image originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight;


- (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight minWidth:(CGFloat)minWidth;

/**
 *  更新 status bar 的颜色
 */
- (void)refreshStatusBar;
/**
 *  解析返回json数据是否有错
 */
-(id)handleResponse:(id)responseJSON;

- (void)loginOutToLoginVC;

@end
