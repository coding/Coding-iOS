//
//  ImageSizeManager.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kPath_ImageSizeDict @"ImageSizeDict"

#define kImageSizeManager_maxCount 1000
#define kImageSizeManager_resetCount (kImageSizeManager_maxCount/2)



#import "ImageSizeManager.h"

@interface ImageSizeManager ()
@property (strong, nonatomic) NSMutableDictionary *imageSizeDict;

@end

@implementation ImageSizeManager
+ (instancetype)shareManager{
    static ImageSizeManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
        [shared_manager read];
    });
    return shared_manager;
}
- (NSMutableDictionary *)read{
    if (!_imageSizeDict) {
        NSString *abslutePath = [NSString stringWithFormat:@"%@/%@.plist", [NSObject pathInCacheDirectory:kPath_ImageSizeDict], kPath_ImageSizeDict];
        _imageSizeDict = [NSMutableDictionary dictionaryWithContentsOfFile:abslutePath];
        if (!_imageSizeDict) {
            _imageSizeDict = [NSMutableDictionary dictionary];
        }
    }
    return _imageSizeDict;
}

- (BOOL)save{
    if (_imageSizeDict) {
        if ([NSObject createDirInCache:kPath_ImageSizeDict]) {
            NSString *abslutePath = [NSString stringWithFormat:@"%@/%@.plist", [NSObject pathInCacheDirectory:kPath_ImageSizeDict], kPath_ImageSizeDict];
            return [_imageSizeDict writeToFile:abslutePath atomically:YES];
        }
    }
    return NO;
}

- (void)saveImage:(NSString *)imagePath size:(CGSize)size{
    if (imagePath && ![_imageSizeDict objectForKey:imagePath]) {
        [_imageSizeDict setObject:[NSNumber numberWithFloat:size.height/size.width] forKey:imagePath];
    }
}

- (CGFloat)sizeOfImage:(NSString *)imagePath{
    CGFloat imageSize = 1;
    NSNumber *sizeValue = [_imageSizeDict objectForKey:imagePath];
    if (sizeValue) {
        imageSize = sizeValue.floatValue;
    }
    return imageSize;
}

- (BOOL)hasSrc:(NSString *)src{
    NSNumber *sizeValue = [_imageSizeDict objectForKey:src];
    BOOL hasSrc = NO;
    if (sizeValue) {
        hasSrc = YES;
    }
    return hasSrc;
}

#pragma mark Image Resize (used in tweet and message)
- (CGSize)sizeWithImageH_W:(CGFloat)height_width originalWidth:(CGFloat)originalWidth{
    CGSize reSize = CGSizeZero;
    reSize.width = originalWidth;
    reSize.height = originalWidth *height_width;
    return reSize;
}

- (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight{
    CGSize reSize = [self sizeWithImageH_W:[self sizeOfImage:src] originalWidth:originalWidth];
    if (reSize.height > maxHeight) {
        reSize.height = maxHeight;
    }
    return reSize;
}
- (CGSize)sizeWithImage:(UIImage *)image originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight{
    CGSize reSize = [self sizeWithImageH_W:(image.size.height/image.size.width) originalWidth:originalWidth];
    if (reSize.height > maxHeight) {
        reSize.height = maxHeight;
    }
    return reSize;
}

- (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight minWidth:(CGFloat)minWidth{
    CGSize reSize = [self sizeWithImageH_W:[self sizeOfImage:src] originalWidth:originalWidth];
    CGFloat scale = maxHeight/reSize.height;
    if (scale < 1) {
        reSize = CGSizeMake(reSize.width *scale, reSize.height*scale);
    }
    if (reSize.width < minWidth) {
        reSize.width = minWidth;
    }
    return reSize;
}
@end
