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
}

- (void)configSegmentItems{
    self.segmentItems = @[@"Ta参与的", @"Ta收藏的"];
}

- (Projects *)projectsWithIndex:(NSUInteger)index{
    return [Projects projectsWithType:(index +3) andUser:self.curUser];
}

@end
