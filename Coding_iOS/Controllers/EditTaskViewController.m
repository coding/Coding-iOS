//
//  EditTaskViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-19.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "EditTaskViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "TaskContentCell.h"
#import "LeftImage_LRTextCell.h"
#import "Coding_NetAPIManager.h"
#import "ProjectMemberListViewController.h"
#import "ValueListViewController.h"
#import "JDStatusBarNotification.h"
#import "TaskCommentCell.h"
#import "TaskDescriptionCell.h"
#import "TaskActivityCell.h"
#import "ActionSheetDatePicker.h"
#import "TaskDescriptionViewController.h"
#import "WebViewController.h"
#import "ProjectToChooseListViewController.h"
#import "EditLabelViewController.h"
#import "TaskResourceReferenceViewController.h"
#import "NProjectViewController.h"
#import "FunctionTipsManager.h"
#import "MartFunctionTipView.h"

@interface EditTaskViewController ()<TTTAttributedLabelDelegate>
@property (strong, nonatomic) UITableView *myTableView;

//评论
@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@property (nonatomic, strong) TaskComment *toComment;
@property (nonatomic, strong) UIView *commentSender;
@end

@implementation EditTaskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myCopyTask = [Task taskWithTask:_myTask];
    if (_myCopyTask.handleType == TaskHandleTypeEdit) {
        //评论
        _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypeTask];
        _myMsgInputView.isAlwaysShow = YES;
        _myMsgInputView.delegate = self;
    }
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[TaskContentCell class] forCellReuseIdentifier:kCellIdentifier_TaskContent];
        [tableView registerClass:[LeftImage_LRTextCell class] forCellReuseIdentifier:kCellIdentifier_LeftImage_LRText];
        [tableView registerClass:[TaskCommentCell class] forCellReuseIdentifier:kCellIdentifier_TaskComment];
        [tableView registerClass:[TaskCommentCell class] forCellReuseIdentifier:kCellIdentifier_TaskComment_Media];
        [tableView registerClass:[TaskActivityCell class] forCellReuseIdentifier:kCellIdentifier_TaskActivityCell];
        [tableView registerClass:[TaskDescriptionCell class] forCellReuseIdentifier:kCellIdentifier_TaskDescriptionCell];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    if (_myMsgInputView) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myMsgInputView.frame), 0.0);
        self.myTableView.contentInset = contentInsets;
        self.myTableView.scrollIndicatorInsets = contentInsets;
    }
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:(_myCopyTask.handleType == TaskHandleTypeEdit? @"保存": @"完成") target:self action:@selector(doneBtnClicked)] animated:YES];
    @weakify(self);
    RAC(self.navigationItem.rightBarButtonItem, enabled) =
    [RACSignal combineLatest:@[RACObserve(self, myCopyTask.content),
                               RACObserve(self, myCopyTask.owner),
                               RACObserve(self, myCopyTask.priority),
                               RACObserve(self, myCopyTask.status),
                               RACObserve(self, myCopyTask.deadline),
                               RACObserve(self, myCopyTask.task_description.markdown)] reduce:^id (NSString *content, User *owner, NSNumber *priority, NSNumber *status, NSString *deadline){
                                   @strongify(self);
                                   BOOL enabled = ![self.myCopyTask isSameToTask:self.myTask];
                                   if (self.myCopyTask.handleType > TaskHandleTypeEdit) {
                                       enabled = ([self.myCopyTask.content trimWhitespace].length > 0 &&
                                                  self.myCopyTask.project != nil &&
                                                  self.myCopyTask.owner != nil);
                                   }
                                   return @(enabled);
                               }];
}

- (void)configTitle{
    if (_myCopyTask.handleType > TaskHandleTypeEdit) {
        self.title = @"创建任务";
    }else{
        UILabel *titleL = [UILabel labelWithFont:[UIFont systemFontOfSize:kNavTitleFontSize] textColor:kColorNavTitle];
        titleL.text = _myTask.project.name;
        titleL.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        [titleL bk_whenTapped:^{
            NProjectViewController *vc = [[NProjectViewController alloc] init];
            vc.myProject = weakSelf.myTask.project;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
        [titleL sizeToFit];
        self.navigationItem.titleView = titleL;
        if ([[FunctionTipsManager shareManager] needToTip:kFunctionTipStr_TaskTitleViewTap]) {
            [MartFunctionTipView showText:@"点击标题可跳转到项目首页哦" direction:AMPopTipDirectionDown  bubbleOffset:0 inView:self.view fromFrame:CGRectMake(kScreen_Width/ 2, 0, 0, 0) dismissHandler:^{
                [[FunctionTipsManager shareManager] markTiped:kFunctionTipStr_TaskTitleViewTap];
            }];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_myMsgInputView) {
        [_myMsgInputView prepareToDismiss];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    键盘
    if (_myMsgInputView) {
        if (!_myMsgInputView.toUser) {
            _myMsgInputView.toUser = nil;
        }
        [_myMsgInputView prepareToShow];
    }
    [self.myTableView reloadData];
    
    if (_myCopyTask.handleType == TaskHandleTypeEdit && !_myCopyTask.activityList) {
        [self queryToRefreshTaskDetail];
    }else{
        [self configTitle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text{
    [self sendCommentMessage:text];
}

- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom{
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        UIEdgeInsets contentInsets= UIEdgeInsetsMake(0.0, 0.0, MAX(CGRectGetHeight(inputView.frame), heightToBottom), 0.0);;
        CGFloat msgInputY = kScreen_Height - heightToBottom - (44 + kSafeArea_Top);

        self.myTableView.contentInset = contentInsets;
        self.myTableView.scrollIndicatorInsets = contentInsets;

        if ([_commentSender isKindOfClass:[UIView class]] && !self.myTableView.isDragging && heightToBottom > 60) {
            UIView *senderView = _commentSender;
            CGFloat senderViewBottom = [_myTableView convertPoint:CGPointZero fromView:senderView].y+ CGRectGetMaxY(senderView.bounds);
            CGFloat contentOffsetY = MAX(0, senderViewBottom- msgInputY);
            [self.myTableView setContentOffset:CGPointMake(0, contentOffsetY) animated:YES];
        }
    } completion:nil];
}

#pragma mark refresh

- (void)queryToRefreshActivityList{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ActivityListOfTask:_myCopyTask andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.myCopyTask.activityList = data;
            [weakSelf.myTableView reloadData];
        };
    }];
}


- (void)queryToRefreshTaskDetail{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_TaskDetail:_myCopyTask andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.myTask = data;
            weakSelf.myCopyTask = [Task taskWithTask:weakSelf.myTask];
            weakSelf.myMsgInputView.curProject = weakSelf.myCopyTask.project;
            weakSelf.myMsgInputView.commentOfId = weakSelf.myCopyTask.id;
            weakSelf.myMsgInputView.toUser = nil;
            [weakSelf configTitle];
            
            [weakSelf.myTableView reloadData];
            [weakSelf queryToRefreshResourceReference];
            [weakSelf queryToRefreshActivityList];
        }else if ([[[error.userInfo objectForKey:@"msg"] allKeys] containsObject:@"task_not_exist"]){
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }
    }];
}

- (void)queryToRefreshResourceReference{
    if (_myCopyTask.handleType == TaskHandleTypeEdit) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_TaskResourceReference:_myTask andBlock:^(id data, NSError *error) {
            if (data) {
                _myTask.resourceReference = data;
                [weakSelf.myTableView reloadData];
            }
        }];
    }
}
#pragma mark Mine M
- (void)doneBtnClicked{
    if (_myCopyTask.isRequesting) {
        return;
    }
    if (_myCopyTask.handleType > TaskHandleTypeEdit) {
        if (!_myCopyTask.content || _myCopyTask.content.length <= 0) {
            return;
        }
        _myCopyTask.isRequesting = YES;
        [[Coding_NetAPIManager sharedManager] request_AddTask:_myCopyTask andBlock:^(id data, NSError *error) {
            _myCopyTask.isRequesting = NO;
            if (data) {
                if (_taskChangedBlock) {
                    _taskChangedBlock();
                }
                [self handleDone];
            }
        }];
    }else{
        [NSObject showStatusBarQueryStr:@"正在修改任务"];
        _myCopyTask.isRequesting = YES;
        [[Coding_NetAPIManager sharedManager] request_EditTask:_myCopyTask oldTask:_myTask andBlock:^(id data, NSError *error) {
            _myCopyTask.isRequesting = NO;
            if (data) {
                [NSObject showStatusBarSuccessStr:@"修改任务成功"];
                _myTask.content = _myCopyTask.content;
                _myTask.owner = _myCopyTask.owner;
                _myTask.status = _myCopyTask.status;
                if (_taskChangedBlock) {
                    _taskChangedBlock();
                }
                [self handleDone];
            }else{
                [NSObject showStatusBarError:error];
            }
        }];
    }
}

- (void)handleDone{
    if (self.doneBlock) {
        self.doneBlock(self);
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)deleteTask:(Task *)toDelete{
    if (toDelete.isRequesting) {
        return;
    }else{
        toDelete.isRequesting = YES;
    }
    [[Coding_NetAPIManager sharedManager] request_DeleteTask:toDelete andBlock:^(id data, NSError *error) {
        toDelete.isRequesting = NO;
        if (data) {
            if (_taskChangedBlock) {
                _taskChangedBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark Comment To Task
- (void)sendCommentMessage:(id)obj{
    if (_toComment) {
        _myCopyTask.nextCommentStr = [NSString stringWithFormat:@"@%@ %@", _toComment.owner.name, obj];
    }else{
        _myCopyTask.nextCommentStr = obj;
    }
    [self sendCurComment:_myCopyTask];
    {
        _toComment = nil;
        _commentSender = nil;
    }
    self.myMsgInputView.toUser = nil;
    [self.myMsgInputView isAndResignFirstResponder];
}

- (void)sendCurComment:(Task *)commentObj{
    [NSObject showHUDQueryStr:@"正在发表评论..."];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DoCommentToTask:commentObj andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"评论成功"];
            [weakSelf queryToRefreshActivityList];
            [weakSelf queryToRefreshResourceReference];
            [weakSelf.myTableView reloadData];
        }
    }];
}

- (void)deleteComment:(TaskComment *)comment{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteComment:comment ofTask:weakSelf.myCopyTask andBlock:^(id data, NSError *error) {
        [weakSelf queryToRefreshActivityList];
        [weakSelf.myTableView reloadData];
    }];
}
#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (self.myCopyTask.handleType > TaskHandleTypeEdit)? 2: self.myTask.resourceReference.itemList.count > 0? 4: 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (section == 0) {
        row = 2;
    }else if (section == 1){
        TaskHandleType handleType = self.myCopyTask.handleType;
        row = handleType == TaskHandleTypeEdit? 5: handleType == TaskHandleTypeAddWithProject? 4: 5;
    }else if (section == 2 && _myTask.resourceReference.itemList.count > 0){
        row = 1;
    }else{
        row = self.myCopyTask.activityList.count;
    }
    return row;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        __weak typeof(self) weakSelf = self;
        if (indexPath.row == 0) {
            TaskContentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskContent forIndexPath:indexPath];
            cell.task = _myCopyTask;
            cell.textValueChangedBlock = ^(NSString *textStr){
                weakSelf.myCopyTask.content = textStr;
            };
            cell.textViewBecomeFirstResponderBlock = ^(){
                [weakSelf.myMsgInputView isAndResignFirstResponder];
                [weakSelf.myTableView setContentOffset:CGPointZero animated:YES];
            };
            cell.deleteBtnClickedBlock = ^(Task *toDelete){
                [weakSelf.view endEditing:YES];
                UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此任务" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                    if (index == 0) {
                        [weakSelf deleteTask:toDelete];
                    }
                }];
                [actionSheet showInView:weakSelf.view];
            };
            cell.descriptionBtnClickedBlock = ^(Task *task){
                if (weakSelf.myCopyTask.has_description.boolValue && !weakSelf.myCopyTask.task_description) {
                    return ;
                }
                [weakSelf goToDescriptionVC];
            };
            cell.addTagBlock = ^(){
                [weakSelf goToTagsVC];
            };
            cell.tagsChangedBlock = ^(){
                weakSelf.myTask.labels = [weakSelf.myCopyTask.labels mutableCopy];
                [weakSelf.myTableView reloadData];
            };
            
            cell.backgroundColor = kColorTableBG;
//            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:20];
            return cell;
        }else{
            TaskDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskDescriptionCell forIndexPath:indexPath];
            NSString *titleStr;
            if (_myCopyTask.handleType > TaskHandleTypeEdit) {
                titleStr = @"添加描述";
            }else{
                titleStr = _myCopyTask.has_description.boolValue? @"查看描述": @"补充描述";
            }
            [cell setTitleStr:titleStr andSpecail:[titleStr isEqualToString:@"查看描述"]];
            cell.buttonClickedBlock = ^(){
                if (weakSelf.myCopyTask.has_description.boolValue && !weakSelf.myCopyTask.task_description) {
                    //描述内容 还没有加载成功
                    return ;
                }
                [weakSelf goToDescriptionVC];
            };
            cell.backgroundColor = kColorTableBG;
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:20];
            return cell;
        }
    }else if (indexPath.section == 1){
        LeftImage_LRTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_LeftImage_LRText forIndexPath:indexPath];
        LeftImage_LRTextCellType cellType = _myCopyTask.handleType == TaskHandleTypeAddWithoutProject? indexPath.row : indexPath.row +1;
        [cell setObj:_myCopyTask type:cellType];
        cell.backgroundColor = kColorTableBG;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
        return cell;
    }else if (indexPath.section == 2 && _myTask.resourceReference.itemList.count > 0){
        LeftImage_LRTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_LeftImage_LRText forIndexPath:indexPath];
        [cell setObj:_myTask type:LeftImage_LRTextCellTypeTaskResourceReference];
        cell.backgroundColor = kColorTableBG;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
        return cell;
    }else{
        ProjectActivity *curActivity = [self.myCopyTask.activityList objectAtIndex:indexPath.row];
        if ([curActivity.target_type isEqualToString:@"TaskComment"]) {
            TaskComment *curComment = curActivity.taskComment;
            curComment.created_at = curActivity.created_at;
            TaskCommentCell *cell;
            if (curComment.htmlMedia.imageItems.count > 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskComment_Media forIndexPath:indexPath];
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskComment forIndexPath:indexPath];
            }
            cell.curComment = curComment;
            cell.contentLabel.delegate = self;
            [cell configTop:(indexPath.row == 0) andBottom:(indexPath.row == _myCopyTask.activityList.count - 1)];
            cell.backgroundColor = kColorTableBG;
            return cell;
        }else{
            TaskActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskActivityCell forIndexPath:indexPath];
            cell.curActivity = curActivity;
            [cell configTop:(indexPath.row == 0) andBottom:(indexPath.row == _myCopyTask.activityList.count - 1)];
            cell.backgroundColor = kColorTableBG;
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cellHeight = [TaskContentCell cellHeightWithObj:_myCopyTask];
        }else{
            cellHeight = [TaskDescriptionCell cellHeight];
        }
    }else if (indexPath.section == 1){
        cellHeight = [LeftImage_LRTextCell cellHeight];
    }else if (indexPath.section == 2 && _myTask.resourceReference.itemList.count > 0){
        cellHeight = [LeftImage_LRTextCell cellHeight];
    }else if (self.myCopyTask.activityList.count > indexPath.row){
        ProjectActivity *curActivity = [self.myCopyTask.activityList objectAtIndex:indexPath.row];
        if ([curActivity.target_type isEqualToString:@"TaskComment"]) {
            TaskComment *curComment = curActivity.taskComment;
            cellHeight = [TaskCommentCell cellHeightWithObj:curComment];
        }else{
            cellHeight = [TaskActivityCell cellHeightWithObj:curActivity];
        }
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.5;
    }else{
        return 20.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
    headerView.backgroundColor = kColorTableSectionBg;
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ESWeakSelf;
    if (indexPath.section == 0) {
    }else if (indexPath.section == 1){
        LeftImage_LRTextCellType cellType = _myCopyTask.handleType == TaskHandleTypeAddWithoutProject? indexPath.row : indexPath.row +1;
        if (cellType == LeftImage_LRTextCellTypeTaskProject) {
            ProjectToChooseListViewController *vc = [[ProjectToChooseListViewController alloc] init];
            vc.projectChoosedBlock = ^(ProjectToChooseListViewController *blockChooseVC, Project *project){
                ESStrongSelf;
                _self.myCopyTask.project = project;
                _self.myCopyTask.owner = nil;//更换新的执行人
                [_self.myCopyTask.labels removeAllObjects];
                [_self.myTableView reloadData];
                [blockChooseVC.navigationController popViewControllerAnimated:YES];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }else if (cellType == LeftImage_LRTextCellTypeTaskOwner) {
            if (_myCopyTask.project == nil) {
                [NSObject showHudTipStr:@"需要选定所属项目先~"];
                return;
            }
            ProjectMemberListViewController *vc = [[ProjectMemberListViewController alloc] init];
            [vc setFrame:self.view.bounds project:_myCopyTask.project type:ProMemTypeTaskOwner refreshBlock:nil selectBlock:^(ProjectMember *member) {
                ESStrongSelf;
                _self.myCopyTask.owner = member.user;//更换新的执行人
                [_self.myTableView reloadData];
            } cellBtnBlock:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (cellType == LeftImage_LRTextCellTypeTaskPriority){
            ValueListViewController *vc = [[ValueListViewController alloc] init];
            [vc setTitle:@"优先级" valueList:kTaskPrioritiesDisplay defaultSelectIndex:_myCopyTask.priority.intValue type:ValueListTypeTaskPriority selectBlock:^(NSInteger index) {
                ESStrongSelf;
                _self.myCopyTask.priority = [NSNumber numberWithInteger:index];//更换新的任务优先级
                [_self.myTableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (cellType == LeftImage_LRTextCellTypeTaskDeadline){
            NSDate *curDate = _myCopyTask.deadline_date? _myCopyTask.deadline_date : [NSDate date];
            ESStrongSelf;
            ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:nil datePickerMode:UIDatePickerModeDate selectedDate:curDate doneBlock:^(ActionSheetDatePicker *picker, NSDate *selectedDate, id origin) {
                _self.myCopyTask.deadline = [selectedDate string_yyyy_MM_dd];
                [_self.myTableView reloadData];
            } cancelBlock:^(ActionSheetDatePicker *picker) {
                if (picker.cancelButtonClicked) {
                    _self.myCopyTask.deadline = nil;
                    [_self.myTableView reloadData];
                }
            } origin:self.view];
            
            UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"移除" style:UIBarButtonItemStylePlain target:nil action:nil];
            [barButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17],
                                                NSForegroundColorAttributeName: kColor666} forState:UIControlStateNormal];
            [picker setCancelButton:barButton];
            [picker showActionSheetPicker];
        }else if (cellType == LeftImage_LRTextCellTypeTaskStatus){
            ValueListViewController *vc = [[ValueListViewController alloc] init];
            [vc setTitle:@"阶段" valueList:@[@"未完成", @"已完成"] defaultSelectIndex:_myCopyTask.status.intValue-1 type:ValueListTypeTaskStatus selectBlock:^(NSInteger index) {
                ESStrongSelf;
                _self.myCopyTask.status = [NSNumber numberWithInteger:index+1];//更换新的任务状态
                [_self.myTableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (cellType == LeftImage_LRTextCellTypeTaskWatchers){
            if (_myCopyTask.project == nil) {
                [NSObject showHudTipStr:@"需要选定所属项目先~"];
                return;
            }
            ProjectMemberListViewController *vc = [[ProjectMemberListViewController alloc] init];
            [vc setFrame:self.view.bounds project:_myCopyTask.project type:ProMemTypeTaskWatchers refreshBlock:nil selectBlock:nil cellBtnBlock:^(ProjectMember *member) {
                ESStrongSelf;
                [_self watchersChanged:member];
            }];
            vc.curTask = _myCopyTask;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 2 && _myTask.resourceReference.itemList.count > 0){
        TaskResourceReferenceViewController *vc = [TaskResourceReferenceViewController new];
        vc.resourceReference = _myTask.resourceReference;
        vc.resourceReferencePath = [self.myTask backend_project_path];
        vc.number = self.myTask.number;
        vc.resourceReferenceFromType = @1;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        ProjectActivity *curActivity = [self.myCopyTask.activityList objectAtIndex:indexPath.row];
        if ([curActivity.target_type isEqualToString:@"TaskComment"]) {
            TaskComment *curComment = curActivity.taskComment;
            [self doCommentToComment:curComment sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
    }
}

#pragma mark - 

- (void)goToDescriptionVC{
    if (!_myCopyTask.task_description) {
        _myCopyTask.task_description = [Task_Description defaultDescription];
    }
    ESWeakSelf;
    TaskDescriptionViewController *vc = [[TaskDescriptionViewController alloc] init];
    vc.curTask = _myCopyTask;
    
    vc.savedNewTDBlock = ^(Task_Description *taskD){
        ESStrongSelf;
        _self.myTask.has_description = _self.myCopyTask.has_description = [NSNumber numberWithBool:taskD.markdown.length > 0];
        _self.myTask.task_description = _self.myCopyTask.task_description = taskD;
        if (_self.taskChangedBlock) {
            _self.taskChangedBlock();
        }
        [_self.myTableView reloadData];
        [_self queryToRefreshResourceReference];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToTagsVC{
    if (!_myCopyTask.project) {
        [NSObject showHudTipStr:@"需要选定所属项目先~"];
        return;
    }
    EditLabelViewController *vc = [[EditLabelViewController alloc] init];
    vc.curProject = self.myCopyTask.project;
    vc.orignalTags = self.myCopyTask.labels;
    @weakify(self);
    vc.tagsSelectedBlock = ^(EditLabelViewController *vc, NSMutableArray *selectedTags){
        @strongify(self);
        [self tagsHasChanged:selectedTags fromVC:vc];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tagsHasChanged:(NSMutableArray *)selectedTags fromVC:(EditLabelViewController *)vc{
    if ([ProjectTag tags:self.myCopyTask.labels isEqualTo:selectedTags] || self.myCopyTask.handleType > TaskHandleTypeEdit) {
        self.myTask.labels = [selectedTags mutableCopy];
        self.myCopyTask.labels = [selectedTags mutableCopy];
        [self.myTableView reloadData];
    }else{
        @weakify(self);
        [[Coding_NetAPIManager sharedManager] request_EditTask:_myCopyTask withTags:selectedTags andBlock:^(id data, NSError *error) {
            @strongify(self);
            if (data) {
                self.myCopyTask.labels = [selectedTags mutableCopy];
                self.myTask.labels = [selectedTags mutableCopy];
                [self.myTableView reloadData];
                if (self.taskChangedBlock) {
                    self.taskChangedBlock();
                }
            }
        }];

    }
}

- (void)doCommentToComment:(TaskComment *)toComment sender:(id)sender{
    if ([self.myMsgInputView isAndResignFirstResponder]) {
        return ;
    }
    _toComment = toComment;
    _commentSender = sender;
    
    _myMsgInputView.toUser = toComment.owner;
    
    if (_toComment) {
        if ([Login isLoginUserGlobalKey:_toComment.owner.global_key]) {
            __weak typeof(self) weakSelf = self;
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此评论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakSelf deleteComment:weakSelf.toComment];
                }
            }];
            [actionSheet showInView:self.view];
            return;
        }
    }
    [_myMsgInputView notAndBecomeFirstResponder];
}

- (void)watchersChanged:(ProjectMember *)member{
    _myTask.watchers = _myCopyTask.watchers.mutableCopy;
    [_myTableView reloadData];
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.view endEditing:YES];
        [self.myMsgInputView isAndResignFirstResponder];
    }
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *clickedItem = [components objectForKey:@"value"];
    [self analyseLinkStr:clickedItem.href];
}

- (void)analyseLinkStr:(NSString *)linkStr{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        //跳转去网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
