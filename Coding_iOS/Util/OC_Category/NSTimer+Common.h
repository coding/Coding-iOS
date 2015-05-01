//
//  NSTimer+Common.h
//  Coding_iOS
//
//  Created by Ease on 15/4/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Common)
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void(^)())block repeats:(BOOL)yesOrNo;
@end
