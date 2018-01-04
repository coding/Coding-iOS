//
//  PHAsset+Common.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/1/3.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "PHAsset+Common.h"

@implementation PHAsset (Common)

+ (PHAsset *)assetWithLocalIdentifier:(NSString *)localIdentifier{
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
    return asset;
}

+ (UIImage *)loadImageWithLocalIdentifier:(NSString *)localIdentifier{
    return [self assetWithLocalIdentifier:localIdentifier].loadImage;
}

- (UIImage *)loadThumbnailImage{
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    imageOptions.networkAccessAllowed = YES;
    PHImageManager *imageManager = [PHImageManager defaultManager];
    CGFloat width = ((kScreen_Width - 15*2- 10*3)/4) * [UIScreen mainScreen].scale;
    CGSize targetSize =CGSizeMake(width, width);
    __block UIImage *assetImage;
    [imageManager requestImageForAsset:self targetSize:targetSize contentMode:PHImageContentModeAspectFill options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        assetImage = result;
    }];
    return assetImage;
}


- (UIImage *)loadImage{
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    imageOptions.networkAccessAllowed = YES;
    PHImageManager *imageManager = [PHImageManager defaultManager];
    __block UIImage *assetImage;
    [imageManager requestImageForAsset:self targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        assetImage = result;
    }];
    return assetImage;
}

- (NSData *)loadImageData{
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    imageOptions.networkAccessAllowed = YES;
    PHImageManager *imageManager = [PHImageManager defaultManager];
    __block NSData *assetData;
    [imageManager requestImageDataForAsset:self options:imageOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        assetData = imageData;
    }];
    return assetData;
}

- (NSString *)fileName{
    NSString *fileName;
    if ([self respondsToSelector:NSSelectorFromString(@"filename")]) {
        fileName = [self valueForKey:@"filename"];
    }else{
        fileName = [NSString stringWithFormat:@"%@.JPG", [self.localIdentifier componentsSeparatedByString:@"/"].firstObject];
    }
    return fileName;
}

- (void)loadImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(UIImage *result, NSDictionary *info))resultHandler{
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = NO;
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    imageOptions.networkAccessAllowed = YES;
    imageOptions.progressHandler = progressHandler;
    PHImageManager *imageManager = [PHImageManager defaultManager];
    [imageManager requestImageForAsset:self targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:resultHandler];
}

@end
