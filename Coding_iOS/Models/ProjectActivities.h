//
//  ProjectActivities.h
//  Coding_iOS
//
//  Created by Ease on 14/12/1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectActivity.h"


typedef NS_ENUM(NSInteger, ProjectActivityType)
{
    ProjectActivityTypeAll = 0,
    ProjectActivityTypeTask,
    ProjectActivityTypeTopic,
    ProjectActivityTypeFile,
    ProjectActivityTypeCode,
    ProjectActivityTypeOther
};



@interface ProjectActivities : NSObject
@property (readwrite, nonatomic, strong) NSNumber *project_id, *last_id, *user_id;
@property (readwrite, nonatomic, strong) NSString *type;

@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSMutableArray *list, *listGroups;
@property (readwrite, nonatomic, strong) Project *curProject;
@property (readwrite, nonatomic, strong) User *curUser;
@property (assign, nonatomic) BOOL isOfUser;

+ (ProjectActivities *)proActivitiesWithPro:(Project *)project type:(ProjectActivityType)type;
+ (ProjectActivities *)proActivitiesWithPro:(Project *)project user:(User *)user;
- (NSString *)toPath;
- (NSDictionary *)toParams;

- (void)configWithProActList:(NSArray *)responseA;
@end
