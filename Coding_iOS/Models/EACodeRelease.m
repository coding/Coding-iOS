//
//  EACodeRelease.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EACodeRelease.h"

@implementation EACodeRelease
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.propertyArrayMap = @{@"resource_references": @"ResourceReferenceItem",
                                  @"attachments": @"EACodeReleaseAttachment",
                                  };
        _contentHeight = 1.0;
    }
    return self;
}

- (NSString *)editTitle{
    if (!_editTitle) {
        _editTitle = _title.copy;
    }
    return _editTitle;
}

- (NSString *)editBody{
    if (!_editBody) {
        _editBody = _body.copy;
    }
    return _editBody;
}

- (BOOL)hasChanged{
    return ![_editTitle isEqualToString:_title] || ![_editBody isEqualToString:_body];
}

- (NSString *)editPath{
    return [NSString stringWithFormat:@"api/user/%@/project/%@/git/releases/update/%@", _project.owner_user_name, _project.name, _tag_name];
}
- (NSDictionary *)editParams{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"title"] = _editTitle;
    params[@"body"] = _editBody;
    
    params[@"tag_name"] = _tag_name;
    params[@"commit_sha"] = _commit_sha;
    params[@"target_commitish"] = _target_commitish;
    params[@"draft"] = _draft;
    params[@"pre"] = _pre;
    
    if (_resource_references.count > 0) {
        params[@"resource_references"] = [_resource_references valueForKey:@"code"];
    }
    for (EACodeReleaseAttachment *item in _attachments) {
        params[[NSString stringWithFormat:@"attachments[%@]", item.id]] = item.name;
    }
    return params;
}

@end


@implementation EACodeReleaseAttachment

@end

