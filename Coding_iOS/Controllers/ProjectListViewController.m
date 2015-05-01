//
//  ProjectListViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/3/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectListViewController.h"

@implementation ProjectListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _curUser.name;
    self.icarouselScrollEnabled = YES;
}

- (void)setupNavBtn{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)configSegmentItems{
    if ([_curUser.global_key isEqualToString:[Login curLoginUser].global_key]) {
        self.segmentItems = @[@"我参与的", @"我收藏的"];
    }else{
        self.segmentItems = @[@"Ta参与的", @"Ta收藏的"];
    }
}

- (Projects *)projectsWithIndex:(NSUInteger)index{
    return [Projects projectsWithType:(index +ProjectsTypeTaProject) andUser:self.curUser];
}

@end
