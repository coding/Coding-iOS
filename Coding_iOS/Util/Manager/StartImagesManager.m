//
//  StartImagesManager.m
//  Coding_iOS
//
//  Created by Ease on 14/12/31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#define kStartImageName @"start_image_name"

#import "StartImagesManager.h"
#import "CodingNetAPIClient.h"
#import "Login.h"
#import "FunctionTipsManager.h"
#import "WebViewController.h"

@interface StartImagesManager ()
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
    if (isCreated) {
        [NSURL addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path isDirectory:YES]];
    }
    return isCreated;
}

- (NSString *)downloadPath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:@"Coding_StartImages"];
    return downloadPath;
}

- (StartImage *)randomImage{
    if ([NSDate isDuringMidAutumn]) {
        _startImage = [StartImage midAutumnImage];
    }else{
        NSUInteger count = _imageLoadedArray.count;
        if (count > 0) {
            NSUInteger index = arc4random()%count;
            _startImage = [_imageLoadedArray objectAtIndex:index];
        }else{
            _startImage = [StartImage defautImage];
        }
    }
    
    [self saveDisplayImageName:_startImage.fileName];
    [self refreshImagesPlist];
    return _startImage;
}
- (StartImage *)curImage{
    if (!_startImage) {
        _startImage = [StartImage defautImage];
    }
    return _startImage;
}
- (void)handleStartLink{
    if (![Login isLogin] || [Login curLoginUser].global_key.length <= 0) {
        return;
    }
    NSString *link = self.curImage.group.link;
    if (![link hasPrefix:[NSObject baseURLStr]]) {
        return;
    }
    NSString *global_key = [Login curLoginUser].global_key;
    NSString *tipKey = [NSString stringWithFormat:@"%@_%@_%@", kFunctionTipStr_StartLinkPrefix, global_key, link];
    if (![[FunctionTipsManager shareManager] needToTip:tipKey]) {
        return;
    }
    UINavigationController *curNav = [BaseViewController presentingVC].navigationController;
    if (!curNav) {
        return;
    }
    [[FunctionTipsManager shareManager] markTiped:tipKey];//标记已处理
    WebViewController *vc = [WebViewController webVCWithUrlStr:link];
    if (vc) {
        [curNav pushViewController:vc animated:YES];
    }
}

- (NSString *)pathOfSTPlist{
    return [[self downloadPath] stringByAppendingPathComponent:@"STARTIMAGE.plist"];
}

- (void)loadStartImages{
    NSArray *plistArray = [NSArray arrayWithContentsOfFile:[self pathOfSTPlist]];
    plistArray = [NSObject arrayFromJSON:plistArray ofObjects:@"StartImage"];

    NSMutableArray *imageLoadedArray = [[NSMutableArray alloc] init];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    for (StartImage *curST in plistArray) {
        if ([fm fileExistsAtPath:curST.pathDisk]) {
            [imageLoadedArray addObject:curST];
        }
    }
    
//    上一次显示的图片，这次就应该把它换掉
    NSString *preDisplayImageName = [self getDisplayImageName];
    if (preDisplayImageName && preDisplayImageName.length > 0) {
        NSUInteger index = [imageLoadedArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([[(StartImage *)obj fileName] isEqualToString:preDisplayImageName]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (index != NSNotFound && imageLoadedArray.count > 1) {//imageLoadedArray.count > 1 是因为，如果一共就一张图片，那么即便上次显示了这张图片，也应该再次显示它
            [imageLoadedArray removeObjectAtIndex:index];
        }
    }
    self.imageLoadedArray = imageLoadedArray;
}

- (void)refreshImagesPlist{
    NSString *aPath = @"api/wallpaper/wallpapers";
    NSDictionary *params = @{@"type" : @"3"};
    [[CodingNetAPIClient sharedJsonClient] GET:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DebugLog(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
        id error = [self handleResponse:responseObject];
        if (!error) {
            NSArray *resultA = [responseObject valueForKey:@"data"];
            if ([self createFolder:[self downloadPath]]) {
                if ([resultA writeToFile:[self pathOfSTPlist] atomically:YES]) {
                    [[StartImagesManager shareManager] startDownloadImages];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"\n===========response===========\n%@:\n%@", aPath, error);
    }];
}

- (void)startDownloadImages{
    
    if (![AFNetworkReachabilityManager sharedManager].reachableViaWiFi) {
        return;
    }
    
    NSArray *plistArray = [NSArray arrayWithContentsOfFile:[self pathOfSTPlist]];
    plistArray = [NSObject arrayFromJSON:plistArray ofObjects:@"StartImage"];
    
    NSMutableArray *needToDownloadArray = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    for (StartImage *curST in plistArray) {
        if (![fm fileExistsAtPath:curST.pathDisk]) {
            [needToDownloadArray addObject:curST];
        }
    }
    
    for (StartImage *curST in needToDownloadArray) {
        [curST startDownloadImage];
    }
}


- (void)saveDisplayImageName:(NSString *)name{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:kStartImageName];
    [defaults synchronize];
}

- (NSString *)getDisplayImageName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kStartImageName];
}

@end


@implementation StartImage
- (NSString *)fileName{
    if (!_fileName && _url.length > 0) {
        _fileName = [[_url componentsSeparatedByString:@"/"] lastObject];
    }
    return _fileName;
}

- (NSString *)descriptionStr{
    if (!_descriptionStr && _group) {
        _descriptionStr = [NSString stringWithFormat:@"\"%@\" © %@", _group.name.length > 0? _group.name : @"今天天气不错", _group.author.length > 0? _group.author : @"作者"];
    }
    return _descriptionStr;
}

- (NSString *)pathDisk{
    if (!_pathDisk && _url) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _pathDisk = [[documentPath
                      stringByAppendingPathComponent:@"Coding_StartImages"]
                     stringByAppendingPathComponent:[[_url componentsSeparatedByString:@"/"] lastObject]];
    }
    return _pathDisk;
}

+ (StartImage *)defautImage{
    StartImage *st = [[StartImage alloc] init];
    st.descriptionStr = @"\"Light Returning\" © 十一步";
    st.fileName = @"STARTIMAGE.jpg";
    st.pathDisk = [[NSBundle mainBundle] pathForResource:@"STARTIMAGE" ofType:@"jpg"];
    return st;
}

+ (StartImage *)midAutumnImage{
    StartImage *st = [[StartImage alloc] init];
    st.descriptionStr = @"\"中秋快乐\" © Mango";
    st.fileName = @"MIDAUTUMNIMAGE.jpg";
    st.pathDisk = [[NSBundle mainBundle] pathForResource:@"MIDAUTUMNIMAGE" ofType:@"jpg"];
    return st;
}

- (UIImage *)image{
    return [UIImage imageWithContentsOfFile:self.pathDisk];
}

- (void)startDownloadImage{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *pathDisk = [[documentPath stringByAppendingPathComponent:@"Coding_StartImages"] stringByAppendingPathComponent:[response suggestedFilename]];
        return [NSURL fileURLWithPath:pathDisk];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        DebugLog(@"downloaded file_path is to: %@", filePath);
    }];
    [downloadTask resume];
}
@end

@implementation Group



@end
