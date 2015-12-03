//
//  MRPR.m
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPR.h"

@implementation MRPR

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"NSString", @"body", nil];
    }
    return self;
}


+ (MRPR *)mrprWithPath:(NSString *)path{
    MRPR *mrpr = [MRPR new];
    mrpr.path = path;
    return mrpr;
}

- (void)setPath:(NSString *)path{
    _path = path;
    NSArray *pathComponents = [_path componentsSeparatedByString:@"/"];
    if (pathComponents.count == 8) {
        _des_owner_name = pathComponents[2];
        _des_project_name = pathComponents[4];
    }
}

- (NSString *)statusDisplay{
    NSString *statusDisplay;
    switch (_status) {
        case MRPRStatusCanMerge:
            statusDisplay = @"可合并";
            break;
        case MRPRStatusCannotMerge:
            statusDisplay = @"不可自动合并";
            break;
        case MRPRStatusAccepted:
            statusDisplay = @"已合并";
            break;
        case MRPRStatusRefused:
            statusDisplay = @"已拒绝";
            break;
        case MRPRStatusCancel:
            statusDisplay = @"已取消";
            break;
        default:
            break;
    }
    return statusDisplay;
}

- (BOOL)isMR{
    return [_path rangeOfString:@"/merge/"].location != NSNotFound;
}
- (BOOL)isPR{
    return [_path rangeOfString:@"/pull/"].location != NSNotFound;
}
- (NSString *)toBasePath{
    return [[self p_prePath] stringByAppendingString:@"base"];
}

- (NSString *)toCommitsPath{
    return [[self p_prePath] stringByAppendingString:@"commits"];
}

- (NSString *)toFileLineChangesPath{
    return [[self p_prePath] stringByAppendingString:@"commitDiffContent"];
}

- (NSString *)toAcceptPath{
    return [[self p_prePath] stringByAppendingString:@"merge"];
}
- (NSDictionary *)toAcceptParams{
    if (_can_edit_src_branch) {
        return @{@"del_source_branch": _del_source_branch? @"true": @"false",
                 @"message" : _message? _message: @""};
    }else{
        return @{@"message" : _message? _message: @""};
    }
}
- (NSString *)toRefusePath{
    return [[self p_prePath] stringByAppendingString:@"refuse"];
}
- (NSString *)toCancelPath{
    return [[self p_prePath] stringByAppendingString:@"cancel"];
}

- (NSString *)toFileChangesPath{
    return [[self p_prePath] stringByAppendingString:@"commitDiffStat"];
}

- (NSString *)p_prePath{
    NSString *prePath = nil;
    NSArray *pathComponents = [_path componentsSeparatedByString:@"/"];
    if (pathComponents.count == 8) {
        prePath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/%@/%@/", pathComponents[2], pathComponents[4], pathComponents[6], pathComponents[7]];
    }
    return prePath;
}

- (void)setMerge_status:(NSString *)merge_status{
    _merge_status = merge_status;
    if ([_merge_status isEqualToString:@"CANMERGE"]) {
        _status = MRPRStatusCanMerge;
    }else if ([_merge_status isEqualToString:@"CANNOTMERGE"]){
        _status = MRPRStatusCannotMerge;
    }else if ([_merge_status isEqualToString:@"ACCEPTED"]){
        _status = MRPRStatusAccepted;
    }else if ([_merge_status isEqualToString:@"REFUSED"]){
        _status = MRPRStatusRefused;
    }else if ([_merge_status isEqualToString:@"CANCEL"]){
        _status = MRPRStatusCancel;
    }
}

@end
