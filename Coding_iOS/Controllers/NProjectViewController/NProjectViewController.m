//
//  NProjectViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/3/11.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "NProjectViewController.h"
#import "ProjectInfoCell.h"
#import "ProjectDescriptionCell.h"
#import "NProjectItemCell.h"

#import "ProjectViewController.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"
#import "WebViewController.h"

#import "UsersViewController.h"
#import "ForkTreeViewController.h"

#import "CodeViewController.h"
#import "EaseGitButtonsView.h"
#import "UserOrProjectTweetsViewController.h"
#import "FunctionTipsManager.h"
#import "MRPRListViewController.h"
#import "WikiViewController.h"
#import "EACodeBranchListViewController.h"
#import "EACodeReleaseListViewController.h"
#import "EALocalCodeListViewController.h"
#import "TaskBoardsViewController.h"


@interface NProjectViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

@property (strong, nonatomic) EaseGitButtonsView *gitButtonsView;

@end

@implementation NProjectViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.myTableView reloadData];
    [self refreshGitButtonsView];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"项目首页";
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ProjectInfoCell class] forCellReuseIdentifier:kCellIdentifier_ProjectInfoCell];
        [tableView registerClass:[ProjectDescriptionCell class] forCellReuseIdentifier:kCellIdentifier_ProjectDescriptionCell];
        [tableView registerClass:[NProjectItemCell class] forCellReuseIdentifier:kCellIdentifier_NProjectItemCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    
    __weak typeof(self) weakSelf = self;
    _gitButtonsView = [EaseGitButtonsView new];
    _gitButtonsView.gitButtonClickedBlock = ^(NSInteger index, EaseGitButtonPosition position){
        if (position == EaseGitButtonPositionLeft) {
            [weakSelf actionWithGitBtnIndex:index];
        }else{
            [weakSelf goToUsersWithGitBtnIndex:index];
        }
    };
    [self.view addSubview:_gitButtonsView];
    [_gitButtonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(EaseGitButtonsView_Height);
    }];

    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    [self refresh];
}


- (void)refresh{
    if (_myProject.isLoadingDetail) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:_myProject andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.myProject = data;
            weakSelf.navigationItem.rightBarButtonItem = weakSelf.myProject.is_public.boolValue? nil: [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addBtn_Artboard"] style:UIBarButtonItemStylePlain target:self action:@selector(tweetsBtnClicked)];
            [self refreshGitButtonsView];
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.refreshControl endRefreshing];
    }];
}

- (void)tweetsBtnClicked{
    UserOrProjectTweetsViewController *vc = [UserOrProjectTweetsViewController new];
    vc.curTweets = [Tweets tweetsWithProject:self.myProject];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (!_myProject.is_public) {
        return 0;
    }else if (_myProject.is_public.boolValue) {
        return 4;
    }else if (_myProject.current_user_role_id.integerValue <= 75){
        return 4;
    }else{
        return 6;
    }
}

//header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat sectionH = 15;
    if (section == 0) {
        sectionH = kLine_MinHeight;
    }else if (!_myProject.is_public.boolValue && (section == 2 || section == 4)){
        sectionH = 50;
    }
    return sectionH;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    headerView.backgroundColor = kColorTableSectionBg;
    if (!_myProject.is_public.boolValue && (section == 2 || section == 4)) {
        UILabel *leftL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorDark3];
        leftL.text = section == 2? @"任务": @"代码";
        [headerView addSubview:leftL];
        [leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(20);
            make.left.offset(kPaddingLeftWidth);
        }];
        if (section == 4) {
            UILabel *rightL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorLightBlue];
            rightL.text = @"查看 README";
            __weak typeof(self) weakSelf = self;
            rightL.userInteractionEnabled = YES;
            [rightL bk_whenTapped:^{
                [weakSelf goToReadme];
            }];
            [headerView addSubview:rightL];
            [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(leftL);
                make.right.offset(-kPaddingLeftWidth);
            }];
        }
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section == ([self numberOfSectionsInTableView:_myTableView] - 1)? 44: kLine_MinHeight;
}

//data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_myProject.is_public.boolValue) {
        row = (section == 0? 2:
               section == 1? 4:
               section == 2? 2:
               1);
    }else{
        row = (section == 0? 2:
               section == 1? 1:
               section == 2? 2:
               section == 3? 2:
               section == 4? 4:
               1);
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            ProjectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectInfoCell forIndexPath:indexPath];
            cell.curProject = _myProject;
            cell.projectBlock = ^(Project *clickedPro){
                [weakSelf gotoPro:clickedPro];
            };
            return cell;
        }else{
            ProjectDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectDescriptionCell forIndexPath:indexPath];
            [cell setDescriptionStr:_myProject.description_mine];
            return cell;
        }
    }else{
        NProjectItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_NProjectItemCell forIndexPath:indexPath];
        if (indexPath.section == 1 && indexPath.row == 0) {
            [cell setImageStr:@"project_item_activity" andTitle:@"动态"];
            if (_myProject.un_read_activities_count.integerValue > 0) {
                [cell addTip:_myProject.un_read_activities_count.stringValue];
            }
        }else if (_myProject.is_public.boolValue) {
            [cell setImageStr:(indexPath.section == 1? (indexPath.row == 1? @"project_item_topic":
                                                        indexPath.row == 2? @"project_item_code":
                                                        @"project_item_member"):
                               indexPath.section == 2? (indexPath.row == 0? @"project_item_readme":
                                                        @"project_item_mr_pr"):
                               @"project_item_reading")
                     andTitle:(indexPath.section == 1? (indexPath.row == 1? @"讨论":
                                                        indexPath.row == 2? @"代码":
                                                        @"成员"):
                               indexPath.section == 2? (indexPath.row == 0? @"README":
                                                        @"Pull Request"):
                               @"本地阅读")];
        }else{
            [cell setImageStr:(indexPath.section == 2? (indexPath.row == 0? @"project_item_task":
                                                        @"project_item_taskboard"):
//                               indexPath.section == 3? (indexPath.row == 0? @"project_item_topic":
                               indexPath.section == 3? (indexPath.row == 0? @"project_item_wiki":
                                                        @"project_item_file"):
                               indexPath.section == 4? (indexPath.row == 0? @"project_item_code":
                                                        indexPath.row == 1? @"project_item_branch":
                                                        indexPath.row == 2? @"project_item_tag":
                                                        @"project_item_mr_pr"):
                               @"project_item_reading")
                     andTitle:(indexPath.section == 2? (indexPath.row == 0? @"任务列表":
                                                        @"任务看板"):
//                               indexPath.section == 3? (indexPath.row == 0? @"讨论":
                               indexPath.section == 3? (indexPath.row == 0? @"Wiki":
                                                        @"文件"):
                               indexPath.section == 4? (indexPath.row == 0? @"代码浏览":
                                                        indexPath.row == 1? @"分支管理":
                                                        indexPath.row == 2? @"发布管理":
                                                        @"合并请求"):
                               @"本地阅读")];
        }
//        FunctionTipsManager *ftm = [FunctionTipsManager shareManager];
//        NSString *tipStr = [self p_TipStrForIndexPath:indexPath];
//        if (tipStr && [ftm needToTip:tipStr]) {
//            [cell addTipIcon];
//        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:52];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    current_user_role_id = 75 是受限成员，不可访问代码
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = indexPath.row == 0? [ProjectInfoCell cellHeight]: [ProjectDescriptionCell cellHeightWithObj:_myProject];
    }else{
        cellHeight = [NProjectItemCell cellHeight];
    }
    return cellHeight;
}

//selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProjectSetting" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Entrance"];
            [vc setValue:self.myProject forKey:@"project"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (_myProject.is_public.boolValue){
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                [self goToProjectType:ProjectViewTypeActivities];
            }else if (indexPath.row == 1){
                [self goToProjectType:ProjectViewTypeTopics];
            }else if (indexPath.row == 2){
                [self goToProjectType:ProjectViewTypeCodes];
            }else{
                [self goToProjectType:ProjectViewTypeMembers];
            }
        }else if (indexPath.section == 2){
            if (indexPath.row == 0) {
                [self goToReadme];
            }else{
                [self goTo_MR_PR];
            }
        }else{
            [self goToLocalRepo];
        }
    }else{
        if (indexPath.section == 1) {
            [self goToProjectType:ProjectViewTypeActivities];
        }else if (indexPath.section == 2){
            if (indexPath.row == 0) {
                [self goToProjectType:ProjectViewTypeTasks];
            }else{
                [self goToTaskBoards];
            }
        }else if (indexPath.section == 3){
            if (indexPath.row == 0) {
//                [self goToProjectType:ProjectViewTypeTopics];
                [self goToWiki];
            }else{
                [self goToProjectType:ProjectViewTypeFiles];
            }
        }else if (indexPath.section == 4){
            if (indexPath.row == 0) {
                [self goToProjectType:ProjectViewTypeCodes];
            }else if (indexPath.row == 1){
                [self goToBranchList];
            }else if (indexPath.row == 2){
                [self goToReleaseList];
            }else{
                [self goTo_MR_PR];
            }
        }else{
            [self goToLocalRepo];
        }
    }
//    FunctionTipsManager *ftm = [FunctionTipsManager shareManager];
//    NSString *tipStr = [self p_TipStrForIndexPath:indexPath];
//    if (tipStr && [ftm needToTip:tipStr]) {
//        [ftm markTiped:tipStr];
//        NProjectItemCell *cell = (NProjectItemCell *)[tableView cellForRowAtIndexPath:indexPath];
//        [cell removeTip];
//    }
}

- (NSString *)p_TipStrForIndexPath:(NSIndexPath *)indexPath{
    NSString *tipStr = nil;
    return tipStr;
}

#pragma mark goTo VC

- (void)goToTaskBoards{
    TaskBoardsViewController *vc = [TaskBoardsViewController new];
    vc.myProject = self.myProject;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToProjectType:(ProjectViewType)type{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Project_UpdateVisit_WithObj:_myProject andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.myProject.un_read_activities_count = [NSNumber numberWithInteger:0];
        }
    }];
    ProjectViewController *vc = [[ProjectViewController alloc] init];
    vc.myProject = self.myProject;
    vc.curType = type;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToWiki{
    WikiViewController *vc = [WikiViewController new];
    vc.myProject = self.myProject;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToBranchList{
    EACodeBranchListViewController *vc = [EACodeBranchListViewController new];
    vc.myProject = self.myProject;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToReleaseList{
    EACodeReleaseListViewController *vc = [EACodeReleaseListViewController new];
    vc.myProject = self.myProject;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoPro:(Project *)project{
    NProjectViewController *vc = [[NProjectViewController alloc] init];
    vc.myProject = project;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToReadme{
    CodeViewController *vc = [CodeViewController codeVCWithProject:_myProject andCodeFile:nil];
    vc.isReadMe = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goTo_MR_PR{
    MRPRListViewController *vc = [[MRPRListViewController alloc] init];
    vc.curProject = self.myProject;
    vc.isMR = !_myProject.is_public.boolValue;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToLocalRepo{
    if (_myProject.isLocalRepoExist) {
        EALocalCodeListViewController *vc = [EALocalCodeListViewController new];
        vc.curPro = _myProject;
        vc.curRepo = _myProject.localRepo;
        vc.curURL = _myProject.localURL;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        __weak typeof(self) weakSelf = self;
        [[UIAlertController ea_actionSheetCustomWithTitle:@"本地阅读需要先 clone 代码，过程可能比较耗时，且不可中断，是否确认要 clone 代码？" buttonTitles:@[@"Clone"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
            if (index == 0) {
                [weakSelf cloneRepo];
            }
        }] showInView:self.view];
    }
}

- (void)cloneRepo{
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = [NSObject showHUDQueryStr:@"正在 clone..."];
    [_myProject gitCloneBlock:^(GTRepository *repo, NSError *error) {
        [NSObject hideHUDQuery];
        if (error) {
            [NSObject showError:error];
        }else{
            [weakSelf goToLocalRepo];
        }
    } progressBlock:^(const git_transfer_progress *progress, BOOL *stop) {
        hud.detailsLabelText = [NSString stringWithFormat:@"%d / %d", progress->received_objects, progress->total_objects];
    }];
}

#pragma mark Git_Btn
- (void)actionWithGitBtnIndex:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    switch (index) {
        case 0://Star
        {
            if (!_myProject.isStaring) {
                [[Coding_NetAPIManager sharedManager] request_StarProject:_myProject andBlock:^(id data, NSError *error) {
                    [weakSelf refreshGitButtonsView];
                }];
            }
        }
            break;
        case 1://Watch
        {
            if (!_myProject.isWatching) {
                [[Coding_NetAPIManager sharedManager] request_WatchProject:_myProject andBlock:^(id data, NSError *error) {
                    [weakSelf refreshGitButtonsView];
                }];
            }
        }
            break;
        default://Fork
        {
            [[UIAlertController ea_actionSheetCustomWithTitle:@"fork将会将此项目复制到您的个人空间，确定要fork吗?" buttonTitles:@[@"确定"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
                if (index == 0) {
                    [[Coding_NetAPIManager sharedManager] request_ForkProject:_myProject andBlock:^(id data, NSError *error) {
                        [weakSelf refreshGitButtonsView];
                        if (data) {
                            NProjectViewController *vc = [[NProjectViewController alloc] init];
                            vc.myProject = data;
                            [weakSelf.navigationController pushViewController:vc animated:YES];
                        }
                    }];
                }
            }] showInView:self.view];
        }
            break;
    }
}

- (void)goToUsersWithGitBtnIndex:(NSInteger)index{
    if (index == 2) {
        //Fork
        ForkTreeViewController *vc = [ForkTreeViewController new];
        vc.project_owner_user_name = _myProject.owner_user_name;
        vc.project_name = _myProject.name;
        [self.navigationController pushViewController:vc animated:YES];
        NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/forks", _myProject.owner_user_name, _myProject.name];
        NSLog(@"path: %@", path);
    }else{
        UsersViewController *vc = [[UsersViewController alloc] init];
        vc.curUsers = [Users usersWithProjectOwner:_myProject.owner_user_name projectName:_myProject.name Type:UsersTypeProjectStar + index];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)refreshGitButtonsView{
    self.gitButtonsView.curProject = self.myProject;
    CGFloat gitButtonsViewHeight = 0;
    if (self.myProject.is_public.boolValue) {
        gitButtonsViewHeight = CGRectGetHeight(self.gitButtonsView.frame) - 1;
    }
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, gitButtonsViewHeight, 0);
    self.myTableView.contentInset = insets;
    self.myTableView.scrollIndicatorInsets = insets;
}

@end
