//
//  TweetDetailViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "Coding_NetAPIManager.h"
#import "TweetDetailCell.h"
#import "TweetDetailCommentCell.h"
#import "UserInfoViewController.h"
#import "LikersViewController.h"
#import "RegexKitLite.h"
#import "TopicDetailViewController.h"
#import "ProjectViewController.h"
#import "MJPhotoBrowser.h"
#import "EditTaskViewController.h"
#import "WebViewController.h"
#import "ReportIllegalViewController.h"
#import "TweetSendLocationDetailViewController.h"
#import "CodingShareView.h"

@interface TweetDetailViewController ()
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

//评论
@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@property (nonatomic, strong) Comment *toComment;
@property (nonatomic, strong) UIView *commentSender;

//TTTAttributedLabel
@property (strong, nonatomic) HtmlMediaItem *clickedItem;
@property (strong, nonatomic) NSString *clickedAutoLinkStr;
@end

@implementation TweetDetailViewController

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
    self.title = @"冒泡详情";
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)] animated:NO];

    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TweetDetailCell class] forCellReuseIdentifier:kCellIdentifier_TweetDetail];
        [tableView registerClass:[TweetDetailCommentCell class] forCellReuseIdentifier:kCellIdentifier_TweetDetailComment];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refreshTweet) forControlEvents:UIControlEventValueChanged];
    
    //评论
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypeTweet];
    _myMsgInputView.isAlwaysShow = YES;
    _myMsgInputView.delegate = self;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myMsgInputView.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
    
    if (!_curTweet.content
        || (_curTweet.likes.integerValue > 0 && _curTweet.like_users.count == 0)) {
        [self refreshTweet];
    }else{
        _myMsgInputView.commentOfId = _curTweet.id;

        if (_curTweet.comments.integerValue > _curTweet.comment_list.count) {
            [self refreshComments];//加载等多评论
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightNavBtnClicked{
    if (self.curTweet.id && [self.curTweet.id isKindOfClass:[NSNumber class]]) {
        [_myMsgInputView isAndResignFirstResponder];
        
//        if (_curTweet.project_id != nil) {
//            [NSObject showHudTipStr:@"项目内冒泡，不能分享"];
//            return;
//        }
        [CodingShareView showShareViewWithObj:_curTweet];

//        @weakify(self);
//        [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"举报"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
//            if (index == 0) {
//                @strongify(self);
//                [self goToReport];
//            }
//        }] showInView:self.view];
    }
}

- (void)goToReport{
    if (self.curTweet.id && [self.curTweet.id isKindOfClass:[NSNumber class]]) {
        NSNumber *tweet_id = self.curTweet.id;
        [ReportIllegalViewController showReportWithIllegalContent:tweet_id.stringValue andType:IllegalContentTypeTweet];
    }else{
        [NSObject showHudTipStr:@"冒泡为空"];
    }
}

#pragma mark UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text{
    [self sendCommentMessage:text];
}

- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom{
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        UIEdgeInsets contentInsets= UIEdgeInsetsMake(0.0, 0.0, MAX(CGRectGetHeight(inputView.frame), heightToBottom), 0.0);;
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
- (void)refreshTweet{
    __weak typeof(self) weakSelf = self;
    if (_curTweet.project && !_curTweet.project_id) {
        [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:_curTweet.project andBlock:^(id data, NSError *error) {
            if (data) {
                weakSelf.curTweet.project = data;
                weakSelf.curTweet.project_id = [(Project *)data id];
                [weakSelf refreshTweet];
            }else{
                [weakSelf.refreshControl endRefreshing];
            }
        }];
    }else{
        [[Coding_NetAPIManager sharedManager] request_Tweet_Detail_WithObj:_curTweet andBlock:^(id data, NSError *error) {
            if (data) {
                if (weakSelf.curTweet.contentHeight > 1) {
                    ((Tweet *)data).contentHeight = weakSelf.curTweet.contentHeight;
                }
                if (weakSelf.curTweet.project) {
                    [(Tweet *)data setProject:weakSelf.curTweet.project];
                }
                weakSelf.curTweet = data;
                weakSelf.myMsgInputView.commentOfId = weakSelf.curTweet.id;
                weakSelf.myMsgInputView.toUser = nil;
                [weakSelf.myTableView reloadData];
                [weakSelf refreshComments];
            }else{
                [weakSelf.refreshControl endRefreshing];
            }
        }];
    }
}

- (void)refreshComments{
    if (_curTweet.isLoading) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Tweet_Comments_WithObj:_curTweet andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        if (data) {
            weakSelf.curTweet.comment_list = data;
            weakSelf.curTweet.comments = [NSNumber numberWithInteger:weakSelf.curTweet.comment_list.count];
            [weakSelf.myTableView reloadData];
        }
    }];
}


#pragma mark TableM
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_curTweet && _curTweet.comment_list) {
        row = 1+ [_curTweet.comment_list count];
    }else{
        row = 1;
    }
    return row;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        TweetDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetDetail forIndexPath:indexPath];
        cell.tweet = _curTweet;
        
        cell.commentClickedBlock = ^(id sender){
            [self doCommentToComment:nil sender:sender];
        };
        cell.cellRefreshBlock = ^(){
            [self.myTableView reloadData];
        };
        cell.deleteClickedBlock = ^(){
            if ([self.myMsgInputView isAndResignFirstResponder]) {
                return ;
            }
            ESWeakSelf;
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此冒泡" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                ESStrongSelf
                if (index == 0) {
                    [_self deleteTweet:_self.curTweet];
                }
            }];
            [actionSheet showInView:self.view];
        };
        
        cell.userBtnClickedBlock = ^(User *curUser){
            [self goToUserInfo:curUser];
        };
        cell.moreLikersBtnClickedBlock = ^(){
            LikersViewController *vc = [[LikersViewController alloc] init];
            vc.curTweet = _curTweet;
            [self.navigationController pushViewController:vc animated:YES];
        };
        cell.cellHeightChangedBlock = ^(){
            [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        };
        cell.loadRequestBlock = ^(NSURLRequest *curRequest){
            [self loadRequest:curRequest];
        };
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        TweetDetailCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetDetailComment forIndexPath:indexPath];
        Comment *curComment = [_curTweet.comment_list objectAtIndex:indexPath.row-1];
        cell.toComment = curComment;
        cell.commentToCommentBlock = ^(Comment *toComment, id sender){
            [self doCommentToComment:toComment sender:sender];
        };
        [cell.ownerIconView addTapBlock:^(id obj) {
            [self goToUserInfo:curComment.owner];
        }];
        cell.contentLabel.delegate = self;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat row = 0;
    if (indexPath.row == 0) {
        row = [TweetDetailCell cellHeightWithObj:_curTweet];
    }else{
        row = [TweetDetailCommentCell cellHeightWithObj:[_curTweet.comment_list objectAtIndex:indexPath.row-1]];
    }
    return row;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != 0) {
        Comment *toComment = [_curTweet.comment_list objectAtIndex:indexPath.row-1];
        [self doCommentToComment:toComment sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

#pragma mark Table Copy
//
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return indexPath.row != 0;
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        if (indexPath.row == 0) {
            [UIPasteboard generalPasteboard].string = _curTweet.content? _curTweet.content: @"";
        }else{
            Comment *curComment = [_curTweet.comment_list objectAtIndex:indexPath.row-1];
            [UIPasteboard generalPasteboard].string = curComment.content? curComment.content: @"";
        }
    }
}

#pragma mark Comment To Tweet

- (void)doCommentToComment:(Comment *)toComment sender:(id)sender{
    if ([self.myMsgInputView isAndResignFirstResponder]) {
        return ;
    }
    _toComment = toComment;
    _commentSender = sender;
    
    _myMsgInputView.toUser = toComment.owner;
    
    if (_toComment) {
        if ([Login isLoginUserGlobalKey:_toComment.owner.global_key]) {
            ESWeakSelf;
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此评论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                ESStrongSelf
                if (index == 0) {
                    [_self deleteComment:_self.toComment ofTweet:_self.curTweet];
                }
            }];
            [actionSheet showInView:self.view];
            return;
        }
    }
    [_myMsgInputView notAndBecomeFirstResponder];
}


- (void)sendCommentMessage:(id)obj{
    if (_toComment) {
        _curTweet.nextCommentStr = [NSString stringWithFormat:@"@%@ %@", _toComment.owner.name, obj];
    }else{
        _curTweet.nextCommentStr = obj;
    }
    [self sendCurComment:_curTweet];
    {
        
        _toComment = nil;
        _commentSender = nil;
    }
    self.myMsgInputView.toUser = nil;
    [self.myMsgInputView isAndResignFirstResponder];
}

- (void)sendCurComment:(Tweet *)commentObj{
    [NSObject showHUDQueryStr:@"正在发表评论..."];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Tweet_DoComment_WithObj:commentObj andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"评论成功"];
            Comment *resultCommnet = (Comment *)data;
            resultCommnet.owner = [Login curLoginUser];
            [commentObj addNewComment:resultCommnet];
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark deleteTweet
- (void)deleteTweet:(Tweet *)curTweet{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Tweet_Delete_WithObj:curTweet andBlock:^(id data, NSError *error) {
        if (data) {
            if (weakSelf.deleteTweetBlock) {
                weakSelf.deleteTweetBlock(curTweet);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)deleteComment:(Comment *)comment ofTweet:(Tweet *)tweet{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_TweetComment_Delete_WithTweet:tweet andComment:comment andBlock:^(id data, NSError *error) {
        if (data) {
            [tweet deleteComment:comment];
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.myMsgInputView isAndResignFirstResponder];
    }
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    DebugLog(@"%@", components.description);
    _clickedItem = [components objectForKey:@"value"];
    [self analyseLinkStr:_clickedItem.href];
}

#pragma mark to VC
- (void)goToUserInfo:(User *)curUser{
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.curUser = curUser;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark loadCellRequest
- (void)loadRequest:(NSURLRequest *)curRequest{
    NSString *linkStr = curRequest.URL.absoluteString;
    [self analyseLinkStr:linkStr];
}

- (void)analyseLinkStr:(NSString *)linkStr{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        //可能是图片链接
        HtmlMedia *htmlMedia = self.curTweet.htmlMedia;
        if (htmlMedia.imageItems.count > 0) {
            for (HtmlMediaItem *item in htmlMedia.imageItems) {
                if ((item.src.length > 0 && [item.src isEqualToString:linkStr])
                    || (item.href.length > 0 && [item.href isEqualToString:linkStr])) {
                    [MJPhotoBrowser showHtmlMediaItems:htmlMedia.imageItems originalItem:item];
                    return;
                }
            }
        }
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
