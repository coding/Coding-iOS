//
//  ListGroupItem.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-19.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListGroupItem : NSObject
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) NSUInteger location, length;
@property (assign, nonatomic) BOOL hide;

+(ListGroupItem *)itemWithDate:(NSDate *)date andLocation:(NSUInteger)location;
- (void)addOneItem;
- (void)deleteOneItem;

@end
