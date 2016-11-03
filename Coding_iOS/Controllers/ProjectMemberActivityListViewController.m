//
//  ProjectMemberActivityListViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectMemberActivityListViewController.h"
#import "UserInfoViewController.h"
#import "EditTaskViewController.h"
#import "TopicDetailViewController.h"
#import "FileListViewController.h"
#import "FileViewController.h"
#import "MRDetailViewController.h"

#import "ProjectCommitsViewController.h"
#import "PRDetailViewController.h"
#import "NProjectViewController.h"
#import "ProjectViewController.h"
#import "CommitFilesViewController.h"

@interface ProjectMemberActivityListViewController ()

@end

@implementation ProjectMemberActivityListViewController

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
                [NSObject showHudTipStr:@"任务不存在"];
            }
        }else if ([target_type isEqualToString:@"TaskComment"]){
            Task *task = proAct.task;
            NSArray *pathArray = [proAct.project.full_name componentsSeparatedByString:@"/"];
            if (pathArray.count >= 2) {
                EditTaskViewController *vc = [[EditTaskViewController alloc] init];
                vc.myTask = [Task taskWithBackend_project_path:[NSString stringWithFormat:@"/user/%@/project/%@", pathArray[0], pathArray[1]] andId:task.id.stringValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [NSObject showHudTipStr:@"任务不存在"];
            }
        }else if ([target_type isEqualToString:@"ProjectTopic"]){
            
            ProjectTopicActivity *topic = proAct.project_topic;
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
                [NSObject showHudTipStr:@"讨论不存在"];
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
                FileViewController *vc = [FileViewController vcWithFile:curFile andVersion:nil];
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
                }
                FileListViewController *vc = [[FileListViewController alloc] init];
                vc.curProject = project;
                vc.curFolder = folder;
                vc.rootFolders = nil;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [NSObject showHudTipStr:(isFile? @"文件不存在" :@"文件夹不存在")];
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
            
            
        }else if ([target_type isEqualToString:@"Depot"]) {
            if ([proAct.action_msg isEqualToString:@"删除了"]) {
                [NSObject showHudTipStr:@"删除了，不能看了~"];
            }else if ([proAct.action isEqualToString:@"fork"]) {
                NSArray *nameComponents = [proAct.depot.name componentsSeparatedByString:@"/"];
                if (nameComponents.count == 2) {
                    NProjectViewController *vc = [NProjectViewController new];
                    vc.myProject = [Project new];
                    vc.myProject.owner_user_name = nameComponents[0];
                    vc.myProject.name = nameComponents[1];
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    [NSObject showHudTipStr:@"没找到 Fork 到哪里去了~"];
                }
            }else if ([proAct.action isEqualToString:@"push"]){
                //    current_user_role_id = 75 是受限成员，不可访问代码
                if (!project.is_public.boolValue && project.current_user_role_id.integerValue <= 75) {
                    [NSObject showHudTipStr:@"无权访问项目代码相关功能"];
                    return;
                }
                if (proAct.commits.count == 1) {
                    Commit *firstCommit = [proAct.commits firstObject];
                    NSString *request_path = [NSString stringWithFormat:@"%@/commit/%@", proAct.depot.path, firstCommit.sha];
                    CommitFilesViewController *vc = [CommitFilesViewController vcWithPath:request_path];
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    NSString *ref = proAct.ref? proAct.ref : @"master";
                    ProjectCommitsViewController *vc = [ProjectCommitsViewController new];
                    vc.curProject = project;
                    vc.curCommits = [Commits commitsWithRef:ref Path:@""];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else{
                ProjectViewController *vc = [ProjectViewController codeVCWithCodeRef:proAct.ref andProject:project];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else if ([target_type isEqualToString:@"PullRequestBean"] ||
                  [target_type isEqualToString:@"MergeRequestBean"] ||
                  [target_type isEqualToString:@"CommitLineNote"]){
            //    current_user_role_id = 75 是受限成员，不可访问代码
            if (!project.is_public.boolValue && project.current_user_role_id.integerValue <= 75) {
                [NSObject showHudTipStr:@"无权访问项目代码相关功能"];
                return;
            }
            NSString *request_path;
            if ([target_type isEqualToString:@"PullRequestBean"]){
                request_path = proAct.pull_request_path;
            }else if ([target_type isEqualToString:@"MergeRequestBean"]){
                request_path = proAct.merge_request_path;
            }else if ([target_type isEqualToString:@"CommitLineNote"]){
                request_path = proAct.line_note.noteable_url;
            }
            
            UIViewController *vc;
            if ([proAct.line_note.noteable_type isEqualToString:@"Commit"]) {
                vc = [CommitFilesViewController vcWithPath:request_path];
            }else{
                if([request_path rangeOfString:@"merge"].location == NSNotFound) {
                     vc = [PRDetailViewController vcWithPath:request_path];
                } else {
                     vc = [MRDetailViewController vcWithPath:request_path];

                }
                
            }
            if (vc) {
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [NSObject showHudTipStr:@"不知道这是个什么东西o(╯□╰)o~"];
            }
        }else{
            if ([target_type isEqualToString:@"Project"]){//这是什么鬼。。遗留的 type 吧
                [NSObject showHudTipStr:@"还不能查看详细信息呢~"];
                //            }else if ([target_type isEqualToString:@"MergeRequestComment"]){//过期类型，已用CommitLineNote替代
                //            }else if ([target_type isEqualToString:@"PullRequestComment"]){//过期类型，已用CommitLineNote替代
                //            }else if ([target_type isEqualToString:@"ProjectStar"]){//不用解析
                //            }else if ([target_type isEqualToString:@"ProjectWatcher"]){//不用解析
            }else if ([target_type isEqualToString:@"QcTask"]){//还不能解析
                [NSObject showHudTipStr:@"还不能查看详细信息呢~"];
            }
        }
    }else{//cell上面第一个Label
        [self goToUserInfo:[User userWithGlobalKey:[clickedItem.href substringFromIndex:3]]];
    }
}
@end
