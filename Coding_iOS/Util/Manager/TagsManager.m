//
//  TagsManager.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TagsManager.h"

@implementation TagsManager
- (NSString *)getTags_strWithTags:(NSArray *)tags{
    NSString *tags_str;
    if (tags && tags.count > 0) {
        NSMutableArray *tags_strArray = [[NSMutableArray alloc] init];
        for (NSString *tag in tags) {
            for (Tag *curTag in _tagArray) {
                if ([tag isEqualToString:curTag.id.stringValue]) {
                    [tags_strArray addObject:curTag.name];
                }
            }
        }
        tags_str = [tags_strArray componentsJoinedByString:@","];
    }else{
        tags_str = @"";
    }
    return tags_str;
}
@end

@implementation Tag

@end