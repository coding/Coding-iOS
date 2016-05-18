//
//  CommitFilesViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Project.h"

@interface CommitFilesViewController : BaseViewController
@property (strong, nonatomic) NSString *ownerGK, *projectName, *commitId;
@property (strong, nonatomic) Project *curProject;//非必需
+ (CommitFilesViewController *)vcWithPath:(NSString *)path;
- (void)refresh;
@end
