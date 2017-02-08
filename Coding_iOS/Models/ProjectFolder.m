//
//  ProjectFolder.m
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectFolder.h"

@implementation ProjectFolder
+ (ProjectFolder *)defaultFolder{
    ProjectFolder *folder = [[ProjectFolder alloc] init];
    folder.file_id = [NSNumber numberWithInteger:0];
    folder.name = @"默认文件夹";
    return folder;
}
+ (ProjectFolder *)shareFolder{
    ProjectFolder *folder = [[ProjectFolder alloc] init];
    folder.file_id = [NSNumber numberWithInteger:-1];
    folder.name = @"分享中";
    return folder;
}
+ (ProjectFolder *)outFolder{
    ProjectFolder *folder = [[ProjectFolder alloc] init];
    folder.file_id = [NSNumber numberWithInteger:0];
    folder.name = @"移出目录";
    return folder;
}
+ (ProjectFolder *)folderWithId:(NSNumber *)file_id{
    ProjectFolder *folder = [[ProjectFolder alloc] init];
    folder.sub_folders = [NSMutableArray array];
    folder.file_id = file_id;
    return folder;
}
- (ProjectFolder *)hasFolderWithId:(NSNumber *)file_id{
    if (!file_id || !_file_id) {
        return nil;
    }
    if (_file_id.integerValue == file_id.integerValue) {
        return self;
    }else{
        for (ProjectFolder *sub_folder in self.sub_folders) {
            if (sub_folder.file_id.integerValue == file_id.integerValue) {
                return sub_folder;
            }
        }
    }
    return nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectFolder", @"sub_folders", nil];
    }
    return self;
}
- (BOOL)isDefaultFolder{
    return _file_id && _file_id.integerValue == 0;
}
- (BOOL)isShareFolder{
    return _file_id && _file_id.integerValue == -1;
}
- (BOOL)isOutFolder{
    return _file_id && _file_id.integerValue == 0 && [_name isEqualToString:@"移出目录"];
}
- (BOOL)canCreatSubfolder{
    return !((_parent_id && _parent_id.integerValue != 0) || [self isDefaultFolder]);
}
- (NSInteger)fileCountIncludeSub{
    NSInteger fileCount = self.count.integerValue;
    for (ProjectFolder *subFolder in self.sub_folders) {
        fileCount += subFolder.fileCountIncludeSub;
    }
    return fileCount;
}
- (NSString *)toFilesPath{
    if ([self isShareFolder]) {
        return [NSString stringWithFormat:@"api/project/%@/shared_files", _project_id];
    }else{
        return [NSString stringWithFormat:@"api/project/%@/files/%@", _project_id, _file_id];
    }
}
- (NSDictionary *)toFilesParams{
    return @{@"height": @"90",
             @"width": @"90",
             @"page" : @"1",
             @"pageSize": @(99999999)};
}
- (NSString *)toRenamePath{
    return [NSString stringWithFormat:@"api/project/%@/dir/%@/name/%@", _project_id.stringValue, _file_id.stringValue, _next_name];
}
- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/project/%@/rmdir/%@", _project_id.stringValue, _file_id.stringValue];
}
- (NSString *)toMoveToPath{
    return [NSString stringWithFormat:@"api/project/%@/files/moveto/%@", _project_id.stringValue, _file_id.stringValue];
}
@end
