//
//  ProjectFile.m
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectFile.h"
#import "Coding_FileManager.h"

@interface ProjectFile ()
@property (strong, nonatomic) NSString *project_name, *project_owner_name;
@end

@implementation ProjectFile

+(ProjectFile *)fileWithFileId:(NSNumber *)fileId andProjectId:(NSNumber *)project_id{
    ProjectFile *file = [[ProjectFile alloc] init];
    file.file_id = fileId;
    file.project_id = project_id;
    return file;
}

- (instancetype)initWithFileId:(NSNumber *)fileId inProject:(NSString *)project_name ofUser:(NSString *)project_owner_name{
    self = [super init];
    if (self) {
        _file_id = fileId;
        _project_id = nil;
        _project_name = project_name;
        _project_owner_name = project_owner_name;
    }
    return self;
}

- (void)setOwner_preview:(NSString *)owner_preview{
    _owner_preview = owner_preview;
    if (!_project_id && owner_preview.length > 0) {
        NSString *project_id;
        project_id = [[[[owner_preview componentsSeparatedByString:@"project/"] lastObject] componentsSeparatedByString:@"/"] firstObject];
        _project_id = @(project_id.integerValue);
    }
}

- (BOOL)isEmpty{
    return !(self.storage_key && self.storage_key.length > 0);
}
- (NSString *)fileIconName{
    NSString *fileType = self.fileType;
    
    if (!fileType) {
        fileType = @"";
    }
    fileType = [fileType lowercaseString];
    NSString *iconName;
    //XXX(s)
    if ([fileType hasPrefix:@"doc"]) {
        iconName = @"icon_file_doc";
    }else if ([fileType hasPrefix:@"ppt"]) {
        iconName = @"icon_file_ppt";
    }else if ([fileType hasPrefix:@"pdf"]) {
        iconName = @"icon_file_pdf";
    }else if ([fileType hasPrefix:@"xls"]) {
        iconName = @"icon_file_xls";
    }
    //XXX
    else if ([fileType isEqualToString:@"txt"]) {
        iconName = @"icon_file_txt";
    }else if ([fileType isEqualToString:@"ai"]) {
        iconName = @"icon_file_ai";
    }else if ([fileType isEqualToString:@"apk"]) {
        iconName = @"icon_file_apk";
    }else if ([fileType isEqualToString:@"md"]) {
        iconName = @"icon_file_md";
    }else if ([fileType isEqualToString:@"psd"]) {
        iconName = @"icon_file_psd";
    }
    //XXX||YYY
    else if ([fileType isEqualToString:@"zip"] || [fileType isEqualToString:@"rar"] || [fileType isEqualToString:@"arj"]) {
        iconName = @"icon_file_zip";
    }else if ([fileType isEqualToString:@"html"]
              || [fileType isEqualToString:@"xml"]
              || [fileType isEqualToString:@"java"]
              || [fileType isEqualToString:@"h"]
              || [fileType isEqualToString:@"m"]
              || [fileType isEqualToString:@"cpp"]
              || [fileType isEqualToString:@"json"]
              || [fileType isEqualToString:@"cs"]
              || [fileType isEqualToString:@"go"]) {
        iconName = @"icon_file_code";
    }else if ([fileType isEqualToString:@"avi"]
              || [fileType isEqualToString:@"rmvb"]
              || [fileType isEqualToString:@"rm"]
              || [fileType isEqualToString:@"asf"]
              || [fileType isEqualToString:@"divx"]
              || [fileType isEqualToString:@"mpeg"]
              || [fileType isEqualToString:@"mpe"]
              || [fileType isEqualToString:@"wmv"]
              || [fileType isEqualToString:@"mp4"]
              || [fileType isEqualToString:@"mkv"]
              || [fileType isEqualToString:@"vob"]) {
        iconName = @"icon_file_movie";
    }else if ([fileType isEqualToString:@"mp3"]
              || [fileType isEqualToString:@"wav"]
              || [fileType isEqualToString:@"mid"]
              || [fileType isEqualToString:@"asf"]
              || [fileType isEqualToString:@"mpg"]
              || [fileType isEqualToString:@"tti"]) {
        iconName = @"icon_file_music";
    }
    //unknown
    else{
        iconName = @"icon_file_unknown";
    }
    return iconName;
}

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
                [[Coding_FileManager sharedManager] removeCDownloadTaskForKey:self.storage_key];
            }
        }
    }
    return state;
}

- (NSString *)downloadPath{
    NSString *path = [NSString stringWithFormat:@"%@api/project/%@/files/%@/download", [NSObject baseURLStr], _project_id.stringValue, _file_id.stringValue];
    return path;
}

- (NSString *)diskFileName{
    if (!_diskFileName) {
//        _diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@|||%@|||%@|%@", _name, _project_id.stringValue, _parent_id.stringValue, _file_id.stringValue, _storage_type, _storage_key];
        _diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@|%@", _name, _project_id.stringValue, _storage_type, _storage_key];
    }
    return _diskFileName;
}

- (Coding_DownloadTask *)cDownloadTask{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    return [manager cDownloadTaskForKey:self.storage_key];
}
- (NSURL *)hasBeenDownload{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    NSURL *fileUrl = [manager diskDownloadUrlForFile:self.diskFileName];
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

- (NSString *)toDetailPath{
    NSString *path;
    if (!_project_id) {
        path = [NSString stringWithFormat:@"api/user/%@/project/%@/files/%@/view", _project_owner_name, _project_name, _file_id.stringValue];
    }else{
        path = [NSString stringWithFormat:@"api/project/%@/files/%@/view", _project_id.stringValue, _file_id.stringValue];
    }
    return path;
}

- (NSString *)toActivityListPath{
    return [NSString stringWithFormat:@"api/project/%@/file/%@/activities", _project_id.stringValue, _file_id.stringValue];
}

- (NSString *)toHistoryListPath{
    return [NSString stringWithFormat:@"api/project/%@/files/%@/histories", _project_id.stringValue, _file_id.stringValue];
}

@end

