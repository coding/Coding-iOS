//
//  ProjectFolders.m
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectFolders.h"

@interface ProjectFolders ()
@property (strong, nonatomic, readwrite) NSArray *useToMoveList;
@end

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
//- (NSArray *)useToMoveList{
//    if (!_useToMoveList) {
//        _useToMoveList = _list.mutableCopy;
//        [(NSMutableArray *)_useToMoveList removeObjectAtIndex:0];
//    }
//    return _useToMoveList;
//}
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
             @"pageSize": @(99999999)};
}

- (NSString *)toFoldersCountPathWithObj:(NSNumber *)project_id{
    return [NSString stringWithFormat:@"api/project/%@/folders/all-file-count-with-share", project_id.stringValue];
}

@end
