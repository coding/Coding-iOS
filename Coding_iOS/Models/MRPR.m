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
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", iidStr, titleStr]];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x4E90BF"]}
                         range:NSMakeRange(0, iidStr.length)];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x333333"]}
                         range:NSMakeRange(iidStr.length + 1, titleStr.length)];
    return attriString;

}
- (NSAttributedString *)attributeTail{
    NSString *nameStr = _author.name? _author.name: @"";
    NSString *timeStr = _created_at? [_created_at stringTimesAgo]: @"";
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", nameStr, timeStr]];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x333333"]}
                         range:NSMakeRange(0, nameStr.length)];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0xA9A9A9"]}
                         range:NSMakeRange(nameStr.length + 1, timeStr.length)];
    return attriString;
}

- (NSString *)toCommentsPath{
    NSArray *pathComponents = [_path componentsSeparatedByString:@"/"];
    if (pathComponents.count == 7) {
        return [NSString stringWithFormat:@"api/user/%@/project/%@/git/%@/%@/comments", pathComponents[1], pathComponents[3], pathComponents[5], pathComponents[6]];
    }else{
        return nil;
    }
}
@end
