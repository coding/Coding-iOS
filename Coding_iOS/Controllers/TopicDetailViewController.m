//
//  TopicDetailViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TopicDetailViewController.h"
#import "TopicContentCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "RegexKitLite.h"
#import "TopicDetailViewController.h"
#import "ProjectViewController.h"
#import "UserInfoViewController.h"
#import "TweetDetailViewController.h"
#import "MJPhotoBrowser.h"
#import "SVPullToRefresh.h"
#import "EditTaskViewController.h"
#import "WebViewController.h"
#import "EditTopicViewController.h"
#import "EditLabelViewController.h"
#import "ProjectMemberListViewController.h"
#import "TopicAnswerCell.h"
#import "TopicAnswerDetailViewController.h"

@interface TopicDetailViewController ()<TTTAttributedLabelDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

// 评论
@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@property (nonatomic, strong) ProjectTopic *toComment, *toAnswer;
@property (nonatomic, strong) UIView *commentSender;

// 链接
@property (strong, nonatomic) NSString *clickedAutoLinkStr;
@property (strong, nonatomic) TopicDetailHeaderView *headerV;
@end

@implementation TopicDetailViewController

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
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[TopicContentCell class] forCellReuseIdentifier:kCellIdentifier_TopicContent];
        [tableView registerClass:[TopicAnswerCell class] forCellReuseIdentifier:kCellIdentifier_TopicAnswerCell];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refreshTopic) forControlEvents:UIControlEventValueChanged];
    
    // 评论
    __weak typeof(self) weakSelf = self;
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypeTopic placeHolder:@"发表看法"];
    _myMsgInputView.isAlwaysShow = YES;
    _myMsgInputView.delegate = self;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, CGRectGetHeight(_myMsgInputView.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
    
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
    if (_curTopic && _curTopic.project) {
        _myMsgInputView.curProject = _curTopic.project;
        _myMsgInputView.commentOfId = _curTopic.id;
    }
    
    [self refreshTopic];
}

- (void)setCurTopic:(ProjectTopic *)curTopic
{
    _curTopic = curTopic;
    self.title = curTopic.project.name ? curTopic.project.name : @"讨论详情";
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

#pragma mark - click
- (void)addtitleBtnClick
{
    EditLabelViewController *vc = [[EditLabelViewController alloc] init];
    vc.curProject = self.curTopic.project;
    vc.orignalTags = self.curTopic.mdLabels;
    @weakify(self);
    vc.tagsSelectedBlock = ^(EditLabelViewController *vc, NSMutableArray *selectedTags){
        @strongify(self);
        [self tagsHasChanged:selectedTags fromVC:vc];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tagsHasChanged:(NSMutableArray *)selectedTags fromVC:(EditLabelViewController *)vc{
    self.curTopic.mdLabels = [selectedTags mutableCopy];
    if (![ProjectTag tags:self.curTopic.labels isEqualTo:self.curTopic.mdLabels]) {
        @weakify(self);
        [[Coding_NetAPIManager sharedManager] request_ModifyProjectTpoicLabel:self.curTopic andBlock:^(id data, NSError *error) {
            @strongify(self);
            if (data) {
                self.curTopic.labels = [self.curTopic.mdLabels mutableCopy];
                [self.myTableView reloadData];
            }
        }];
    }
}

#pragma mark nav
- (void)configNavBtn
{
    [self.navigationItem setRightBarButtonItem:[self.curTopic canEdit] ? [UIBarButtonItem itemWithBtnTitle:@"编辑" target:self action:@selector(editBtnClicked)]:nil animated:YES];
}

- (void)editBtnClicked
{
    EditTopicViewController *vc = [[EditTopicViewController alloc] init];
    vc.curProTopic = self.curTopic;
    vc.type = TopicEditTypeModify;
    
    __weak typeof(self) weakSelf = self;
    vc.topicChangedBlock = ^(ProjectTopic *topic, TopicEditType type){
        [weakSelf refreshTopic];
    };
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark Refresh M
- (void)refreshComments{
    if (_curTopic.isLoading) {
        return;
    }
    _curTopic.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshTopic
{
    if (_curTopic.isTopicLoading) {
        return;
    }
    if (!_curTopic.comments) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectTopic_WithObj:_curTopic andBlock:^(id data, NSError *error) {
        if (data) {
            if (weakSelf.curTopic.contentHeight > 1) {
                ((ProjectTopic *)data).contentHeight = weakSelf.curTopic.contentHeight;
            }
            weakSelf.curTopic = data;
            weakSelf.myMsgInputView.curProject = weakSelf.curTopic.project;
            weakSelf.myMsgInputView.commentOfId = weakSelf.curTopic.id;
            weakSelf.myMsgInputView.toUser = nil;
            [weakSelf configNavBtn];
            [weakSelf refreshComments];
        } else {
            [weakSelf.view endLoading];
            [weakSelf.refreshControl endRefreshing];
        }
    }];
}

- (void)refreshMore
{
    if (_curTopic.isLoading || !_curTopic.canLoadMore) {
        return;
    }
    _curTopic.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest
{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Comments_WithProjectTpoic:self.curTopic andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.curTopic configWithComments:data];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.curTopic.canLoadMore;
        }
        [weakSelf.myTableView reloadData];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _myTableView) {
        [self.myMsgInputView isAndResignFirstResponder];
    }
}

#pragma mark Table header footer
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0? 1.0/[UIScreen mainScreen].scale: _curTopic.watchers.count > 0? 142: 88;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section == 0? 10: 1.0/[UIScreen mainScreen].scale;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerV = [UIView new];
    footerV.backgroundColor = kColorTableSectionBg;
    return footerV;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerV = [UIView new];
    if (section == 1) {
        if (!_headerV) {
            _headerV = [TopicDetailHeaderView new];
        }
        _headerV.curTopic = self.curTopic;
        __weak typeof(self) weakSelf = self;
        _headerV.goToUserBlock = ^(User *user){
            [weakSelf goToUser:user];
        };
        _headerV.commentBlock = ^(id sender){
            [weakSelf doCommentToTopic:nil ofAnswer:nil sender:sender];
        };
        _headerV.deleteBlock = ^(ProjectTopic *curTopic){
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此讨论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakSelf deleteTopic:weakSelf.curTopic ofAnswer:nil isComment:NO];
                }
            }];
            [actionSheet showInView:weakSelf.view];
        };
        headerV = _headerV;
    }
    return headerV;
}

- (void)goToUser:(User *)user{
    if (user) {
        UserInfoViewController *vc = [UserInfoViewController new];
        vc.curUser = user;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        __weak typeof(self) weakSelf = self;
        ProjectMemberListViewController *vc = [ProjectMemberListViewController new];
        [vc setFrame:self.view.bounds project:_curTopic.project type:ProMemTypeTopicWatchers refreshBlock:nil selectBlock:nil cellBtnBlock:^(ProjectMember *member) {
            [weakSelf.myTableView reloadData];
        }];
        vc.curTopic = _curTopic;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _curTopic && _curTopic.comments? 2: 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0? 1: _curTopic.comments.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        TopicContentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicContent forIndexPath:indexPath];
        cell.curTopic = self.curTopic;
        cell.cellHeightChangedBlock = ^(){
            [weakSelf.myTableView reloadData];
        };
        cell.addLabelBlock = ^(){
            [weakSelf addtitleBtnClick];
        };
        cell.loadRequestBlock = ^(NSURLRequest *curRequest){
            [weakSelf loadRequest:curRequest];
        };
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    } else {
        ProjectTopic *toComment = [_curTopic.comments.list objectAtIndex:indexPath.row];
        
        TopicAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicAnswerCell forIndexPath:indexPath];
        cell.curAnswer = toComment;
        cell.projectId = _curTopic.project.id;
        cell.linkStrBlock = ^(NSString *linkStr){
            [weakSelf analyseLinkStr:linkStr];
        };
        cell.commentClickedBlock = ^(ProjectTopic *curAnswer, ProjectTopic *toComment, id sender){
            if (toComment) {//评论或删除
                [weakSelf doCommentToTopic:toComment ofAnswer:curAnswer sender:sender];
            }else{//查看更多评论
                [weakSelf goToAnswer:curAnswer];
            }
        };
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = [TopicContentCell cellHeightWithObj:self.curTopic];
    } else {
        ProjectTopic *toComment = [_curTopic.comments.list objectAtIndex:indexPath.row];
        cellHeight = [TopicAnswerCell cellHeightWithObj:toComment];
    }
    return cellHeight;
}

- (void)doCommentToTopic:(ProjectTopic *)toComment ofAnswer:(ProjectTopic *)answer sender:(id)sender
{
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
        if (!isC) {
            [[Coding_NetAPIManager sharedManager] request_ProjectTopic_Delete_WithObj:curTopic andBlock:^(id data, NSError *error) {
                if (data) {
                    if (weakSelf.deleteTopicBlock) {
                        weakSelf.deleteTopicBlock(weakSelf.curTopic);
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];
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
    }else{
        [answer.child_comments removeObject:curTopic];
        answer.child_count = @(answer.child_count.integerValue - 1);
    }
    self.toComment = self.toAnswer = nil;
    self.commentSender = nil;
    self.myMsgInputView.toUser = nil;
    
    [self.myTableView reloadData];
}
#pragma mark Comment To Topic
- (void)sendCommentMessage:(id)obj
{
    __weak typeof(self) weakSelf = self;
    NSNumber *answerId = nil;
    if (_toComment) {
        _curTopic.nextCommentStr = [NSString stringWithFormat:@"@%@ %@", _toComment.owner.name, obj];
        answerId = _toComment.parent_id;
        if ([answerId isEqual:_curTopic.id]) {
            answerId = _toComment.id;
        }
    }else{
        _curTopic.nextCommentStr = obj;
    }
    [NSObject showHUDQueryStr:@"请稍等..."];
    [[Coding_NetAPIManager sharedManager] request_DoComment_WithProjectTpoic:_curTopic andAnswerId:answerId andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"发表成功"];
            [weakSelf uiDoComment:data ofAnswer:weakSelf.toAnswer];
        }
    }];
}

- (void)uiDoComment:(ProjectTopic *)comment ofAnswer:(ProjectTopic *)answer{
    [self.curTopic configWithComment:comment andAnswer:answer];
    self.toComment = self.toAnswer = nil;
    self.commentSender = nil;
    self.myMsgInputView.toUser = nil;
    [self.myMsgInputView isAndResignFirstResponder];
    [self.myTableView reloadData];
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
    }else{
        // 可能是图片链接
        HtmlMedia *htmlMedia = self.curTopic.htmlMedia;
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

#pragma mark goTo
- (void)goToAnswer:(ProjectTopic *)answer{
    TopicAnswerDetailViewController *vc = [TopicAnswerDetailViewController new];
    vc.curAnswer = answer;
    vc.curTopic = _curTopic;
    [self.navigationController pushViewController:vc animated:YES];
}

@end

@interface TopicDetailHeaderView ()
@property (strong, nonatomic) UIView *contentView, *watchersV;
@property (strong, nonatomic) UILabel *watchersL, *commentL, *tipL;
@property (strong, nonatomic) UIButton *addBtn, *commentBtn, *deleteBtn;
@property (strong, nonatomic) UIView *lineV;
@end

@implementation TopicDetailHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        if (!_contentView) {
            _contentView = [UIView new];
            _contentView.backgroundColor = kColorTableBG;
            [self addSubview:_contentView];
        }
        if (!_watchersL) {
            _watchersL = [UILabel new];
            _watchersL.textColor = kColor999;
            _watchersL.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_watchersL];
        }
        if (!_tipL) {
            _tipL = [UILabel new];
            _tipL.textColor = kColor999;
            _tipL.font = [UIFont systemFontOfSize:12];
            [_tipL setAttrStrWithStr:@"尚未添加任何关注者，去添加" diffColorStr:@"去添加" diffColor:kColorBrandGreen];
            _tipL.userInteractionEnabled = YES;
            [_tipL bk_whenTapped:^{
                if (weakSelf.goToUserBlock) {
                    weakSelf.goToUserBlock(nil);
                }
            }];
            [self.contentView addSubview:_tipL];
        }
        if (!_addBtn) {
            _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_addBtn setImage:[UIImage imageNamed:@"topic_add_watcher_btn"] forState:UIControlStateNormal];
            [_addBtn bk_addEventHandler:^(id sender) {
                if (weakSelf.goToUserBlock) {
                    weakSelf.goToUserBlock(nil);
                }
            } forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_addBtn];
        }
        if (!_lineV) {
            _lineV = [UIView new];
            _lineV.backgroundColor = kColorDDD;
            [self.contentView addSubview:_lineV];
        }
        if (!_watchersV) {
            _watchersV = [UIView new];
            [self.contentView addSubview:_watchersV];
        }
        if (!_commentL) {
            _commentL = [UILabel new];
            _commentL.textColor = kColor999;
            _commentL.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_commentL];
        }
        if (!_commentBtn) {
            _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_commentBtn setImage:[UIImage imageNamed:@"tweet_comment_btn"] forState:UIControlStateNormal];
            [_commentBtn bk_addEventHandler:^(id sender) {
                if (weakSelf.commentBlock) {
                    weakSelf.commentBlock(_commentBtn);
                }
            } forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_commentBtn];
        }
        if (!_deleteBtn) {
            _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [_deleteBtn setTitleColor:kColorBrandGreen forState:UIControlStateNormal];
            [_deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            _deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [_deleteBtn bk_addEventHandler:^(id sender) {
                if (weakSelf.deleteBlock) {
                    weakSelf.deleteBlock(self.curTopic);
                }
            } forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_deleteBtn];
        }
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [_watchersL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(_contentView.mas_top).offset(22);
        }];
        [_tipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_watchersL);
            make.centerX.equalTo(_contentView);
        }];
        [_addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(_watchersL);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(25);
        }];
        [_lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_watchersL);
            make.top.equalTo(_contentView).offset(44);
            make.right.equalTo(_contentView);
            make.height.mas_equalTo(0.5);
        }];
        [_watchersV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_watchersL);
            make.right.equalTo(_addBtn);
            make.top.equalTo(_lineV.mas_bottom);
            make.height.mas_equalTo(54);
        }];
        [_commentL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_watchersL);
            make.centerY.equalTo(_contentView.mas_bottom).offset(-20);
        }];
        [_commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_addBtn);
            make.centerY.equalTo(_commentL);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(25);
        }];
        [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_commentBtn.mas_left);
            make.centerY.equalTo(_commentL);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(25);
        }];
    }
    return self;
}

- (void)setCurTopic:(ProjectTopic *)curTopic{
    _curTopic = curTopic;
    
    _commentL.text = [NSString stringWithFormat:@"%d 条回答", _curTopic.child_count.intValue];

    BOOL hasWatchers = _curTopic.watchers.count > 0;
    _tipL.hidden = hasWatchers;
    _watchersL.hidden = _addBtn.hidden = _watchersV.hidden = !hasWatchers;
    _deleteBtn.hidden = ![_curTopic canEdit];
    if (hasWatchers) {
        _watchersL.text = [NSString stringWithFormat:@"%lu 人关注", (unsigned long)_curTopic.watchers.count];
        [[_watchersV subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        CGFloat maxWidth = kScreen_Width - 2* kPaddingLeftWidth;
        CGFloat watcherWidth = 30.0, watcherPadding = 8.0;
        CGPoint nextCenterP = CGPointMake(watcherWidth/2, 54.09/2);
        for (User *user in curTopic.watchers) {
            UIView *watcherV = [self makeViewForUser:nextCenterP.x + watcherWidth* 3/ 2 + watcherPadding > maxWidth? nil: user];
            [watcherV setCenter:nextCenterP];
            [_watchersV addSubview:watcherV];
            nextCenterP.x += watcherWidth + watcherPadding;
        }
    }
}

- (UIView *)makeViewForUser:(User *)user{
    CGFloat width = 30.0;
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    imageV.layer.masksToBounds = YES;
    imageV.layer.cornerRadius = width/2;
    imageV.layer.borderColor = [UIColor colorWithHexString:@"0xFFAE03"].CGColor;
    imageV.userInteractionEnabled = YES;
    [imageV bk_whenTapped:^{
        if ( self.goToUserBlock) {
            self.goToUserBlock(user);
        }
    }];
    if (user) {
        [imageV sd_setImageWithURL:[user.avatar urlImageWithCodePathResizeToView:imageV] placeholderImage:kPlaceholderMonkeyRoundWidth(33.0)];
    }else{
        [imageV setImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xdadada"]]];
        {
            UILabel *watchersLabel = [[UILabel alloc] initWithFrame:imageV.bounds];
            watchersLabel.backgroundColor = [UIColor clearColor];
            watchersLabel.textColor = [UIColor whiteColor];
            watchersLabel.font = [UIFont systemFontOfSize:15];
            watchersLabel.minimumScaleFactor = 0.5;
            watchersLabel.textAlignment = NSTextAlignmentCenter;
            watchersLabel.text = @"···";
            [imageV addSubview:watchersLabel];
        }
    }
    return imageV;
}

@end

