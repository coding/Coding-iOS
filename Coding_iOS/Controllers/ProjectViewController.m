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
#import "TaskSelectionView.h"
#import "ScreenView.h"


@interface ProjectViewController ()

@property (nonatomic, strong) NSMutableDictionary *projectContentDict;

//项目成员
@property (strong, nonatomic) ProjectMemberListViewController *proMemberVC;
@property (strong, nonatomic) UIButton *titleBtn;

@property (nonatomic, strong) TaskSelectionView *myFliterMenu;
@property (nonatomic, strong) ScreenView *screenView;


@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *status; //任务状态，进行中的为1，已完成的为2
@property (nonatomic, strong) NSString *label; //任务标签
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) TaskRoleType role;

@property (nonatomic, strong)  UIBarButtonItem *screenBar;

@property (strong, nonatomic) CodeTree *myCodeTree;

@end

@implementation ProjectViewController

+ (ProjectViewController *)codeVCWithCodeRef:(NSString *)codeRef andProject:(Project *)project{
    ProjectViewController *vc = [self new];
    vc.myCodeTree = [CodeTree codeTreeWithRef:codeRef andPath:@""];
    vc.myProject = project;
    if (vc.myProject.is_public.boolValue) {
        vc.curIndex = 2;
    }else{
        vc.curIndex = 4;
    }
    return vc;
}

- (CodeTree *)myCodeTree{
    if (!_myCodeTree) {
        _myCodeTree = [CodeTree codeTreeWithRef:@"master" andPath:@""];
    }
    return _myCodeTree;
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
    UIView *curView = [self getCurContentView];
    if ([curView isKindOfClass:[ProjectTasksView class]]) {
        [self setupTitleBtn];

        ProjectTasksView *tasksView = (ProjectTasksView *)curView;
        [self assignmentWithlistView:tasksView];
        [tasksView refresh];
        
        _role = TaskRoleTypeAll;
        //初始化过滤目录
        _myFliterMenu = [[TaskSelectionView alloc] initWithFrame:CGRectMake(0, 44 + kSafeArea_Top, kScreen_Width, kScreen_Height - (44 + kSafeArea_Top)) items:@[@"所有任务（0）", @"我关注的（0）", @"我创建的（0）"]];
        __weak typeof(self) weakSelf = self;
        _myFliterMenu.clickBlock = ^(NSInteger pageIndex){
            _role = pageIndex;
            if (pageIndex == 0) {
                _role = TaskRoleTypeAll;
            }
            
            NSString *title = weakSelf.myFliterMenu.items[pageIndex];
            [weakSelf.titleBtn setTitle:[title substringToIndex:4] forState:UIControlStateNormal];
            
            UIView *curView = [weakSelf getCurContentView];
            if (![curView isKindOfClass:[ProjectTasksView class]]) {
                return;
            }
            ProjectTasksView *tasksView = (ProjectTasksView *)curView;
            [weakSelf assignmentWithlistView:tasksView];
            [tasksView refresh];
            [weakSelf resetTaskCount];
            [weakSelf loadTasksLabels];
            
        };
        _myFliterMenu.closeBlock=^(){
            [weakSelf.myFliterMenu dismissMenu];
        };
        
        _screenView = [ScreenView creat];
        weakSelf.screenView.tastArray = @[[NSString stringWithFormat:@"进行中的（0）"],
                                          [NSString stringWithFormat:@"已完成的（0）"]
                                          ];
        
        _screenView.selectBlock = ^(NSString *keyword, NSString *status, NSString *label) {
            [((UIButton *)weakSelf.screenBar.customView) setImage:[UIImage imageNamed:@"task_filter_nav_checked"] forState:UIControlStateNormal];
            weakSelf.keyword = keyword;
            weakSelf.status = status;
            weakSelf.label = label;
            if (keyword == nil && status == nil && label == nil) {
                [((UIButton *)weakSelf.screenBar.customView) setImage:[UIImage imageNamed:@"task_filter_nav_unchecked"] forState:UIControlStateNormal];
                
            }
            UIView *curView = [weakSelf getCurContentView];
            if (![curView isKindOfClass:[ProjectTasksView class]]) {
                return;
            }
            ProjectTasksView *tasksView = (ProjectTasksView *)curView;
            [weakSelf assignmentWithlistView:tasksView];
            [tasksView refresh];
            
        };
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
    [self resetTaskCount];
    [self loadTasksLabels];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_myFliterMenu dismissMenu];
}

- (void)refreshToQueryData{
    UIView *curView = [self getCurContentView];
    if (!curView) {
        return;
    }
    
    if ([curView respondsToSelector:@selector(refreshToQueryData)]) {
        [curView performSelector:@selector(refreshToQueryData)];
    }else if ([curView respondsToSelector:@selector(reloadData)]){
        [curView performSelector:@selector(reloadData)];
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
    if (self.curType != ProjectViewTypeTasks) {
        self.title = _myProject.name;
    }
}

- (void)configRightBarButtonItemWithViewType:(ProjectViewType)viewType{
    UIBarButtonItem *navRightBtn = nil;
    if ((viewType == ProjectViewTypeMembers && _myProject.current_user_role_id.integerValue >= 90)
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
        [button setImage:[UIImage imageNamed:@"moreBtn_Nav"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(navRightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        navRightBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    if (ProjectViewTypeTasks == viewType) {
        UIBarButtonItem *screenBar = [self HDCustomNavButtonWithTitle:nil imageName:@"task_filter_nav_unchecked" target:self action:@selector(screenItemClicked:)];
        self.navigationItem.rightBarButtonItems = @[navRightBtn, screenBar];
        _screenBar = screenBar;
    } else {
        [self.navigationItem setRightBarButtonItem:navRightBtn animated:YES];
    }
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
                ((ProjectTasksView *)curView).selctUserBlock = ^(NSString *owner) {
                    weakSelf.userId = owner;
                    [weakSelf resetTaskCount];
                    [weakSelf loadTasksLabels];
                };
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
                    folderListView.containerVC = self;
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
                    ProjectCodeListView *codeListView = [[ProjectCodeListView alloc] initWithFrame:self.view.bounds project:_myProject andCodeTree:_myCodeTree];
                    codeListView.codeTreeFileOfRefBlock = ^(CodeTree_File *curCodeTreeFile, NSString *ref){
                        [weakSelf goToVCWith:curCodeTreeFile andRef:ref];
                    };
                    codeListView.codeTreeChangedBlock = ^(CodeTree *tree){
                        weakSelf.myCodeTree = tree;
                    };
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
    }else if ([@[@"file", @"image", @"sym_link", @"executable"] containsObject:codeTreeFile.mode]){//文件
        CodeFile *nextCodeFile = [CodeFile codeFileWithRef:ref andPath:codeTreeFile.path];
        CodeViewController *vc = [CodeViewController codeVCWithProject:_myProject andCodeFile:nextCodeFile];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([codeTreeFile.mode isEqualToString:@"git_link"]){
        UIViewController *vc = [BaseViewController analyseVCFromLinkStr:codeTreeFile.info.submoduleLink];
        if (vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [NSObject showHudTipStr:@"有些文件还不支持查看呢_(:з」∠)_"];
        }
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
        NSString *linkPath = nil, *tipStr = nil;
        
        if ([target_type isEqualToString:@"Task"]) {
            linkPath = proAct.task.path;
            tipStr = @"任务不存在";
        }else if ([target_type isEqualToString:@"TaskComment"]){
            NSArray *pathArray = [proAct.project.full_name componentsSeparatedByString:@"/"];
            linkPath = pathArray.count >= 2? [NSString stringWithFormat:@"/u/%@/p/%@/task/%@", pathArray[0], pathArray[1], proAct.task.id]: nil;
        }else if ([target_type isEqualToString:@"ProjectFile"]){
            BOOL isFile = [proAct.type isEqualToString:@"file"];
            NSArray *pathArray = [proAct.file.path componentsSeparatedByString:@"/"];
            if (!isFile && pathArray.count >= 7){
                //文件夹
                ProjectFolder *folder;
                NSString *folderIdStr = pathArray[6];
                if (![folderIdStr isEqualToString:@"default"] && [folderIdStr isPureInt]) {
                    NSNumber *folderId = [NSNumber numberWithInteger:folderIdStr.integerValue];
                    folder = [ProjectFolder folderWithId:folderId];
                    folder.name = proAct.file.name;
                }else{
                    folder = [ProjectFolder defaultFolder];
                }
                FileListViewController *vc = [[FileListViewController alloc] init];
                vc.curProject = project;
                vc.curFolder = folder;
                vc.rootFolders = nil;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                if (isFile) {
                    linkPath = proAct.file.path;
                }
                tipStr = isFile? @"文件不存在" :@"文件夹不存在";
            }
        }else if ([target_type isEqualToString:@"ProjectMember"]) {
            if ([proAct.action isEqualToString:@"quit"]) {
                //退出项目
            }else{
                //添加了某成员
                linkPath = [NSString stringWithFormat:@"/u/%@", proAct.target_user.global_key];
            }
        }else if ([target_type isEqualToString:@"Depot"]) {
            if ([proAct.action_msg isEqualToString:@"删除了"]) {
                tipStr = @"删除了，不能看了~";
            }else if ([proAct.action isEqualToString:@"fork"]) {
                NSArray *nameComponents = [proAct.depot.name componentsSeparatedByString:@"/"];
                linkPath = nameComponents.count == 2? [NSString stringWithFormat:@"/u/%@/p/%@", nameComponents[0], nameComponents[1]]: nil;
                tipStr = @"没找到 Fork 到哪里去了~";
            }else if ([proAct.action isEqualToString:@"push"]){
                //    current_user_role_id = 75 是受限成员，不可访问代码
                if (!project.is_public.boolValue && project.current_user_role_id.integerValue <= 75) {
                    tipStr = @"无权访问项目代码相关功能";
                }else{
                    if (proAct.commits.count == 1) {
                        Commit *firstCommit = [proAct.commits firstObject];
                        linkPath = [NSString stringWithFormat:@"%@/commit/%@", proAct.depot.path, firstCommit.sha];
                    }else{
                        NSString *ref = proAct.ref? proAct.ref : @"master";
                        ProjectCommitsViewController *vc = [ProjectCommitsViewController new];
                        vc.curProject = project;
                        vc.curCommits = [Commits commitsWithRef:ref Path:@""];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
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
                tipStr = @"无权访问项目代码相关功能";
            }else{
                if ([target_type isEqualToString:@"PullRequestBean"]){
                    linkPath = proAct.pull_request_path;
                }else if ([target_type isEqualToString:@"MergeRequestBean"]){
                    linkPath = proAct.merge_request_path;
                }else if ([target_type isEqualToString:@"CommitLineNote"]){
                    linkPath = proAct.line_note.noteable_url;
                }
                tipStr = @"不知道这是个什么东西o(╯□╰)o~";
            }
        }else if ([target_type isEqualToString:@"ProjectTweet"]) {
            if ([proAct.action isEqualToString:@"delete"]) {
                tipStr = @"删除了，不能看了~";
            }else{
                linkPath = [NSString stringWithFormat:@"/p/%@/setting/notice", proAct.project.name];
            }
        }else if ([target_type isEqualToString:@"Wiki"]) {
            if ([proAct.action isEqualToString:@"delete"]) {
                tipStr = @"删除了，不能看了~";
            }else{
                linkPath = proAct.wiki_path;
            }
        }else{
            if ([target_type isEqualToString:@"Project"]){//转让项目之类的
                //            }else if ([target_type isEqualToString:@"MergeRequestComment"]){//过期类型，已用CommitLineNote替代
                //            }else if ([target_type isEqualToString:@"PullRequestComment"]){//过期类型，已用CommitLineNote替代
                //            }else if ([target_type isEqualToString:@"ProjectStar"]){//不用解析
                //            }else if ([target_type isEqualToString:@"ProjectWatcher"]){//不用解析
                //            }else if ([target_type isEqualToString:@"QcTask"]){//还不能解析
            }else{
                tipStr = @"还不能查看详细信息呢~";
            }
        }
        UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkPath];
        if (vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [NSObject showHudTipStr:tipStr];
        }
    }else{//cell上面第一个Label
        [self goToUserInfo:[User userWithGlobalKey:[clickedItem.href substringFromIndex:3]]];
    }
}

#pragma mark Mine M
- (void)navRightBtnClicked{
    [_myFliterMenu dismissMenu];

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
            vc.type = AddUserTypeProjectRoot;
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
            __weak typeof(self) weakSelf = self;
            [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"上传图片", @"创建文本文件", @"查看提交记录"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [(ProjectCodeListView *)[weakSelf getCurContentView] uploadImageClicked];
                }else if (index == 1){
                    [(ProjectCodeListView *)[weakSelf getCurContentView] createFileClicked];
                }else if (index == 2){
                    [weakSelf goToCommitsVC];
                }
            }] showInView:self.view];
        }
            break;
        default:
            break;
    }
}

- (void)goToCommitsVC{
    //代码提交记录
    ProjectCommitsViewController *vc = [ProjectCommitsViewController new];
    vc.curProject = self.myProject;
    vc.curCommits = [Commits commitsWithRef:self.myCodeTree.ref Path:@""];
    [self.navigationController pushViewController:vc animated:YES];
}



- (UIBarButtonItem *)HDCustomNavButtonWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)targe action:(SEL)action {
    UIButton *itemButtom = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    [itemButtom setImage:image forState:UIControlStateNormal];
    itemButtom.titleLabel.font = [UIFont systemFontOfSize: 16];
    [itemButtom setTitle:title forState:UIControlStateNormal];
    [itemButtom setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    UIColor *color = [UINavigationBar appearance].titleTextAttributes[NSForegroundColorAttributeName];
    if (color == nil) {
        color = [UIColor blackColor];
    }
    [itemButtom setTitleColor:color forState:UIControlStateNormal];
    itemButtom.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [itemButtom addTarget:targe action:action
         forControlEvents:UIControlEventTouchUpInside];
    if (title == nil && imageName != nil) {
        [itemButtom setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    } else {
        [itemButtom setFrame:CGRectMake(0, 0, 80, 40)];
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]
                                      initWithCustomView:itemButtom];
    return barButtonItem;
}

- (void)screenItemClicked:(UIBarButtonItem *)sender {
    [_myFliterMenu dismissMenu];
    [_screenView showOrHide];
}

- (void)setupTitleBtn{
    if (!_titleBtn) {
        _titleBtn = [UIButton new];
        [_titleBtn setTitleColor:kColorNavTitle forState:UIControlStateNormal];
        [_titleBtn.titleLabel setFont:[UIFont systemFontOfSize:kNavTitleFontSize]];
        [_titleBtn addTarget:self action:@selector(fliterClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = _titleBtn;
        [self setTitleBtnStr:@"所有任务"];
    }
}

- (void)setTitleBtnStr:(NSString *)titleStr{
    if (_titleBtn) {
        CGFloat titleWidth = [titleStr getWidthWithFont:_titleBtn.titleLabel.font constrainedToSize:CGSizeMake(kScreen_Width, 30)];
        CGFloat imageWidth = 12;
        CGFloat btnWidth = titleWidth +imageWidth;
        _titleBtn.frame = CGRectMake((kScreen_Width-btnWidth)/2, (44-30)/2, btnWidth, 30);
        _titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
        _titleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth, 0, -titleWidth);
        [_titleBtn setTitle:titleStr forState:UIControlStateNormal];
        [_titleBtn setImage:[UIImage imageNamed:@"btn_fliter_down"] forState:UIControlStateNormal];
    }
}

-(void)fliterClicked:(id)sender{
    if (_myFliterMenu.showStatus) {
        [_myFliterMenu dismissMenu];
    }else {
        [_myFliterMenu showMenuAtView:kKeyWindow];
    }
    
}

- (void)assignmentWithlistView:(ProjectTasksView *)listView {
    listView.keyword = self.keyword;
    listView.status = self.status;
    listView.label = self.label;
    listView.userId = self.userId;
    listView.role = self.role;
    listView.project_id = self.myProject.id.stringValue;
}

- (void)resetTaskCount {
    if (self.curType != ProjectViewTypeTasks) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (_userId != nil) {
        [[Coding_NetAPIManager sharedManager] request_tasks_searchWithUserId:_userId role:TaskRoleTypeAll project_id:_myProject.id.stringValue andBlock:^(id data, NSError *error) {
            NSInteger ownerDone = [data[@"data"][@"memberDone"] integerValue];
            NSInteger ownerProcessing = [data[@"data"][@"memberProcessing"] integerValue];
            NSInteger watcherDone = [data[@"data"][@"watcherDone"] integerValue];
            NSInteger watcherProcessing = [data[@"data"][@"watcherProcessing"] integerValue];
            NSInteger creatorDone = [data[@"data"][@"creatorDone"] integerValue];
            NSInteger creatorProcessing = [data[@"data"][@"creatorProcessing"] integerValue];
             weakSelf.myFliterMenu.items = @[[NSString stringWithFormat:@"所有任务（%ld）", ownerDone + ownerProcessing],
                                             [NSString stringWithFormat:@"我关注的（%ld）", watcherDone + watcherProcessing],
                                             [NSString stringWithFormat:@"我创建的（%ld）", creatorDone + creatorProcessing]
                                             ];
             if (_role == TaskRoleTypeAll) {
                 weakSelf.screenView.tastArray = @[[NSString stringWithFormat:@"进行中的（%ld）", ownerProcessing],
                                                   [NSString stringWithFormat:@"已完成的（%ld）", ownerDone]
                                                   ];
             }
            if (_role == TaskRoleTypeWatcher) {
                weakSelf.screenView.tastArray = @[[NSString stringWithFormat:@"进行中的（%ld）", watcherProcessing],
                                                  [NSString stringWithFormat:@"已完成的（%ld）", watcherDone]
                                                  ];
            }
            if (_role == TaskRoleTypeCreator) {
                weakSelf.screenView.tastArray = @[[NSString stringWithFormat:@"进行中的（%ld）", creatorProcessing],
                                                  [NSString stringWithFormat:@"已完成的（%ld）", creatorDone]
                                                  ];
            }
         }];

    } else {
        [[Coding_NetAPIManager sharedManager] request_tasks_searchWithUserId:nil role:TaskRoleTypeAll project_id:_myProject.id.stringValue andBlock:^(id data, NSError *error) {
            NSInteger ownerDone, ownerProcessing;
            
            
            ownerDone = [data[@"data"][@"done"] integerValue];
            ownerProcessing = [data[@"data"][@"processing"] integerValue];
            
            weakSelf.myFliterMenu.items = @[[NSString stringWithFormat:@"所有任务（%ld）", ownerDone + ownerProcessing],
                                            weakSelf.myFliterMenu.items[1],
                                            weakSelf.myFliterMenu.items[2]
                                            ];
            if (_role == TaskRoleTypeAll) {
                weakSelf.screenView.tastArray = @[[NSString stringWithFormat:@"进行中的（%ld）", ownerProcessing],
                                                  [NSString stringWithFormat:@"已完成的（%ld）", ownerDone]
                                                  ];
            }
        }];
        [[Coding_NetAPIManager sharedManager] request_tasks_searchWithUserId:nil role:TaskRoleTypeWatcher project_id:_myProject.id.stringValue andBlock:^(id data, NSError *error) {
            NSInteger watcherDone = [data[@"data"][@"watcherDone"] integerValue];
            NSInteger watcherProcessing = [data[@"data"][@"watcherProcessing"] integerValue];
            NSInteger creatorDone = [data[@"data"][@"creatorDone"] integerValue];
            NSInteger creatorProcessing = [data[@"data"][@"creatorProcessing"] integerValue];
            weakSelf.myFliterMenu.items = @[weakSelf.myFliterMenu.items[0],
                                            [NSString stringWithFormat:@"我关注的（%ld）", watcherDone + watcherProcessing],
                                            [NSString stringWithFormat:@"我创建的（%ld）", creatorDone + creatorProcessing]
                                            ];
            if (_role == TaskRoleTypeWatcher) {
                weakSelf.screenView.tastArray = @[[NSString stringWithFormat:@"进行中的（%ld）", watcherProcessing],
                                                  [NSString stringWithFormat:@"已完成的（%ld）", watcherDone]
                                                  ];
            }
            if (_role == TaskRoleTypeCreator) {
                weakSelf.screenView.tastArray = @[[NSString stringWithFormat:@"进行中的（%ld）", creatorProcessing],
                                                  [NSString stringWithFormat:@"已完成的（%ld）", creatorDone]
                                                  ];
            }
        }];
    }
}

- (void)loadTasksLabels {
    if (self.curType != ProjectViewTypeTasks) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_projects_tasks_labelsWithRole:_role projectId:_myProject.id.stringValue projectName:_myProject.name memberId:_userId owner_user_name:_myProject.owner_user_name andBlock:^(id data, NSError *error) {
        if (data != nil) {
            weakSelf.screenView.labels = data;
        }
    }];
}


@end
