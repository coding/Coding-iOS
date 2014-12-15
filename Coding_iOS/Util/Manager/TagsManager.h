//
//  TagsManager.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagsManager : NSObject
@property (readwrite, nonatomic, strong) NSArray *tagArray;
- (NSString *)getTags_strWithTags:(NSArray *)tags;
@end

@interface Tag : NSObject
@property (readwrite, nonatomic, strong) NSDate *created_at, *updated_at;
@property (readwrite, nonatomic, strong) NSNumber *id;
@property (readwrite, nonatomic, strong) NSString *name, *type;
@end