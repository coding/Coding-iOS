//
//  EditTaskViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-19.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TaskContent @"TaskContentCell"
#define kCellIdentifier_LeftImage_LRText @"LeftImage_LRTextCell"
#define kCellIdentifier_TaskComment @"TaskCommentCell"
#define kCellIdentifier_TaskCommentTop @"TaskCommentTopCell"
#define kCellIdentifier_TaskCommentBlank @"TaskCommentBlankCell"
#define kCellIdentifier_TaskDescription @"TaskDescriptionCell"

#import "EditTaskViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "TaskContentCell.h"
#import "LeftImage_LRTextCell.h"
#import "Coding_NetAPIManager.h"
#import "ProjectMemberListViewController.h"
#import "ValueListViewController.h"
#import "JDStatusBarNotification.h"
#import "TaskCommentCell.h"
#import "TaskCommentTopCell.h"
#import "TaskCommentBlankCell.h"
#import "ActionSheetDatePicker.h"
#import "TaskDescriptionViewController.h"

@interface EditTaskViewController ()
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
    switch (_myTask.handleType) {
        case TaskHandleTypeAdd:{
            self.title = @"创建任务";
            _myCopyTask = [Task taskWithTask:_myTask];
            _myCopyTask.handleType = TaskHandleTypeAdd;
        }
            break;
        case TaskHandleTypeEdit:{
            self.title = @"任务详情";
            _myCopyTask = [Task taskWithTask:_myTask];
            
            //评论
            _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewTypeSimple];
            _myMsgInputView.contentType = UIMessageInputViewContentTypeTask;
            _myMsgInputView.isAlwaysShow = YES;
            _myMsgInputView.delegate = self;
            
            if (_myCopyTask.needRefreshDetail || _myCopyTask.has_description.boolValue) {
                [self queryToRefreshTaskDetail];
            }else{
                _myMsgInputView.curProject = _myCopyTask.project;
                _myMsgInputView.commentOfId = _myCopyTask.id;
                [self queryToRefreshCommentList];
            }
        }
            break;
        default:
            break;
    }
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[TaskContentCell class] forCellReuseIdentifier:kCellIdentifier_TaskContent];
        [tableView registerClass:[LeftImage_LRTextCell class] forCellReuseIdentifier:kCellIdentifier_LeftImage_LRText];
        [tableView registerClass:[TaskCommentCell class] forCellReuseIdentifier:kCellIdentifier_TaskComment];
        [tableView registerClass:[TaskCommentBlankCell class] forCellReuseIdentifier:kCellIdentifier_TaskCommentBlank];
        [tableView registerClass:[TaskCommentTopCell class] forCellReuseIdentifier:kCellIdentifier_TaskCommentTop];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    if (_myMsgInputView) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myMsgInputView.frame), 0.0);
        self.myTableView.contentInset = contentInsets;
        self.myTableView.scrollIndicatorInsets = contentInsets;
    }
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(doneBtnClicked)] animated:YES];
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
                                   if (self.myCopyTask.handleType == TaskEditTypeAdd && self.myCopyTask.content.length <= 0) {
                                       enabled = NO;
                                   }
                                   return @(enabled);
                               }];
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
        UIEdgeInsets contentInsets= UIEdgeInsetsMake(0.0, 0.0, heightToBottom, 0.0);;
        CGFloat msgInputY = kScreen_Height - heightToBottom - 64;

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
- (void)queryToRefreshCommentList{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CommentListOfTask:_myCopyTask andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.myCopyTask.commentList = data;
            [weakSelf.myTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            
            [weakSelf.myTableView reloadData];
            [weakSelf queryToRefreshCommentList];
        }
    }];
}

#pragma mark Mine M
- (BOOL)hasComment{
    return (self.myCopyTask.commentList && self.myCopyTask.commentList.count > 0);
}

- (void)doneBtnClicked{
    if (_myCopyTask.isRequesting) {
        return;
    }
    if (_myCopyTask.handleType == TaskHandleTypeAdd) {
        if (!_myCopyTask.content || _myCopyTask.content.length <= 0) {
            return;
        }
        _myCopyTask.isRequesting = YES;
        [[Coding_NetAPIManager sharedManager] request_AddTask:_myCopyTask andBlock:^(id data, NSError *error) {
            _myCopyTask.isRequesting = NO;
            if (data) {
                if (_taskChangedBlock) {
                    _taskChangedBlock(_myTask, TaskEditTypeAdd);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }else{
        [self showStatusBarQueryStr:@"正在修改任务"];
        _myCopyTask.isRequesting = YES;
        [[Coding_NetAPIManager sharedManager] request_EditTask:_myCopyTask oldTask:_myTask andBlock:^(id data, NSError *error) {
            _myCopyTask.isRequesting = NO;
            if (data) {
                [self showStatusBarSuccessStr:@"修改任务成功"];
                _myTask.content = _myCopyTask.content;
                _myTask.owner = _myCopyTask.owner;
                _myTask.status = _myCopyTask.status;
                if (_taskChangedBlock) {
                    _taskChangedBlock(_myTask, TaskEditTypeModify);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self showStatusBarError:error];
            }
        }];
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
                _taskChangedBlock(_myTask, TaskEditTypeAdd);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark Comment To Task
- (void)sendCommentMessage:(id)obj{
    if (_toComment) {
        _myCopyTask.nextCommentStr = [NSString stringWithFormat:@"@%@ : %@", _toComment.owner.name, obj];
    }else{
        _myCopyTask.nextCommentStr = obj;
    }
    [self sendCurComment:_myCopyTask];
    {
        _toComment = nil;
        _commentSender = nil;
    }
    [self.myMsgInputView isAndResignFirstResponder];
}

- (void)sendCurComment:(Task *)commentObj{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DoCommentToTask:commentObj andBlock:^(id data, NSError *error) {
        if (data) {
            [commentObj addNewComment:data];
            [weakSelf.myTableView reloadData];
        }
    }];
}

- (void)deleteComment:(TaskComment *)comment{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteComment:comment ofTask:weakSelf.myCopyTask andBlock:^(id data, NSError *error) {
        [weakSelf.myCopyTask deleteComment:comment];
        [weakSelf.myTableView reloadData];
    }];
}
#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (self.myCopyTask.handleType == TaskEditTypeAdd)? 2: 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (section == 0) {
        row = 1;
    }else if (section == 1){
        row = (self.myCopyTask.handleType == TaskHandleTypeAdd)? 3: 4;
    }else{
        if ([self hasComment]) {
            row = self.myCopyTask.commentList.count +1;
        }else{
            row = 2;
        }
    }
    return row;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        __weak typeof(self) weakSelf = self;

        TaskContentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskContent forIndexPath:indexPath];
        cell.task = _myCopyTask;
        cell.textValueChangedBlock = ^(NSString *textStr){
            weakSelf.myCopyTask.content = textStr;
        };
        cell.textViewBecomeFirstResponderBlock = ^(){
            [weakSelf.myMsgInputView isAndResignFirstResponder];
        };
        cell.deleteBtnClickedBlock = ^(Task *toDelete){
            [weakSelf.view endEditing:YES];
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此任务" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakSelf deleteTask:toDelete];
                }
            }];
            [actionSheet showInView:kKeyWindow];
        };
        cell.descriptionBtnClickedBlock = ^(Task *toDelete){
            [weakSelf goToDescriptionVC];
        };

        cell.backgroundColor = kColorTableBG;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:20];
        return cell;
    }else if (indexPath.section == 1){
        LeftImage_LRTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_LeftImage_LRText forIndexPath:indexPath];
        [cell setObj:_myCopyTask type:indexPath.row];
        cell.backgroundColor = kColorTableBG;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:20];
        return cell;
    }else{
        if (indexPath.row == 0) {
            TaskCommentTopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskCommentTop forIndexPath:indexPath];
            cell.commentNumStrLabel.text = [NSString stringWithFormat:@"%d 条评论", _myCopyTask.comments.intValue];
            cell.backgroundColor = kColorTableBG;
            [cell addLineUp:YES andDown:NO andColor:tableView.separatorColor];
            return cell;
        }else{
            if ([self hasComment]) {
                TaskCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskComment forIndexPath:indexPath];
                TaskComment *curComment = [_myCopyTask.commentList objectAtIndex:indexPath.row-1];
                cell.curComment = curComment;
                cell.backgroundColor = kColorTableBG;
                [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:20];
                return cell;
            }else{
                TaskCommentBlankCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskCommentBlank forIndexPath:indexPath];
                cell.blankStrLabel.text = (_myCopyTask.comments.intValue <= 0)? @"尚无评论，速速抢个先手吧": @"正在加载评论...";
                cell.backgroundColor = kColorTableBG;
                [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:20];
                return cell;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = [TaskContentCell cellHeightWithObj:_myCopyTask];
    }else if (indexPath.section == 1){
        cellHeight = [LeftImage_LRTextCell cellHeight];
    }else{
        if (indexPath.row == 0) {
            cellHeight = [TaskCommentTopCell cellHeight];
        }else{
            if ([self hasComment]) {
                cellHeight = [TaskCommentCell cellHeightWithObj:[_myCopyTask.commentList objectAtIndex:indexPath.row-1]];
            }else{
                cellHeight = [TaskCommentBlankCell cellHeight];
            }
        }
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 30.0;
    }else if (section == 3){
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
    headerView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    if (section == 0) {
        [headerView setHeight:30.0];
    }else if (section == 3){
        headerView.backgroundColor = [UIColor whiteColor];
        [headerView setHeight:1.0];
    }else{
        [headerView setHeight:20];
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ESWeakSelf;
    if (indexPath.section == 0) {
        
    }else if (indexPath.section == 1){
        if (indexPath.row == LeftImage_LRTextCellTypeTaskOwner) {
            ProjectMemberListViewController *vc = [[ProjectMemberListViewController alloc] init];
            [vc setFrame:self.view.bounds project:_myCopyTask.project type:ProMemTypeTaskOwner refreshBlock:nil selectBlock:^(ProjectMember *member) {
                ESStrongSelf;
                _self.myCopyTask.owner = member.user;//更换新的执行人
                [_self.myTableView reloadData];
            } cellBtnBlock:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == LeftImage_LRTextCellTypeTaskPriority){
            ValueListViewController *vc = [[ValueListViewController alloc] init];
            [vc setTitle:@"优先级" valueList:kTaskPrioritiesDisplay defaultSelectIndex:_myCopyTask.priority.intValue type:ValueListTypeTaskPriority selectBlock:^(NSInteger index) {
                ESStrongSelf;
                _self.myCopyTask.priority = [NSNumber numberWithInteger:index];//更换新的任务优先级
                [_self.myTableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == LeftImage_LRTextCellTypeTaskDeadline){
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
                                                NSForegroundColorAttributeName: [UIColor colorWithHexString:@"0x666666"]} forState:UIControlStateNormal];
            [picker setCancelButton:barButton];
            [picker showActionSheetPicker];
        }else if (indexPath.row == LeftImage_LRTextCellTypeTaskStatus){
            ValueListViewController *vc = [[ValueListViewController alloc] init];
            [vc setTitle:@"阶段" valueList:@[@"未完成", @"已完成"] defaultSelectIndex:_myCopyTask.status.intValue-1 type:ValueListTypeTaskStatus selectBlock:^(NSInteger index) {
                ESStrongSelf;
                _self.myCopyTask.status = [NSNumber numberWithInteger:index+1];//更换新的任务状态
                [_self.myTableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else {
        if (indexPath.row > 0 && [self hasComment]) {
            TaskComment *curComment = [_myCopyTask.commentList objectAtIndex:indexPath.row-1];
            [self doCommentToComment:curComment sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
    }
}

- (void)goToDescriptionVC{
    if (!_myCopyTask.task_description) {
        _myCopyTask.task_description = [Task_Description defaultDescription];
    }
    ESWeakSelf;
    TaskDescriptionViewController *vc = [[TaskDescriptionViewController alloc] init];
    vc.markdown = _myCopyTask.task_description.markdown;
    vc.savedNewMDBlock = ^(NSString *mdStr, NSString *mdHtmlStr){
        ESStrongSelf;
        _self.myCopyTask.has_description = [NSNumber numberWithBool:(mdStr.length > 0)];
        _self.myCopyTask.task_description.markdown = mdStr;
        _self.myCopyTask.task_description.description_mine = mdHtmlStr;
        [_self.myTableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)doCommentToComment:(TaskComment *)toComment sender:(id)sender{
    if ([self.myMsgInputView isAndResignFirstResponder]) {
        return ;
    }
    _toComment = toComment;
    _commentSender = sender;
    
    _myMsgInputView.toUser = toComment.owner;
    
    if (_toComment) {
        if (_toComment.owner_id.intValue == [Login curLoginUser].id.intValue) {
            __weak typeof(self) weakSelf = self;
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此评论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakSelf deleteComment:weakSelf.toComment];
                }
            }];
            [actionSheet showInView:kKeyWindow];
            return;
        }
    }
    [_myMsgInputView notAndBecomeFirstResponder];
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.view endEditing:YES];
        [self.myMsgInputView isAndResignFirstResponder];
    }
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
