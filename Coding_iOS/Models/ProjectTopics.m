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
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _queryType = TopicQueryTypeAll;
    }
    return self;
}

+ (ProjectTopics *)topicsWithPro:(Project *)project queryType:(TopicQueryType)type{
    ProjectTopics *topics = [[ProjectTopics alloc] init];
    topics.project = project;
    topics.queryType = type;
    return topics;
}
- (NSDictionary *)toParams{
    NSDictionary *dict;
    if (_queryType == TopicQueryTypeAll) {
        dict = @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue+1] : [NSNumber numberWithInteger:1]),
                 @"pageSize" : _pageSize,
                 @"type" : @"1"};
    }else if (_queryType == TopicQueryTypeMe){
        dict = @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue+1] : [NSNumber numberWithInteger:1]),
                 @"pageSize" : _pageSize};
    }
    return dict;
}
- (NSString *)toRequestPath{
    NSString *path;
    if (_queryType == TopicQueryTypeAll) {
        path = [NSString stringWithFormat:@"api/project/%d/topics", _project.id.intValue];
    }else{
        path = [NSString stringWithFormat:@"api/project/%d/topics/me", _project.id.intValue];
    }
    return path;
}
- (void)configWithTopics:(ProjectTopics *)resultA{
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
