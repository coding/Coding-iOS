//
//  JobManager.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "JobManager.h"
@interface JobManager ()
@property (nonatomic, strong) NSMutableArray *jobNameArray;
@end

@implementation JobManager

- (NSArray *)jobNameArray{
    if (_jobDict) {
        if (!_jobNameArray) {
            _jobNameArray = [[NSMutableArray alloc] init];
            NSArray *keys = [_jobDict allKeys];
            keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2 options:NSNumericSearch];
            }];
            for (NSString *key in keys) {
                [_jobNameArray addObject:[_jobDict objectForKey:key]];
            }
        }
        return _jobNameArray;
    }else{
        return @[@"暂无选项"];
    }
}
- (NSString *)jobNameWithIndex:(NSNumber *)index{
    NSString *jobName;
    if (_jobDict) {
        jobName = [_jobDict objectForKey:index.stringValue];
    }else{
        jobName = nil;
    }
    return jobName;
}
- (NSNumber *)indexOfJobName:(NSString *)job_str{
    NSInteger index = 0;
    if (_jobNameArray) {
        index = [_jobNameArray indexOfObject:job_str];
    }
    if (index == NSNotFound) {
        index = 0;
    }
    return [NSNumber numberWithInteger:index];
}
@end
