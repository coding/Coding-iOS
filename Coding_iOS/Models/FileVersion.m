//
//  FileVersion.m
//  Coding_iOS
//
//  Created by Ease on 15/8/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileVersion.h"
#import "Coding_FileManager.h"

@interface FileVersion ()
@property (strong, nonatomic, readwrite) NSString *diskFileName;
@end

@implementation FileVersion
- (NSString *)diskFileName{
    if (!_diskFileName) {
        _diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@|%@", _name, _project_id.stringValue, _storage_type, _storage_key];
    }
    return _diskFileName;
}
- (NSString *)downloadPath{
    return [NSString stringWithFormat:@"%@api/project/%@/files/histories/%@/download", [NSObject baseURLStr], _project_id, _history_id];
}

- (NSString *)toRemarkPath{
    return [NSString stringWithFormat:@"api/project/%@/files/%@/histories/%@/remark", _project_id.stringValue, _file_id.stringValue, _history_id.stringValue];
}
- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/project/%@/files/histories/%@", _project_id.stringValue, _history_id.stringValue];
}

//download
- (DownloadState)downloadState{
    DownloadState state = DownloadStateDefault;
    if ([self hasBeenDownload]) {
        state = DownloadStateDownloaded;
    }else{
        Coding_DownloadTask *cDownloadTask = [self cDownloadTask];
        if (cDownloadTask) {
            if (cDownloadTask.task.state == NSURLSessionTaskStateRunning) {
                state = DownloadStateDownloading;
            }else if (cDownloadTask.task.state == NSURLSessionTaskStateSuspended) {
                state = DownloadStatePausing;
            }else{
                [Coding_FileManager cancelCDownloadTaskForKey:self.storage_key];
            }
        }
    }
    return state;
}
- (Coding_DownloadTask *)cDownloadTask{
    return [Coding_FileManager cDownloadTaskForKey:_storage_key];
}
- (NSURL *)hasBeenDownload{
    return [Coding_FileManager diskDownloadUrlForKey:_storage_key];
}
@end
