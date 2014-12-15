//
//  NSDate+Common.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+Helper.h"
#import "NSDate+convenience.h"

@interface NSDate (Common)

- (BOOL)isSameDay:(NSDate*)anotherDate;

- (NSInteger)secondsAgo;
- (NSInteger)minutesAgo;
- (NSInteger)hoursAgo;
- (NSInteger)monthsAgo;
- (NSInteger)yearsAgo;

- (NSString *)stringTimesAgo;
- (NSString *)string_yyyy_MM_dd_EEE;
- (NSString *)stringTimeDisplay;

- (NSString *)string_yyyy_MM_dd;
- (NSString *)string_a_HH_mm;
+ (NSString *)convertStr_yyyy_MM_ddToDisplay:(NSString *)str_yyyy_MM_dd;

@end
