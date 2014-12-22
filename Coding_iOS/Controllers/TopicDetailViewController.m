//
//  TopicDetailViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TopicContent @"TopicContentCell"
#define kCellIdentifier_TopicComment @"TopicCommentCell"
#define kTagActionDeleteTopic 1002
#define kTagActionDeleteComment 1003

#import "TopicDetailViewController.h"
#import "TopicContentCell.h"
#import "TopicCommentCell.h"
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

@interface TopicDetailViewController ()
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

//评论
@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@property (nonatomic, strong) ProjectTopic *toComment;
@property (nonatomic, strong) UIView *commentSender;

//链接
@property (strong, nonatomic) NSString *clickedAutoLinkStr;

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
    
    self.title = @"讨论详情";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[TopicContentCell class] forCellReuseIdentifier:kCellIdentifier_TopicContent];
        [tableView registerClass:[TopicCommentCell class] forCellReuseIdentifier:kCellIdentifier_TopicComment];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView;
    });
    [self.view addSubview:_myTableView];
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    //评论
    __weak typeof(self) weakSelf = self;
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewTypeSimple];
    _myMsgInputView.isAlwaysShow = YES;
    _myMsgInputView.delegate = self;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myMsgInputView.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
    
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
    if (_curTopic && _curTopic.project) {
        _myMsgInputView.curProject = _curTopic.project;
    }
    [self refresh];
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

#pragma mark Refresh M
- (void)refresh{
    [self refreshTopic];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf refreshComments];
    });
}

- (void)refreshComments{
    if (_curTopic.isLoading) {
        return;
    }
    _curTopic.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshTopic{
    if (_curTopic.isTopicLoading) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectTopic_WithObj:_curTopic andBlock:^(id data, NSError *error) {
        [self.refreshControl endRefreshing];
        if (data) {
            [weakSelf.curTopic configWithRefreshedTopic:data];
            weakSelf.myMsgInputView.curProject = weakSelf.curTopic.project;
            [weakSelf.myTableView reloadData];
        }
    }];
}

- (void)refreshMore{
    if (_curTopic.isLoading || !_curTopic.canLoadMore) {
        [self.myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _curTopic.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Comments_WithProjectTpoic:self.curTopic andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.curTopic configWithComments:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.curTopic.canLoadMore;
        }
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.myMsgInputView isAndResignFirstResponder];
    }
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_curTopic) {
        row = 1;
        if (_curTopic.comments && _curTopic.comments.list && [_curTopic.comments.list count] > 0) {
            row = [_curTopic.comments.list count] +1;
        }
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        TopicContentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicContent forIndexPath:indexPath];
        cell.curTopic = self.curTopic;
        __weak typeof(self) weakSelf = self;
        cell.commentTopicBlock = ^(ProjectTopic *curTopic, id sender){
            [weakSelf doCommentToTopic:nil sender:sender];
        };
        cell.cellHeightChangedBlock = ^(){
            [weakSelf.myTableView reloadData];
        };
        cell.loadRequestBlock = ^(NSURLRequest *curRequest){
            [weakSelf loadRequest:curRequest];
        };
        cell.deleteTopicBlock = ^(ProjectTopic *curTopic){
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"删除此讨论" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles: nil];
            actionSheet.tag = kTagActionDeleteTopic;
            [actionSheet showInView:kKeyWindow];
        };
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
        return cell;
    }else{
        TopicCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicComment forIndexPath:indexPath];
        ProjectTopic *toComment = [_curTopic.comments.list objectAtIndex:indexPath.row-1];
        cell.toComment = toComment;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:45];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [TopicContentCell cellHeightWithObj:self.curTopic];
    }else{
        ProjectTopic *toComment = [_curTopic.comments.list objectAtIndex:indexPath.row - 1];
        cellHeight = [TopicCommentCell cellHeightWithObj:toComment];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != 0) {
        ProjectTopic *toComment = [_curTopic.comments.list objectAtIndex:indexPath.row-1];
        [self doCommentToTopic:toComment sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)doCommentToTopic:(ProjectTopic *)toComment sender:(id)sender{
    if ([self.myMsgInputView isAndResignFirstResponder]) {
        return ;
    }
    _toComment = toComment;
    _commentSender = sender;
    
    if (_toComment) {
        _myMsgInputView.placeHolder = [NSString stringWithFormat:@"回复 %@:", _toComment.owner.name];
        if (_toComment.owner_id.intValue == [Login curLoginUser].id.intValue) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"删除此评论" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles: nil];
            actionSheet.tag = kTagActionDeleteComment;
            [actionSheet showInView:kKeyWindow];
            return;
        }
    }else{
        _myMsgInputView.placeHolder = @"撰写评论";
    }
    [_myMsgInputView notAndBecomeFirstResponder];
}

#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (actionSheet.tag == kTagActionDeleteTopic) {
            [self deleteTopic:_curTopic isComment:NO];
        }else if (actionSheet.tag == kTagActionDeleteComment){
            [self deleteTopic:_toComment isComment:YES];
        }
    }
}

#pragma mark Delete M
- (void)deleteTopic:(ProjectTopic *)curTopic isComment:(BOOL)isC{
    if (curTopic) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_ProjectTopic_Delete_WithObj:curTopic andBlock:^(id data, NSError *error) {
            if (data) {
                if (isC) {
                    [weakSelf.curTopic.comments.list removeObject:_toComment];
                    [weakSelf.myTableView reloadData];
                }else{
                    if (weakSelf.deleteTopicBlock) {
                        weakSelf.deleteTopicBlock(weakSelf.curTopic);
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
        }];
    }
}

#pragma mark Comment To Topic
- (void)sendCommentMessage:(id)obj{
    __weak typeof(self) weakSelf = self;
    if (_toComment) {
        _curTopic.nextCommentStr = [NSString stringWithFormat:@"@%@ : %@", _toComment.owner.name, obj];
    }else{
        _curTopic.nextCommentStr = obj;
    }
    [[Coding_NetAPIManager sharedManager] request_DoComment_WithProjectTpoic:_curTopic andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.curTopic configWithComment:data];
            [weakSelf.myTableView reloadData];
        }
    }];
    {
        _toComment = nil;
        _commentSender = nil;
    }
    [self.myMsgInputView isAndResignFirstResponder];
}

#pragma mark loadCellRequest
- (void)loadRequest:(NSURLRequest *)curRequest{
    NSString *linkStr = curRequest.URL.absoluteString;
    NSLog(@"\n linkStr : %@", linkStr);
    [self analyseLinkStr:linkStr withHtmlMedia:_curTopic.htmlMedia];
}

- (void)analyseLinkStr:(NSString *)linkStr withHtmlMedia:(HtmlMedia *)htmlMedia{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        //网页
        NSLog(@"\n linkStr : %@", linkStr);
        if (htmlMedia.imageItems.count > 0) {
            for (HtmlMediaItem *item in htmlMedia.imageItems) {
                if (item.src.length > 0 && [item.src isEqualToString:linkStr]) {
                    //[MJPhotoBrowser showHtmlMediaItems:_curTweet.htmlMedia.imageItems originalItem:item];
                    return;
                }
            }
        }
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:linkStr];
        [actionSheet bk_addButtonWithTitle:@"在Safari中打开" handler:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkStr]];
        }];
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [actionSheet showInView:kKeyWindow];
    }
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
