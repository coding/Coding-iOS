//
//  ProjectActivity.h
//  Coding_iOS
//
//  Created by Ease on 15/5/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectTopicActivity.h"
#import "ProjectLineNoteActivity.h"

#import "Projects.h"
#import "FileComment.h"
#import "ProjectFile.h"
#import "ProjectTag.h"

@class Task;
@class ProjectTopic;

@interface ProjectActivity : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id;
@property (readwrite, nonatomic, strong) NSString *target_type, *action, *action_msg, *type, *ref, *ref_type, *ref_path, *pull_request_title, *merge_request_title, *comment_content, *merge_request_path, *pull_request_path, *version;
@property (readwrite, nonatomic, strong) User *user, *target_user, *watcher;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) Task *origin_task, *task;
@property (readwrite, nonatomic, strong) TaskComment *taskComment, *origin_taskComment;
@property (readwrite, nonatomic, strong) Project *project;
@property (readwrite, nonatomic, strong) ProjectTopicActivity *project_topic;
@property (readwrite, nonatomic, strong) File *file;
@property (readwrite, nonatomic, strong) QcTask *qc_task;
@property (readwrite, nonatomic, strong) Depot *depot, *source_depot;
@property (readwrite, nonatomic, strong) NSMutableArray *commits, *labels;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) ProjectLineNoteActivity *line_note;
@property (strong, nonatomic) Commit *commit;
@property (strong, nonatomic) FileComment *projectFileComment;
@property (strong, nonatomic) ProjectFile *projectFile;

@property (readonly, nonatomic, strong) NSMutableArray *actionMediaItems, *contentMediaItems;
@property (readonly, nonatomic, strong) NSMutableString *actionStr, *contentStr;
@end
