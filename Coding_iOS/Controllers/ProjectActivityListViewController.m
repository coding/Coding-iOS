//
//  ProjectActivityListViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectActivityListViewController.h"
#import "UserInfoViewController.h"
#import "EditTaskViewController.h"
#import "TopicDetailViewController.h"
#import "FileListViewController.h"
#import "FileViewController.h"

@interface ProjectActivityListViewController ()

@end

@implementation ProjectActivityListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _curUser.name;

    __weak typeof(self) weakSelf = self;
    ProjectActivityListView *listView = [[ProjectActivityListView alloc] initWithFrame:self.view.bounds proAtcs:[ProjectActivities proActivitiesWithPro:_curProject user:_curUser] block:^(ProjectActivity *proActivity) {
        [weakSelf goToVCWithItem:nil activity:proActivity isContent:YES inProject:weakSelf.curProject];
    }];
    listView.htmlItemClickedBlock = ^(HtmlMediaItem *clickedItem, ProjectActivity *proAct, BOOL isContent){
        [weakSelf goToVCWithItem:clickedItem activity:proAct isContent:isContent inProject:weakSelf.curProject];
    };
    listView.userIconClickedBlock = ^(User *curUser){
        [weakSelf goToUserInfo:curUser];
    };
    [self.view addSubview:listView];
    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark toVC
- (void)goToUserInfo:(User *)user{
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.curUser = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToVCWithItem:(HtmlMediaItem *)clickedItem activity:(ProjectActivity *)proAct isContent:(BOOL)isContent inProject:(Project *)project{
    if (isContent) {//cell上面第二个Label
        NSString *target_type = proAct.target_type;
        if ([target_type isEqualToString:@"Task"]) {
            Task *task = proAct.task;
            NSArray *pathArray = [task.path componentsSeparatedByString:@"/"];
            if (pathArray.count >= 7) {
                EditTaskViewController *vc = [[EditTaskViewController alloc] init];
                vc.myTask = [Task taskWithBackend_project_path:[NSString stringWithFormat:@"/user/%@/project/%@", pathArray[2], pathArray[4]] andId:pathArray[6]];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [self showHudTipStr:@"任务不存在"];
            }
        }else if ([target_type isEqualToString:@"TaskComment"]){
            Task *task = proAct.task;
            NSArray *pathArray = [proAct.project.full_name componentsSeparatedByString:@"/"];
            if (pathArray.count >= 2) {
                EditTaskViewController *vc = [[EditTaskViewController alloc] init];
                vc.myTask = [Task taskWithBackend_project_path:[NSString stringWithFormat:@"/user/%@/project/%@", pathArray[0], pathArray[1]] andId:task.id.stringValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [self showHudTipStr:@"任务不存在"];
            }
        }else if ([target_type isEqualToString:@"ProjectTopic"]){
            
            ProjectTopic *topic = proAct.project_topic;
            NSArray *pathArray;
            if ([proAct.action isEqualToString:@"comment"]) {
                pathArray = [topic.parent.path componentsSeparatedByString:@"/"];
            }else{
                pathArray = [topic.path componentsSeparatedByString:@"/"];
            }
            if (pathArray.count >= 7) {
                TopicDetailViewController *vc = [[TopicDetailViewController alloc] init];
                vc.curTopic = [ProjectTopic topicWithId:[NSNumber numberWithInteger:[pathArray[6] integerValue]]];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [self showHudTipStr:@"讨论不存在"];
            }
        }else if ([target_type isEqualToString:@"ProjectFile"]){
            File *file = proAct.file;
            NSArray *pathArray = [file.path componentsSeparatedByString:@"/"];
            BOOL isFile = [proAct.type isEqualToString:@"file"];
            
            if (isFile && pathArray.count >= 9) {
                //文件
                NSString *fileIdStr = pathArray[8];
                ProjectFile *curFile = [ProjectFile fileWithFileId:@(fileIdStr.integerValue) andProjectId:@(project.id.integerValue)];
                curFile.name = file.name;
                FileViewController *vc = [[FileViewController alloc] init];
                vc.curFile = curFile;
                [self.navigationController pushViewController:vc animated:YES];
            }else if (!isFile && pathArray.count >= 7){
                //文件夹
                ProjectFolder *folder;
                NSString *folderIdStr = pathArray[6];
                if (![folderIdStr isEqualToString:@"default"] && [folderIdStr isPureInt]) {
                    NSNumber *folderId = [NSNumber numberWithInteger:folderIdStr.integerValue];
                    folder = [ProjectFolder folderWithId:folderId];
                    folder.name = file.name;
                }else{
                    folder = [ProjectFolder defaultFolder];
                    folder.name = @"默认文件夹";
                }
                FileListViewController *vc = [[FileListViewController alloc] init];
                vc.curProject = project;
                vc.curFolder = folder;
                vc.rootFolders = nil;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [self showHudTipStr:(isFile? @"文件不存在" :@"文件夹不存在")];
            }
        }else if ([target_type isEqualToString:@"ProjectMember"]) {
            if ([proAct.action isEqualToString:@"quit"]) {
                //退出项目
                
            }else{
                //添加了某成员
                User *user = proAct.target_user;
                UserInfoViewController *vc = [[UserInfoViewController alloc] init];
                vc.curUser = [User userWithGlobalKey:user.global_key];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else{
            [self showHudTipStr:@"还不能查看详细信息呢~"];
            DebugLog(@"暂时不解析啊：%@--%@", proAct.user.name, proAct.action_msg);
        }
    }else{//cell上面第一个Label
        [self goToUserInfo:[User userWithGlobalKey:[clickedItem.href substringFromIndex:3]]];
    }
}

@end
