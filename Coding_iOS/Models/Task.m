//
//  Task.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-15.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Task.h"

@implementation Task
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.handleType = TaskHandleTypeEdit;
        _isRequesting = _isRequestingDetail = _isRequestingCommentList = NO;
        _needRefreshDetail = NO;
    }
    return self;
}
- (void)setOwner:(User *)owner{
    if (owner != _owner) {
        _owner = owner;
        _owner_id = owner.id;
    }
}

//- (void)setContent:(NSString *)content{
//    if (_content != content) {
//        _content = content;
//    }
//}
//- (void)setTitle:(NSString *)title{
//    if (_title != title) {
//        _title = title;
//    }
//}

- (void)setDescription_mine:(NSString *)description_mine{
    if (_description_mine != description_mine) {
        HtmlMedia *htmlMedia = [HtmlMedia htmlMediaWithString:description_mine trimWhitespaceAndNewline:YES];
        _description_mine = htmlMedia.contentDisplay;
    }
}

+ (Task *)taskWithProject:(Project *)project{
    Task *curTask = [[Task alloc] init];
    curTask.project = project;
    curTask.creator = [Login curLoginUser];
    curTask.owner = [Login curLoginUser];
    curTask.status = [NSNumber numberWithInt:1];
    curTask.handleType = TaskHandleTypeAdd;
    curTask.priority = [NSNumber numberWithInt:1];
    curTask.content = @"";
    return curTask;
}
+ (Task *)taskWithTask:(Task *)task{
    Task *curTask = [[Task alloc] init];
    [curTask copyDataFrom:task];
    return curTask;
}
+ (Task *)taskWithBackend_project_path:(NSString *)backend_project_path andId:(NSString *)taskId{
    Task *curTask = [[Task alloc] init];
    curTask.backend_project_path = backend_project_path;
    curTask.id = [NSNumber numberWithInteger:taskId.integerValue];
    curTask.needRefreshDetail = YES;
    return curTask;
}
- (BOOL)isSameToTask:(Task *)task{
    if (!task) {
        return NO;
    }
    return ([self.content isEqualToString:task.content]
            && [self.owner.global_key isEqualToString:task.owner.global_key]
            && self.priority.intValue == task.priority.intValue
            && self.status.intValue == task.status.intValue);
}
- (void)copyDataFrom:(Task *)task{
    self.id = task.id;
    self.backend_project_path = task.backend_project_path;
    self.project = task.project;
    self.creator = task.creator;
    self.owner = task.owner;
    self.owner_id = task.owner_id;
    self.status = task.status;
    self.content = task.content;
    self.title = task.title;
    self.created_at = task.created_at;
    self.updated_at = task.updated_at;
    self.handleType = TaskHandleTypeEdit;
    self.isRequesting = task.isRequesting;
    self.isRequestingDetail = task.isRequestingDetail;
    self.isRequestingCommentList = task.isRequestingCommentList;
    self.priority = task.priority;
    self.comments = task.comments;
    self.needRefreshDetail = task.needRefreshDetail;
}

//内容
- (NSString *)toEditTaskContentPath{
    return [NSString stringWithFormat:@"api/task/%d/content", self.id.intValue];
}
-(NSDictionary *)toEditContentParams{
    return @{@"content" : [self.content aliasedString]};
}
//执行人
- (NSString *)toEditTaskOwnerPath{
    return [NSString stringWithFormat:@"api/task/%d/owner", self.id.intValue];
}
-(NSDictionary *)toEditOwnerParams{
    return @{@"owner_id" : self.owner_id};
}
//任务状态
- (NSString *)toEditTaskStatusPath{
    return [NSString stringWithFormat:@"api/task/%d/status", self.id.intValue];
}
-(NSDictionary *)toEditStatusParams{
    return @{@"status" : self.status};
}
-(NSDictionary *)toChangeStatusParams{
    NSNumber *status = [NSNumber numberWithInteger:(_status.integerValue != 1? 1 : 2)];
    return @{@"status" : status};
}

//任务优先级
- (NSString *)toEditTaskPriorityPath{
    return [NSString stringWithFormat:@"api/task/%d/priority", self.id.intValue];
}
-(NSDictionary *)toEditPriorityParams{
    return @{@"priority" : self.priority};
}

//添加新任务
- (NSString *)toAddTaskPath{
    return [NSString stringWithFormat:@"api%@/task", self.backend_project_path];
}
- (NSDictionary *)toAddTaskParams{
    return @{@"content" : [self.content aliasedString],
             @"owner_id" : self.owner.id,
             @"priority" : self.priority};
}
//删除任务
- (NSString *)toDeleteTaskPath{
    return [NSString stringWithFormat:@"api%@/task/%ld", self.backend_project_path, (long)self.id.integerValue];
}

//任务评论列表
- (NSString *)toCommentListPath{
    return [NSString stringWithFormat:@"api/task/%ld/comments", (long)self.id.integerValue];
}
- (NSDictionary *)toCommentListParams{
    return @{@"page" : [NSNumber numberWithInt:1],
             @"pageSize" : [NSNumber numberWithInt:500]};
}

//任务详情
- (NSString *)toTaskDetailPath{
    return [NSString stringWithFormat:@"api%@/task/%ld", self.backend_project_path, (long)self.id.integerValue];
}

- (NSString *)backend_project_path{
    if (!_backend_project_path || _backend_project_path.length <= 0) {
        if (self.project && self.project.backend_project_path && self.project.backend_project_path.length > 0) {
            _backend_project_path = self.project.backend_project_path;
        }
    }
    return _backend_project_path;
}
//评论任务
- (NSString *)toDoCommentPath{
    return [NSString stringWithFormat:@"api/task/%ld/comment", (long)self.id.integerValue];
}
- (NSDictionary *)toDoCommentParams{
    if (_nextCommentStr) {
        return @{@"content" : [_nextCommentStr aliasedString]};
    }else{
        return nil;
    }
}

- (void)addNewComment:(TaskComment *)comment{
    if (_commentList) {
        [_commentList insertObject:comment atIndex:0];
    }else{
        _commentList = [NSMutableArray arrayWithObject:comment];
    }
    _comments = [NSNumber numberWithInteger:_comments.integerValue +1];
}
- (void)deleteComment:(TaskComment *)comment{
    if (_commentList) {
        NSUInteger index = [_commentList indexOfObject:comment];
        if (index != NSNotFound) {
            [_commentList removeObjectAtIndex:index];
            _comments = [NSNumber numberWithInteger:_comments.integerValue -1];
        }
    }
}
@end

