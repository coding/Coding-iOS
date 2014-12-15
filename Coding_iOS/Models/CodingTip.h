//
//  CodingTip.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HtmlMedia.h"


@interface CodingTip : NSObject

@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *status, *target_id, *type;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) NSString *content, *target_type;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;

@end
