//
//  QcTask.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-22.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface QcTask : NSObject
@property (readwrite, nonatomic, strong) NSString *link;
@property (readwrite, nonatomic, strong) User *user;

@end
