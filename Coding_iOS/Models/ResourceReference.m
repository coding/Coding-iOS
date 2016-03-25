//
//  ResourceReference.m
//  Coding_iOS
//
//  Created by Ease on 16/2/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "ResourceReference.h"

@implementation ResourceReference
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = @{@"Task": @"ResourceReferenceItem",
                              @"MergeRequestBean": @"ResourceReferenceItem",
                              @"ProjectTopic": @"ResourceReferenceItem",
                              @"ProjectFile": @"ResourceReferenceItem",
                              };

    }
    return self;
}
- (NSMutableArray *)itemList{
    if (!_itemList) {
        _itemList = [NSMutableArray new];
        [_itemList addObjectsFromArray:_Task];
        [_itemList addObjectsFromArray:_ProjectTopic];
        [_itemList addObjectsFromArray:_ProjectFile];
        [_itemList addObjectsFromArray:_MergeRequestBean];
    }
    return _itemList;
}
@end

@implementation ResourceReferenceItem

@end