//
//  Topic.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSTopic.h"

@implementation CSTopic

- (CGFloat)listCellHeight {
    //TODO psy
    return 44.0;
}

- (NSString *)toDoWatchPath{
    NSString *doLikePath;
    doLikePath = [NSString stringWithFormat:@"api/tweet_topic/%@/%@", self.id, (_watched? @"unwatch":@"watch")];
    return doLikePath;
}

@end
