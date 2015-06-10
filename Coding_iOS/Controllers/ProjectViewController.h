//
//  ProjectViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Projects.h"

typedef NS_ENUM(NSInteger, ProjectViewType)
{
    ProjectViewTypeActivities = 0,
    ProjectViewTypeTasks,
    ProjectViewTypeTopics,
    ProjectViewTypeFiles,
    ProjectViewTypeCodes,
    ProjectViewTypeMembers
};

@interface ProjectViewController : BaseViewController
@property (nonatomic, strong) Project *myProject;
@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, assign, readonly) ProjectViewType curType;
@property (strong, nonatomic) NSString *codeRef;

+ (ProjectViewController *)codeVCWithCodeRef:(NSString *)codeRef andProject:(Project *)project;

@end
