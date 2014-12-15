//
//  Coding_FileManager.h
//  Coding_iOS
//
//  Created by Ease on 14/11/18.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "DirectoryWatcher.h"

@class Coding_DownloadTask;

@interface Coding_FileManager : NSObject

+ (Coding_FileManager *)sharedManager;
+ (AFURLSessionManager *)af_manager;
- (AFURLSessionManager *)af_manager;
- (NSURL *)urlForDownloadFolder;
- (NSURL *)diskUrlForFile:(NSString *)fileName;

- (void)addDownloadTask:(NSURLSessionDownloadTask *)downloadTask progress:(NSProgress *)progress fileName:(NSString *)fileName forKey:(NSString *)storage_key;
- (void)removeCTaskForKey:(NSString *)storage_key;
- (Coding_DownloadTask *)cTaskForKey:(NSString *)storage_key;
- (void)removeCTaskForResponse:(NSURLResponse *)response;
- (Coding_DownloadTask *)cTaskForResponse:(NSURLResponse *)response;
@end

@interface Coding_DownloadTask : NSObject
@property (strong, nonatomic) NSURLSessionDownloadTask *task;
@property (strong, nonatomic) NSProgress *progress;
@property (strong, nonatomic) NSString *diskFileName;
+ (Coding_DownloadTask *)cTaskWithTask:(NSURLSessionDownloadTask *)task progress:(NSProgress *)progress fileName:(NSString *)fileName;
- (void)cancel;
@end
