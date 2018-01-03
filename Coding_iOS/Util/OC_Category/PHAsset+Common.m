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

- (UIImage *)loadImage{
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
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


@end
