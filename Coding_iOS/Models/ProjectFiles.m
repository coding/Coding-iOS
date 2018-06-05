//
//  ProjectFiles.m
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectFiles.h"

@implementation ProjectFiles
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectFile", @"list", nil];
        _list = [NSMutableArray array];
        _isLoading = NO;
    }
    return self;
}

- (void)setList:(NSMutableArray *)list{
    _list = list.mutableCopy;
    _folderList = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"type == 0"]]].mutableCopy ?: @[].mutableCopy;
    _fileList = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"type != 0"]]].mutableCopy ?: @[].mutableCopy;
    
}

- (void)addSharedFolder{
    ProjectFile *tempF = _list.firstObject;
    ProjectFile *sharedF = [ProjectFile sharedFolderInProject:tempF.project_name ofUser:tempF.project_owner_name];
    [_list insertObject:sharedF atIndex:0];
    [_folderList insertObject:sharedF atIndex:0];
}

@end
