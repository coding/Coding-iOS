//
//  MRDetailViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/10/23.
//  Copyright © 2015年 Coding. All rights reserved.
//



#define kMRPRDetailViewController_BottomViewHeight 56.0
#import "MRDetailViewController.h"
#import "PRDetailViewController.h"
#import "ReviewerListController.h"
#import "Coding_NetAPIManager.h"
#import "FunctionTipsManager.h"
#import "ODRefreshControl.h"
#import "TaskResourceReferenceViewController.h"
#import "FileChangeDetailViewController.h"

#import "MRPRTopCell.h"
#import "MRPRDetailCell.h"
#import "MRPRDisclosureCell.h"
#import "MRPRCommentCell.h"
#import "AddCommentCell.h"
#import "MRReviewerCell.h"
#import "MRReviewerListCell.h"
#import "DynamicCommentCell.h"

#import "WebViewController.h"
#import "MJPhotoBrowser.h"

#import "MRPRCommitsViewController.h"
#import "MRPRFilesViewController.h"
#import "AddMDCommentViewController.h"
#import "MRPRAcceptViewController.h"
#import "MActivityInfo.h"
#import "DynamicActivityCell.h"
#import "UIView+PressMenu.h"
#import "MRPRPreInfo.h"
#import "AddReviewerViewController.h"

typedef NS_ENUM(NSInteger, MRPRAction) {
    MRPRActionAccept = 1000,
    MRPRActionRefuse,
    MRPRActionAuthorization,
    MRPRActionCancelAuthorization,
    MRPRActionCancel
};

@interface MRDetailViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (strong, nonatomic) MRPRBaseInfo *curMRPRInfo;
@property (strong, nonatomic) MRPRPreInfo *curPreMRPRInfo;
@property (strong, nonatomic) ReviewersInfo *curReviewersInfo;
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) NSString *referencePath;
@property (strong, nonatomic) NSString *activityPath;
@property (strong, nonatomic) NSString *diffPath;
@property (strong, nonatomic) ResourceReference *resourceReference;
@property (strong, nonatomic) NSMutableArray *activityList;
@property (strong, nonatomic) NSMutableArray *activityCList;
@property (nonatomic, strong) NSMutableArray *projectUsers;
@property (strong, nonatomic) NSString *reviewGoodPath;
@property (strong, nonatomic) NSNumber *isLike;
@property (assign, nonatomic) BOOL loadedActivty;
@end

@implementation MRDetailViewController

+ (MRDetailViewController *)vcWithPath:(NSString *)path{
    NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
    if (pathComponents.count != 8) {
        return nil;
    }
    MRDetailViewController *vc = [MRDetailViewController new];
    vc.curMRPR = [MRPR new];
    vc.curMRPR.path = path;
    vc.curMRPR.iid = [NSNumber numberWithInteger:[(NSString *)pathComponents.lastObject integerValue]];
    return vc;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.loadedActivty = false;
    self.activityList = [[NSMutableArray alloc] init];
    self.title = [NSString stringWithFormat:@"%@ #%@", _curMRPR.des_project_name, _curMRPR.iid.stringValue];
    self.referencePath = [NSString stringWithFormat:@"/api/user/%@/project/%@/resource_reference/%@", _curMRPR.des_owner_name, _curMRPR.des_project_name,self.curMRPR.iid];
    self.activityPath = [NSString stringWithFormat:@"/api/user/%@/project/%@/git/merge/%@/activities", _curMRPR.des_owner_name, _curMRPR.des_project_name,self.curMRPR.iid];
    self.diffPath  = [NSString stringWithFormat:@"/api/user/%@/project/%@/git/merge/%@/commitDiffContent",_curMRPR.des_owner_name, _curMRPR.des_project_name,self.curMRPR.iid];
    self.reviewGoodPath = [NSString stringWithFormat:@"/api/user/%@/project/%@/git/merge/%@/review_good",_curMRPR.des_owner_name, _curMRPR.des_project_name,self.curMRPR.iid];
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[MRPRTopCell class] forCellReuseIdentifier:kCellIdentifier_MRPRTopCell];
        [tableView registerClass:[MRPRDetailCell class] forCellReuseIdentifier:kCellIdentifier_MRPRDetailCell];
        [tableView registerClass:[MRPRDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_MRPRDisclosureCell];
        [tableView registerClass:[MRPRCommentCell class] forCellReuseIdentifier:kCellIdentifier_MRPRCommentCell];
        [tableView registerClass:[MRPRCommentCell class] forCellReuseIdentifier:kCellIdentifier_MRPRCommentCell_Media];
        [tableView registerClass:[AddCommentCell class] forCellReuseIdentifier:kCellIdentifier_AddCommentCell];
        [tableView registerClass:[MRReviewerCell class] forCellReuseIdentifier:kCellIdentifier_MRReviewerCell];
        [tableView registerClass:[MRReviewerListCell class] forCellReuseIdentifier:kCellIdentifier_MRReviewerListCell];
        [tableView registerClass:[DynamicCommentCell class] forCellReuseIdentifier:kCellIdentifier_DynamicCommentCell];
        [tableView registerClass:[DynamicCommentCell class] forCellReuseIdentifier:kCellIdentifier_DynamicCommentCell_Media];
        [tableView registerClass:[DynamicActivityCell class] forCellReuseIdentifier:kCellIdentifier_DynamicActivityCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)configBottomView{
    BOOL canCancel = [self.curPreMRPRInfo.mrpr.author.global_key isEqualToString:[Login curLoginUser].global_key];
    BOOL canAction = self.curPreMRPRInfo.can_edit.boolValue ||(canCancel && self.curPreMRPRInfo.mrpr.granted.boolValue);//有权限 || （作者身份 && 被授权）
    BOOL canAuthorization  = self.curPreMRPRInfo.can_edit.boolValue &&!canCancel &&!self.curPreMRPRInfo.author_can_edit.boolValue && !self.curPreMRPRInfo.mrpr.granted.boolValue;
    BOOL canCancelAuthorization = self.curPreMRPRInfo.can_edit.boolValue &&!canCancel &&!self.curPreMRPRInfo.author_can_edit.boolValue && self.curPreMRPRInfo.mrpr.granted.boolValue;
    BOOL hasBottomView = self.curMRPRInfo.mrpr.status <= MRPRStatusCannotMerge && (canAction || canCancel);
    if(self.curMRPRInfo == nil || self.curPreMRPRInfo == nil) {
        hasBottomView = NO ;
    }
    if (!hasBottomView) {
        [_bottomView removeFromSuperview];
    }else if (!_bottomView){
        if (hasBottomView) {
            _bottomView = [UIView new];
            _bottomView.backgroundColor = kColorTableBG;
            [_bottomView addLineUp:YES andDown:NO];
            [self.view addSubview:_bottomView];
            [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self.view);
                make.height.mas_equalTo(kMRPRDetailViewController_BottomViewHeight);
            }];
            NSArray *buttonArray;
            if (canAction && canCancel) {//三个按钮
                buttonArray = @[ [self buttonWithType:MRPRActionCancel],
//                                [self buttonWithType:MRPRActionRefuse],
                                [self buttonWithType:MRPRActionAccept]];
            } else if (canAction && !canCancel){//两个按钮
                if(canAuthorization) {
                    buttonArray = @[[self buttonWithType:MRPRActionRefuse],
                                    [self buttonWithType:MRPRActionAuthorization],
                                    [self buttonWithType:MRPRActionAccept]];
                }
                if (canCancelAuthorization) {
                    buttonArray = @[[self buttonWithType:MRPRActionRefuse],
                                    [self buttonWithType:MRPRActionCancelAuthorization],
                                    [self buttonWithType:MRPRActionAccept]];
                }
                if (!canAuthorization && !canCancelAuthorization) {
                    buttonArray = @[[self buttonWithType:MRPRActionRefuse],
                                    [self buttonWithType:MRPRActionAccept]];
                }
                
            } else if (!canAction && canCancel){//一个按钮
                buttonArray = @[[self buttonWithType:MRPRActionCancel]];
            } else{//无按钮
                buttonArray = nil;
            }
            if (buttonArray.count > 0) {
                CGFloat buttonHeight = 36;
                CGFloat padding = 15;
                CGFloat buttonWidth = ((kScreen_Width - 2*kPaddingLeftWidth) - padding* (buttonArray.count -1))/buttonArray.count;
                CGFloat buttonY = (kMRPRDetailViewController_BottomViewHeight - buttonHeight)/2;
                [buttonArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
                    obj.frame = CGRectMake(kPaddingLeftWidth + idx* (buttonWidth + padding), buttonY, buttonWidth, buttonHeight);
                    [_bottomView addSubview:obj];
                }];
            }
        }
    }
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, hasBottomView? kMRPRDetailViewController_BottomViewHeight: 0, 0);
    _myTableView.contentInset = insets;
    _myTableView.scrollIndicatorInsets = insets;
}

- (void)updateActivityList{
    if (!_curMRPRInfo || !_activityCList) {
        return;
    }
    NSMutableArray *activityList = [NSMutableArray new];
    for (NSArray *list in _curMRPRInfo.discussions) {
        ProjectLineNote *note = list.firstObject;
        if (note.path.length > 0) {
            note.action = @"mergeChanges";
        }
        [activityList addObject:note];
    }
    [activityList addObjectsFromArray:_activityCList];
    [activityList sortUsingComparator:^NSComparisonResult(ProjectLineNote *obj1, ProjectLineNote *obj2) {
        return [obj1.created_at compare:obj2.created_at];
    }];
    self.activityList = activityList;
}


- (void)updateProjectStatus {
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_MRPRPreInfo_WithObj:_curMRPR andBlock:^(MRPRPreInfo *data, NSError *error) {
        if (data) {
            weakSelf.curPreMRPRInfo = data;
            [weakSelf.myTableView reloadData];
            [weakSelf configBottomView];
        }
    }];
}

- (BOOL) shouldShowReviews {
    if(self.curReviewersInfo.reviewers.count + self.curReviewersInfo.volunteer_reviewers.count > 0) return YES;
    return NO;
}
- (void)refresh{
    if (_curMRPR.isLoading) {
        return;
    }
    if (!_curMRPRInfo) {
        [_bottomView removeFromSuperview];
        [self.view beginLoading];
    }
    [self updateProjectStatus];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_MRPRBaseInfo_WithObj:_curMRPR andBlock:^(MRPRBaseInfo *data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            if (weakSelf.curMRPRInfo.contentHeight > 1) {
                [(MRPRBaseInfo *)data setContentHeight:weakSelf.curMRPRInfo.contentHeight];
            }
            weakSelf.curMRPRInfo = data;
            [weakSelf updateActivityList];
            [weakSelf configBottomView];
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeMRForbidden hasData:data != nil hasError:(error != nil && error.code != 1400) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
    //MR 动态
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:self.activityPath withParams:@{@"iid": _curMRPR.iid} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            weakSelf.activityCList = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectLineNote"];
            [weakSelf updateActivityList];
            [weakSelf.myTableView reloadData];
        }
    }];
    //项目成员
    [[Coding_NetAPIManager sharedManager] request_ProjectMembers_WithObj:self.curProject andBlock:^(id data, NSError *error) {
        if (data) {
            NSMutableArray* projectUsers = data;
            weakSelf.projectUsers = projectUsers;
        }
    }];
    //MR 评审者
    [[Coding_NetAPIManager sharedManager] request_MRReviewerInfo_WithObj:_curMRPR andBlock:^(ReviewersInfo *data, NSError *error) {
        if (data) {
            weakSelf.curReviewersInfo = data;
        }
    }];
    //关联资源
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:self.referencePath withParams:@{@"iid": _curMRPR.iid} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            if (weakSelf.resourceReference == nil) {
                weakSelf.resourceReference = [NSObject objectOfClass:@"ResourceReference" fromJSON:data[@"data"]];
            } else {
                weakSelf.resourceReference = [NSObject objectOfClass:@"ResourceReference" fromJSON:data[@"data"]];
                [weakSelf.myTableView reloadData];
            }
            
        }
    }];
    //项目信息
    if (!_curProject) {
        _curProject = [Project new];
        _curProject.owner_user_name = _curMRPR.des_owner_name;
        _curProject.name = _curMRPR.des_project_name;
    }
    if (![_curProject.id isKindOfClass:[NSNumber class]]) {
        [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:_curProject andBlock:^(id data, NSError *error) {
            if (data) {
                weakSelf.curProject = data;
            }
        }];
    }
}

#pragma mark Action_MRPR

- (UIButton *)buttonWithType:(MRPRAction)actionType{
    UIButton *curButton = [UIButton new];
    curButton.layer.cornerRadius = 2.0;
    curButton.tag = actionType;
    [curButton addTarget:self action:@selector(actionMRPR:) forControlEvents:UIControlEventTouchUpInside];
    [curButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    NSString *title, *colorStr;
    if (actionType == MRPRActionAccept) {
        title = @"合并";
        colorStr = @"0x425063";
        if (_curMRPRInfo.mrpr.status == MRPRStatusCannotMerge) {
            curButton.alpha = 0.5;
        }
    } else if (actionType == MRPRActionRefuse){
        title = @"拒绝";
        colorStr = @"0xF56061";
    } else if (actionType == MRPRActionCancel){
        title = @"取消";
        colorStr = @"0xD8DDE4";
    } else if(actionType == MRPRActionAuthorization) {
        title = @"授权";
        colorStr = @"0x4F95E8";
    } else if(actionType == MRPRActionCancelAuthorization) {
        title = @"取消授权";
        colorStr = @"0x4F95E8";
    }
    [curButton setTitleColor:[UIColor colorWithHexString:(actionType == MRPRActionCancel? @"0x323A45": @"0xFFFFFF")] forState:UIControlStateNormal];
    [curButton setTitle:title forState:UIControlStateNormal];
    [curButton setBackgroundColor:[UIColor colorWithHexString:colorStr]];
    return curButton;
}

- (void)actionMRPR:(UIButton *)sender{
    __weak typeof(self) weakSelf = self;
    NSString *tipStr;
    if (sender.tag == MRPRActionAccept) {//合并
        if (_curMRPRInfo.mrpr.status == MRPRStatusCannotMerge) {//不能合并
            tipStr = @"Coding 不能帮你在线自动合并这个合并请求。";
            kTipAlert(@"%@", tipStr);
        } else {
            MRPRAcceptViewController *vc = [MRPRAcceptViewController new];
            vc.curProject = _curProject;
            vc.curMRPRInfo = _curMRPRInfo;
            vc.completeBlock = ^(id data){
                weakSelf.curMRPRInfo = nil;
                [weakSelf.myTableView reloadData];
                [weakSelf refresh];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if (sender.tag == MRPRActionRefuse){//拒绝
        tipStr = [_curMRPRInfo.mrpr isMR]? @"确定要拒绝这个 Merge Request 么？": @"确定要拒绝这个 Pull Request 么？";
        [[UIActionSheet bk_actionSheetCustomWithTitle:tipStr buttonTitles:@[@"确定"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf refuseMRPR];
            }
        }] showInView:self.view];
    } else if (sender.tag == MRPRActionCancel){//取消
        tipStr = [_curMRPRInfo.mrpr isMR]? @"确定要取消这个 Merge Request 么？": @"确定要取消这个 Pull Request 么？";
        [[UIActionSheet bk_actionSheetCustomWithTitle:tipStr buttonTitles:@[@"确定"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf cancelMRPR];
            }
        }] showInView:self.view];
    } else if(sender.tag == MRPRActionAuthorization) {
        tipStr = [_curMRPRInfo.mrpr isMR]? @"确定要授权这个 Merge Request 么？": @"确定要授权这个 Pull Request 么？";
        [[UIActionSheet bk_actionSheetCustomWithTitle:tipStr buttonTitles:@[@"确定"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf authorizationMRPR];
            }
        }] showInView:self.view];
    } else if(sender.tag == MRPRActionCancelAuthorization) {
        tipStr = [_curMRPRInfo.mrpr isMR]? @"确定要取消授权这个 Merge Request 么？": @"确定要取消授权这个 Pull Request 么？";
        [[UIActionSheet bk_actionSheetCustomWithTitle:tipStr buttonTitles:@[@"确定"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf cancelAuthorizationMRPR];
            }
        }] showInView:self.view];
    }
}

- (void)refuseMRPR{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_MRPRRefuse:_curMRPRInfo.mrpr andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curMRPRInfo = nil;
            [weakSelf.myTableView reloadData];
            [weakSelf refresh];
        }
    }];
}

- (void)cancelMRPR{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_MRPRCancel:_curMRPRInfo.mrpr andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)authorizationMRPR{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_MRPRAuthorization:_curMRPRInfo.mrpr andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curPreMRPRInfo.mrpr.granted = @1;
//            weakSelf.bottomView = nil;
            [weakSelf refresh];
            [weakSelf.myTableView reloadData];
            [weakSelf configBottomView];
        }
    }];
}

- (void)cancelAuthorizationMRPR{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_MRPRCancelAuthorization:_curMRPRInfo.mrpr andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curPreMRPRInfo.mrpr.granted = @0;
//            weakSelf.bottomView = nil;
            [weakSelf refresh];
            [weakSelf.myTableView reloadData];
            [weakSelf configBottomView];
        }
    }];
}

#pragma mark TableM Footer Header
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = kColorTableSectionBg;
    return view;
}

#pragma mark TableM
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return !self.curMRPRInfo? 0: self.activityList.count > 0? 5: 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (section == 0) {
        row = 2;
    } else if(section == 1) {
        if(self.curMRPR.isMR) {
            row = 3;
        } else {
            row = 2;
        }
    } else if(section == 2) {
        if([self shouldShowReviews]) {
            row = 2;
        } else {
            row = 1;
        }
    } else if (self.activityList.count > 0 && section == 3){
        row = self.activityList.count;
    }else{
        row = 1;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {//Content
        if (indexPath.row == 0) {
            MRPRTopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRPRTopCell forIndexPath:indexPath];
            cell.curMRPRInfo = _curMRPRInfo;
            return cell;
        } else {
            MRPRDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRPRDetailCell forIndexPath:indexPath];
            cell.curMRPRInfo = _curMRPRInfo;
            cell.cellHeightChangedBlock = ^(){
                [weakSelf.myTableView reloadData];
            };
            cell.loadRequestBlock = ^(NSURLRequest *curRequest){
                [weakSelf loadRequest:curRequest];
            };
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
            return cell;
        }
    } else if (indexPath.section == 1){//Disclosure
        MRPRDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRPRDisclosureCell forIndexPath:indexPath];
        if (indexPath.row == 0) {
            [cell setImageStr:@"mrpr_icon_commit" andTitle:@"提交记录"];
        }else if(indexPath.row == 1){
            [cell setImageStr:@"mrpr_icon_fileChange" andTitle:@"文件改动"];
        } else {
            [cell setImageStr:@"PR_TaskResource" andTitle:@"关联资源"];
            if(self.resourceReference.itemList.count > 0) {
                [cell setrightText:[NSString stringWithFormat:@"%lu个",(unsigned long)self.resourceReference.itemList.count]];
            } else {
                [cell setNorightText];
            }
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }  else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            MRReviewerCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRReviewerCell forIndexPath:indexPath];
            if([self CurrentUserIsOwer]) {
                [cell setImageStr:@"PRReviewer" isowner:[self CurrentUserIsOwer] hasLikeMr:@0];
            } else {
                Reviewer* tmpReviewer = [self checkUserisReviewer];
                if(tmpReviewer == nil){
                    self.isLike = @1;
                } else {
                    if([tmpReviewer.value isEqual:@0]) {
                        self.isLike = @1;
                    } else {
                        self.isLike = @0;
                    }
                }
                [cell setImageStr:@"PRReviewer" isowner:NO hasLikeMr:self.isLike];
                
            }
            if (self.curMRPRInfo.mrpr.status == MRPRStatusAccepted || self.curMRPRInfo.mrpr.status == MRPRStatusRefused) {
                [cell cantReviewer];
            }
            cell.rightSideClickedBlock = ^(){
                [weakSelf jiaYi];
            };
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
            return cell;
        }else {
            MRReviewerListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRReviewerListCell forIndexPath:indexPath];
            NSMutableArray *tmpReviewers = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.curReviewersInfo.reviewers.count; i ++) {
                [tmpReviewers addObject:self.curReviewersInfo.reviewers[i]];
            }
            for (int i = 0; i < self.curReviewersInfo.volunteer_reviewers.count; i ++) {
                [tmpReviewers addObject:self.curReviewersInfo.volunteer_reviewers[i]];
            }
            [cell initCellWithReviewers:tmpReviewers];
            cell.lastItemClickedBlock = ^(){
                [weakSelf goToReviewerList];
            };
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
            return cell;
        }
    }else if (self.activityList.count > 0 && indexPath.section == 3){//Comment
        ProjectLineNote *curCommentItem = self.activityList[indexPath.row];
        if(curCommentItem.action == nil) {
            DynamicCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:curCommentItem.htmlMedia.imageItems.count> 0? kCellIdentifier_DynamicCommentCell_Media: kCellIdentifier_DynamicCommentCell forIndexPath:indexPath];
            cell.curComment = curCommentItem;
            cell.contentLabel.delegate = self;
            [cell configTop:(indexPath.row == 0) andBottom:(indexPath.row == self.activityList.count  - 1)];
            cell.backgroundColor = kColorTableBG;
            return cell;
        } else {
            
            DynamicActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_DynamicActivityCell forIndexPath:indexPath];
            cell.curActivity = curCommentItem;
            [cell configTop:(indexPath.row == 0) andBottom:(indexPath.row == self.activityList.count  - 1)];
            cell.backgroundColor = kColorTableBG;
            return cell;
        }
    }else{//Add Comment
        AddCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AddCommentCell forIndexPath:indexPath];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }
}

- (void)jiaYi{
    if (self.curMRPRInfo.mrpr.status == MRPRStatusAccepted || self.curMRPRInfo.mrpr.status == MRPRStatusRefused) {
        return;
    }
    if([self CurrentUserIsOwer]) {
        NSArray  *apparray= [[NSBundle mainBundle]loadNibNamed:@"AddReviewerViewController" owner:nil options:nil];
        AddReviewerViewController *appview=[apparray firstObject];
        appview.currentProject = self.curProject;
        appview.curMRPR = self.curMRPR;
        [self.navigationController pushViewController:appview animated:YES];
    } else {
        __weak typeof(self) weakSelf = self;
        if ([self.isLike isEqual:@0]) {
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:self.reviewGoodPath withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
                weakSelf.isLike = @1;
                [weakSelf refresh];
            }];
        } else {
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:self.reviewGoodPath withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
                weakSelf.isLike = @0;
                [weakSelf refresh];
            }];
        }
    }
}
- (void)goToReviewerList{
    NSArray  *apparray= [[NSBundle mainBundle]loadNibNamed:@"ReviewerListController" owner:nil options:nil];
    ReviewerListController *appview=[apparray firstObject];
    appview.currentProject = self.curProject;
    appview.curMRPR = self.curMRPR;
    appview.isPublisher = [self currentUserCanAddMember];
    [self.navigationController pushViewController:appview animated:YES];
}

- (BOOL)CurrentUserIsOwer{
    User *currentUser = [Login curLoginUser];
    User *MROwer = self.curMRPR.author;
    if([currentUser.id isEqual:MROwer.id]){
        return true;
    }
    return false;
}

- (bool)currentUserCanAddMember {
    User *currentUser = [Login curLoginUser];
    for(int i = 0; i < self.projectUsers.count; i ++) {
        ProjectMember* member = self.projectUsers[i];
        if(member.user.id == currentUser.id && [member.type isEqual:@75]) {
            return NO;
        }
    }
    if (self.curMRPRInfo.mrpr.status == MRPRStatusAccepted || self.curMRPRInfo.mrpr.status == MRPRStatusRefused) {
        return NO;
    }
    return YES;
}

- (Reviewer*)checkUserisReviewer {
    User *currentUser = [Login curLoginUser];
    for(int i = 0; i < self.curReviewersInfo.reviewers.count; i ++) {
        Reviewer *reviewer = (Reviewer *)self.curReviewersInfo.reviewers[i];
        if([currentUser.id isEqual:reviewer.reviewer.id])
            return reviewer;
    }
    
    for(int i = 0; i < self.curReviewersInfo.volunteer_reviewers.count; i ++) {
        Reviewer *reviewer = (Reviewer *)self.curReviewersInfo.volunteer_reviewers[i];
        if([currentUser.id isEqual:reviewer.reviewer.id])
            return reviewer;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {//Content
        if (indexPath.row == 0) {
            return [MRPRTopCell cellHeightWithObj:_curMRPRInfo];
        }else{
            return [MRPRDetailCell cellHeightWithObj:_curMRPRInfo];
        }
    } else if (indexPath.section == 1){//Disclosure
        return [MRPRDisclosureCell cellHeight];
    } else if (indexPath.section == 2){//Disclosure
        if (indexPath.row == 0) {
            return [MRPRDisclosureCell cellHeight];
        } else {
            return [MRReviewerListCell cellHeight];
        }
    } else if (self.activityList.count > 0 && indexPath.section == 3){//Comment
        ProjectLineNote *curCommentItem = self.activityList[indexPath.row];
        if(curCommentItem.action == nil) {
            return [DynamicCommentCell cellHeightWithObj:curCommentItem];
        } else {
            return [DynamicActivityCell cellHeightWithObj:curCommentItem contentHeight:0];
        }
    } else {//Add Comment
        return [AddCommentCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {//Content
    }else if (indexPath.section == 1){//Disclosure
        if (indexPath.row == 0) {
            MRPRCommitsViewController *vc = [MRPRCommitsViewController new];
            vc.curMRPR = _curMRPR;
            vc.curProject = _curProject;
            [self.navigationController pushViewController:vc animated:YES];
        } else if(indexPath.row == 1){
            MRPRFilesViewController *vc = [MRPRFilesViewController new];
            vc.curMRPR = _curMRPR;
            vc.curMRPRInfo = _curMRPRInfo;
            vc.curProject = _curProject;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            TaskResourceReferenceViewController *vc = [TaskResourceReferenceViewController new];
            vc.resourceReference = self.resourceReference;
            vc.resourceReferencePath = self.referencePath;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if (indexPath.section == 2){//Disclosure
    } else if (self.activityList.count > 0 && indexPath.section == 3){//Comment
        ProjectLineNote *curCommentItem = self.activityList[indexPath.row];
        if ([curCommentItem.action isEqual:@"mergeChanges"]) {
            FileChangeDetailViewController *vc = [FileChangeDetailViewController new];
            vc.linkUrlStr = [NSString stringWithFormat:@"%@?path=%@", self.diffPath, curCommentItem.path];
            vc.curProject = _curProject;
            vc.commitId = curCommentItem.commitId;
            vc.filePath = curCommentItem.path;
            vc.noteable_id = _curMRPRInfo.mrpr.id.stringValue;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        if (![curCommentItem.noteable_type isEqual:@"MergeRequestBean"]) {
            return;
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell.contentView isMenuVCVisible]) {
            [cell.contentView removePressMenu];
            return;
        }
        NSArray *menuTitles;
        if ([curCommentItem.author.global_key isEqualToString:[Login curLoginUser].global_key]) {
            menuTitles = @[@"拷贝文字", @"删除"];
        } else {
            menuTitles = @[@"拷贝文字", @"回复"];
        }
        __weak typeof(self) weakSelf = self;
        [cell.contentView showMenuTitles:menuTitles menuClickedBlock:^(NSInteger index, NSString *title) {
            if ([title hasPrefix:@"拷贝"]) {
                [[UIPasteboard generalPasteboard] setString:curCommentItem.content];
            } else if ([title isEqualToString:@"删除"]){
                [weakSelf deleteComment:curCommentItem];
            } else if ([title isEqualToString:@"回复"]){
                [weakSelf goToAddCommentVCToUser:curCommentItem.author.name];
            }
        }];
    }else{//Add Comment
        [self goToAddCommentVCToUser:nil];
    }
}

#pragma mark Comment
- (void)goToAddCommentVCToUser:(NSString *)userName{
    DebugLog(@"%@", userName);
    AddMDCommentViewController *vc = [AddMDCommentViewController new];
    vc.curProject = _curProject;
    vc.requestPath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/line_notes", _curMRPR.des_owner_name, _curMRPR.des_project_name];
    vc.requestParams = [@{
                          @"noteable_type" : [self.curMRPRInfo.mrpr isMR]? @"MergeRequestBean" : @"PullRequestBean",
                          @"noteable_id" : _curMRPRInfo.mrpr.id,
                          } mutableCopy];
    vc.contentStr = userName.length > 0? [NSString stringWithFormat:@"@%@ ", userName]: nil;
    @weakify(self);
    vc.completeBlock = ^(id data){
        @strongify(self);
        if (data && [data isKindOfClass:[ProjectLineNote class]]) {
            [self.curMRPRInfo.discussions addObject:@[data]];
            [self.myTableView reloadData];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteComment:(ProjectLineNote *)lineNote{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteLineNote:lineNote.id inProject:_curMRPRInfo.mrpr.des_project_name ofUser:_curMRPRInfo.mrpr.des_owner_name andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.activityList removeObject:lineNote];
            [weakSelf.myTableView reloadData];
        }
    }];
}


#pragma mark loadCellRequest
- (void)loadRequest:(NSURLRequest *)curRequest
{
    NSString *linkStr = curRequest.URL.absoluteString;
    [self analyseLinkStr:linkStr];
}

- (void)analyseLinkStr:(NSString *)linkStr
{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        // 可能是图片链接
        HtmlMedia *htmlMedia = self.curMRPRInfo.htmlMedia;
        if (htmlMedia.imageItems.count > 0) {
            for (HtmlMediaItem *item in htmlMedia.imageItems) {
                if ((item.src.length > 0 && [item.src isEqualToString:linkStr])
                    || (item.href.length > 0 && [item.href isEqualToString:linkStr])) {
                    [MJPhotoBrowser showHtmlMediaItems:htmlMedia.imageItems originalItem:item];
                    return;
                }
            }
        }
        // 跳转去网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *clickedItem = [components objectForKey:@"value"];
    [self analyseLinkStr:clickedItem.href];
}


@end
