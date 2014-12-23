//
//  Coding_FileManager.m
//  Coding_iOS
//
//  Created by Ease on 14/11/18.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Coding_FileManager.h"

@interface Coding_FileManager ()<DirectoryWatcherDelegate>

@property (nonatomic, strong) DirectoryWatcher *docWatcher;
@property (nonatomic, strong) NSMutableDictionary *downloadDict, *uploadDict, *diskDict;

@property (nonatomic, strong) NSURL *downloadDirectoryURL;
@end


@implementation Coding_FileManager

+ (Coding_FileManager *)sharedManager {
    static Coding_FileManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[Coding_FileManager alloc] init];
        [_sharedManager urlForDownloadFolder];
    });
    return _sharedManager;
}

+ (AFURLSessionManager *)af_manager{
    static AFURLSessionManager *_af_manager = nil;
    static dispatch_once_t af_onceToken;
    dispatch_once(&af_onceToken, ^{
        _af_manager= [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return _af_manager;
}

- (AFURLSessionManager *)af_manager{
    return [Coding_FileManager af_manager];
}

- (Coding_DownloadTask *)addDownloadTask:(NSURLSessionDownloadTask *)downloadTask progress:(NSProgress *)progress fileName:(NSString *)fileName forKey:(NSString *)storage_key{
    Coding_DownloadTask *cTask = [Coding_DownloadTask cTaskWithTask:downloadTask progress:progress fileName:fileName];
    [self.downloadDict setObject:cTask forKey:storage_key];
    return cTask;
}
- (void)removeCTaskForKey:(NSString *)storage_key{
    Coding_DownloadTask *cTack = [self.downloadDict objectForKey:storage_key];
    if (cTack) {
        [cTack cancel];
    }
    if (storage_key) {
        [self.downloadDict removeObjectForKey:storage_key];
    }
}
- (Coding_DownloadTask *)cTaskForKey:(NSString *)storage_key{
    return [self.downloadDict objectForKey:storage_key];
}
- (void)removeCTaskForResponse:(NSURLResponse *)response{
    NSString *keyStr = [self keyStrFromResponse:response];
    if (keyStr) {
        [self removeCTaskForKey:keyStr];
    }
}
- (Coding_DownloadTask *)cTaskForResponse:(NSURLResponse *)response{
    NSString *keyStr = [self keyStrFromResponse:response];
    if (!keyStr) {
        return nil;
    }
    return [self cTaskForKey:keyStr];
}
- (NSString *)keyStrFromResponse:(NSURLResponse *)response{
    NSString *keyStr = response.URL.absoluteString;
    if (keyStr) {
        keyStr = [[[[keyStr componentsSeparatedByString:@"?download"] firstObject] componentsSeparatedByString:@"/"] lastObject];
    }
    return keyStr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[self class] createFolder:[[self class] downloadPath]];
        [[self class] createFolder:[[self class] uploadPath]];
        _downloadDict = [[NSMutableDictionary alloc] init];
        _uploadDict = [[NSMutableDictionary alloc] init];
        _diskDict = [[NSMutableDictionary alloc] init];
        _downloadDirectoryURL = nil;
        _docWatcher = [DirectoryWatcher watchFolderWithPath:[[self class] downloadPath] delegate:self];
        [self directoryDidChange:_docWatcher];
    }
    return self;
}


+ (NSString *)downloadPath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:@"Coding_Download"];
    return downloadPath;
}

+ (NSString *)uploadPath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *uploadPath = [documentPath stringByAppendingPathComponent:@"Coding_Upload"];
    return uploadPath;
}

+ (BOOL)createFolder:(NSString *)path{
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

+ (BOOL)writeUploadDataWithName:(NSString*)fileName andAsset:(ALAsset*)asset{
    NSString *filePath = [[self uploadPath] stringByAppendingPathComponent:fileName];
    
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!handle) {
        return NO;
    }
    static const NSUInteger BufferSize = 1024*1024;
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
    NSUInteger offset = 0, bytesRead = 0;
    
    do {
        @try {
            bytesRead = [rep getBytes:buffer fromOffset:offset length:BufferSize error:nil];
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            offset += bytesRead;
        } @catch (NSException *exception) {
            free(buffer);
            
            return NO;
        }
    } while (bytesRead > 0);
    
    free(buffer);
    return YES;
}

- (NSURL *)urlForDownloadFolder{
    if (!_downloadDirectoryURL) {
        if ([[self class] createFolder:[[self class] downloadPath]]) {
            _downloadDirectoryURL = [NSURL fileURLWithPath:[[self class] downloadPath] isDirectory:YES];
        }else{
            kTipAlert(@"创建文件夹失败，无法继续下载！");
        }
    }
    return _downloadDirectoryURL;
}
- (NSURL *)diskUrlForFile:(NSString *)fileName{
    return [self.diskDict objectForKey:fileName];
}
- (Coding_DownloadTask *)addDownloadTaskForFile:(ProjectFile *)file progress:(NSProgress *)progress completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    
    __weak typeof(file) weakFile = file;
    
    NSURL *downloadURL = [NSURL URLWithString:file.downloadPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NSURLSessionDownloadTask *downloadTask = [self.af_manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSLog(@"destination------Path");
        NSURL *downloadUrl = [[Coding_FileManager sharedManager] urlForDownloadFolder];
        Coding_DownloadTask *cTask = [[Coding_FileManager sharedManager] cTaskForResponse:response];
        if (cTask) {
            downloadUrl = [downloadUrl URLByAppendingPathComponent:cTask.diskFileName];
        }else{
            downloadUrl = [downloadUrl URLByAppendingPathComponent:[response suggestedFilename]];
        }
        return downloadUrl;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            [[Coding_FileManager sharedManager] removeCTaskForKey:weakFile.storage_key];
        }else{
            [[Coding_FileManager sharedManager] removeCTaskForResponse:response];
        }
        if (completionHandler) {
            completionHandler(response, filePath, error);
        }
    }];
    [downloadTask resume];
    Coding_DownloadTask *cTask = [self addDownloadTask:downloadTask progress:progress fileName:file.diskFileName forKey:file.storage_key];
    return cTask;
}
#pragma mark DirectoryWatcherDelegate
- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher{
    [self.diskDict removeAllObjects];
    NSString *downloadPath = [[self class] downloadPath];
    NSArray *downloadFileContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadPath error:NULL];
    for (NSString *curFileName in [downloadFileContents objectEnumerator]) {
        NSString *filePath = [downloadPath stringByAppendingPathComponent:curFileName];
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
//        if (!(isDirectory && [curFileName isEqualToString:@"Inbox"]))
        {
            [self.diskDict setObject:fileUrl forKey:curFileName];
        }
    }
}

@end

@implementation Coding_DownloadTask
+ (Coding_DownloadTask *)cTaskWithTask:(NSURLSessionDownloadTask *)task progress:(NSProgress *)progress fileName:(NSString *)fileName{
    Coding_DownloadTask *cTask = [[Coding_DownloadTask alloc] init];
    cTask.task = task;
    cTask.progress = progress;
    cTask.diskFileName = fileName;
    return cTask;
}
- (void)cancel{
    if (self.task &&
        (self.task.state == NSURLSessionTaskStateRunning || self.task.state == NSURLSessionTaskStateSuspended)) {
        [self.task cancel];
    }
}

@end
