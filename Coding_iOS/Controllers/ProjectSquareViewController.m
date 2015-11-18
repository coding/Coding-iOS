//
//  ProjectSquareViewController.m
//  Coding_iOS
//
//  Created by jwill on 15/11/11.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ProjectSquareViewController.h"
#import "ProjectListView.h"
#import "NProjectViewController.h"

@interface ProjectSquareViewController ()
@property (strong, nonatomic) Projects *curPros;
@end

@implementation ProjectSquareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"项目广场";
    self.curPros = [Projects projectsWithType:ProjectsTypeAllPublic andUser:nil];
    
    __weak typeof(self) weakSelf = self;
    ProjectListView *listView = [[ProjectListView alloc] initWithFrame:self.view.bounds projects:self.curPros block:^(Project *project) {
        [weakSelf goToProject:project];
    } tabBarHeight:0];
    listView.useNewStyle=TRUE;
    [self.view addSubview:listView];
    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- evnt

- (void)goToProject:(Project *)project{
    NProjectViewController *vc = [[NProjectViewController alloc] init];
    vc.myProject = project;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
