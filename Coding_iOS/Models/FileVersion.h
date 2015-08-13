//
//  FileVersion.h
//  Coding_iOS
//
//  Created by Ease on 15/8/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileVersion : NSObject
@property (strong, nonatomic) NSNumber *file_id, *history_id, *owner_id, *parent_id, *size, *type, *version, *action;
@property (strong, nonatomic) NSString *action_msg, *name, *remark, *storage_key, *storage_type;
@property (strong, nonatomic) NSDate *created_at;
@end
