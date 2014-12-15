//
//  ProjectTopics.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectTopic.h"

typedef NS_ENUM(NSInteger, TopicQueryType){
    TopicQueryTypeAll = 0,
    TopicQueryTypeMe
};

@class Project;

@interface ProjectTopics : NSObject

@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (assign, nonatomic) TopicQueryType queryType;

@property (readwrite, nonatomic, strong) Project *project;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;

+ (ProjectTopics *)topicsWithPro:(Project *)project queryType:(TopicQueryType)type;
- (NSDictionary *)toParams;
- (NSString *)toRequestPath;
- (void)configWithTopics:(ProjectTopics *)resultA;
@end
