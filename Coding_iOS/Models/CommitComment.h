//
//  CommitComment.h
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRPRCommentItem.h"

@interface CommitComment : MRPRCommentItem
@property (strong, nonatomic) NSString *anchor, *commitId, *path;
@property (strong, nonatomic) NSNumber *line, *noteable_id, *position, *outdated;
@end
