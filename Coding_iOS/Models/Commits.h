//
//  Commits.h
//  Coding_iOS
//
//  Created by Ease on 15/6/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Commit.h"
#import "ListGroupItem.h"

@interface Commits : NSObject

@property (strong, nonatomic) NSString *ref, *path;

@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSNumber *totalPage, *totalRow;
@property (readwrite, nonatomic, strong) NSMutableArray *list, *listGroups;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;

+ (Commits *)commitsWithRef:(NSString *)ref Path:(NSString *)path;

- (NSDictionary *)toParams;
- (void)configWithCommits:(Commits *)responseCommits;
@end
