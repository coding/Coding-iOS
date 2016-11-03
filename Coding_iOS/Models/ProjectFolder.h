//
//  ProjectFolder.h
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Projects.h"

@interface ProjectFolder : NSObject
@property (readwrite, nonatomic, strong) NSDate *created_at, *updated_at;
@property (readwrite, nonatomic, strong) NSNumber *project_id, *file_id, *owner_id, *parent_id, *type, *count;
@property (readwrite, nonatomic, strong) NSString *name, *owner_name, *next_name;
@property (readwrite, nonatomic, strong) NSMutableArray *sub_folders;
@property (strong, nonatomic) NSDictionary *propertyArrayMap;
+ (ProjectFolder *)defaultFolder;
+ (ProjectFolder *)shareFolder;
+ (ProjectFolder *)outFolder;
+ (ProjectFolder *)folderWithId:(NSNumber *)file_id;
- (ProjectFolder *)hasFolderWithId:(NSNumber *)file_id;

- (BOOL)isDefaultFolder;
- (BOOL)isShareFolder;
- (BOOL)isOutFolder;
- (BOOL)canCreatSubfolder;
- (NSInteger)fileCountIncludeSub;

- (NSString *)toFilesPath;
- (NSDictionary *)toFilesParams;

- (NSString *)toRenamePath;
- (NSString *)toDeletePath;

- (NSString *)toMoveToPath;
@end
