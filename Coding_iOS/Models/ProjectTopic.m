//
//  ProjectTopic.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectTopic.h"
#import "Login.h"
#import "ProjectTag.h"

@implementation ProjectTopic

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectTag", @"labels",
                             @"ProjectTopic", @"child_comments",
                             @"User", @"up_vote_users",
                             nil];
        
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _contentHeight = 1;
        
        _title = @"";
        _content = @"";
        _mdTitle = @"";
        _mdContent = @"";
        
        _labels = [[NSMutableArray alloc] initWithCapacity:3];
        _mdLabels = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
}

- (NSNumber *)is_up_voted{
    if (!_is_up_voted) {
        _is_up_voted = @(NO);
        for (User *user in _up_vote_users) {
            if ([user.global_key isEqualToString:[Login curLoginUser].global_key]) {
                _is_up_voted = @(YES);
                break;
            }
        }
    }
    return _is_up_voted;
}

- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeNone];
        _content = _htmlMedia.contentDisplay;
    }
}

+ (ProjectTopic *)feedbackTopic
{
    ProjectTopic *topic = [[ProjectTopic alloc] init];
    topic.project = [Project project_FeedBack];
    topic.project_id = topic.project.id;
    return topic;
}

+ (ProjectTopic *)topicWithPro:(Project *)pro
{
    ProjectTopic *topic = [[ProjectTopic alloc] init];
    topic.owner = [Login curLoginUser];
    topic.project = pro;
    topic.project_id = pro.id;
    return topic;
}
+ (ProjectTopic *)topicWithId:(NSNumber *)topicId{
    ProjectTopic *topic = [[ProjectTopic alloc] init];
    topic.id = topicId;
    return topic;
}

- (User *)hasWatcher:(User *)watcher{
    for (User *user in self.watchers) {
        if ([user.id isEqual:watcher.id]) {
            return user;
        }
    }
    return nil;
}

- (NSString *)toTopicPath
{
    return [NSString stringWithFormat:@"api/topic/%d", self.id.intValue];
}

- (NSDictionary *)toEditParams
{
    NSMutableArray *tempAry = [NSMutableArray arrayWithCapacity:_mdLabels.count];
    for (ProjectTag *lbl in _mdLabels) {
        [tempAry addObject:lbl.id];
    }
    return @{@"title" : [_mdTitle aliasedString],
             @"content" : [_mdContent aliasedString],
             @"label" : tempAry};
}

- (NSString *)toLabelPath
{
    return [NSString stringWithFormat:@"api/user/%@/project/%@/topics/%d/labels", _project.owner_user_name, _project.name, self.id.intValue];
}

- (NSDictionary *)toLabelParams
{
    NSMutableArray *tempAry = [NSMutableArray arrayWithCapacity:_mdLabels.count];
    for (ProjectTag *lbl in _mdLabels) {
        [tempAry addObject:lbl.id];
    }
    return @{@"label_id" : tempAry};
}

- (NSString *)toAddTopicPath
{
    return [NSString stringWithFormat:@"api/project/%d/topic?parent=0", [self.project_id intValue]];
}

- (NSDictionary *)toAddTopicParams
{
    NSMutableArray *tempAry = [NSMutableArray arrayWithCapacity:_mdLabels.count];
    for (ProjectTag *lbl in _mdLabels) {
        [tempAry addObject:lbl.id];
    }
    return @{@"title" : [_mdTitle aliasedString],
             @"content" : [_mdContent aliasedString],
             @"label" : tempAry};
}

- (NSString *)toCommentsPath
{
    return [NSString stringWithFormat:@"api/topic/%d/comments", _id.intValue];
}
- (NSDictionary *)toCommentsParams
{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}
- (void)configWithComments:(ProjectTopics *)comments
{
    self.page = comments.page;
    self.totalRow = comments.totalRow;
    self.totalPage = comments.totalPage;
    
    if (_willLoadMore) {
        [_comments.list addObjectsFromArray:comments.list];
    } else {
        self.comments = comments;
    }
    _canLoadMore = (_page.integerValue < _totalPage.integerValue);
}

- (NSString *)toDoCommentPath
{
    return [NSString stringWithFormat:@"api/project/%@/topic/%@/comment", _project_id, _id];
}

- (void)configWithComment:(ProjectTopic *)comment andAnswer:(ProjectTopic *)answer
{
    if (answer) {
        if (answer.child_comments) {
            [answer.child_comments addObject:comment];
            answer.child_count = @(answer.child_count.integerValue + 1);
        }else{
            answer.child_comments = @[comment].mutableCopy;
            answer.child_count = @1;
        }
    }else{
        if (self.canLoadMore) {
            return;
        }
        
        if (self.comments && self.comments.list) {
            [self.comments.list addObject:comment];
        }else{
            self.comments = [[ProjectTopics alloc] init];
            self.comments.list = [NSMutableArray arrayWithObject:comment];
        }
        self.child_count = [NSNumber numberWithInteger:_child_count.intValue +1];
    }
}
- (NSString *)toDeletePath
{
    return [NSString stringWithFormat:@"api/topic/%d", self.id.intValue];
}

- (BOOL)canEdit
{
    return ([Login isLoginUserGlobalKey:self.owner.global_key] || // 讨论创建者
            [Login isLoginUserGlobalKey:self.project.owner_user_name]);// 项目创建者
}
- (NSInteger)commentsDisplayNum{
    return MIN(_child_comments.count, 6);
}
- (void)change_is_up_voted{
    _is_up_voted = @(!self.is_up_voted.boolValue);
    if (_is_up_voted.boolValue) {//原来没有，现在需要添加
        if (!_up_vote_users) {
            _up_vote_users = @[].mutableCopy;
        }
        [_up_vote_users addObject:[Login curLoginUser]];
        _up_vote_counts = @(_up_vote_counts.integerValue + 1);
    }else{//原来有，现在需要移除
        User *meUser = nil;
        for (User *user in _up_vote_users) {
            if ([user.global_key isEqualToString:[Login curLoginUser].global_key]) {
                meUser = user;
                break;
            }
        }
        if (meUser) {
            [_up_vote_users removeObject:meUser];
            _up_vote_counts = @(_up_vote_counts.integerValue - 1);
        }
    }
}
@end
