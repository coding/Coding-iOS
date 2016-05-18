//
//  NSTimer+Common.m
//  Coding_iOS
//
//  Created by Ease on 15/4/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "NSTimer+Common.h"

@implementation NSTimer (Common)
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void(^)())block repeats:(BOOL)yesOrNo{
    return [self scheduledTimerWithTimeInterval:ti target:self selector:@selector(blockInvoke:) userInfo:[block copy] repeats:yesOrNo];
}

+ (void)blockInvoke:(NSTimer *)timer{
    void (^block)() = timer.userInfo;
    if (block) {
        block();
    }
}
@end
