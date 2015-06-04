//
//  MRPR.m
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPR.h"

@implementation MRPR
- (NSAttributedString *)attributeTitle{
    NSString *iidStr = [NSString stringWithFormat:@"#%@", _iid.stringValue? _iid.stringValue: @""];
    NSString *titleStr = _title? _title: @"";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", iidStr, titleStr]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x4E90BF"]}
                         range:NSMakeRange(0, iidStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x333333"]}
                         range:NSMakeRange(iidStr.length + 1, titleStr.length)];
    return attrString;

}
- (NSAttributedString *)attributeTail{
    NSString *nameStr = _author.name? _author.name: @"";
    NSString *timeStr = _created_at? [_created_at stringTimesAgo]: @"";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", nameStr, timeStr]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x333333"]}
                         range:NSMakeRange(0, nameStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0xA9A9A9"]}
                         range:NSMakeRange(nameStr.length + 1, timeStr.length)];
    return attrString;
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
        case MRPRStatusAccept:
            statusDisplay = @"已合并";
            break;
        case MRPRStatusRefuse:
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
        _status = MRPRStatusAccept;
    }else if ([_merge_status isEqualToString:@"REFUSED"]){
        _status = MRPRStatusRefuse;
    }else if ([_merge_status isEqualToString:@"CANCEL"]){
        _status = MRPRStatusCancel;
    }
}

@end
