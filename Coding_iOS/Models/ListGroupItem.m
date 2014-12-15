//
//  ListGroupItem.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-19.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ListGroupItem.h"

@implementation ListGroupItem
+(ListGroupItem *)itemWithDate:(NSDate *)date andLocation:(NSUInteger)location{
    ListGroupItem *item = [[ListGroupItem alloc] init];
    item.date = date;
    item.location = location;
    item.length = 0;
    item.hide = NO;
    return item;
}
- (void)addOneItem{
    _length++;
}
- (void)deleteOneItem{
    _length--;
}
@end
