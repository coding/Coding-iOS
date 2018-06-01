//
//  TeamMember.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TeamMember.h"

@implementation TeamMember

- (NSString *)editAlias{
    if (!_editAlias) {
        _editAlias = _alias ?: @"";
    }
    return _editAlias;
}
- (NSNumber *)editRole{
    if (!_editRole) {
        _editRole = _role;
    }
    return _editRole;
}

@end
