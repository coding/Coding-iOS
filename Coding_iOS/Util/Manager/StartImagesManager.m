//
//  StartImagesManager.m
//  Coding_iOS
//
//  Created by Ease on 14/12/31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "StartImagesManager.h"

@interface StartImagesManager ()
@property (strong, nonatomic) NSDictionary *imageDict;
@property (strong, nonatomic) NSMutableArray *imageLoadedArray;
@property (strong, nonatomic) StartImage *startImage;
@end

@implementation StartImagesManager
+ (instancetype)shareManager{
    static StartImagesManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createFolder:[self downloadPath]];
        [self loadStartImages];
    }
    return self;
}

- (BOOL)createFolder:(NSString *)path{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    BOOL isCreated = NO;
    if (!(isDir == YES && existed == YES)){
        isCreated = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        isCreated = YES;
    }
    return isCreated;
}

- (NSString *)downloadPath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:@"Coding_StartImages"];
    return downloadPath;
}

- (StartImage *)randomImage{
    NSUInteger count = _imageLoadedArray.count;
    if (count > 0) {
        NSUInteger index = arc4random()%count;
        _startImage = [_imageLoadedArray objectAtIndex:index];
    }else{
        _startImage = [StartImage defautImage];
    }
    return _startImage;
}
- (StartImage *)curImage{
    if (_startImage) {
        _startImage = [StartImage defautImage];
    }
    return _startImage;
}

- (NSString *)pathOfSTPlist{
    return [[self downloadPath] stringByAppendingPathComponent:@"STARTIMAGE.plist"];
}

- (void)loadStartImages{
    self.imageDict = [[NSDictionary alloc] initWithContentsOfFile:[self pathOfSTPlist]];
    self.imageLoadedArray = [[NSMutableArray alloc] init];
    NSString *path = [self downloadPath];
    NSArray *fileContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (NSString *curFileName in [fileContents objectEnumerator]) {
        NSString *filePath = [path stringByAppendingPathComponent:curFileName];
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        StartImage *st = [StartImage stFromDict:[self.imageDict objectForKey:curFileName]];
        if (st) {
            st.pathDisk = filePath;
            [self.imageLoadedArray addObject:st];
        }
    }
}

@end

@implementation StartImage

- (UIImage *)image{
    return [UIImage imageWithContentsOfFile:self.pathDisk];
}

+ (StartImage *)defautImage{
    StartImage *st = [[StartImage alloc] init];
    st.hasBeenDownload = YES;
    st.descriptionStr = @"“最春光乍泄” @堂堂超栗子";
    st.fileName = @"STARTIMAGE.jpg";
    
    st.pathDisk = [[NSBundle mainBundle] pathForResource:@"STARTIMAGE" ofType:@"jpg"];
    return st;
}
+ (StartImage *)stFromDict:(NSDictionary *)dict{
    StartImage *st = [[StartImage alloc] init];
    st.hasBeenDownload = YES;

    st.descriptionStr = [dict objectForKey:@"descriptionStr"];
    st.fileName = [dict objectForKey:@"fileName"];
    return st;
}

@end
