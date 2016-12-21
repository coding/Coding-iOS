//
//  ProjectToChooseListViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/7/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectToChooseListViewController.h"
#import "ProjectListView.h"
#import "EditTaskViewController.h"

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
            weakSelf.projectChoosedBlock(self, project);
        }else{
            [weakSelf goToNewTaskWithPro:project];
        }
    } tabBarHeight:0];
    [self.view addSubview:listView];
    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)goToNewTaskWithPro:(Project *)project{
    EditTaskViewController *taskVC = [EditTaskViewController new];
    taskVC.myTask = [Task taskWithProject:project andUser:[Login curLoginUser]];
    taskVC.myTask.handleType = TaskHandleTypeAddWithoutProject;
    NSUInteger index = MIN(0, [self.navigationController.viewControllers indexOfObject:self] - 1);
    UIViewController *doneVC = self.navigationController.viewControllers[index];
    __weak UIViewController *weakDoneVC = doneVC;
    taskVC.doneBlock = ^(EditTaskViewController *vc){
        [vc.navigationController popToViewController:weakDoneVC animated:YES];
    };
    [self.navigationController pushViewController:taskVC animated:YES];
}
@end
