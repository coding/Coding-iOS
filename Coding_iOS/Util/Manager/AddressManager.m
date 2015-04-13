//
//  AddressManager.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-10.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "AddressManager.h"

@interface AddressManager ()
@property (strong, nonatomic) NSArray *addressArray;
@property (strong, nonatomic) NSMutableArray *firstLevelArray;
@property (strong, nonatomic) NSMutableDictionary *secondLevelMap;
@end

@implementation AddressManager

+ (AddressManager *)sharedManager {
    static AddressManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"address" ofType:@"json"];
        NSError *error = nil;
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                      options:NSJSONReadingAllowFragments
                                                          error:&error];
        if (error) {
            DebugLog(@"address.json - fail: %@", error.description);
        }
        if (jsonObject) {
            shared_manager.addressArray = jsonObject;
            NSMutableArray *firstLevelArray = [[NSMutableArray alloc] initWithCapacity:35];
            NSMutableDictionary *secondLevelMap = [[NSMutableDictionary alloc] initWithCapacity:35];
            for (NSDictionary *firstLevelDict in jsonObject) {
                NSArray *secondLevelDictArray = [firstLevelDict objectForKey:@"c"];
                NSMutableArray *secondLevelArray = [[NSMutableArray alloc] init];
                for (NSDictionary *secondLevelDict in secondLevelDictArray) {
                    [secondLevelArray addObject:[secondLevelDict objectForKey:@"n"]];
                }
                [secondLevelMap setObject:secondLevelArray forKey:[firstLevelDict objectForKey:@"p"]];
                [firstLevelArray addObject:[firstLevelDict objectForKey:@"p"]];
            }
            shared_manager.firstLevelArray = firstLevelArray;
            shared_manager.secondLevelMap = secondLevelMap;
        }
    });
    return shared_manager;
}

+ (NSArray *)firstLevelArray{
    return [self sharedManager].firstLevelArray;
}
+ (NSDictionary *)secondLevelMap{
    return [self sharedManager].secondLevelMap;
}

+ (NSArray *)secondLevelArrayInFirst:(NSString *)firstLevelName{
    return [[self sharedManager].secondLevelMap objectForKey:firstLevelName];
}
+ (NSNumber *)indexOfFirst:(NSString *)firstLevelName{
    NSInteger index = [[self firstLevelArray] indexOfObject:firstLevelName];
    if (index == NSNotFound) {
        return nil;
    }
    return [NSNumber numberWithInteger:index];
}
+ (NSNumber *)indexOfSecond:(NSString *)secondLevelName inFirst:(NSString *)firstLevelName{
    NSInteger index = [[self secondLevelArrayInFirst:firstLevelName] indexOfObject:secondLevelName];
    if (index == NSNotFound) {
        return nil;
    }
    return [NSNumber numberWithInteger:index];
}

@end
