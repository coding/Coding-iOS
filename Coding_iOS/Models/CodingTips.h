//
//  CodingTips.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodingTip.h"

@interface CodingTips : NSObject
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow, *unreadCount;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (assign, nonatomic) NSInteger type;
@property (assign, nonatomic) BOOL onlyUnread;

+(CodingTips *)codingTipsWithType:(NSInteger)type;
- (NSString *)toTipsPath;
- (NSDictionary *)toTipsParams;
- (void)configWithObj:(CodingTips *)tips;

- (NSDictionary *)toMarkReadParams;

@end
