//
//  StartImagesManager.h
//  Coding_iOS
//
//  Created by Ease on 14/12/31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StartImage;
@class Group;

@interface StartImagesManager : NSObject
+ (instancetype)shareManager;

- (StartImage *)randomImage;
- (StartImage *)curImage;
- (void)handleStartLink;

- (void)refreshImagesPlist;
- (void)startDownloadImages;

@end

@interface StartImage : NSObject
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSString *fileName, *descriptionStr, *pathDisk;

+ (StartImage *)defautImage;
+ (StartImage *)midAutumnImage;

- (UIImage *)image;
- (void)startDownloadImage;
@end

@interface Group : NSObject
@property (strong, nonatomic) NSString *name, *author, *link;
@end