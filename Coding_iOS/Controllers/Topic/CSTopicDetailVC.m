//
//  CSTopicDetailVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSTopicDetailVC.h"
#import "TweetSendViewController.h"
#import "Coding_NetAPIManager.h"
#import "CSTopicHeaderView.h"

#import "TweetCell.h"
#import "Tweet.h"
#import "Tweets.h"

#import "UserInfoViewController.h"
#import "LikersViewController.h"
#import "TweetSendLocationDetailViewController.h"
#import "UIMessageInputView.h"
#import "TweetDetailViewController.h"
#import "CSTopicDetailVC.h"
#import "WebViewController.h"
#import "SVPullToRefresh.h"
#import "ODRefreshControl.h"

#define kCommentIndexNotFound -1

@interface CSTopicDetailVC ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIMessageInputViewDelegate>
@property (nonatomic,strong)UITableView *myTableView;

@property (nonatomic,strong)Tweets *curTweets;
@property (nonatomic,strong)Tweet *curTopWteet;
@property (nonatomic,strong)CSTopicHeaderView *tableHeader;

//评论
@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@property (nonatomic, strong) Tweet *commentTweet;
@property (nonatomic, assign) NSInteger commentIndex;
@property (nonatomic, strong) UIView *commentSender;
@property (nonatomic, strong) User *commentToUser;

@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@end

@implementation CSTopicDetailVC{
    CGFloat _oldPanOffsetY;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _curIndex = 0;
    [self setupData];
    [self setupUI];
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    [self.myTableView reloadData];
    __weak typeof(self) weakSelf = self;
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf sendRequestLoadMore:YES];
    }];
    [self refresh];
}

- (void)refresh{
    [self refreshheader];
    [self refreshTopTweet];
    [self sendRequestLoadMore:NO];
}

- (void)sendRequestLoadMore:(BOOL)loadMore{
    if (_curTweets.isLoading) {
        return;
    }
    _curTweets.willLoadMore = loadMore;
    _curTweets.isLoading = YES;
    __weak typeof(self) weakSelf = self;
    NSNumber *last_id = nil;
    if (_curTweets.willLoadMore && _curTweets.list.count > 0) {
        last_id = [(Tweet *)_curTweets.list.lastObject id];
    }
    [[Coding_NetAPIManager sharedManager] request_PublicTweetsWithTopic:_topicID last_id:last_id andBlock:^(NSArray *datalist, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        weakSelf.curTweets.isLoading = NO;
        [weakSelf.curTweets configWithTweets:datalist];
        [weakSelf.myTableView reloadData];
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
        [_myMsgInputView prepareToShow];
    }
}

- (void)refreshTopTweet {
    __weak typeof(self) weakSelf = self;
    
    [[Coding_NetAPIManager sharedManager] request_TopTweetWithTopicID:_topicID block:^(id data, NSError *error) {
        if (data) {
            weakSelf.curTopWteet = data;
            [weakSelf.myTableView reloadData];
        }
    }];
}

- (void)refreshheader {
    [[Coding_NetAPIManager sharedManager]request_TopicDetailsWithTopicID:_topicID block:^(id data, NSError *error) {
        if (data) {
            self.title = data[@"name"];

            [self.tableHeader updateWithTopic:data];
        }
    }];
    
    [[Coding_NetAPIManager sharedManager] request_Users_WithTopicID:_topicID andBlock:^(NSArray *userlist, NSError *error) {
        if (userlist) {
            [self.tableHeader updateWithJoinedUsers:userlist];
        }
    }];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (_curTopWteet) {
            return 2;
        }else {
            return 0;
        }
    }
    
    if (_curTweets && _curTweets.list) {
        return [_curTweets.list count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row ==0) {
        CSTopTweetDescCell *cell0 = [tableView dequeueReusableCellWithIdentifier:@"CSTopTweetDescCell" forIndexPath:indexPath];
        [cell0 updateUI];
        [tableView addLineforPlainCell:cell0 forRowAtIndexPath:indexPath withLeftSpace:0];
        return cell0;
    }
    
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Tweet forIndexPath:indexPath];
    if (indexPath.section == 0) {
        [cell setTweet:_curTopWteet needTopView:NO];
    }else{
        [cell setTweet:[_curTweets.list objectAtIndex:indexPath.row] needTopView:YES];
    }
    
    cell.outTweetsIndex = _curIndex;
    
    __weak typeof(self) weakSelf = self;
    cell.commentClickedBlock = ^(Tweet *tweet, NSInteger index, id sender){
        if ([self.myMsgInputView isAndResignFirstResponder]) {
            return ;
        }
        weakSelf.commentTweet = tweet;
        weakSelf.commentIndex = index;
        weakSelf.commentSender = sender;
        
        weakSelf.myMsgInputView.commentOfId = tweet.id;
        
        if (weakSelf.commentIndex >= 0) {
            weakSelf.commentToUser = ((Comment*)[weakSelf.commentTweet.comment_list objectAtIndex:weakSelf.commentIndex]).owner;
            weakSelf.myMsgInputView.toUser = ((Comment*)[weakSelf.commentTweet.comment_list objectAtIndex:weakSelf.commentIndex]).owner;
            
            if ([Login isLoginUserGlobalKey:weakSelf.commentToUser.global_key]) {
                ESWeakSelf
                UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此评论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                    ESStrongSelf
                    if (index == 0 && _self.commentIndex >= 0) {
                        Comment *comment  = [_self.commentTweet.comment_list objectAtIndex:_self.commentIndex];
                        [_self deleteComment:comment ofTweet:_self.commentTweet];
                    }
                }];
                [actionSheet showInView:weakSelf.view];
                return;
            }
        }else{
            weakSelf.myMsgInputView.toUser = nil;
        }
        [_myMsgInputView notAndBecomeFirstResponder];
    };
    cell.cellRefreshBlock = ^(){
        [weakSelf.myTableView reloadData];
    };
    cell.userBtnClickedBlock = ^(User *curUser){
        UserInfoViewController *vc = [[UserInfoViewController alloc] init];
        vc.curUser = curUser;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.moreLikersBtnClickedBlock = ^(Tweet *curTweet){
        LikersViewController *vc = [[LikersViewController alloc] init];
        vc.curTweet = curTweet;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
     cell.goToDetailTweetBlock = ^(Tweet *curTweet){
        [weakSelf goToDetailWithTweet:curTweet];
    };
    cell.mediaItemClickedBlock = ^(HtmlMediaItem *curItem){
        [weakSelf analyseLinkStr:curItem.href];
    };
    
    cell.deleteClickedBlock = ^(Tweet *curTweet, NSInteger outTweetsIndex){
        if ([self.myMsgInputView isAndResignFirstResponder]) {
            return ;
        }
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此冒泡" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf deleteTweet:curTweet];
            }
        }];
        [actionSheet showInView:self.view];
    };

    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    
    return cell;
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

- (void)goToDetailWithTweet:(Tweet *)curTweet{
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
    vc.curTweet = curTweet;
    vc.deleteTweetBlock = ^(Tweet *toDeleteTweet){
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)analyseLinkStr:(NSString *)linkStr{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        //网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (_curTopWteet && indexPath.row ==0) {
            return 36;
        }else if(_curTopWteet && indexPath.row == 1){
            return [TweetCell cellHeightWithObj:_curTopWteet needTopView:NO];
        }
        else {
            return 0;
        }
    }
    return [TweetCell cellHeightWithObj:[_curTweets.list objectAtIndex:indexPath.row] needTopView:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row ==0) {
        return;
    }
    Tweet *toTweet = nil;
    if (indexPath.section == 0) {
        toTweet = _curTopWteet;
    }else{
        toTweet = [_curTweets.list objectAtIndex:indexPath.row];
    }
    if (toTweet) {
        [self goToDetailWithTweet:toTweet];
    }
}

#pragma mark UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text{
    [self sendCommentMessage:text];
}

- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom{
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        UIEdgeInsets contentInsets= UIEdgeInsetsMake(0.0, 0.0, heightToBottom, 0.0);;
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


- (void)sendCommentMessage:(id)obj{
    if (_commentIndex >= 0) {
        _commentTweet.nextCommentStr = [NSString stringWithFormat:@"@%@ %@", _commentToUser.name, obj];
    }else{
        _commentTweet.nextCommentStr = obj;
    }
    [self sendCurComment:_commentTweet];
    {
        _commentTweet = nil;
        _commentIndex = kCommentIndexNotFound;
        _commentSender = nil;
        _commentToUser = nil;
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

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

#pragma mark - myscrollview

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.myMsgInputView isAndResignFirstResponder];
    }
}


#pragma mark - 

- (void) setupUI {
    self.navigationItem.title = @"话题";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tweetBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(sendTweet)];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TweetCell class] forCellReuseIdentifier:kCellIdentifier_Tweet];
        [tableView registerClass:[CSTopTweetDescCell class] forCellReuseIdentifier:@"CSTopTweetDescCell"];
        
        [self.view addSubview:tableView];
        
        CSTopicHeaderView *header = [[CSTopicHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 115)];
        header.parentVC = self;
        tableView.tableHeaderView = header;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        _tableHeader = header;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypeTweet];
    _myMsgInputView.delegate = self;
    
}

- (void)setupData {
    _curTweets = [Tweets tweetsWithType:TweetTypePublicTime];
}

- (void)sendTweet{
    __weak typeof(self) weakSelf = self;
    TweetSendViewController *vc = [[TweetSendViewController alloc] init];
    vc.sendNextTweet = ^(Tweet *nextTweet){
        [nextTweet saveSendData];//发送前保存草稿
        [[Coding_NetAPIManager sharedManager] request_Tweet_DoTweet_WithObj:nextTweet andBlock:^(id data, NSError *error) {
            if (data) {
                [Tweet deleteSendData];//发送成功后删除草稿
                [weakSelf refresh];
            }
        }];
    };
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self.parentViewController presentViewController:nav animated:YES completion:nil];
}

#pragma mark Delete Tweet
- (void)deleteTweet:(Tweet *)curTweet{
    ESWeakSelf;
    [[Coding_NetAPIManager sharedManager] request_Tweet_Delete_WithObj:curTweet andBlock:^(id data, NSError *error) {
        ESStrongSelf;
        if (data) {
            [_self.curTweets.list removeObject:curTweet];
            [_self.myTableView reloadData];
            [_self.view configBlankPage:([[Login curLoginUser] isSameToUser:_self.curTweets.curUser]? EaseBlankPageTypeTweet: EaseBlankPageTypeTweetOther)  hasData:(_self.curTweets.list.count > 0) hasError:NO reloadButtonBlock:^(id sender) {
                ESStrongSelf;
                [_self refresh];
            }];
        }
    }];
}
@end


@implementation CSTopTweetDescCell

- (void)updateUI {
    self.imageView.frame = CGRectMake(12, 0, 15, 15);
    self.imageView.image = [UIImage imageNamed:@"icon_topic_hotTop"];
    self.imageView.centerY = 18;
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.frame = CGRectMake(30, 0, 100, 36);
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.textColor = kColor666;
    self.textLabel.text = @"置顶话题";
}

@end

