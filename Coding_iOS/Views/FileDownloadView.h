//
//  FileDownloadView.h
//  Coding_iOS
//
//  Created by Ease on 14/12/16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectFile.h"
#import "FileVersion.h"

@interface FileDownloadView : UIView
@property (nonatomic,copy) void(^completionBlock)();
@property (nonatomic,copy) void(^otherMethodOpenBlock)();//用其他应用打开

- (void)setFile:(ProjectFile *)file version:(FileVersion *)version;
- (void)reloadData;
- (DownloadState)downloadState;
- (void)startDownload;
@end
