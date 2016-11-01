//
//  ProjectTopics.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectTopics.h"

@implementation ProjectTopics

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectTopic", @"list", nil];
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _labelID = [NSNumber numberWithInteger:0];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _queryType = TopicQueryTypeAll;
        _labelType = LabelOrderTypeUpdate;
    }
    return self;
}

+ (ProjectTopics *)topicsWithPro:(Project *)project queryType:(TopicQueryType)type
{
    ProjectTopics *topics = [[ProjectTopics alloc] init];
    topics.project = project;
    topics.queryType = type;
    return topics;
}

- (NSDictionary *)toParams
{
    NSDictionary *dict;
    if (_labelID && [_labelID integerValue] > 0 ) {
        dict = @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue+1] : [NSNumber numberWithInteger:1]),
                 @"pageSize" : _pageSize,
                 @"type" : (_queryType == TopicQueryTypeAll ? @"all" : @"my"),
                 @"orderBy" : [NSNumber numberWithInteger:_labelType],
                 @"labelId" : _labelID,
                 @"no_content": @(true)
                 };
    } else {
        dict = @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue+1] : [NSNumber numberWithInteger:1]),
                 @"pageSize" : _pageSize,
                 @"type" : (_queryType == TopicQueryTypeAll ? @"all" : @"my"),
                 @"orderBy" : [NSNumber numberWithInteger:_labelType],
                 @"no_content": @(true)
                 };
    }
    return dict;
}

- (NSString *)toRequestPath
{
    NSString *path;
    path = [NSString stringWithFormat:@"api/user/%@/project/%@/topics/mobile", _project.owner_user_name, _project.name];
    return path;
}

- (void)configWithTopics:(ProjectTopics *)resultA
{
    self.page = resultA.page;
    self.totalPage = resultA.totalPage;
    self.totalRow = resultA.totalRow;
    
    if (_willLoadMore) {
        [self.list addObjectsFromArray:resultA.list];
    }else{
        self.list = [NSMutableArray arrayWithArray:resultA.list];
    }
    self.canLoadMore = self.page.intValue < self.totalPage.intValue;
}

@end
