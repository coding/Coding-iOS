//
//  ProjectFolders.h
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectFolder.h"

@interface ProjectFolders : NSObject
@property (readwrite, nonatomic, strong) NSMutableArray *list;
//@property (strong, nonatomic, readonly) NSArray *useToMoveList;
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (strong, nonatomic) NSDictionary *propertyArrayMap;
@property (assign, nonatomic) BOOL isLoading;
+ (ProjectFolders *)emptyFolders;
- (BOOL)isEmpty;
- (ProjectFolder *)hasFolderWithId:(NSNumber *)file_id;

- (NSString *)toFoldersPathWithObj:(NSNumber *)project_id;
- (NSDictionary *)toFoldersParams;

- (NSString *)toFoldersCountPathWithObj:(NSNumber *)project_id;

@end
