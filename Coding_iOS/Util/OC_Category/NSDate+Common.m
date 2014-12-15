//
//  NSDate+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "NSDate+Common.h"

@implementation NSDate (Common)

- (BOOL)isSameDay:(NSDate*)anotherDate{
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];
	return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}
- (NSInteger)secondsAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSSecondCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    NSDate *now = [NSDate date];
    NSLog(@"creat:%@   now:%@", self.description, now.description);
    return [components second];
}
- (NSInteger)minutesAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSMinuteCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components minute];
}
- (NSInteger)hoursAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components hour];
}
- (NSInteger)monthsAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSMonthCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components month];
}

- (NSInteger)yearsAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components year];
}

- (NSString *)stringTimesAgo{
    if ([self compare:[NSDate date]] == NSOrderedDescending) {
        return @"刚刚";
    }
    
    NSString *text = nil;

    NSInteger agoCount = [self monthsAgo];
    if (agoCount > 0) {
        text = [NSString stringWithFormat:@"%ld个月前", (long)agoCount];
    }else{
        agoCount = [self daysAgoAgainstMidnight];
        if (agoCount > 0) {
            text = [NSString stringWithFormat:@"%ld天前", (long)agoCount];
        }else{
            agoCount = [self hoursAgo];
            if (agoCount > 0) {
                text = [NSString stringWithFormat:@"%ld小时前", (long)agoCount];
            }else{
                agoCount = [self minutesAgo];
                if (agoCount > 0) {
                    text = [NSString stringWithFormat:@"%ld分钟前", (long)agoCount];
                }else{
                    agoCount = [self secondsAgo];
                    if (agoCount > 15) {
                        text = [NSString stringWithFormat:@"%ld秒前", (long)agoCount];
                    }else{
                        text = @"刚刚";
                    }
                }
            }
        }
    }
    return text;
}

- (NSString *)string_yyyy_MM_dd_EEE{
    NSString *text = [self stringWithFormat:@"yyyy-MM-dd EEE"];
    NSInteger daysAgo = [self daysAgoAgainstMidnight];
    switch (daysAgo) {
        case 0:
            text = [text stringByAppendingString:@"（今天）"];
            break;
        case 1:
            text = [text stringByAppendingString:@"（昨天）"];
            break;
        default:
            break;
    }
    return text;
}
- (NSString *)stringTimeDisplay{
    NSString *text = nil;
    NSInteger daysAgo = [self daysAgoAgainstMidnight];
    NSString *dateStr;
    switch (daysAgo) {
        case 0:
            dateStr = @"今天";
            break;
        case 1:
            dateStr = @"昨天";
            break;
        default:
            dateStr = [self stringWithFormat:@"MM-dd"];
            break;
    }
    text = [NSString stringWithFormat:@"%@ %@", dateStr, [self string_a_HH_mm]];
    return text;
    
//    NSString *text = nil;
//    NSInteger daysAgo = [self daysAgoAgainstMidnight];
//    switch (daysAgo) {
//        case 0:
//            text = [NSString stringWithFormat:@"今天 %@", [self stringWithFormat:@"a hh:mm"]];
//            break;
//        case 1:
//            text = [NSString stringWithFormat:@"昨天 %@", [self stringWithFormat:@"a hh:mm"]];
//            break;
//        default:
//            text = [self stringWithFormat:@"MM-dd a hh:mm"];
//            break;
//    }
//    text = [text stringByReplacingOccurrencesOfString:@"上午 12" withString:@"上午 00"];
//    return text;
}

- (NSString *)string_yyyy_MM_dd{
    return [self stringWithFormat:@"yyyy-MM-dd"];
}

- (NSString *)string_a_HH_mm{
    NSString *text = nil;
    NSString *aStr, *timeStr;
    timeStr = [self stringWithFormat:@"hh:mm"];
    NSUInteger hour = [self hour];
    if (hour < 3) {
        aStr = @"凌晨";
    }else if (hour >= 3 && hour < 12){
        aStr = @"上午";
    }else if (hour >= 12 && hour < 13){
        aStr = @"中午";
    }else if (hour >= 13 && hour < 18){
        aStr = @"下午";
    }else{
        aStr = @"晚上";
    }
    text = [NSString stringWithFormat:@"%@ %@", aStr, timeStr];
    return text;
}
+ (NSString *)convertStr_yyyy_MM_ddToDisplay:(NSString *)str_yyyy_MM_dd{
    NSString *displayStr = @"";
    if (str_yyyy_MM_dd && str_yyyy_MM_dd.length > 0) {
        NSDate *date = [NSDate dateFromString:str_yyyy_MM_dd withFormat:@"yyyy-MM-dd"];
        if (date) {
            NSDate *today = [NSDate dateFromString:[[NSDate date] stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];
            if ([date year] != [today year]) {
                displayStr = [date stringWithFormat:@"yyyy年MM月dd日"];
            }else{
                NSCalendar *calendar = [[self class] sharedCalendar];
                NSDateComponents *components = [calendar components:(NSDayCalendarUnit)
                                                           fromDate:today
                                                             toDate:date
                                                            options:0];
                NSInteger leftDayCount = [components day];
                switch (leftDayCount) {
                    case 2:
                        displayStr = @"后天";
                        break;
                    case 1:
                        displayStr = @"明天";
                        break;
                    case 0:
                        displayStr = @"今天";
                        break;
                    case -1:
                        displayStr = @"昨天";
                        break;
                    case -2:
                        displayStr = @"前天";
                        break;
                    default:
                        displayStr = [date stringWithFormat:@"MM月dd日"];
                        break;
                }
            }
        }
        
    }
    return displayStr;
}

@end
