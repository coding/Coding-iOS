//
//  ProjectFolders.m
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectFolders.h"

@implementation ProjectFolders
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectFolder", @"list", nil];
        _list = [NSMutableArray array];
        _isLoading = NO;
    }
    return self;
}
+ (ProjectFolders *)emptyFolders{
    return [[ProjectFolders alloc] init];
}
- (BOOL)isEmpty{
    return (!self.list || self.list.count <= 0);
}

- (ProjectFolder *)hasFolderWithId:(NSNumber *)file_id{
    if (!file_id || [self isEmpty]) {
        return nil;
    }
    ProjectFolder *resultFolder;
    for (ProjectFolder *folder in self.list) {
        resultFolder = [folder hasFolderWithId:file_id];
        if (resultFolder) {
            return resultFolder;
        }
    }
    return nil;
}

- (NSString *)toFoldersPathWithObj:(NSNumber *)project_id{
    return [NSString stringWithFormat:@"api/project/%@/all_folders", project_id.stringValue];
}
- (NSDictionary *)toFoldersParams{
    return @{@"page": @"1",
             @"pageSize": @"9999"};
}

- (NSString *)toFoldersCountPathWithObj:(NSNumber *)project_id{
    return [NSString stringWithFormat:@"api/project/%@/folders/all_file_count", project_id.stringValue];
}

@end
