//
//  EACodeRelease.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Commit.h"
#import "ResourceReference.h"
#import "Project.h"

@class EACodeReleaseAttachment;

@interface EACodeRelease : NSObject

@property (strong, nonatomic) NSNumber *id, *creator_id, *project_id, *iid, *pre, *draft;
@property (strong, nonatomic) NSString *tag_name, *commit_sha, *target_commitish, *title, *body, *markdownBody, *compare_tag_name;
@property (strong, nonatomic) NSDate *created_at;
@property (strong, nonatomic) User *author;
@property (strong, nonatomic) Commit *last_commit;
@property (strong, nonatomic) NSMutableArray *resource_references;//ResourceReferenceItem
@property (strong, nonatomic) NSMutableArray *attachments;//EACodeReleaseAttachment
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;//指定数据类型的字典

@property (strong, nonatomic) Project *project;//需要自己填充的
@property (assign, nonatomic) CGFloat contentHeight;

@property (strong, nonatomic) NSString *editTitle, *editBody;//edit

- (BOOL)hasChanged;

- (NSString *)editPath;
- (NSDictionary *)editParams;

@end

@interface EACodeReleaseAttachment : NSObject

@property (strong, nonatomic) NSNumber *id, *size;
@property (strong, nonatomic) NSString *name;

@end

