//
//  NProjectViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/3/11.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "NProjectViewController.h"
#import "ProjectInfoCell.h"
#import "ProjectItemsCell.h"
#import "ProjectDescriptionCell.h"
#import "ProjectReadMeCell.h"
#import "ProjectActivityListCell.h"
#import "ProjectViewController.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "WebViewController.h"

#import "UserInfoViewController.h"
#import "EditTaskViewController.h"
#import "TopicDetailViewController.h"
#import "FileListViewController.h"
#import "FileViewController.h"

@interface NProjectViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

@property (nonatomic, strong) ProjectActivities *myProActs;
@property (nonatomic, assign) NSInteger un_read_activities_count;

@end

@implementation NProjectViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"项目首页";
    _myProActs = [ProjectActivities proActivitiesWithPro:_myProject type:ProjectActivityTypeAll];
    _un_read_activities_count = _myProject.un_read_activities_count.intValue;
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ProjectInfoCell class] forCellReuseIdentifier:kCellIdentifier_ProjectInfoCell];
        [tableView registerClass:[ProjectItemsCell class] forCellReuseIdentifier:kCellIdentifier_ProjectItemsCell_Private];
        [tableView registerClass:[ProjectItemsCell class] forCellReuseIdentifier:kCellIdentifier_ProjectItemsCell_Public];
        [tableView registerClass:[ProjectDescriptionCell class] forCellReuseIdentifier:kCellIdentifier_ProjectDescriptionCell];
        [tableView registerClass:[ProjectReadMeCell class] forCellReuseIdentifier:kCellIdentifier_ProjectReadMeCell];
        [tableView registerClass:[ProjectActivityListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectActivityList];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });

    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    @weakify(self)
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        [self refreshActivityMore:YES];
    }];
    
    if (_myProject.is_public.boolValue) {
        self.myTableView.showsInfiniteScrolling = NO;
    }

    [self refresh];
}


- (void)refresh{
    if (_myProject.isLoadingDetail) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (!_myProject.is_public) {
        [self.view beginLoading];
    }
    [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:_myProject andBlock:^(id data, NSError *error) {
        if (data) {
            CGFloat readMeHeight = weakSelf.myProject.readMeHeight;
            weakSelf.myProject = data;
            weakSelf.myProject.readMeHeight = readMeHeight;
            if (weakSelf.myProActs.list.count <= 0) {
                weakSelf.myProActs = [ProjectActivities proActivitiesWithPro:weakSelf.myProject type:ProjectActivityTypeAll];
            }
            weakSelf.myTableView.showsInfiniteScrolling = !weakSelf.myProject.is_public.boolValue;
            
            if (weakSelf.myProject.is_public.boolValue) {
                [weakSelf refreshReadMe];
            }else{
                [weakSelf refreshActivityMore:NO];
            }
        }else{
            [weakSelf.refreshControl endRefreshing];
            [weakSelf.view endLoading];
        }
    }];
}

- (void)refreshReadMe{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ReadMeOFProject:_myProject andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.view endLoading];
        if (data) {
            weakSelf.myProject.readMeHtml = data;
        }
        [weakSelf.myTableView reloadData];
    }];
}

- (void)refreshActivityMore:(BOOL)loadMore{
    if (!_myProActs.user_id || _myProActs.isLoading) {
        return;
    }
    _myProActs.willLoadMore = loadMore;
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectActivityList_WithObj:_myProActs andBlock:^(NSArray *data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.view endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myProActs configWithProActList:data];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myProActs.canLoadMore;
        }
        [weakSelf.myTableView reloadData];
    }];
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger section = 0;
    if (_myProject.is_public) {
        section = _myProject.is_public.boolValue? 3: (1 +_myProActs.listGroups.count);
    }
    return section;
}

//footer
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_myProject.is_public.boolValue
        || section == 0) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        footerView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [footerView addLineUp:YES andDown:NO andColor:tableView.separatorColor];
        return footerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat footerHeight = 0;
    if (_myProject.is_public.boolValue) {
        footerHeight = section == 2? 0: 20;
    }else{
        footerHeight = section == 0? 20: 0;
    }
    return footerHeight;
}
//header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_myProject.is_public && !_myProject.is_public.boolValue
        && section > 0) {
        return section == 1? kScaleFrom_iPhone5_Desgin(60): kScaleFrom_iPhone5_Desgin(24);
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = nil;
    if (_myProject.is_public && !_myProject.is_public.boolValue
        && section > 0) {
        ListGroupItem *item = [_myProActs.listGroups objectAtIndex:section -1];
        UIView *dateStrView = [tableView getHeaderViewWithStr:[item.date string_yyyy_MM_dd_EEE] color:[UIColor colorWithHexString:@"0xeeeeee"] andBlock:nil];
        dateStrView.layer.masksToBounds = YES;
        dateStrView.layer.cornerRadius = 2.0;
        
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, [self tableView:tableView heightForHeaderInSection:section])];
        headerView.backgroundColor = self.view.backgroundColor;
        [dateStrView setFrame:CGRectMake(kPaddingLeftWidth,
                                         CGRectGetHeight(headerView.frame) - CGRectGetHeight(dateStrView.frame),
                                         kScreen_Width - 2* kPaddingLeftWidth,
                                         CGRectGetHeight(dateStrView.frame))];
        [headerView addSubview:dateStrView];
        if (section == 1) {
            UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kScaleFrom_iPhone5_Desgin(10), 200, 20)];
            titleL.font = [UIFont systemFontOfSize:15];
            titleL.textColor = [UIColor colorWithHexString:@"0x222222"];
            titleL.text = @"最近动态";
            [headerView addSubview:titleL];
        }
    }
    return headerView;
}

//data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_myProject.is_public.boolValue) {
        row = section == 0? 2: 1;
    }else{
        row = section == 0? 2: ((ListGroupItem *)[_myProActs.listGroups objectAtIndex:section - 1]).length;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (_myProject.is_public.boolValue) {
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
                cell.curProject = _myProject;
                cell.gitButtonClickedBlock = ^(NSInteger index){
                    [weakSelf gitButtonClicked:index];
                };
                return cell;
            }
        }else if (indexPath.section == 1){
            ProjectItemsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectItemsCell_Public forIndexPath:indexPath];
            cell.curProject = _myProject;
            cell.itemClickedBlock = ^(NSInteger index){
                [weakSelf goToIndex:index];
            };
            return cell;
        }else{
            ProjectReadMeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectReadMeCell forIndexPath:indexPath];
            cell.curProject = _myProject;
            cell.cellHeightChangedBlock = ^(){
                [weakSelf.myTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            };
            cell.loadRequestBlock = ^(NSURLRequest *curRequest){
                [weakSelf loadRequest:curRequest];
            };
            return cell;
        }
    }else{
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                ProjectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectInfoCell forIndexPath:indexPath];
                cell.curProject = _myProject;
                return cell;
            }else{
                ProjectItemsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectItemsCell_Private forIndexPath:indexPath];
                cell.curProject = _myProject;
                cell.itemClickedBlock = ^(NSInteger index){
                    [self goToIndex:index];
                };
                return cell;
            }
        }else{
            ListGroupItem *item = [_myProActs.listGroups objectAtIndex:indexPath.section - 1];
            NSUInteger row = indexPath.row +item.location;
            ProjectActivity *curProAct = [_myProActs.list objectAtIndex:row];
            ProjectActivityListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectActivityList forIndexPath:indexPath];
            BOOL haveRead, isTop, isBottom;
            
            if (_myProActs.isOfUser || ![_myProActs.type isEqualToString:@"all"]) {
                haveRead = YES;
                isTop = (row == item.location);
                isBottom = (row == item.location +item.length -1);
            }else{
                haveRead = row >= _un_read_activities_count;
                isTop = (row == item.location) || (row == _un_read_activities_count);
                isBottom = (row == item.location +item.length -1) || (row == _un_read_activities_count-1);
            }
            
            [cell configWithProAct:curProAct haveRead:haveRead isTop:isTop isBottom:isBottom];
            [cell.userIconView addTapBlock:^(id obj) {
                [weakSelf goToUserInfo:curProAct.user];
            }];
            cell.htmlItemClickedBlock = ^(HtmlMediaItem *clickedItem, ProjectActivity *proAct, BOOL isContent){
                [weakSelf goToVCWithItem:clickedItem activity:proAct isContent:isContent inProject:weakSelf.myProject];
            };
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:
             (row == item.location +item.length -1)? 0: 85 hasSectionLine:NO];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (_myProject.is_public.boolValue) {
        if (indexPath.section == 0) {
            cellHeight = indexPath.row == 0? [ProjectInfoCell cellHeight]: [ProjectDescriptionCell cellHeightWithObj:_myProject];
        }else if (indexPath.section == 1){
            cellHeight = [ProjectItemsCell cellHeightWithObj:_myProject];
        }else{
            cellHeight = [ProjectReadMeCell cellHeightWithObj:_myProject];
        }
    }else{
        if (indexPath.section == 0) {
            cellHeight = indexPath.row == 0? [ProjectInfoCell cellHeight]: [ProjectItemsCell cellHeightWithObj:_myProject];
        }else{
            ListGroupItem *item = [_myProActs.listGroups objectAtIndex:indexPath.section - 1];
            NSUInteger row = indexPath.row +item.location;
            cellHeight = [ProjectActivityListCell cellHeightWithObj:[_myProActs.list objectAtIndex:row]];
        }
    }
    return cellHeight;
}

//selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.myProject.is_public && !self.myProject.is_public.boolValue
        && indexPath.section > 0) {
        ListGroupItem *item = [_myProActs.listGroups objectAtIndex:indexPath.section -1];
        NSUInteger row = indexPath.row +item.location;
        ProjectActivity *curProAct = [_myProActs.list objectAtIndex:row];
        [self goToVCWithItem:nil activity:curProAct isContent:YES inProject:self.myProject];
    }
    
    // 如果是自己的项目才能进入设置
    if ([self.myProject.owner_id isEqual:[Login curLoginUser].id]) {
        // 项目设置
        if (indexPath.section == 0 && indexPath.row == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProjectSetting" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ProjectSettingVC"];
            [vc setValue:self.myProject forKey:@"project"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }

}

#pragma mark goTo VC
- (void)goToIndex:(NSInteger)index{
    ProjectViewController *vc = [[ProjectViewController alloc] init];
    vc.myProject = self.myProject;
    vc.curIndex = index;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)gotoPro:(Project *)project{
    NProjectViewController *vc = [[NProjectViewController alloc] init];
    vc.myProject = project;
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark loadCellRequest
- (void)loadRequest:(NSURLRequest *)curRequest{
    NSString *linkStr = curRequest.URL.absoluteString;
    NSLog(@"\n linkStr : %@", linkStr);
    [self analyseLinkStr:linkStr];
}

- (void)analyseLinkStr:(NSString *)linkStr{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        //跳转去网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}

#pragma mark Git_Btn
- (void)gitButtonClicked:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    switch (index) {
        case 0://Star
        {
            if (!_myProject.isStaring) {
                [[Coding_NetAPIManager sharedManager] request_StarProject:_myProject andBlock:^(id data, NSError *error) {
                    [weakSelf.myTableView reloadData];
                }];
            }
        }
            break;
        case 1://Watch
        {
            if (!_myProject.isWatching) {
                [[Coding_NetAPIManager sharedManager] request_WatchProject:_myProject andBlock:^(id data, NSError *error) {
                    [weakSelf.myTableView reloadData];
                }];
            }
        }
            break;
        default://Fork
        {
            [[UIActionSheet bk_actionSheetCustomWithTitle:@"fork将会将此项目复制到您的个人空间，确定要fork吗?" buttonTitles:@[@"确定"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [[Coding_NetAPIManager sharedManager] request_ForkProject:_myProject andBlock:^(id data, NSError *error) {
                        [weakSelf.myTableView reloadData];
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

#pragma mark Activity
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
