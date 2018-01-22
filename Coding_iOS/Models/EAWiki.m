//
//  EAWiki.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/4/5.
//  Copyright © 2017年 Coding. All rights reserved.
//
#define kEAWiki_MaxLevel 3

#import "EAWiki.h"

@interface EAWiki ()
@property (readwrite, strong, nonatomic) EAWiki *parentWiki;
@property (readwrite, nonatomic, strong) NSArray *childrenDisplayList;
@end

@implementation EAWiki

- (instancetype)init{
    self = [super init];
    if (self) {
        _isExpanded = YES;
        _parentWiki = nil;
    }
    return self;
}

- (NSDictionary *)propertyArrayMap{
    return @{@"children": @"EAWiki"};
}

- (void)setChildren:(NSArray *)children{
    _children = children;
    for (EAWiki *wiki in _children) {
        wiki.parentWiki = self;
    }
}

- (NSInteger)lavel{
    NSInteger lavel = 0;
    EAWiki *tempWiki = self;
    while (tempWiki.parentWiki) {
        tempWiki = tempWiki.parentWiki;
        lavel += 1;
    }
//    return lavel;
    return MIN(lavel, kEAWiki_MaxLevel);
}

- (BOOL)isHistoryVersion{
    return _currentVersion.integerValue < _lastVersion.integerValue;
}

- (BOOL)hasChildren{
    return self.childrenDisplayList.count > 0;
}

- (NSString *)mdTitle{
    if (!_mdTitle) {
        _mdTitle = _title.copy;
    }
    return _mdTitle;
}

- (NSString *)mdContent{
    if (!_mdContent) {
        _mdContent = _content.copy;
    }
    return _mdContent;
}

- (NSArray *)childrenDisplayList{
//    return _children;
    if (self.lavel < kEAWiki_MaxLevel - 1) {
        return _children;
    }else
    if (!_childrenDisplayList) {
        if (self.lavel < kEAWiki_MaxLevel - 1) {
            _childrenDisplayList = _children.copy;
        }else if (self.lavel == kEAWiki_MaxLevel - 1){
            _childrenDisplayList = [self allChildren].copy;
        }else{
            _childrenDisplayList = @[];
        }
    }
    return _childrenDisplayList;
}

- (NSArray *)allChildren{
    NSMutableArray *list = _children? _children.mutableCopy: @[].mutableCopy;
    for (EAWiki *wiki in _children) {
        NSArray *childrenList = [wiki allChildren];
        NSUInteger loc = [list indexOfObject:wiki];
        if (childrenList.count > 0 && loc != NSNotFound) {
            [list insertObjects:childrenList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc + 1, childrenList.count)]];
        }
    }
    return list;
}

- (BOOL)hasDraft{
    NSDictionary *data = [NSObject loadResponseWithPath:[self p_draftPath]];
    return data != nil;
}
- (BOOL)draftVersionChanged{
    NSDictionary *data = [NSObject loadResponseWithPath:[self p_draftPath]];
    NSNumber *draftVersion = data[@"draftVersion"];
    if (draftVersion.integerValue < _currentVersion.integerValue) {
        return YES;
    }
    return NO;
}
- (BOOL)hasChanged{
    return ![_mdTitle isEqualToString:_title] || ![_mdContent isEqualToString:_content];
}
- (void)saveDraft{
    [NSObject saveResponseData:[self p_draftData] toPath:[self p_draftPath]];
}
- (void)readDraft{
    NSDictionary *data = [NSObject loadResponseWithPath:[self p_draftPath]];
    self.mdTitle = data[@"mdTitle"];
    self.mdContent = data[@"mdContent"];
    self.draftVersion = data[@"draftVersion"];
}
- (void)deleteDraft{
    [NSObject deleteResponseCacheForPath:[self p_draftPath]];
}
- (NSString *)p_draftPath{
    return [NSString stringWithFormat:@"wiki_%@", _id];
}
- (NSDictionary *)p_draftData{
    return @{@"mdTitle": _mdTitle ?: @"",
             @"mdContent": _mdContent ?: @"",
             @"draftVersion": _currentVersion ?: @0};
}

- (NSDictionary *)toShareParams{
    return @{
             @"projectId": _project_id,
             @"resourceId": _iid,
             @"resourceType": @2,
             @"accessType": @0
             };
}

@end
