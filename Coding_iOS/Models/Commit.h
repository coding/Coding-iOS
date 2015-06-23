//
//  Commit.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Committer;

@interface Commit : NSObject
@property (readwrite, nonatomic, strong) NSString *sha, *short_message, *ref, *ref_path;
@property (strong, nonatomic) NSString *fullMessage, *shortMessage, *allMessage, *commitId;
@property (strong, nonatomic) NSDate *commitTime;
@property (strong, nonatomic) NSNumber *notesCount;
@property (readwrite, nonatomic, strong) Committer *committer;
- (NSString *)contentStr;
@end

@interface Committer : NSObject
@property (readwrite, nonatomic, strong) NSString *avatar, *name, *link, *email;
@end