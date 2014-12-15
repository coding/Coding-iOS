//
//  TaskComment.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/17.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskComment : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *taskId;
@property (readwrite, nonatomic, strong) NSString *content;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (readwrite, nonatomic, strong) NSDate *created_at;

@end
