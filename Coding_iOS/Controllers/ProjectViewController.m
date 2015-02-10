//
//  ProjectViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectViewController.h"
#import "UIViewController+DownMenu.h"
#import "ProjectActivitiesView.h"
#import "ProjectTasksView.h"
#import "EditTaskViewController.h"
#import "ProjectTopicsView.h"
#import "ProjectMemberListViewController.h"
#import "EditTopicViewController.h"
#import "TopicDetailViewController.h"
#import "ConversationViewController.h"
#import "Coding_NetAPIManager.h"
#import "UserInfoViewController.h"
#import "AddUserViewController.h"
#import "ProjectFolderListView.h"
#import "ProjectCodeListView.h"
#import "CodeListViewController.h"
#import "CodeViewController.h"
#import "ProjectActivityListViewController.h"
#import "FileListViewController.h"
#import "SettingTextViewController.h"
#import "FolderToMoveViewController.h"
#import "FileViewController.h"

typedef NS_ENUM(NSInteger, ProjectViewType)
{
    ProjectViewTypeActivities = 0,
    ProjectViewTypeTasks,
    ProjectViewTypeTopics,
    ProjectViewTypeFiles,
    ProjectViewTypeCodes,
    ProjectViewTypeMembers
};

@interface ProjectViewController ()

@property (nonatomic, strong) NSMutableDictionary *projectContentDict;
@property (nonatomic, strong) UIBarButtonItem *navAddBtn;

//项目成员
@property (strong, nonatomic) ProjectMemberListViewController *proMemberVC;

@end

@implementation ProjectViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        _curIndex = 0;
    }
    return self;
}
- (UIView *)getCurContentView{
    return [_projectContentDict objectForKey:[NSNumber numberWithInteger:_curIndex]];
}
- (void)saveCurContentView:(UIView *)curContentView{
    if (curContentView) {
        [_projectContentDict setObject:curContentView forKey:[NSNumber numberWithInteger:_curIndex]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _projectContentDict = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    if (_myProject) {
        if (!_myProject.owner_id) {
            [self requestForMyProject];
        }else{
            [self configNavBtnWithMyProject];
            [self refreshWithViewType:_curIndex];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshToQueryData];
}

- (void)refreshToQueryData{
    UIView *curView = [self getCurContentView];
    if (curView && [curView respondsToSelector:@selector(refreshToQueryData)]) {
        [curView performSelector:@selector(refreshToQueryData)];
    }
    
    
    if ([curView isKindOfClass:[ProjectTasksView class]]) {
        ProjectTasksView *tasksView = (ProjectTasksView *)curView;
        [tasksView refreshToQueryData];
    }else{
        if (curView && [curView respondsToSelector:@selector(reloadData)]) {
            [curView performSelector:@selector(reloadData)];
        }
    }
}


- (void)requestForMyProject{
    [self.view beginLoading];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:_myProject andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        if (data) {
            weakSelf.myProject = data;
            [weakSelf configNavBtnWithMyProject];
            [weakSelf refreshWithViewType:_curIndex];
        }
    }];
}

- (void)configNavBtnWithMyProject{
    __weak typeof(self) weakSelf = self;
    if (_myProject.is_public.boolValue) {
        [self customDownMenuWithTitles:@[[DownMenuTitle title:@"项目动态" image:@"nav_project_activity" badge:nil],
                                         [DownMenuTitle title:@"项目讨论" image:@"nav_project_topic" badge:nil],
                                         [DownMenuTitle title:@"项目代码" image:@"nav_project_code" badge:nil],
                                         [DownMenuTitle title:@"项目成员" image:@"nav_project_member" badge:nil]]
                       andDefaultIndex:_curIndex
                              andBlock:^(id titleObj, NSInteger index) {
                                  [(DownMenuTitle *)titleObj setBadgeValue:nil];
                                  ProjectViewType type;
                                  switch (index) {
                                      case 0:
                                          type = ProjectViewTypeActivities;
                                          break;
                                      case 1:
                                          type = ProjectViewTypeTopics;
                                          break;
                                      case 2:
                                          type = ProjectViewTypeCodes;
                                          break;
                                      case 3:
                                          type = ProjectViewTypeMembers;
                                          break;
                                      default:
                                          type = ProjectViewTypeActivities;
                                          break;
                                  }
                                  [weakSelf refreshWithViewType:type];
                              }];
    }else{
        [self customDownMenuWithTitles:@[[DownMenuTitle title:@"项目动态" image:@"nav_project_activity" badge:nil],
                                         [DownMenuTitle title:@"项目任务" image:@"nav_project_task" badge:nil],
                                         [DownMenuTitle title:@"项目讨论" image:@"nav_project_topic" badge:nil],
                                         [DownMenuTitle title:@"项目文档" image:@"nav_project_file" badge:nil],
                                         [DownMenuTitle title:@"项目代码" image:@"nav_project_code" badge:nil],
                                         [DownMenuTitle title:@"项目成员" image:@"nav_project_member" badge:nil]]
                       andDefaultIndex:_curIndex
                              andBlock:^(id titleObj, NSInteger index) {
                                  [(DownMenuTitle *)titleObj setBadgeValue:nil];
                                  [weakSelf refreshWithViewType:index];
                              }];
    }
}

- (void)configRightBarButtonItemWithViewType:(ProjectViewType)viewType{
    if (!_navAddBtn) {
        _navAddBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(navAddBtnClicked)];
    }
    
    UIBarButtonItem *shouldBeItem = nil;
    if ((viewType == ProjectViewTypeMembers && [[Login curLoginUser].global_key isEqualToString:_myProject.owner_user_name])
        || viewType == ProjectViewTypeTasks
        || viewType == ProjectViewTypeTopics
        || viewType == ProjectViewTypeFiles) {
        shouldBeItem = self.navAddBtn;
    }
    [self.navigationItem setRightBarButtonItem:shouldBeItem animated:YES];
}

- (void)refreshWithViewType:(ProjectViewType)viewType{
    [self configRightBarButtonItemWithViewType:viewType];
    
//    隐藏上一个视图
    UIView *curView = [self getCurContentView];
    if (_curIndex!= viewType && curView) {
        curView.hidden = YES;
    }
//    配置将要显示的视图
    _curIndex = viewType;
    curView = [self getCurContentView];
    __weak typeof(self) weakSelf = self;
    if (curView == nil) {
        switch (_curIndex) {
            case ProjectViewTypeActivities:{
                curView = ({
                    ProjectActivitiesView *activitiesView = [[ProjectActivitiesView alloc] initWithFrame:self.view.bounds project:_myProject block:^(ProjectActivity *proActivity) {
                        [weakSelf goToVCWithItem:nil activity:proActivity isContent:YES inProject:weakSelf.myProject];
                    } defaultIndex:0];
                    activitiesView.htmlItemClickedBlock = ^(HtmlMediaItem *clickedItem, ProjectActivity *proAct, BOOL isContent){
                        [weakSelf goToVCWithItem:clickedItem activity:proAct isContent:isContent inProject:weakSelf.myProject];
                    };
                    activitiesView.userIconClickedBlock = ^(User *curUser){
                        [weakSelf goToUserInfo:curUser];
                    };
                    activitiesView;
                });
            }
                break;
            case ProjectViewTypeTasks:{
                curView = ({
                    [[ProjectTasksView alloc] initWithFrame:self.view.bounds project:_myProject block:^(ProjectTaskListView *taskListView, Task *task) {
                        DebugLog(@"%@--%@", task.owner.name, task.content);
                        EditTaskViewController *vc = [[EditTaskViewController alloc] init];
                        vc.myTask = task;
                        vc.taskChangedBlock = ^(Task *curTask, TaskEditType type){
                            [taskListView refreshToQueryData];
                        };
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    } defaultIndex:0];
                });
            }
                break;
            case ProjectViewTypeTopics:{
                curView = [[ProjectTopicsView alloc] initWithFrame:self.view.bounds project:_myProject block:^(ProjectTopicListView *projectTopicListView, ProjectTopic *projectTopic) {
                    DebugLog(@"%@--\nProjectTopic:%@", projectTopicListView, projectTopic.title);
                    TopicDetailViewController *vc = [[TopicDetailViewController alloc] init];
                    vc.curTopic = projectTopic;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                } defaultIndex:0];
            }
                break;
            case ProjectViewTypeFiles:{
                curView = ({
                    ProjectFolderListView *folderListView = [[ProjectFolderListView alloc] initWithFrame:self.view.bounds project:_myProject];
                    folderListView.folderInProjectBlock = ^(ProjectFolders *rootFolders, ProjectFolder *clickedFolder, Project *inProject){
                        NSLog(@"folderInProjectBlock-----: %@- %@", clickedFolder.name, inProject.name);
                        [weakSelf goToVCWithRootFolder:rootFolders folder:clickedFolder inProject:inProject];
                    };
                    folderListView;
                });
            }
                break;
            case ProjectViewTypeCodes:{
                curView = ({
                    ProjectCodeListView *codeListView = [[ProjectCodeListView alloc] initWithFrame:self.view.bounds project:_myProject andCodeTree:nil];
                    codeListView.codeTreeFileOfRefBlock = ^(CodeTree_File *curCodeTreeFile, NSString *ref){
                        [weakSelf goToVCWith:curCodeTreeFile andRef:ref];
                    };
                    [codeListView addBranchTagButton];
                    codeListView;
                });
            }
                break;
            case ProjectViewTypeMembers:{
                _proMemberVC = [[ProjectMemberListViewController alloc] init];
                [_proMemberVC setFrame:self.view.bounds project:_myProject type:ProMemTypeProject refreshBlock:^(NSArray *memberArray) {
                    DebugLog(@"%@", memberArray.description);
                } selectBlock:^(ProjectMember *member) {
                    DebugLog(@"%@", member.user.name);
                    [weakSelf goToActivityListOfUser:member.user];
                } cellBtnBlock:^(ProjectMember *member) {
                    DebugLog(@"%@", member.user.name);
                    if (member.user_id.intValue == [Login curLoginUser].id.intValue) {//自己，退出了项目
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    }else{//别人，发起私信
                        ConversationViewController *vc = [[ConversationViewController alloc] init];
                        vc.myPriMsgs = [PrivateMessages priMsgsWithUser:member.user];
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    }
                }];
                curView = _proMemberVC.view;
            }
                break;
            default:
                break;
        }
        [self saveCurContentView:curView];
        [self.view addSubview:curView];
        [curView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    if (_curIndex != ProjectViewTypeMembers && _proMemberVC) {
        [_proMemberVC willHiden];
    }
    curView.hidden = NO;
}

#pragma mark toVC
- (void)goToUserInfo:(User *)user{
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.curUser = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToActivityListOfUser:(User *)user{
    ProjectActivityListViewController *vc = [[ProjectActivityListViewController alloc] init];
    vc.curProject = self.myProject;
    vc.curUser = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToVCWith:(CodeTree_File *)codeTreeFile andRef:(NSString *)ref{
    NSLog(@"%@", codeTreeFile.path);
    if ([codeTreeFile.mode isEqualToString:@"tree"]) {//文件夹
        CodeTree *nextCodeTree = [CodeTree codeTreeWithRef:ref andPath:codeTreeFile.path];
        CodeListViewController *vc = [[CodeListViewController alloc] init];
        vc.myProject = _myProject;
        vc.myCodeTree = nextCodeTree;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([codeTreeFile.mode isEqualToString:@"file"] || [codeTreeFile.mode isEqualToString:@"image"]){//文件
        CodeFile *nextCodeFile = [CodeFile codeFileWithRef:ref andPath:codeTreeFile.path];
        CodeViewController *vc = [CodeViewController codeVCWithProject:_myProject andCodeFile:nextCodeFile];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self showHudTipStr:@"有些文件还不支持查看呢_(:з」∠)_"];
    }
}

- (void)goToVCWithRootFolder:(ProjectFolders *)rootFolders folder:(ProjectFolder *)folder inProject:(Project *)project{
    FileListViewController *vc = [[FileListViewController alloc] init];
    vc.rootFolders = rootFolders;
    vc.curFolder = folder;
    vc.curProject = project;
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

#pragma mark Mine M
- (void)navAddBtnClicked{
    switch (_curIndex) {
        case ProjectViewTypeTasks:
        {
            EditTaskViewController *vc = [[EditTaskViewController alloc] init];
            vc.myTask = [Task taskWithProject:self.myProject];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case ProjectViewTypeTopics:
        {
            EditTopicViewController *vc = [[EditTopicViewController alloc] init];
            vc.curProTopic = [ProjectTopic topicWithPro:self.myProject];
            vc.type = TopicEditTypeAdd;
            vc.topicChangedBlock = nil;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case ProjectViewTypeMembers:{
            __weak typeof(self) weakSelf = self;
            AddUserViewController *vc = [[AddUserViewController alloc] init];
            vc.curProject = self.myProject;
            vc.type = AddUserTypeProject;
            if (_proMemberVC && _proMemberVC.myMemberArray) {
                [vc configAddedArrayWithMembers:_proMemberVC.myMemberArray];
            }
            vc.popSelfBlock = ^(){
                if (weakSelf.proMemberVC) {
                    [weakSelf.proMemberVC refreshMembersData];
                }
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case ProjectViewTypeFiles:{
            //新建文件夹
            __weak typeof(self) weakSelf = self;
            [SettingTextViewController showSettingFolderNameVCFromVC:self withTitle:@"新建文件夹" textValue:nil type:SettingTypeNewFolderName doneBlock:^(NSString *textValue) {
                NSLog(@"%@", textValue);
                [[Coding_NetAPIManager sharedManager] request_CreatFolder:textValue inFolder:nil inProject:weakSelf.myProject andBlock:^(id data, NSError *error) {
                    if (data) {
                        [weakSelf showHudTipStr:@"创建文件夹成功"];
                        ProjectFolderListView *folderListView = (ProjectFolderListView *)[weakSelf getCurContentView];
                        if (folderListView && [folderListView isKindOfClass:[ProjectFolderListView class]]) {
                            [folderListView refreshToQueryData];
                        }
                    }
                }];
            }];

        }
            break;
        default:
            break;
    }

}


@end
