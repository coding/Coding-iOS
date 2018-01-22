//
//  WikiHistoryListViewController.h
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/4/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "EAWiki.h"
#import "Project.h"

@interface WikiHistoryListViewController : BaseViewController
@property (nonatomic, strong) Project *myProject;
@property (strong, nonatomic) EAWiki *curWiki;

@end
