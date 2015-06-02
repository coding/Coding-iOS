//
//  CommitComment.h
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface CommitComment : NSObject
@property (strong, nonatomic) User *author;
@property (strong, nonatomic) NSString *anchor, *commitId, *content, *noteable_type, *path;
@property (strong, nonatomic) NSDate *created_at;
@property (strong, nonatomic) NSNumber *id, *line, *noteable_id, *position, *outdated;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@end
