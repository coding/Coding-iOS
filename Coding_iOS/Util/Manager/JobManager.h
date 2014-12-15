//
//  JobManager.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JobManager : NSObject
@property (readwrite, nonatomic, strong) NSDictionary *jobDict;
- (NSArray *)jobNameArray;
- (NSString *)jobNameWithIndex:(NSNumber *)index;
- (NSNumber *)indexOfJobName:(NSString *)job_str;
@end