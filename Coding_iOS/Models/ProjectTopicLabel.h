//
//  ProjectTopicLabel.h
//  Coding_iOS
//
//  Created by 周文敏 on 15/4/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectTopicLabel : NSObject

@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *count, *type;
@property (readwrite, nonatomic, strong) NSString *name, *color;

- (NSDictionary *)toModifyParams;
- (NSString *)toDelPath;
- (NSString *)toLabelPath;

@end
