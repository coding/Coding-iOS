//
//  ProjectToChooseListViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/7/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectToChooseListViewController.h"
#import "ProjectListView.h"

@interface ProjectToChooseListViewController ()
@property (strong, nonatomic) Projects *curPros;
@end

@implementation ProjectToChooseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"所属项目";
    self.curPros = [Projects projectsWithType:ProjectsTypeToChoose andUser:nil];
    
    __weak typeof(self) weakSelf = self;
    ProjectListView *listView = [[ProjectListView alloc] initWithFrame:self.view.bounds projects:self.curPros block:^(Project *project) {
        if (weakSelf.projectChoosedBlock) {
            weakSelf.projectChoosedBlock(project);
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } tabBarHeight:0];
    [self.view addSubview:listView];
    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
