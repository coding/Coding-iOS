//
//  PointRecords.h
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointRecord.h"

@interface PointRecords : NSObject
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow, *unreadCount;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSMutableArray *list;

- (NSString *)toPath;
- (NSDictionary *)toParams;
- (void)configWithObj:(PointRecords *)records;
@end
