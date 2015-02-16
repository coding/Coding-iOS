//
//  UnReadManager.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-23.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnReadManager : NSObject
@property (strong, nonatomic) NSNumber *messages, *notifications, *project_update_count;

+ (instancetype)shareManager;
- (void)updateUnRead;
@end
