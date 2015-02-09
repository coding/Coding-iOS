//
//  Coding_FileManager.h
//  Coding_iOS
//
//  Created by Ease on 14/11/18.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kNotificationUploadCompled @"notification_upload_compled" 
//{NSURLResponse: response, NSError: error, ProjectFile: data}

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "DirectoryWatcher.h"
#import "ProjectFile.h"

@class Coding_DownloadTask;
@class Coding_UploadTask;
@class ProjectFile;
@protocol Coding_FileManagerDelegate;

@interface Coding_FileManager : NSObject

//download
+ (Coding_FileManager *)sharedManager;
+ (AFURLSessionManager *)af_manager;
- (AFURLSessionManager *)af_manager;

- (NSURL *)urlForDownloadFolder;
- (NSURL *)diskDownloadUrlForFile:(NSString *)fileName;
- (void)removeCDownloadTaskForKey:(NSString *)storage_key;
- (void)removeCDownloadTaskForResponse:(NSURLResponse *)response;
- (Coding_DownloadTask *)cDownloadTaskForKey:(NSString *)storage_key;
- (Coding_DownloadTask *)cDownloadTaskForResponse:(NSURLResponse *)response;
- (Coding_DownloadTask *)addDownloadTaskForFile:(ProjectFile *)file completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;


//upload
+ (BOOL)writeUploadDataWithName:(NSString*)fileName andAsset:(ALAsset*)asset;
- (NSURL *)diskUploadUrlForFile:(NSString *)fileName;
- (void)removeCUploadTaskForFile:(NSString *)fileName hasError:(BOOL)hasError;
- (Coding_UploadTask *)cUploadTaskForFile:(NSString *)fileName;
- (Coding_UploadTask *)addUploadTaskWithFileName:(NSString *)fileName;
- (NSArray *)uploadFilesInProject:(NSString *)project_id andFolder:(NSString *)folder_id;
@end

@interface Coding_DownloadTask : NSObject
@property (strong, nonatomic) NSURLSessionDownloadTask *task;
@property (strong, nonatomic) NSProgress *progress;
@property (strong, nonatomic) NSString *diskFileName;
+ (Coding_DownloadTask *)cDownloadTaskWithTask:(NSURLSessionDownloadTask *)task progress:(NSProgress *)progress fileName:(NSString *)fileName;
- (void)cancel;
@end

@interface Coding_UploadTask : NSObject
@property (strong, nonatomic) NSURLSessionUploadTask *task;
@property (strong, nonatomic) NSProgress *progress;
@property (strong, nonatomic) NSString *fileName;
+ (Coding_UploadTask *)cUploadTaskWithTask:(NSURLSessionUploadTask *)task progress:(NSProgress *)progress fileName:(NSString *)fileName;
- (void)cancel;
@end
