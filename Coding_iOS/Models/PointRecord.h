//
//  PointRecord.h
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HtmlMedia.h"

@interface PointRecord : NSObject
@property (strong, nonatomic) NSDate *created_at;
@property (strong, nonatomic) NSString *usage, *remark;
@property (strong, nonatomic) NSNumber *points_change, *points_left, *action;
@property (strong, nonatomic) HtmlMedia *htmlMedia;
@end
