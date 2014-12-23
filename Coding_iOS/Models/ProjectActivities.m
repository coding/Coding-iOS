//
//  ProjectActivities.m
//  Coding_iOS
//
//  Created by Ease on 14/12/1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectActivities.h"

@implementation ProjectActivities

- (instancetype)init
{
    self = [super init];
    if (self) {
        _listGroups = [[NSMutableArray alloc] init];
        _list = [[NSMutableArray alloc] init];
        _canLoadMore = YES;
        _willLoadMore = _isLoading = NO;
        _last_id = kDefaultLastId;
    }
    return self;
}

+ (ProjectActivities *)proActivitiesWithPro:(Project *)project type:(ProjectActivityType)type{
    ProjectActivities *proActs = [[ProjectActivities alloc] init];
    
    proActs.isOfUser = NO;
    
    proActs.curProject = project;
    proActs.project_id = project.id;
    
    proActs.curUser = nil;
    proActs.user_id = project.owner_id;
    
    switch (type) {
        case ProjectActivityTypeAll:
            proActs.type = @"all";
            break;
        case ProjectActivityTypeTask:
            proActs.type = @"task";
            break;
        case ProjectActivityTypeTopic:
            proActs.type = @"topic";
            break;
        case ProjectActivityTypeFile:
            proActs.type = @"file";
            break;
        case ProjectActivityTypeCode:
            proActs.type = @"code";
            break;
        case ProjectActivityTypeOther:
            proActs.type = @"other";
            break;
        default:
            proActs.type = @"all";
            break;
    }
    return proActs;
}

+ (ProjectActivities *)proActivitiesWithPro:(Project *)project user:(User *)user{
    ProjectActivities *proActs = [[ProjectActivities alloc] init];
    
    proActs.isOfUser = YES;
    
    proActs.curProject = project;
    proActs.project_id = project.id;
    
    proActs.curUser = user;
    proActs.user_id = user.id;
    
    return proActs;
}


- (NSString *)toPath{
    NSString *path;
    if (_isOfUser) {
        path = [self toPathOfUser];
    }else{
        path = [self toPathOfType];
    }
    return path;
}
- (NSDictionary *)toParams{
    NSDictionary *params;
    if (_isOfUser) {
        params = [self toParamsOfUser];
    }else{
        params = [self toParamsOfType];
    }
    return params;
}
- (NSString *)toPathOfType{
    return [NSString stringWithFormat:@"api/project/%@/activities", _project_id.stringValue];
}
- (NSDictionary *)toParamsOfType{
    return @{@"last_id" : _willLoadMore? self.last_id:kDefaultLastId,
             @"user_id" : self.user_id,
             @"type" : self.type};
}
- (NSString *)toPathOfUser{
    return [NSString stringWithFormat:@"api/project/%@/activities/user/%@", _project_id.stringValue, _user_id.stringValue];
}
- (NSDictionary *)toParamsOfUser{
    return @{@"last_id" : _willLoadMore? self.last_id:kDefaultLastId};
}

- (void)configWithProActList:(NSArray *)responseA{
    if (responseA && [responseA count] > 0) {
        self.canLoadMore = YES;
        ProjectActivity *lastProAct = [responseA lastObject];
        self.last_id = lastProAct.id;
        
        
        if (self.willLoadMore) {
            [_list addObjectsFromArray:responseA];
            [self refreshListGroupWithArray:responseA isAdd:YES];
        }else{
            self.list = [NSMutableArray arrayWithArray:responseA];
            [self refreshListGroupWithArray:responseA isAdd:NO];
        }
    }else{
        self.canLoadMore = NO;
    }
}

- (void)refreshListGroupWithArray:(NSArray *)responseA isAdd:(BOOL)isAdd{
    if (!isAdd) {
        [_listGroups removeAllObjects];
    }
    for (NSUInteger i = 0; i< [responseA count]; i++) {
        ProjectActivity *curProAct = [responseA objectAtIndex:i];
        NSUInteger location = [_list indexOfObject:curProAct];
        if (location != NSNotFound) {
            ListGroupItem *item = _listGroups.lastObject;
            if (item && [item.date isSameDay:curProAct.created_at]) {
                [item addOneItem];
            }else{
                item = [ListGroupItem itemWithDate:curProAct.created_at andLocation:location];
                [item addOneItem];
                [_listGroups addObject:item];
                [item.date isSameDay:curProAct.created_at];
            }
        }
    }
    DebugLog(@"\n_listGroups:\n%@", _listGroups);
}
@end
@implementation ProjectActivity
@synthesize actionStr = _actionStr, contentStr = _contentStr;
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Commit", @"commits", nil];
        _actionMediaItems = [[NSMutableArray alloc] init];
        _contentMediaItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setComment_content:(NSString *)comment_content{
    if (comment_content) {
        _comment_content = [comment_content stringByRemoveHtmlTag];
    }else{
        _comment_content = @"";
    }
}

- (void)addActionUser:(User *)curUser{
    if (curUser) {
        [HtmlMedia addMediaItemUser:curUser toString:_actionStr andMediaItems:_actionMediaItems];
    }
}

//- (void)addActionLinkStr:(NSString *)linkStr{
//    [HtmlMedia addLinkStr:linkStr type:HtmlMediaItemType_CustomLink toString:_actionStr andMediaItems:_actionMediaItems];
//}

- (void)addContentLinkStr:(NSString *)linkStr{
    [HtmlMedia addLinkStr:linkStr type:HtmlMediaItemType_CustomLink toString:_contentStr andMediaItems:_contentMediaItems];
}

- (NSMutableString *)actionStr{
    if (!_actionStr) {
        _actionStr = [[NSMutableString alloc] init];
        if ([_target_type isEqualToString:@"ProjectMember"]) {
            if ([_action isEqualToString:@"quit"]) {
                [self addActionUser:_target_user];
                [_actionStr appendString:_action_msg];
                [_actionStr appendString:@"项目"];
            }else{
                [self addActionUser:_user];
                [_actionStr appendString:_action_msg];
                [_actionStr appendString:@"项目成员"];
            }
        }else if ([_target_type isEqualToString:@"Task"]){
            [self addActionUser:_user];
            if ([_action isEqualToString:@"update_priority"]) {
                [_actionStr appendFormat:@"更新了任务<%@>的优先级", _task.title];
            }else if ([_action isEqualToString:@"update_deadline"]) {
                if (_task.deadline && _task.deadline.length > 0) {
                    [_actionStr appendFormat:@"更新了任务<%@>的截止日期", _task.title];
                }else{
                    [_actionStr appendFormat:@"移除了任务<%@>的截止日期", _task.title];
                }
            }else if ([_action isEqualToString:@"update_description"]) {
                [_actionStr appendFormat:@"更新了任务<%@>的描述", _task.title];
            }else{
                [_actionStr appendString:_action_msg];
                if (_origin_task.owner) {
                    [self addActionUser:_origin_task.owner];
                    [_actionStr appendString:@"的"];
                }
                [_actionStr appendString:@"任务"];
                
                if ([_action isEqualToString:@"reassign"]) {
                    [_actionStr appendString:@"给"];
                    [self addActionUser:_task.owner];
                }
            }
        }else if ([_target_type isEqualToString:@"TaskComment"]){
            [self addActionUser:_user];
            [_actionStr appendFormat:@"%@任务<%@>的评论", _action_msg, _task.title];
        }else{
            [self addActionUser:_user];
            [_actionStr appendString:_action_msg];
            if ([_target_type isEqualToString:@"ProjectTopic"]){
                [_actionStr appendString:@"讨论"];
                if ([_action isEqualToString:@"comment"]) {
                    [_actionStr appendString:@":"];
                    [_actionStr appendString:_project_topic.parent.title];
                }
            }else if ([_target_type isEqualToString:@"ProjectFile"]){
                if ([_type isEqualToString:@"dir"]) {
                    [_actionStr appendString:@"文件夹"];
                }else{
                    [_actionStr appendString:@"文件"];
                }
            }else if ([_target_type isEqualToString:@"Depot"]){
                if (!_ref && _ref.length <= 0) {
                    _ref = @"";
                }
                if ([_action isEqualToString:@"push"]) {
                    [_actionStr appendString:@"项目分支:"];
                    [_actionStr appendString:_ref];
                }else if ([_action isEqualToString:@"fork"]){
                    [_actionStr appendString:@"项目"];
                    [_actionStr appendString:_source_depot.name];
                    [_actionStr appendString:@"到"];
                    [_actionStr appendString:_depot.name];
                }
            }else{
                [_actionStr appendString:@"项目"];
                if ([_target_type isEqualToString:@"Project"]){
                }else if ([_target_type isEqualToString:@"QcTask"]){
                    [_actionStr appendString:[NSString stringWithFormat:@"[%@]", _project.full_name]];
                    [_actionStr appendString:@"的质量分析任务"];
                }else if ([_target_type isEqualToString:@"ProjectStar"]){
                    [_actionStr appendString:[NSString stringWithFormat:@"[%@]", _project.full_name]];
                }else if ([_target_type isEqualToString:@"ProjectWatcher"]){
                    [_actionStr appendString:[NSString stringWithFormat:@"[%@]", _project.full_name]];
                }else if ([_target_type isEqualToString:@"PullRequestBean"]){
                    [_actionStr appendString:[NSString stringWithFormat:@"[%@]", _depot.name]];
                    [_actionStr appendString:@"中的 Pull Request"];
                }else if ([_target_type isEqualToString:@"PullRequestComment"]){
                    [_actionStr appendString:[NSString stringWithFormat:@"[%@]", _depot.name]];
                    [_actionStr appendString:@"中的 Pull Request"];
                    [_actionStr appendString:_pull_request_title];
                }else if ([_target_type isEqualToString:@"MergeRequestBean"]){
                    [_actionStr appendString:[NSString stringWithFormat:@"[%@]", _depot.name]];
                    [_actionStr appendString:@"中的 Merge Request"];
                }else if ([_target_type isEqualToString:@"MergeRequestComment"]){
                    [_actionStr appendString:[NSString stringWithFormat:@"[%@]", _depot.name]];
                    [_actionStr appendString:@"中的 Merge Request"];
                    [_actionStr appendString:_merge_request_title];
                }
            }
        }
    }
    return _actionStr;
}

- (NSMutableString *)contentStr{
    if (!_contentStr) {
        _contentStr = [[NSMutableString alloc] init];
        
        if ([_target_type isEqualToString:@"Task"]) {
            NSString *linkStr;
            if ([_action isEqualToString:@"update_priority"]) {
                if (_task.priority && _task.priority.intValue < kTaskPrioritiesDisplay.count) {
                    linkStr = [NSString stringWithFormat:@"[%@] %@", kTaskPrioritiesDisplay[_task.priority.intValue], _task.title];
                }
            }else if ([_action isEqualToString:@"update_deadline"] && _task.deadline && _task.deadline.length > 0) {
                linkStr = [NSString stringWithFormat:@"[%@] %@", [NSDate convertStr_yyyy_MM_ddToDisplay:_task.deadline], _task.title];
            }else if ([_action isEqualToString:@"update_description"]) {
                linkStr = _task.description_mine;
            }else{
                linkStr = _task.title;
            }
            [self addContentLinkStr:linkStr];
        }else if ([_target_type isEqualToString:@"TaskComment"]){
            if (_taskComment.content) {
                [self addContentLinkStr:_taskComment.content];
            }
        }else if ([_target_type isEqualToString:@"ProjectTopic"]){
            if ([_action isEqualToString:@"comment"]) {
                [self addContentLinkStr:_project_topic.content];
            }else{
                [self addContentLinkStr:_project_topic.title];
            }
        }else if ([_target_type isEqualToString:@"ProjectFile"]){
            [self addContentLinkStr:_file.name];
        }else if ([_target_type isEqualToString:@"Depot"]){
            if (_commits && [_commits count] > 0) {
                Commit *curCommit = _commits.firstObject;
                [_contentStr appendString:curCommit.contentStr];
                for (int i = 1; i<[_commits count]; i++) {
                    curCommit = [_commits objectAtIndex:i];
                    [_contentStr appendString:[NSString stringWithFormat:@"\n%@",curCommit.contentStr]];
                }
            }
        }else{
            if ([_target_type isEqualToString:@"ProjectMember"]) {
                if ([_action isEqualToString:@"quit"]) {
                    [_contentStr appendString:_project.full_name];
                }else{
                    [self addContentLinkStr:_target_user.name];
                }
            }else if ([_target_type isEqualToString:@"Project"]){
                [_contentStr appendString:_project.full_name];
            }else if ([_target_type isEqualToString:@"QcTask"]){
                [_contentStr appendString:_qc_task.link];
            }else if ([_target_type isEqualToString:@"ProjectStar"]){
                [_contentStr appendString:_project.full_name];
            }else if ([_target_type isEqualToString:@"ProjectWatcher"]){
                [_contentStr appendString:_project.full_name];
            }else if ([_target_type isEqualToString:@"PullRequestBean"]){
                [_contentStr appendString:_pull_request_title];
            }else if ([_target_type isEqualToString:@"PullRequestComment"]){
                [_contentStr appendString:_comment_content];
            }else if ([_target_type isEqualToString:@"MergeRequestBean"]){
                [_contentStr appendString:_merge_request_title];
            }else if ([_target_type isEqualToString:@"MergeRequestComment"]){
                [_contentStr appendString:_comment_content];
            }else{
                [_contentStr appendString:@"**未知**"];
            }
        }
    }
    return _contentStr;
}
@end