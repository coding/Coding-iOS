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
@property (readwrite, strong, nonatomic) NSString *noteable_type;
@property (readwrite, strong, nonatomic) NSString *action;
@property (readwrite, strong, nonatomic) NSString *anchor;
@property (readwrite, strong, nonatomic) NSString *commit_id;
@property (readwrite, strong, nonatomic) NSString *commit_path;
@property (readwrite, strong, nonatomic) NSString *content;
@property (readwrite, strong, nonatomic) NSString *path;
@property (readwrite, strong, nonatomic) NSString *commitId;
@property (readwrite, strong, nonatomic) NSNumber *id;
@property (readwrite, strong, nonatomic) NSNumber *noteable_id;
@property (readwrite, strong, nonatomic) NSNumber *outdated;
@property (readwrite, strong, nonatomic) NSNumber *line;
@property (readwrite, strong, nonatomic) NSNumber *position;
@property (strong, nonatomic) NSDate *created_at;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@end
