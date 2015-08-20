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
    proActs.type = @"user";

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
        }else{
            self.list = [NSMutableArray arrayWithArray:responseA];
        }
        [self refreshListGroupWithArray:responseA isAdd:self.willLoadMore];
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
            }
        }
    }
}
@end