//
//  UserTweetsViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-4.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_Tweet @"TweetCell"
#define kTagActionDeleteTweet 1002
#define kTagActionDeleteComment 1003
#define kCommentIndexNotFound -1

#import "UserTweetsViewController.h"
#import "TweetCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "UserInfoViewController.h"
#import "LikersViewController.h"
#import "TweetDetailViewController.h"
#import "SVPullToRefresh.h"

@interface UserTweetsViewController ()
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

//评论
@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@property (nonatomic, strong) Tweet *commentTweet;
@property (nonatomic, assign) NSInteger commentIndex;
@property (nonatomic, strong) UIView *commentSender;
@property (nonatomic, strong) User *commentToUser;

//删冒泡
@property (strong, nonatomic) Tweet *deleteTweet;
@property (nonatomic, assign) NSInteger deleteTweetsIndex;
@end

@implementation UserTweetsViewController

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
    
    CGRect frame = [UIView frameWithOutNav];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.title = _curTweets.curUser.name;
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableBG;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        Class tweetCellClass = [TweetCell class];
        [tableView registerClass:tweetCellClass forCellReuseIdentifier:kCellIdentifier_Tweet];
        [self.view addSubview:tableView];
        tableView;
    });
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    //评论
    __weak typeof(self) weakSelf = self;
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewTypeSimple];
    _myMsgInputView.delegate = self;
    
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
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


#pragma mark M
- (void)deleteTweet:(Tweet *)curTweet outTweetsIndex:(NSInteger)outTweetsIndex{
    ESWeakSelf;
    [[Coding_NetAPIManager sharedManager] request_Tweet_Delete_WithObj:curTweet andBlock:^(id data, NSError *error) {
        ESStrongSelf;
        if (data) {
            [_self.curTweets.list removeObject:curTweet];
            [_self.myTableView reloadData];
            [_self.view configBlankPage:([[Login curLoginUser] isSameToUser:_self.curTweets.curUser]? EaseBlankPageTypeTweet: EaseBlankPageTypeTweetOther)  hasData:(_self.curTweets.list.count > 0) hasError:NO reloadButtonBlock:^(id sender) {
                ESStrongSelf;
                [_self sendRequest];
            }];
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

#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (actionSheet.tag == kTagActionDeleteTweet) {
            [self deleteTweet:self.deleteTweet outTweetsIndex:self.deleteTweetsIndex];
        }else if (actionSheet.tag == kTagActionDeleteComment){
            if (self.commentIndex >= 0) {
                Comment *comment  = [_commentTweet.comment_list objectAtIndex:_commentIndex];
                [self deleteComment:comment ofTweet:self.commentTweet];
            }
        }
    }
}


#pragma mark Refresh M

- (void)refresh{
    if (_curTweets.isLoading) {
        [_refreshControl endRefreshing];
        return;
    }
    _curTweets.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore{
    if (_curTweets.isLoading || !_curTweets.canLoadMore) {
        return;
    }
    _curTweets.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest{
    if (_curTweets.list.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Tweets_WithObj:_curTweets andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.view endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.curTweets configWithTweets:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.curTweets.canLoadMore;
        }
        [weakSelf.view configBlankPage:([[Login curLoginUser] isSameToUser:self.curTweets.curUser]? EaseBlankPageTypeTweet: EaseBlankPageTypeTweetOther) hasData:(weakSelf.curTweets.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf sendRequest];
        }];
    }];
}

#pragma mark TableM
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_curTweets && _curTweets.list) {
        return [_curTweets.list count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Tweet forIndexPath:indexPath];
    cell.tweet = [_curTweets.list objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    cell.commentClickedBlock = ^(Tweet *tweet, NSInteger index, id sender){
        if ([self.myMsgInputView isAndResignFirstResponder]) {
            return ;
        }
        weakSelf.commentTweet = tweet;
        weakSelf.commentIndex = index;
        weakSelf.commentSender = sender;
        
        if (weakSelf.commentIndex >= 0) {
            weakSelf.commentToUser = ((Comment*)[weakSelf.commentTweet.comment_list objectAtIndex:weakSelf.commentIndex]).owner;
            weakSelf.myMsgInputView.placeHolder = [NSString stringWithFormat:@"回复 %@:", weakSelf.commentToUser.name];
            if (weakSelf.commentToUser.id.intValue == [Login curLoginUser].id.intValue) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"删除此评论" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles: nil];
                actionSheet.tag = kTagActionDeleteComment;
                [actionSheet showInView:kKeyWindow];
                return;
            }
        }else{
            weakSelf.myMsgInputView.placeHolder = @"说点什么吧...";
        }
        [_myMsgInputView notAndBecomeFirstResponder];
    };
    cell.likeBtnClickedBlock = ^(Tweet *tweet){
        [weakSelf.myTableView reloadData];
    };
    cell.userBtnClickedBlock = ^(User *curUser){
        UserInfoViewController *vc = [[UserInfoViewController alloc] init];
        vc.curUser = curUser;
        [self.navigationController pushViewController:vc animated:YES];
    };
    cell.moreLikersBtnClickedBlock = ^(Tweet *curTweet){
        LikersViewController *vc = [[LikersViewController alloc] init];
        vc.curTweet = curTweet;
        [self.navigationController pushViewController:vc animated:YES];
    };
    cell.deleteClickedBlock = ^(Tweet *curTweet, NSInteger outTweetsIndex){
        if ([self.myMsgInputView isAndResignFirstResponder]) {
            return ;
        }
        self.deleteTweet = curTweet;
        self.deleteTweetsIndex = outTweetsIndex;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"删除此冒泡" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles: nil];
        actionSheet.tag = kTagActionDeleteTweet;
        [actionSheet showInView:kKeyWindow];
    };

    cell.goToDetailTweetBlock = ^(Tweet *curTweet){
        [self goToDetailWithTweet:curTweet];
    };
    cell.refreshSingleCCellBlock = ^(){
        [weakSelf.myTableView reloadData];
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [TweetCell cellHeightWithObj:[_curTweets.list objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Tweet *toTweet = [_curTweets.list objectAtIndex:indexPath.row];
    [self goToDetailWithTweet:toTweet];
}

- (void)goToDetailWithTweet:(Tweet *)curTweet{
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
    vc.curTweet = curTweet;
    __weak typeof(self) weakSelf = self;
    vc.deleteTweetBlock = ^(Tweet *toDeleteTweet){
        [weakSelf.curTweets.list removeObject:toDeleteTweet];
        [weakSelf.myTableView reloadData];
        [weakSelf.view configBlankPage:([[Login curLoginUser] isSameToUser:self.curTweets.curUser]? EaseBlankPageTypeTweet: EaseBlankPageTypeTweetOther) hasData:(weakSelf.curTweets.list.count > 0) hasError:NO reloadButtonBlock:^(id sender) {
            [weakSelf sendRequest];
        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.myMsgInputView isAndResignFirstResponder];
    }
}

#pragma mark Comment To Tweet
- (void)sendCommentMessage:(id)obj{
    if (_commentIndex >= 0) {
        _commentTweet.nextCommentStr = [NSString stringWithFormat:@"@%@ : %@", _commentToUser.name, obj];
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
    [self.myMsgInputView isAndResignFirstResponder];
}


- (void)sendCurComment:(Tweet *)commentObj{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Tweet_DoComment_WithObj:commentObj andBlock:^(id data, NSError *error) {
        if (data) {
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

@end
