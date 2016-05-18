//
//  FileChanges.h
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileChange.h"

@interface FileChanges : NSObject
@property (strong, nonatomic) NSString *commitId;
@property (strong, nonatomic) NSNumber *insertions, *deletions;
@property (strong, nonatomic) NSMutableArray *paths;
@property (strong, nonatomic) NSDictionary *propertyArrayMap;
@end
