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
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:@"Coding_Download"];
    return downloadPath;
}

+ (NSString *)uploadPath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
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
    if (isCreated) {
        [NSURL addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path isDirectory:YES]];
    }
    return isCreated;
}

#pragma mark download

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

+ (NSArray *)localFileUrlList{
    return [[[self sharedManager] diskDownloadDict] allValues];
}

+(NSURL *)diskDownloadUrlForKey:(NSString *)storage_key{
    return [self.sharedManager.diskDownloadDict objectForKey:storage_key];
}
+ (Coding_DownloadTask *)cDownloadTaskForKey:(NSString *)storage_key{
    if (!storage_key) {
        return nil;
    }
    return [self.sharedManager.downloadDict objectForKey:storage_key];
}
+ (void)cancelCDownloadTaskForKey:(NSString *)storage_key{
    if (!storage_key) {
        return;
    }
    Coding_DownloadTask *cDownloadTack = [self.sharedManager.downloadDict objectForKey:storage_key];
    if (cDownloadTack) {
        [cDownloadTack cancel];
    }
    [self.sharedManager.downloadDict removeObjectForKey:storage_key];
}
+ (NSString *)keyStrFromResponse:(NSURLResponse *)response{
    if (!response) {
        return nil;
    }
    NSString *keyStr = response.URL.absoluteString;
    keyStr = [[[[keyStr componentsSeparatedByString:@"?download"] firstObject] componentsSeparatedByString:@"/"] lastObject];
    return keyStr;
}
+ (Coding_DownloadTask *)cDownloadTaskForResponse:(NSURLResponse *)response{
    return [self cDownloadTaskForKey:[self keyStrFromResponse:response]];
}
+ (void)cancelCDownloadTaskForResponse:(NSURLResponse *)response{
    [self cancelCDownloadTaskForKey:[self keyStrFromResponse:response]];
}
- (Coding_DownloadTask *)addDownloadTaskForObj:(id)obj completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    Coding_DownloadTask *cTask = nil;
    if ([obj isKindOfClass:[ProjectFile class]]) {
        ProjectFile *file = (ProjectFile*)obj;
        cTask = [self addDownloadTaskWithPath:file.downloadPath diskFileName:file.diskFileName storage_key:file.storage_key completionHandler:completionHandler];
    }else if ([obj isKindOfClass:[FileVersion class]]){
        FileVersion *fileVersion = (FileVersion *)obj;
        cTask = [self addDownloadTaskWithPath:fileVersion.downloadPath diskFileName:fileVersion.diskFileName storage_key:fileVersion.storage_key completionHandler:completionHandler];
    }
    return cTask;
}

- (Coding_DownloadTask *)addDownloadTaskWithPath:(NSString *)downloadPath
                                    diskFileName:(NSString *)diskFileName
                                       storage_key:(NSString *)storage_key
                               completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    
    [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"下载文件"];
    
    NSProgress *progress;
    NSURL *downloadURL = [NSURL URLWithString:downloadPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NSURLSessionDownloadTask *downloadTask = [self.af_manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *downloadUrl = [[Coding_FileManager sharedManager] urlForDownloadFolder];
        Coding_DownloadTask *cDownloadTask = [Coding_FileManager cDownloadTaskForResponse:response];
        if (cDownloadTask) {
            downloadUrl = [downloadUrl URLByAppendingPathComponent:cDownloadTask.diskFileName];
        }else{
            downloadUrl = [downloadUrl URLByAppendingPathComponent:[response suggestedFilename]];
        }
        [downloadUrl setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
        DebugLog(@"download_destinationPath------\n%@", downloadUrl.absoluteString);
        return downloadUrl;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            [Coding_FileManager cancelCDownloadTaskForKey:storage_key];
        }else{
            [Coding_FileManager cancelCDownloadTaskForResponse:response];
        }
        if (completionHandler) {
            completionHandler(response, filePath, error);
        }
    }];
    Coding_DownloadTask *cDownloadTask = [Coding_DownloadTask cDownloadTaskWithTask:downloadTask progress:progress fileName:diskFileName];
    [self.downloadDict setObject:cDownloadTask forKey:storage_key];
    [downloadTask resume];
    return cDownloadTask;
}

#pragma upload
+ (BOOL)writeUploadDataWithName:(NSString *)fileName andAsset:(ALAsset *)asset{
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
+ (BOOL)writeUploadDataWithName:(NSString *)fileName andImage:(UIImage *)image{
    if (![self createFolder:[self uploadPath]]) {
        return NO;
    }
    NSString *filePath = [[self uploadPath] stringByAppendingPathComponent:fileName];
    
    return [[image dataForCodingUpload] writeToFile:filePath options:NSAtomicWrite error:nil];
}
+ (BOOL)deleteUploadDataWithName:(NSString *)fileName{
    NSString *filePath = [[self uploadPath] stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        return [fm removeItemAtPath:fileName error:nil];
    }else{
        return YES;
    }
}
- (Coding_UploadTask *)addUploadTaskWithFileName:(NSString *)fileName projectIsPublic:(BOOL)is_public{
    if (!fileName) {
        return nil;
    }
    NSArray *fileInfos = [fileName componentsSeparatedByString:@"|||"];
    if (fileInfos.count != 3) {
        return nil;
    }
    NSString *project_id, *folder_id, *name;
    project_id = fileInfos[0];
    folder_id = fileInfos[1];
    name = fileInfos[2];
    NSString *filePath = [[[self class] uploadPath] stringByAppendingPathComponent:fileName];
    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
    
    NSURL *uploadUrl;
    if (is_public) {
        uploadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/project/%@/upload_public_image", [NSObject baseURLStr], project_id]];
    }else{
        uploadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/project/%@/file/upload", [NSObject baseURLStr], project_id]];
    }
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:uploadUrl.absoluteString parameters:@{@"dir": folder_id} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePathUrl name:@"file" fileName:name mimeType:@"image/jpeg, image/png, image/gif" error:nil];
    } error:nil];
    
    [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"上传文件"];
    
    NSProgress *progress = nil;
    NSURLSessionUploadTask *uploadTask = [self.af_manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        Coding_FileManager *manager = [Coding_FileManager sharedManager];
        if (!error) {
            error = [manager handleResponse:responseObject];
        }
        response = response? response: [[NSURLResponse alloc] init];
        if (error){
            [NSObject showError:error];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUploadCompled object:manager userInfo:@{@"response" : response,
                                                                                                                            @"error" : error}];
        }else if (responseObject) {
            NSString *block_project_id = [[[[response.URL.absoluteString componentsSeparatedByString:@"/project/"] lastObject] componentsSeparatedByString:@"/"] firstObject];
            responseObject = [responseObject valueForKey:@"data"];
            
            if ([responseObject isKindOfClass:[NSString class]]) {
                //处理completionHandler
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUploadCompled object:manager userInfo:@{@"response" : response,
                                                                                                                                @"data" : responseObject}];
            }else{
                ProjectFile *curFile = [NSObject objectOfClass:@"ProjectFile" fromJSON:responseObject];
                NSString *block_fileName = [NSString stringWithFormat:@"%@|||%@|||%@", block_project_id, curFile.parent_id.stringValue, curFile.name];
                NSString *block_filePath = [[[manager class] uploadPath] stringByAppendingPathComponent:block_fileName];
                
                //移动文件到已下载
                NSString *diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@|%@", curFile.name, block_project_id, curFile.storage_type, curFile.storage_key];
                NSString *diskFilePath = [[[manager class] downloadPath] stringByAppendingPathComponent:diskFileName];
                [[NSFileManager defaultManager] moveItemAtPath:block_filePath toPath:diskFilePath error:nil];
                [manager directoryDidChange:manager.docUploadWatcher];
                [manager directoryDidChange:manager.docDownloadWatcher];
                DebugLog(@"upload_fileName------\n%@", block_fileName);
                
                //移除任务
                [Coding_FileManager cancelCUploadTaskForFile:block_fileName hasError:(error != nil)];
                
                //处理completionHandler
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUploadCompled object:manager userInfo:@{@"response" : response,
                                                                                                                                @"data" : curFile}];
            }
        }
    }];
    
    [uploadTask resume];
    Coding_UploadTask *cUploadTask = [Coding_UploadTask cUploadTaskWithTask:uploadTask progress:progress fileName:fileName];
    [self.uploadDict setObject:cUploadTask forKey:fileName];

    return cUploadTask;
}

+ (NSURL *)diskUploadUrlForFile:(NSString *)diskFileName{
    return [self.sharedManager.diskUploadDict objectForKey:diskFileName];
}

+ (Coding_UploadTask *)cUploadTaskForFile:(NSString *)diskFileName{
    return [self.sharedManager.uploadDict objectForKey:diskFileName];
}
+ (void)cancelCUploadTaskForFile:(NSString *)diskFileName hasError:(BOOL)hasError{
    if (!diskFileName) {
        return;
    }
    Coding_UploadTask *cUploadTack = [self.sharedManager.uploadDict objectForKey:diskFileName];
    if (cUploadTack) {
        [cUploadTack cancel];
    }
    [self.sharedManager.uploadDict removeObjectForKey:diskFileName];
    if (!hasError) {
        NSString *filePath = [[[self class] uploadPath] stringByAppendingPathComponent:diskFileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}
+ (NSArray *)uploadFilesInProject:(NSString *)project_id andFolder:(NSString *)folder_id{
    if (!project_id || !folder_id) {
        return nil;
    }
    [self.sharedManager directoryDidChange:self.sharedManager.docUploadWatcher];
    NSMutableArray *uploadFiles = [NSMutableArray array];
    for (NSString *fileName in [self.sharedManager.diskUploadDict allKeys]) {
        NSArray *fileInfos = [fileName componentsSeparatedByString:@"|||"];
        if (fileInfos.count == 3 &&
            ([project_id isEqualToString:fileInfos[0]] && [folder_id isEqualToString:fileInfos[1]])) {
            
            [uploadFiles addObject:fileName];
        }
    }
    return uploadFiles;
}

#pragma mark DirectoryWatcherDelegate
- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher{
    NSMutableDictionary *diskDict;
    NSString *path;
    BOOL isDownload = NO;
    if (folderWatcher == self.docDownloadWatcher) {
        diskDict = self.diskDownloadDict;
        path = [[self class] downloadPath];
        isDownload = YES;
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
        if (!isDirectory) {
            NSString *keyStr;
            if (isDownload) {//下载文件，用 storge_key 做键值
                keyStr = [curFileName componentsSeparatedByString:@"|"].lastObject;
            }else{
                keyStr = curFileName;
            }
            [diskDict setObject:fileUrl forKey:keyStr];
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