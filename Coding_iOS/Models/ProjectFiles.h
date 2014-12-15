//
//  ProjectFiles.h
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectFile.h"
#import "ProjectFolder.h"

@interface ProjectFiles : NSObject
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (strong, nonatomic) NSDictionary *propertyArrayMap;
@property (assign, nonatomic) BOOL isLoading;

@end
