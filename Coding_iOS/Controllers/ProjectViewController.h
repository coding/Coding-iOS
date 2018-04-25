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
    ProjectViewTypeFiles,
    ProjectViewTypeTopics,
    ProjectViewTypeCodes,
    ProjectViewTypeMembers
};

@interface ProjectViewController : BaseViewController
@property (nonatomic, strong) Project *myProject;
@property (nonatomic, assign) ProjectViewType curType;

@property (assign, nonatomic) BOOL hideBranchTagButton;
+ (ProjectViewController *)codeVCWithCodeRef:(NSString *)codeRef andProject:(Project *)project;

@end
