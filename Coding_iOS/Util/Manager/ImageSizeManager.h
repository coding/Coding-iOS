//
//  ImageSizeManager.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSizeManager : NSObject
+ (instancetype)shareManager;

- (void)read;
- (void)save;

- (void)saveImage:(NSString *)imagePath size:(CGSize)size;
- (CGFloat)sizeOfImage:(NSString *)imagePath;
- (BOOL)hasSrc:(NSString *)src;

+ (void)save;
+ (void)saveImage:(NSString *)imagePath size:(CGSize)size;
+ (CGFloat)sizeOfImage:(NSString *)imagePath;
+ (BOOL)hasSrc:(NSString *)src;
@end
