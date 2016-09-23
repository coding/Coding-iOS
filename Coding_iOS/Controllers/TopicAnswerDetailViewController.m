//
//  TopicAnswerDetailViewController.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/18.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TopicAnswerDetailViewController.h"
#import "TopicCommentCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "WebViewController.h"
#import "MJPhotoBrowser.h"
#import "UIMessageInputView.h"
#import "SVPullToRefresh.h"

@interface TopicAnswerDetailViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate, UIMessageInputViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
// 评论
@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@property (nonatomic, strong) ProjectTopic *toComment, *toAnswer;
@property (nonatomic, strong) UIView *commentSender;

@end

@implementation TopicAnswerDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"讨论详情";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = kColorTableBG;
        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[TopicCommentCell class] forCellReuseIdentifier:kCellIdentifier_TopicComment];
        [tableView registerClass:[TopicCommentCell class] forCellReuseIdentifier:kCellIdentifier_TopicComment_Media];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    // 评论
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypeTopic placeHolder:@"发表看法"];
    _myMsgInputView.isAlwaysShow = YES;
    _myMsgInputView.delegate = self;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, CGRectGetHeight(_myMsgInputView.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
    if (_curTopic && _curTopic.project) {
        _myMsgInputView.curProject = _curTopic.project;
        _myMsgInputView.commentOfId = _curTopic.id;
    }
    [self refresh];
}

- (ProjectTopic *)toAnswer{
    return _curAnswer;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_myMsgInputView) {
        [_myMsgInputView prepareToDismiss];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 键盘
    if (_myMsgInputView) {
        if (!_myMsgInputView.toUser) {
            _myMsgInputView.toUser = nil;
        }
        [_myMsgInputView prepareToShow];
    }
    [_myTableView reloadData];
}

- (void)refresh{
    if (_curAnswer.isLoading) {
        return;
    }
    ESWeak(self, weakSelf);
    [[Coding_NetAPIManager sharedManager] request_Comments_WithAnswer:_curAnswer inProjectId:_curTopic.project.id andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.curAnswer.child_comments = [(ProjectTopics *)data list];
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text
{
    [self sendCommentMessage:text];
}

- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom
{
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        UIEdgeInsets contentInsets= UIEdgeInsetsMake(0.0, 0.0, MAX(CGRectGetHeight(inputView.frame), heightToBottom), 0.0);;
        CGFloat msgInputY = kScreen_Height - heightToBottom - 64;
        
        self.myTableView.contentInset = contentInsets;
        self.myTableView.scrollIndicatorInsets = contentInsets;
        [self.myTableView updateInfiniteScrollingPosition];
        
        if ([_commentSender isKindOfClass:[UIView class]] && !self.myTableView.isDragging && heightToBottom > 60) {
            UIView *senderView = _commentSender;
            CGFloat senderViewBottom = [_myTableView convertPoint:CGPointZero fromView:senderView].y+ CGRectGetMaxY(senderView.bounds);
            CGFloat contentOffsetY = MAX(0, senderViewBottom- msgInputY);
            [self.myTableView setContentOffset:CGPointMake(0, contentOffsetY) animated:YES];
        }
    } completion:nil];
}

#pragma mark Comment To Topic
- (void)sendCommentMessage:(id)obj{
    __weak typeof(self) weakSelf = self;
    if (_toComment) {
        _curTopic.nextCommentStr = [NSString stringWithFormat:@"@%@ %@", _toComment.owner.name, obj];
    }else{
        _curTopic.nextCommentStr = obj;
    }
    [NSObject showHUDQueryStr:@"请稍等..."];
    [[Coding_NetAPIManager sharedManager] request_DoComment_WithProjectTpoic:_curTopic andAnswerId:_curAnswer.id andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"发表成功"];
            [weakSelf uiDoComment:data ofAnswer:weakSelf.toAnswer];
        }
    }];
}

- (void)uiDoComment:(ProjectTopic *)comment ofAnswer:(ProjectTopic *)answer{
    [self.curTopic configWithComment:comment andAnswer:answer];
    self.toComment = nil;
    self.commentSender = nil;
    self.myMsgInputView.toUser = nil;
    [self.myMsgInputView isAndResignFirstResponder];
    [self.myTableView reloadData];
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _curAnswer.child_comments.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectTopic *toComment = indexPath.row == 0? _curAnswer: _curAnswer.child_comments[indexPath.row - 1];
    TopicCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:toComment.htmlMedia.imageItems.count > 0? kCellIdentifier_TopicComment_Media: kCellIdentifier_TopicComment forIndexPath:indexPath];
    cell.toComment = toComment;
    cell.isAnswer = indexPath.row == 0;
    cell.projectId = _curTopic.project.id;
    cell.contentLabel.delegate = self;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth + (indexPath.row == 0? 40: 40) hasSectionLine:YES];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectTopic *toComment = indexPath.row == 0? _curAnswer: _curAnswer.child_comments[indexPath.row - 1];
    return [TopicCommentCell cellHeightWithObj:toComment];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ProjectTopic *toComment = indexPath.row == 0? _curAnswer: _curAnswer.child_comments[indexPath.row - 1];
    [self doCommentToTopic:toComment ofAnswer:_curAnswer sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (void)doCommentToTopic:(ProjectTopic *)toComment ofAnswer:(ProjectTopic *)answer sender:(id)sender{
    if ([self.myMsgInputView isAndResignFirstResponder]) {
        return ;
    }
    _toComment = toComment;
    _toAnswer = answer;
    _commentSender = sender;
    
    _myMsgInputView.toUser = toComment.owner;
    
    if (_toComment) {
        if ([Login isLoginUserGlobalKey:_toComment.owner.global_key]) {
            ESWeakSelf
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此评论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                ESStrongSelf
                if (index == 0) {
                    [_self deleteTopic:_self.toComment ofAnswer:answer isComment:YES];
                }
            }];
            [actionSheet showInView:self.view];
            return;
        }
    }
    [_myMsgInputView notAndBecomeFirstResponder];
}
#pragma mark Delete M

- (void)deleteTopic:(ProjectTopic *)curTopic ofAnswer:(ProjectTopic *)answer isComment:(BOOL)isC{
    if (curTopic) {
        __weak typeof(self) weakSelf = self;
        if (!isC) {//不可能事件
        }else{
            [[Coding_NetAPIManager sharedManager] request_ProjectTopicComment_Delete_WithObj:curTopic projectId:_curTopic.project.id andBlock:^(id data, NSError *error) {
                if (data) {
                    [weakSelf uiDeleteTopic:curTopic ofAnswer:answer];
                }
            }];
        }
    }
}

- (void)uiDeleteTopic:(ProjectTopic *)curTopic ofAnswer:(ProjectTopic *)answer{
    if (curTopic == answer) {
        [self.curTopic.comments.list removeObject:curTopic];
        self.curTopic.child_count = @(self.curTopic.child_count.integerValue - 1);
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [answer.child_comments removeObject:curTopic];
        answer.child_count = @(answer.child_count.integerValue - 1);
    }
    self.toComment = nil;
    self.commentSender = nil;
    self.myMsgInputView.toUser = nil;
    
    [self.myTableView reloadData];
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *clickedItem = [components objectForKey:@"value"];
    [self analyseLinkStr:clickedItem.href];
}

- (void)analyseLinkStr:(NSString *)linkStr
{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        // 跳转去网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}

@end
