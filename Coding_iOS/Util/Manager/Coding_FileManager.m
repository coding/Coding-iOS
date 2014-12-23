//
//  Coding_FileManager.m
//  Coding_iOS
//
//  Created by Ease on 14/11/18.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Coding_FileManager.h"

@interface Coding_FileManager ()<DirectoryWatcherDelegate>

@property (nonatomic, strong) DirectoryWatcher *docDownloadWatcher, *docUploadWatcher;
@property (nonatomic, strong) NSMutableDictionary *downloadDict, *uploadDict, *diskDownloadDict, *diskUploadDict;

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

#pragma mark download
- (void)removeCDownloadTaskForKey:(NSString *)storage_key{
    Coding_DownloadTask *cDownloadTack = [self.downloadDict objectForKey:storage_key];
    if (cDownloadTack) {
        [cDownloadTack cancel];
    }
    if (storage_key) {
        [self.downloadDict removeObjectForKey:storage_key];
    }
}
- (Coding_DownloadTask *)cDownloadTaskForKey:(NSString *)storage_key{
    return [self.downloadDict objectForKey:storage_key];
}
- (void)removeCDownloadTaskForResponse:(NSURLResponse *)response{
    NSString *keyStr = [self keyStrFromResponse:response];
    if (keyStr) {
        [self removeCDownloadTaskForKey:keyStr];
    }
}
- (Coding_DownloadTask *)cDownloadTaskForResponse:(NSURLResponse *)response{
    NSString *keyStr = [self keyStrFromResponse:response];
    if (!keyStr) {
        return nil;
    }
    return [self cDownloadTaskForKey:keyStr];
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
        _diskDownloadDict = [[NSMutableDictionary alloc] init];
        _diskUploadDict = [[NSMutableDictionary alloc] init];
        _downloadDirectoryURL = nil;
        _docDownloadWatcher = [DirectoryWatcher watchFolderWithPath:[[self class] downloadPath] delegate:self];
        [self directoryDidChange:_docDownloadWatcher];
        _docUploadWatcher = [DirectoryWatcher watchFolderWithPath:[[self class] uploadPath] delegate:self];
        [self directoryDidChange:_docUploadWatcher];
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
- (NSURL *)diskDownloadUrlForFile:(NSString *)fileName{
    return [self.diskDownloadDict objectForKey:fileName];
}

- (Coding_DownloadTask *)addDownloadTaskForFile:(ProjectFile *)file progress:(NSProgress *)progress completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    
    __weak typeof(file) weakFile = file;
    
    NSURL *downloadURL = [NSURL URLWithString:file.downloadPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NSURLSessionDownloadTask *downloadTask = [self.af_manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSLog(@"destination------Path");
        NSURL *downloadUrl = [[Coding_FileManager sharedManager] urlForDownloadFolder];
        Coding_DownloadTask *cDownloadTask = [[Coding_FileManager sharedManager] cDownloadTaskForResponse:response];
        if (cDownloadTask) {
            downloadUrl = [downloadUrl URLByAppendingPathComponent:cDownloadTask.diskFileName];
        }else{
            downloadUrl = [downloadUrl URLByAppendingPathComponent:[response suggestedFilename]];
        }
        return downloadUrl;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            [[Coding_FileManager sharedManager] removeCDownloadTaskForKey:weakFile.storage_key];
        }else{
            [[Coding_FileManager sharedManager] removeCDownloadTaskForResponse:response];
        }
        if (completionHandler) {
            completionHandler(response, filePath, error);
        }
    }];
    
    Coding_DownloadTask *cDownloadTask = [Coding_DownloadTask cDownloadTaskWithTask:downloadTask progress:progress fileName:file.diskFileName];
    [self.downloadDict setObject:cDownloadTask forKey:file.storage_key];
    
    [downloadTask resume];
    return cDownloadTask;
}


#pragma upload
+ (BOOL)writeUploadDataWithName:(NSString*)fileName andAsset:(ALAsset*)asset{
    if (![self createFolder:[self uploadPath]]) {
        return NO;
    }
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
- (Coding_UploadTask *)addUploadTaskWithFileName:(NSString *)fileName completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
    if (!fileName) {
        return nil;
    }
    NSArray *fileInfos = [fileName componentsSeparatedByString:@"|||"];
    if (fileInfos.count != 4) {
        return nil;
    }
    NSString *project_id, *folder_id, *name;
    project_id = fileInfos[0];
    folder_id = fileInfos[1];
    name = fileInfos[3];
    NSString *filePath = [[[self class] uploadPath] stringByAppendingPathComponent:fileName];
    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
    
    NSURL *uploadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/project/%@/file/upload", kNetPath_Code_Base, project_id]];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:uploadUrl.absoluteString parameters:@{@"dir": folder_id} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePathUrl name:@"file" fileName:name mimeType:@"image/jpeg" error:nil];
    } error:nil];
    
    NSProgress *progress = nil;
    @weakify(project_id);
    @weakify(filePath);
    NSURLSessionUploadTask *uploadTask = [self.af_manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        @strongify(project_id);
        @strongify(filePath);
        if (!error) {
            //移动文件到已下载
            NSDictionary *dict = [responseObject valueForKey:@"data"];
            NSString *name_block = [dict objectForKey:@"name"];
            NSString *storage_type = [dict objectForKey:@"storage_type"];
            NSString *storage_key = [dict objectForKey:@"storage_key"];
            
            if (filePath && project_id && name_block && storage_type && storage_key) {
                NSString *diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@|%@", name_block, project_id, storage_type, storage_key];
                NSString *diskFilePath = [[[self class] downloadPath] stringByAppendingPathComponent:diskFileName];
                if (![[NSFileManager defaultManager] moveItemAtPath:filePath toPath:diskFilePath error:nil]) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
            }
        }
        if (completionHandler) {
            completionHandler(response, responseObject, error);
        }
    }];
    
    [uploadTask resume];
    Coding_UploadTask *cUploadTask = [Coding_UploadTask cUploadTaskWithTask:uploadTask progress:progress fileName:fileName];
    return cUploadTask;
}
- (NSURL *)diskUploadUrlForFile:(NSString *)fileName{
    return [self.diskUploadDict objectForKey:fileName];
}

- (void)removeCUploadTaskForFile:(NSString *)fileName{
    Coding_UploadTask *cUploadTack = [self.uploadDict objectForKey:fileName];
    if (cUploadTack) {
        [cUploadTack cancel];
    }
    if (fileName) {
        [self.uploadDict removeObjectForKey:fileName];
        NSString *filePath = [[[self class] uploadPath] stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}
- (Coding_UploadTask *)cUploadTaskForFile:(NSString *)fileName{
    return [self.uploadDict objectForKey:fileName];
}

#pragma mark DirectoryWatcherDelegate
- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher{
    NSMutableDictionary *diskDict;
    NSString *path;
    if (folderWatcher == self.docDownloadWatcher) {
        diskDict = self.diskDownloadDict;
        path = [[self class] downloadPath];
    }else if (folderWatcher == self.docUploadWatcher){
        diskDict = self.diskUploadDict;
        path = [[self class] uploadPath];
    }
    
    [diskDict removeAllObjects];
    NSArray *fileContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (NSString *curFileName in [fileContents objectEnumerator]) {
        NSString *filePath = [path stringByAppendingPathComponent:curFileName];
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
//        if (!(isDirectory && [curFileName isEqualToString:@"Inbox"]))
        {
            [diskDict setObject:fileUrl forKey:curFileName];
        }
    }
}

@end

@implementation Coding_DownloadTask
+ (Coding_DownloadTask *)cDownloadTaskWithTask:(NSURLSessionDownloadTask *)task progress:(NSProgress *)progress fileName:(NSString *)fileName{
    Coding_DownloadTask *cDownloadTask = [[Coding_DownloadTask alloc] init];
    cDownloadTask.task = task;
    cDownloadTask.progress = progress;
    cDownloadTask.diskFileName = fileName;
    return cDownloadTask;
}
- (void)cancel{
    if (self.task &&
        (self.task.state == NSURLSessionTaskStateRunning || self.task.state == NSURLSessionTaskStateSuspended)) {
        [self.task cancel];
    }
}

@end

@implementation Coding_UploadTask

+ (Coding_UploadTask *)cUploadTaskWithTask:(NSURLSessionUploadTask *)task progress:(NSProgress *)progress fileName:(NSString *)fileName{
    Coding_UploadTask *cUploadTask = [[Coding_UploadTask alloc] init];
    cUploadTask.task = task;
    cUploadTask.progress = progress;
    cUploadTask.fileName = fileName;
    return cUploadTask;
}
- (void)cancel{
    if (self.task &&
        (self.task.state == NSURLSessionTaskStateRunning || self.task.state == NSURLSessionTaskStateSuspended)) {
        [self.task cancel];
    }
}

@end