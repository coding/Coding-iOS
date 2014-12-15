//
//  AddressManager.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-10.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressManager : NSObject
+ (AddressManager *)sharedManager;
+ (NSArray *)firstLevelArray;
+ (NSDictionary *)secondLevelMap;
+ (NSArray *)secondLevelArrayInFirst:(NSString *)firstLevelName;
+ (NSNumber *)indexOfFirst:(NSString *)firstLevelName;
+ (NSNumber *)indexOfSecond:(NSString *)secondLevelName inFirst:(NSString *)firstLevelName;
@end
