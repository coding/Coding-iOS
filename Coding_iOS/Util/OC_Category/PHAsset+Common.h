//
//  PHAsset+Common.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/1/3.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (Common)

+ (PHAsset *)assetWithLocalIdentifier:(NSString *)localIdentifier;
+ (UIImage *)loadImageWithLocalIdentifier:(NSString *)localIdentifier;

- (UIImage *)loadImage;
- (NSData *)loadImageData;
- (NSString *)fileName;

@end
