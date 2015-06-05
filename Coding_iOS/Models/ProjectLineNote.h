//
//  ProjectLineNote.h
//  Coding_iOS
//
//  Created by Ease on 15/5/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ProjectLineNote : NSObject
@property (strong, nonatomic) User *author;
@property (readwrite, strong, nonatomic) NSString *noteable_type, *anchor, *commit_id, *commit_path, *content, *path, *commitId;
@property (readwrite, strong, nonatomic) NSNumber *id, *noteable_id, *outdated, *line, *position;
@property (strong, nonatomic) NSDate *created_at;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@end
