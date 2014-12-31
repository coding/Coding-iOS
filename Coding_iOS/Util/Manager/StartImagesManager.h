//
//  StartImagesManager.h
//  Coding_iOS
//
//  Created by Ease on 14/12/31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StartImage;

@interface StartImagesManager : NSObject
+ (instancetype)shareManager;

- (StartImage *)randomImage;
- (StartImage *)curImage;

@end

@interface StartImage : NSObject
@property (strong, nonatomic) NSString *fileName, *pathDisk, *descriptionStr;
@property (assign, nonatomic) BOOL hasBeenDownload;
- (UIImage *)image;
+ (StartImage *)defautImage;
+ (StartImage *)stFromDict:(NSDictionary *)dict;
@end