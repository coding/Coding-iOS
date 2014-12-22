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

#import "EditTaskViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "TaskContentCell.h"
#import "LeftImage_LRTextCell.h"
#import "Coding_NetAPIManager.h"
#import "ProjectMemberListViewController.h"
#import "ValueListViewController.h"
#import "JDStatusBarNotification.h"
#import "ActionSheetStringPicker.h"
#import "TaskCommentCell.h"
#import "TaskCommentTopCell.h"
#import "TaskCommentBlankCell.h"

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
        [_myMsgInputView prepareToShow];
    }
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView{
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:[UIView frameWithOutNav]];
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
        tableView;
    });
    [self.view addSubview:_myTableView];
    //评论
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewTypeSimple];
    _myMsgInputView.isAlwaysShow = YES;
    _myMsgInputView.delegate = self;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myMsgInputView.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
    
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
            if (_myCopyTask.needRefreshDetail) {
                [self queryToRefreshTaskDetail];
            }else{
                _myMsgInputView.curProject = _myCopyTask.project;
                [self queryToRefreshCommentList];
            }
        }
            break;
        default:
            break;
    }
    
    if (self.myTask.handleType == TaskEditTypeAdd) {
        _myMsgInputView.hidden = YES;
    }
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"完成" color:[UIColor lightGrayColor] target:self action:@selector(doneBtnClicked)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    @weakify(self);
    [[RACSignal combineLatest:@[RACObserve(self, self.myCopyTask.content),
                               RACObserve(self, self.myCopyTask.owner),
                               RACObserve(self, self.myCopyTask.priority),
                               RACObserve(self, self.myCopyTask.status), ] reduce:^id (NSString *content, User *owner, NSNumber *priority, NSNumber *status){
                                   return nil;
                               }] subscribeNext:^(id x) {
                                   @strongify(self);
                                   BOOL enabled = ![self.myCopyTask isSameToTask:self.myTask];
                                   if (self.myCopyTask.handleType == TaskEditTypeAdd && self.myCopyTask.content.length <= 0) {
                                       enabled = NO;
                                   }
                                   self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"完成" color:(enabled? [UIColor whiteColor]: [UIColor lightGrayColor]) target:self action:@selector(doneBtnClicked)];
                                   self.navigationItem.rightBarButtonItem.enabled = enabled;
                               }];
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

        if ([_commentSender isKindOfClass:[UIView class]] && !self.myTableView.isDragging) {
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
            [weakSelf.myTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
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
                    _taskChangedBlock(_myTask, TaskEditTypeChange);
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
    return self.myTask.handleType == TaskEditTypeAdd? 2:3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (section == 0) {
        row = 1;
    }else if (section == 1){
        if (_myTask.handleType == TaskHandleTypeAdd) {
            row = 2;
        }else{
            row = 3;
        }
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
        if (_myCopyTask.handleType == TaskHandleTypeAdd) {
            cell.deleteBtnClickedBlock = nil;
        }else{
            cell.deleteBtnClickedBlock = ^(Task *toDelete){
                [weakSelf.view endEditing:YES];
                UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"删除此任务"];
                [actionSheet bk_setDestructiveButtonWithTitle:@"确认删除" handler:nil];
                [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
                [actionSheet bk_setDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                    switch (index) {
                        case 0:
                            [weakSelf deleteTask:toDelete];
                            break;
                        default:
                            break;
                    }
                }];
                [actionSheet showInView:kKeyWindow];
            };
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:20];
        return cell;
    }else if (indexPath.section == 1){
        LeftImage_LRTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_LeftImage_LRText forIndexPath:indexPath];
        [cell setObj:_myCopyTask type:indexPath.row];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:20];
        return cell;
    }else{
        if (indexPath.row == 0) {
            TaskCommentTopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskCommentTop forIndexPath:indexPath];
            cell.commentNumStrLabel.text = [NSString stringWithFormat:@"%d 条评论", _myCopyTask.comments.intValue];
            [cell addLineUp:YES andDown:NO andColor:tableView.separatorColor];
            return cell;
        }else{
            if ([self hasComment]) {
                TaskCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskComment forIndexPath:indexPath];
                TaskComment *curComment = [_myCopyTask.commentList objectAtIndex:indexPath.row-1];
                cell.curComment = curComment;
                [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:20];
                return cell;
            }else{
                TaskCommentBlankCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskCommentBlank forIndexPath:indexPath];
                cell.blankStrLabel.text = (_myCopyTask.comments.intValue <= 0)? @"尚无评论，速速抢个先手吧": @"正在加载评论...";
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
    }else{
        return 20.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    if (section == 0) {
        [headerView setHeight:30.0];
    }else{
        [headerView setHeight:20];
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ESWeakSelf;
    if (indexPath.section == 1) {
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
                _myCopyTask.priority = [NSNumber numberWithInteger:index];//更换新的任务优先级
                [self.myTableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == LeftImage_LRTextCellTypeTaskStatus){
            ValueListViewController *vc = [[ValueListViewController alloc] init];
            [vc setTitle:@"阶段" valueList:@[@"未完成", @"已完成"] defaultSelectIndex:_myCopyTask.status.intValue-1 type:ValueListTypeTaskStatus selectBlock:^(NSInteger index) {
                _myCopyTask.status = [NSNumber numberWithInteger:index+1];//更换新的任务状态
                [self.myTableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 2){
        if (indexPath.row > 0 && [self hasComment]) {
            TaskComment *curComment = [_myCopyTask.commentList objectAtIndex:indexPath.row-1];
            [self doCommentToComment:curComment sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
    }

}

- (void)doCommentToComment:(TaskComment *)toComment sender:(id)sender{
    if ([self.myMsgInputView isAndResignFirstResponder]) {
        return ;
    }
    _toComment = toComment;
    _commentSender = sender;
    
    if (_toComment) {
        _myMsgInputView.placeHolder = [NSString stringWithFormat:@"回复 %@:", _toComment.owner.name];
        if (_toComment.owner_id.intValue == [Login curLoginUser].id.intValue) {
            __weak typeof(self) weakSelf = self;
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"删除此评论"];
            [actionSheet bk_setDestructiveButtonWithTitle:@"确认删除" handler:nil];
            [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
            [actionSheet bk_setDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                switch (index) {
                    case 0:
                        [weakSelf deleteComment:weakSelf.toComment];
                        break;
                    default:
                        break;
                }
            }];
            [actionSheet showInView:kKeyWindow];
            return;
        }
    }else{
        _myMsgInputView.placeHolder = @"撰写评论";
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
