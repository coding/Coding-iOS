//
//  ProjectTopic.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectTopic.h"

@implementation ProjectTopic

- (instancetype)init
{
    self = [super init];
    if (self) {
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _contentHeight = 1;
    }
    return self;
}

- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content trimWhitespaceAndNewline:YES];
        _content = _htmlMedia.contentDisplay;
    }
}

+ (ProjectTopic *)topicWithPro:(Project *)pro{
    ProjectTopic *topic = [[ProjectTopic alloc] init];
    topic.project = pro;
    topic.project_id = pro.id;
    return topic;
}
+ (ProjectTopic *)topicWithId:(NSNumber *)topicId{
    ProjectTopic *topic = [[ProjectTopic alloc] init];
    topic.id = topicId;
    topic.title = @"";
    topic.content = @"";
    return topic;
}

- (NSString *)toTopicPath{
    return [NSString stringWithFormat:@"api/topic/%d", self.id.intValue];
}
- (NSDictionary *)toTopicParams{
    return @{@"type" : [NSNumber numberWithInteger:0]};
}

- (NSString *)toAddTopicPath{
    return [NSString stringWithFormat:@"api/project/%d/topic?parent=0", [self.project_id intValue]];
}
- (NSDictionary *)toAddTopicParams{
    return @{@"title" : [_title aliasedString],
             @"content" : [_content aliasedString]};
}

- (NSString *)toCommentsPath{
    return [NSString stringWithFormat:@"api/topic/%d/comments", _id.intValue];
}
- (NSDictionary *)toCommentsParams{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}
- (void)configWithComments:(ProjectTopics *)comments{
    self.page = comments.page;
    self.totalRow = comments.totalRow;
    self.totalPage = comments.totalPage;
    
    if (_willLoadMore) {
        [_comments.list addObjectsFromArray:comments.list];
    }else{
        self.comments = comments;
    }
    _canLoadMore = (_page.integerValue < _totalPage.integerValue);
    
}

- (void)configWithRefreshedTopic:(ProjectTopic *)topic{
    self.child_count = topic.child_count;
    self.content = topic.htmlMedia.contentOrigional;
    self.title = topic.title;
    self.created_at = topic.created_at;
    self.current_user_role_id = topic.current_user_role_id;
    self.owner = topic.owner;
    self.project = topic.project;
    self.owner_id = topic.owner_id;
    self.project_id = topic.project_id;
    self.updated_at = topic.updated_at;
    self.parent_id = topic.parent_id;
}

- (NSString *)toDoCommentPath{
    return [NSString stringWithFormat:@"api/project/%d/topic?parent=%d",_project_id.intValue, _id.intValue];
}
- (NSDictionary *)toDoCommentParams{
    return @{@"content" : [_nextCommentStr aliasedString]};
}
- (void)configWithComment:(ProjectTopic *)comment{
    if (self.comments && self.comments.list) {
        [self.comments.list addObject:comment];
    }else{
        self.comments = [[ProjectTopics alloc] init];
        self.comments.list = [NSMutableArray arrayWithObject:comment];
    }
    self.child_count = [NSNumber numberWithInteger:_child_count.intValue +1];
}
- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/topic/%d", self.id.intValue];
}

@end
