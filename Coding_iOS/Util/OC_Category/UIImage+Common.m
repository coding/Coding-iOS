//
//  UIImage+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-4.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIImage+Common.h"
#import "AnimatedGIFImageSerialization.h"

@implementation UIImage (Common)
+(UIImage *)imageWithColor:(UIColor *)aColor{
    return [UIImage imageWithColor:aColor withFrame:CGRectMake(0, 0, 1, 1)];
}

+(UIImage *)imageWithColor:(UIColor *)aColor withFrame:(CGRect)aFrame{
    UIGraphicsBeginImageContext(aFrame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [aColor CGColor]);
    CGContextFillRect(context, aFrame);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


//对图片尺寸进行压缩--
-(UIImage*)scaledToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat scaleFactor = 0.0;
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetSize.width / imageSize.width;
        CGFloat heightFactor = targetSize.height / imageSize.height;
        if (widthFactor < heightFactor)
            scaleFactor = heightFactor; // scale to fit height
        else
            scaleFactor = widthFactor; // scale to fit width
    }
    scaleFactor = MIN(scaleFactor, 1.0);
    CGFloat targetWidth = imageSize.width* scaleFactor;
    CGFloat targetHeight = imageSize.height* scaleFactor;

    targetSize = CGSizeMake(floorf(targetWidth), floorf(targetHeight));
    UIGraphicsBeginImageContext(targetSize); // this will crop
    [sourceImage drawInRect:CGRectMake(0, 0, ceilf(targetWidth), ceilf(targetHeight))];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        DebugLog(@"could not scale image");
        newImage = sourceImage;
    }
    UIGraphicsEndImageContext();
    return newImage;
}
-(UIImage*)scaledToSize:(CGSize)targetSize highQuality:(BOOL)highQuality{
    if (highQuality) {
        targetSize = CGSizeMake(2*targetSize.width, 2*targetSize.height);
    }
    return [self scaledToSize:targetSize];
}

-(UIImage *)scaledToMaxSize:(CGSize)size{
    
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGFloat oldWidth = self.size.width;
    CGFloat oldHeight = self.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    // 如果不需要缩放
    if (scaleFactor > 1.0) {
        return self;
    }
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

//+ (UIImage *)fullResolutionImageFromALAsset:(ALAsset *)asset{
//    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
//    CGImageRef imgRef = [assetRep fullResolutionImage];
//    UIImage *img = [UIImage imageWithCGImage:imgRef scale:assetRep.scale orientation:(UIImageOrientation)assetRep.orientation];
//    return img;
//}
//
//+ (UIImage *)fullScreenImageALAsset:(ALAsset *)asset{
//    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
//    CGImageRef imgRef = [assetRep fullScreenImage];//fullScreenImage已经调整过方向了
//    UIImage *img = [UIImage imageWithCGImage:imgRef];
//    return img;
//}

+(NSString *)p_iconNameWithFileType:(NSString *)fileType{
    fileType = [fileType lowercaseString];
    NSString *iconName;
    //XXX(s)
    if ([fileType hasPrefix:@"doc"]) {
        iconName = @"icon_file_doc";
    }else if ([fileType hasPrefix:@"ppt"]) {
        iconName = @"icon_file_ppt";
    }else if ([fileType hasPrefix:@"pdf"]) {
        iconName = @"icon_file_pdf";
    }else if ([fileType hasPrefix:@"xls"]) {
        iconName = @"icon_file_xls";
    }
    //XXX
    else if ([fileType isEqualToString:@"txt"]) {
        iconName = @"icon_file_txt";
    }else if ([fileType isEqualToString:@"ai"]) {
        iconName = @"icon_file_ai";
    }else if ([fileType isEqualToString:@"apk"]) {
        iconName = @"icon_file_apk";
    }else if ([fileType isEqualToString:@"md"]) {
        iconName = @"icon_file_md";
    }else if ([fileType isEqualToString:@"psd"]) {
        iconName = @"icon_file_psd";
    }
    //XXX||YYY
    else if ([fileType isEqualToString:@"zip"] || [fileType isEqualToString:@"rar"] || [fileType isEqualToString:@"arj"]) {
        iconName = @"icon_file_zip";
    }else if ([fileType isEqualToString:@"html"]
              || [fileType isEqualToString:@"xml"]
              || [fileType isEqualToString:@"java"]
              || [fileType isEqualToString:@"h"]
              || [fileType isEqualToString:@"m"]
              || [fileType isEqualToString:@"cpp"]
              || [fileType isEqualToString:@"json"]
              || [fileType isEqualToString:@"cs"]
              || [fileType isEqualToString:@"go"]) {
        iconName = @"icon_file_code";
    }else if ([fileType isEqualToString:@"avi"]
              || [fileType isEqualToString:@"rmvb"]
              || [fileType isEqualToString:@"rm"]
              || [fileType isEqualToString:@"asf"]
              || [fileType isEqualToString:@"divx"]
              || [fileType isEqualToString:@"mpeg"]
              || [fileType isEqualToString:@"mpe"]
              || [fileType isEqualToString:@"wmv"]
              || [fileType isEqualToString:@"mp4"]
              || [fileType isEqualToString:@"mkv"]
              || [fileType isEqualToString:@"vob"]) {
        iconName = @"icon_file_movie";
    }else if ([fileType isEqualToString:@"mp3"]
              || [fileType isEqualToString:@"wav"]
              || [fileType isEqualToString:@"mid"]
              || [fileType isEqualToString:@"asf"]
              || [fileType isEqualToString:@"mpg"]
              || [fileType isEqualToString:@"tti"]) {
        iconName = @"icon_file_music";
    }
    //unknown
    else{
        iconName = @"icon_file_unknown";
    }
    return iconName;
}

+ (UIImage *)imageWithFileType:(NSString *)fileType{
    return [UIImage imageNamed:[self p_iconNameWithFileType:fileType]];
}

+ (UIImage *)big_imageWithFileType:(NSString *)fileType{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_big", [self p_iconNameWithFileType:fileType]]];
}

- (NSData *)dataSmallerThan:(CGFloat)maxLength{
    NSAssert(maxLength > 0, @"maxLength 必须是个大于零的数");
    if (self.images.count > 0) {//gif 不压缩
        NSData *data = [AnimatedGIFImageSerialization animatedGIFDataWithImage:self error:nil];
        return data;
    }
    //先调整 compression（图片质量）进行压缩
    //当 compression 减小到一定程度时，再继续减小，data 的值也不会改变了。这也是之前压缩会进到死循环的原因
    //compressionFixed 之后，再调整 ratio（图片尺寸）
    //percentInStep 是每步压缩的百分比
    //maxLoopCount 表示调整 compression 或者 ratio 的最大迭代次数。
    //因为有 maxLoopCount，所以这是个不能保证结果正确的方法
    static NSInteger maxLoopCount = 5;
    NSInteger loopCount = 0;
    CGFloat compression = 1.0;
    CGFloat ratio = 1.0;
    CGFloat percentInStep = 1.0;
    UIImage *tempImage = self;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    NSUInteger dataLengthBeforeCompression = data.length;
    BOOL compressionFixed = NO;
    DebugLog(@"\n=============================================dataSmallerThan Start");
    while (data.length > maxLength) {
        percentInStep = maxLength / dataLengthBeforeCompression;
        percentInStep = percentInStep < .8? MAX(sqrtf(percentInStep), .3): percentInStep;
        if (!compressionFixed) {
            compression *= percentInStep;
            data = UIImageJPEGRepresentation(tempImage, compression);
            DebugLog(@"\ncompression:\t%.6f\
                     \nloopCount:\t%ld\
                     \npreLength:\t%lu\
                     \ncurLength:\t%lu\
                     \nmaxLength:\t%.f",
                     compression,
                     (long)loopCount,
                     (unsigned long)dataLengthBeforeCompression,
                     (unsigned long)data.length,
                     maxLength);
            if (data.length / (CGFloat)dataLengthBeforeCompression > .99
                || ++loopCount >= maxLoopCount) {
                loopCount = 0;
                compressionFixed = YES;
            }
            dataLengthBeforeCompression = data.length;
        }else{
            ratio = percentInStep;
            // Use NSUInteger to prevent white blank
            CGSize size = CGSizeMake((NSUInteger)(tempImage.size.width * ratio),
                                     (NSUInteger)(tempImage.size.height * ratio));
            UIGraphicsBeginImageContext(size);
            [tempImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
            tempImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            data = UIImageJPEGRepresentation(tempImage, compression);
            DebugLog(@"\nratio:\t%.6f\
                     \nloopCount:\t%ld\
                     \npreLength:\t%lu\
                     \ncurLength:\t%lu\
                     \nmaxLength:\t%.f",
                     ratio,
                     (long)loopCount,
                     (unsigned long)dataLengthBeforeCompression,
                     (unsigned long)data.length,
                     maxLength);
            if (dataLengthBeforeCompression == data.length
                || ++loopCount >= maxLoopCount) {
                break;
            }
            dataLengthBeforeCompression = data.length;
        }
    }
    DebugLog(@"\n=============================================dataSmallerThan End");
    return data;
}
- (NSData *)dataForCodingUpload{
    return [self dataSmallerThan:1024 * 5000];
}


@end
