//
//  ProjectFile.m
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectFile.h"

@implementation ProjectFile

- (NSString *)downloadPath{
    NSString *path = [NSString stringWithFormat:@"%@api/project/%@/files/%@/download", kNetPath_Code_Base, _project_id.stringValue, _file_id.stringValue];
    return path;
}

- (NSString *)diskFileName{
    if (!_diskFileName) {
//        _diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@|||%@|||%@|%@", _name, _project_id.stringValue, _parent_id.stringValue, _file_id.stringValue, _storage_type, _storage_key];
        _diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@|%@", _name, _project_id.stringValue, _storage_type, _storage_key];
    }
    return _diskFileName;
}

- (Coding_DownloadTask *)cTask{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    return [manager cTaskForKey:self.storage_key];
}
- (NSURL *)hasBeenDownload{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    NSURL *fileUrl = [manager diskUrlForFile:self.diskFileName];
    return fileUrl;
}
- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/project/%@/file/delete", _project_id.stringValue];
}
- (NSDictionary *)toDeleteParams{
    return @{@"fileIds" : @[_file_id.stringValue]};
}
- (NSDictionary *)toMoveToParams{
    return @{@"fileId" : @[_file_id.stringValue]};
}
@end

