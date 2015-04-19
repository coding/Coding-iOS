//
//  ProjectTopicLabel.m
//  Coding_iOS
//
//  Created by 周文敏 on 15/4/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectTopicLabel.h"

@implementation ProjectTopicLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _id = [NSNumber numberWithInteger:0];
        _owner_id = [NSNumber numberWithInteger:0];
        _count = [NSNumber numberWithInteger:0];
        _type = [NSNumber numberWithInteger:1];
        
        _name = @"";
        _color = @"#d8f3e4";
    }
    return self;
}

- (NSString *)toLabelPath
{
    return [NSString stringWithFormat:@"api/project/%d/topic/label?", _owner_id.intValue];
}

- (NSString *)toDelPath
{
    return [NSString stringWithFormat:@"api/project/%d/topic/label/%lld", _owner_id.intValue, _id.longLongValue];
}

- (NSDictionary *)toModifyParams
{
    return @{@"label_id" : _id,
             @"name" : _name,
             @"color" : _color};
}

@end
