//
//  ImageSizeManager.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


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
- (void)read{
    if (!_imageSizeDict) {
        _imageSizeDict = [self loadImageSizeDict];
        if (!_imageSizeDict) {
            _imageSizeDict = [NSMutableDictionary dictionary];
        }else if (_imageSizeDict.count > kImageSizeManager_maxCount){//数据太大的时候，适当清理
            NSMutableArray *keyArray = [NSMutableArray arrayWithArray:_imageSizeDict.allKeys];
//            [keyArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                return [obj1 compare:obj2 options:NSNumericSearch];
//            }];
            [_imageSizeDict removeObjectsForKeys:[keyArray subarrayWithRange:NSMakeRange(kImageSizeManager_resetCount, keyArray.count - kImageSizeManager_resetCount)]];
        }
    }
}
- (void)save{
    if (_imageSizeDict) {
        [self saveImageSizeDict:_imageSizeDict];
    }
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
+ (void)save{
    [[self shareManager] save];
}
+ (void)saveImage:(NSString *)imagePath size:(CGSize)size{
    [[self shareManager] saveImage:imagePath size:size];
}
+ (CGFloat)sizeOfImage:(NSString *)imagePath{
    return [[self shareManager] sizeOfImage:imagePath];
}
+ (BOOL)hasSrc:(NSString *)src{
    return [[self shareManager] hasSrc:src];
}
@end
