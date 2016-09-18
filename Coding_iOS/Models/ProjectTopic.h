//
//  ProjectTopic.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Projects.h"
#import "ProjectTopics.h"

@class Project;
@class ProjectTopics;

@interface ProjectTopic : NSObject

@property (readwrite, nonatomic, strong) NSNumber *id, *child_count, *current_user_role_id, *owner_id, *project_id, *parent_id, *number,*resource_id, *topic_id, *is_recommended, *up_vote_counts, *is_up_voted;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) NSDate *updated_at;
@property (readwrite, nonatomic, strong) NSString *title, *content, *path,*contentStr;
@property (readwrite, strong, nonatomic) NSMutableArray *labels;
@property (readwrite, strong, nonatomic) NSMutableArray *child_comments, *up_vote_users;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;

@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) Project *project;
@property (readwrite, nonatomic, strong) ProjectTopic *parent;
@property (readwrite, nonatomic, strong) ProjectTopics *comments;
@property (readwrite, nonatomic, strong) NSString *nextCommentStr;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (assign, nonatomic) CGFloat contentHeight;

@property (strong, nonatomic) NSString *mdTitle, *mdContent;
@property (strong, nonatomic) NSMutableArray *mdLabels;
@property (strong, nonatomic) NSMutableArray *watchers;

@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading, isTopicLoading, isTopicEditLoading;

+ (ProjectTopic *)feedbackTopic;
+ (ProjectTopic *)topicWithPro:(Project *)pro;
+ (ProjectTopic *)topicWithId:(NSNumber *)topicId;

- (User *)hasWatcher:(User *)watcher;

- (NSString *)toTopicPath;
- (NSDictionary *)toEditParams;

- (NSString *)toLabelPath;
- (NSDictionary *)toLabelParams;

- (NSString *)toAddTopicPath;
- (NSDictionary *)toAddTopicParams;

- (NSString *)toCommentsPath;
- (NSDictionary *)toCommentsParams;
- (void)configWithComments:(ProjectTopics *)comments;

- (NSString *)toDoCommentPath;
- (void)configWithComment:(ProjectTopic *)comment andAnswer:(ProjectTopic *)answer;

- (NSString *)toDeletePath;

- (BOOL)canEdit;
- (NSInteger)commentsDisplayNum;
- (void)change_is_up_voted;
@end
