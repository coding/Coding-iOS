//
//  ProjectLineNoteActivity.m
//  Coding_iOS
//
//  Created by Ease on 15/5/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectLineNoteActivity.h"

@implementation ProjectLineNoteActivity
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeImageAndMonkey];
        _content = _htmlMedia.contentDisplay;
    }
}

- (NSString *)noteable_type{
    if ([_noteable_type isEqualToString:@"Commit"]) {
        return @"Commit";
    }else if ([_noteable_type isEqualToString:@"MergeRequestBean"]) {
        return @"MergeRequest";
    }else if ([_noteable_type isEqualToString:@"PullRequestBean"]) {
        return @"PullRequest";
    }else {
        return @"(⊙_⊙)?";
    }
}
@end
