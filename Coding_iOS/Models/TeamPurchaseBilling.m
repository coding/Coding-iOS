//
//  TeamPurchaseBilling.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "TeamPurchaseBilling.h"

@implementation TeamPurchaseBilling

- (NSDictionary *)propertyArrayMap{
    return @{@"details": @"TeamPurchaseBillingDetail"};
}

- (void)setDetails:(NSArray *)details{
    _details = details;
    NSSet *daySet = [NSSet setWithArray:[_details valueForKey:@"days"]];
    NSArray *dayArray = [daySet sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(compare:)]]];
    NSMutableArray *details_display = @[].mutableCopy;
    for (NSNumber *day in dayArray) {
        NSArray *list = [_details filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"days = %@", day]];
//        NSString *displayStr = [NSString stringWithFormat:@"%lu 人，已使用 %@ 天", (unsigned long)list.count, day];
        NSString *displayStr = [NSString stringWithFormat:@"%lu 人", (unsigned long)list.count];
        [details_display addObject:displayStr];
    }
    _details_display = details_display;
}
@end
