//
//  NSObject+ReviewerListView.h
//  Coding_iOS
//
//  Created by hardac on 16/3/25.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "Project.h"
#import "MRPR.h"

typedef void(^ReviewerListControllerBlock)(Project *project);

@interface ReviewerListController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (readwrite, nonatomic, strong) NSMutableArray *reviewers;
@property(strong, nonatomic) Project* currentProject;
@property (strong, nonatomic) MRPR *curMRPR;
@property (assign, nonatomic) BOOL isPublisher;
@property (readwrite, nonatomic, strong) NSMutableArray *volunteer_reviewers;

@end
