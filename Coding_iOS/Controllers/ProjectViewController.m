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
#import "ProjectMemberActivityListViewController.h"
#import "FileListViewController.h"
#import "SettingTextViewController.h"
#import "FolderToMoveViewController.h"
#import "FileViewController.h"
#import "ProjectCommitsViewController.h"
#import "MRDetailViewController.h"

#import "ProjectCommitsViewController.h"
#import "PRDetailViewController.h"
#import "NProjectViewController.h"
#import "CommitFilesViewController.h"

#import "FunctionTipsManager.h"

@interface ProjectViewController ()

@property (nonatomic, strong) NSMutableDictionary *projectContentDict;

//项目成员
@property (strong, nonatomic) ProjectMemberListViewController *proMemberVC;

@end

@implementation ProjectViewController

+ (ProjectViewController *)codeVCWithCodeRef:(NSString *)codeRef andProject:(Project *)project{
    ProjectViewController *vc = [self new];
    vc.codeRef = codeRef;
    vc.myProject = project;
    if (vc.myProject.is_public.boolValue) {
        vc.curIndex = 2;
    }else{
        vc.curIndex = 4;
    }
    return vc;
}
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
        if (!_myProject.is_public) {
            [self requestForMyProject];
        }else{
            [self configNavBtnWithMyProject];
            [self refreshWithNewIndex:_curIndex];
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
            [weakSelf refreshWithNewIndex:_curIndex];
        }
    }];
}

- (void)configNavBtnWithMyProject{
    self.title = _myProject.name;
}

- (void)configRightBarButtonItemWithViewType:(ProjectViewType)viewType{
    UIBarButtonItem *navRightBtn = nil;
    if ((viewType == ProjectViewTypeMembers && [[Login curLoginUser].global_key isEqualToString:_myProject.owner_user_name])
        || viewType == ProjectViewTypeTasks
        || viewType == ProjectViewTypeTopics
        || viewType == ProjectViewTypeFiles) {
        navRightBtn = [[UIBarButtonItem alloc]
                       initWithImage:[UIImage
                                      imageNamed:(viewType == ProjectViewTypeCodes ? @"timeBtn_Nav" : @"addBtn_Nav")]
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(navRightBtnClicked)];
    }else if (viewType == ProjectViewTypeCodes){
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [button setImage:[UIImage imageNamed:@"timeBtn_Nav"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(navRightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        if ([[FunctionTipsManager shareManager] needToTip:kFunctionTipStr_CommitList]) {
            [button addBadgeTip:kBadgeTipStr withCenterPosition:CGPointMake(20, 0)];
        }
        navRightBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    [self.navigationItem setRightBarButtonItem:navRightBtn animated:YES];
}

- (ProjectViewType)viewTypeFromIndex:(NSInteger)index{
    ProjectViewType type = 0;
    if (_myProject.is_public) {
        if (_myProject.is_public.boolValue) {
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
        }else{
            type = index;
        }
    }
    return type;
}

- (ProjectViewType)curType{
    return [self viewTypeFromIndex:_curIndex];
}

- (void)refreshWithNewIndex:(NSInteger)newIndex{
    ProjectViewType curViewType = [self viewTypeFromIndex:_curIndex];
    ProjectViewType newViewType = [self viewTypeFromIndex:newIndex];
    
//    配置navBtn
    [self configRightBarButtonItemWithViewType:newViewType];
    
//    隐藏上一个视图
    UIView *curView = [self getCurContentView];
    if (curViewType != newViewType && curView) {
        curView.hidden = YES;
    }
//    配置将要显示的视图
    _curIndex = newIndex;
    curView = [self getCurContentView];
    __weak typeof(self) weakSelf = self;
    if (curView == nil) {
        switch (newViewType) {
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
                        EditTaskViewController *vc = [[EditTaskViewController alloc] init];
                        vc.myTask = task;
                        vc.taskChangedBlock = ^(){
                            [taskListView refreshToQueryData];
                        };
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    } defaultIndex:0];
                });
            }
                break;
            case ProjectViewTypeTopics:{
                curView = [[ProjectTopicsView alloc] initWithFrame:self.view.bounds project:_myProject block:^(ProjectTopicListView *projectTopicListView, ProjectTopic *projectTopic) {
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
                        DebugLog(@"folderInProjectBlock-----: %@- %@", clickedFolder.name, inProject.name);
                        [weakSelf goToVCWithRootFolder:rootFolders folder:clickedFolder inProject:inProject];
                    };
                    folderListView;
                });
            }
                break;
            case ProjectViewTypeCodes:{
                curView = ({
                    ProjectCodeListView *codeListView = [[ProjectCodeListView alloc] initWithFrame:self.view.bounds project:_myProject andCodeTree:[CodeTree codeTreeWithRef:_codeRef andPath:@""]];
                    codeListView.codeTreeFileOfRefBlock = ^(CodeTree_File *curCodeTreeFile, NSString *ref){
                        [weakSelf goToVCWith:curCodeTreeFile andRef:ref];
                    };
                    codeListView.refChangedBlock = ^(NSString *ref){
                        weakSelf.codeRef = ref;
                    };
                    [codeListView addBranchTagButton];
                    codeListView;
                });
            }
                break;
            case ProjectViewTypeMembers:{
                _proMemberVC = [[ProjectMemberListViewController alloc] init];
                [_proMemberVC setFrame:self.view.bounds project:_myProject type:ProMemTypeProject refreshBlock:^(NSArray *memberArray) {
                } selectBlock:^(ProjectMember *member) {
                    [weakSelf goToActivityListOfUser:member.user];
                } cellBtnBlock:^(ProjectMember *member) {
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
    if (newViewType != ProjectViewTypeMembers && _proMemberVC) {
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
    ProjectMemberActivityListViewController *vc = [[ProjectMemberActivityListViewController alloc] init];
    vc.curProject = self.myProject;
    vc.curUser = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToVCWith:(CodeTree_File *)codeTreeFile andRef:(NSString *)ref{
    DebugLog(@"%@", codeTreeFile.path);
    if ([codeTreeFile.mode isEqualToString:@"tree"]) {//文件夹
        CodeTree *nextCodeTree = [CodeTree codeTreeWithRef:ref andPath:codeTreeFile.path];
        CodeListViewController *vc = [[CodeListViewController alloc] init];
        vc.myProject = _myProject;
        vc.myCodeTree = nextCodeTree;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([@[@"file", @"image", @"sym_link"] containsObject:codeTreeFile.mode]){//文件
        CodeFile *nextCodeFile = [CodeFile codeFileWithRef:ref andPath:codeTreeFile.path];
        CodeViewController *vc = [CodeViewController codeVCWithProject:_myProject andCodeFile:nextCodeFile];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [NSObject showHudTipStr:@"有些文件还不支持查看呢_(:з」∠)_"];
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
                    folder.name = @"默认文件夹";
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

#pragma mark Mine M
- (void)navRightBtnClicked{
    ProjectViewType curViewType = [self viewTypeFromIndex:_curIndex];
    switch (curViewType) {
        case ProjectViewTypeTasks:
        {
            UIView *curView = [self getCurContentView];
            if (![curView isKindOfClass:[ProjectTasksView class]]) {
                return;
            }
            ProjectTasksView *tasksView = (ProjectTasksView *)curView;
            EditTaskViewController *vc = [[EditTaskViewController alloc] init];
            User *user = tasksView.selectedMember.user? tasksView.selectedMember.user : [Login curLoginUser];
            vc.myTask = [Task taskWithProject:self.myProject andUser:user];
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
        case ProjectViewTypeMembers:
        {
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
        case ProjectViewTypeFiles:
        {
            //新建文件夹
            __weak typeof(self) weakSelf = self;
            [SettingTextViewController showSettingFolderNameVCFromVC:self withTitle:@"新建文件夹" textValue:nil type:SettingTypeNewFolderName doneBlock:^(NSString *textValue) {
                DebugLog(@"%@", textValue);
                [[Coding_NetAPIManager sharedManager] request_CreatFolder:textValue inFolder:nil inProject:weakSelf.myProject andBlock:^(id data, NSError *error) {
                    if (data) {
                        [NSObject showHudTipStr:@"创建文件夹成功"];
                        ProjectFolderListView *folderListView = (ProjectFolderListView *)[weakSelf getCurContentView];
                        if (folderListView && [folderListView isKindOfClass:[ProjectFolderListView class]]) {
                            [folderListView refreshToQueryData];
                        }
                    }
                }];
            }];

        }
            break;
        case ProjectViewTypeCodes:
        {
            if ([[FunctionTipsManager shareManager] needToTip:kFunctionTipStr_CommitList]) {
                [[FunctionTipsManager shareManager] markTiped:kFunctionTipStr_CommitList];
                [self configRightBarButtonItemWithViewType:ProjectViewTypeCodes];
            }
            //代码提交记录
            ProjectCommitsViewController *vc = [ProjectCommitsViewController new];
            vc.curProject = self.myProject;
            vc.curCommits = [Commits commitsWithRef:self.codeRef? self.codeRef: @"master" Path:@""];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}


@end
