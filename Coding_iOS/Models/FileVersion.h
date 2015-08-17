//
//  FileVersion.h
//  Coding_iOS
//
//  Created by Ease on 15/8/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectFile.h"

@interface FileVersion : NSObject
@property (strong, nonatomic) NSNumber *file_id, *history_id, *owner_id, *parent_id, *size, *type, *version, *action, *project_id;
@property (strong, nonatomic) NSString *action_msg, *name, *remark, *storage_key, *storage_type, *fileType, *preview, *owner_preview;
@property (strong, nonatomic) NSDate *created_at;
@property (readwrite, nonatomic, strong) User *owner;

@property (strong, nonatomic, readonly) NSString *diskFileName;

- (NSString *)downloadPath;

- (NSString *)toRemarkPath;
- (NSString *)toDeletePath;

//download
- (DownloadState)downloadState;
- (Coding_DownloadTask *)cDownloadTask;
- (NSURL *)hasBeenDownload;
@end
