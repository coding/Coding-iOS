//
//  FileActivityCell.m
//  Coding_iOS
//
//  Created by Ease on 15/8/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileActivityCell.h"

@implementation FileActivityCell

+ (NSAttributedString *)attrContentWithObj:(ProjectActivity *)curActivity{
    if (![curActivity.target_type isEqualToString:@"ProjectFile"]) {
        return nil;
    }
    
    NSString *userName, *contentStr;
    userName = curActivity.user.name? curActivity.user.name: @"";
    NSMutableAttributedString *attrContent;
    
    if ([curActivity.action isEqualToString:@"delete_history"]) {
        contentStr = [NSString stringWithFormat:@"%@ 历史版本 V%@ - %@", curActivity.action_msg, curActivity.version, [curActivity.created_at stringDisplay_HHmm]];

    }else{
        contentStr = [NSString stringWithFormat:@"%@ 文件 - %@", curActivity.action_msg, [curActivity.created_at stringDisplay_HHmm]];
    }
    
    attrContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", userName, contentStr]];
    [attrContent addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:13],
                                 NSForegroundColorAttributeName : kColor222}
                         range:NSMakeRange(0, userName.length)];
    [attrContent addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13],
                                 NSForegroundColorAttributeName : kColor999}
                         range:NSMakeRange(userName.length + 1, contentStr.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.minimumLineHeight = 18;
    
    [attrContent addAttribute:NSParagraphStyleAttributeName
                        value:paragraphStyle
                        range:NSMakeRange(0, [attrContent length])];
    return attrContent;
}

@end
