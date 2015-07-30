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

@interface CSTopicDetailVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *myTableView;

@property (nonatomic,strong)Tweets *curTweets;

@property (nonatomic,strong)CSTopicHeaderView *tableHeader;
@end

@implementation CSTopicDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupData];
    [self setupUI];
    
    [self.myTableView reloadData];
    [self refreshheader];
    [self sendRequest];
}

- (void)sendRequest{
//    Tweets *curTweets = [self getCurTweets];
//    if (curTweets.list.count <= 0) {
//        [self.view beginLoading];
//    }
    __weak typeof(self) weakSelf = self;
    
    [[Coding_NetAPIManager sharedManager] request_PublicTweetsWithTopic:_topicID andBlock:^(id data, NSError *error) {
        [weakSelf.curTweets configWithTweets:data];
        [weakSelf.myTableView reloadData];
//        [weakSelf.view endLoading];
//        [weakSelf.refreshControl endRefreshing];
//        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
//        if (data) {
//            [curTweets configWithTweets:data];
//            [weakSelf.myTableView reloadData];
//            weakSelf.myTableView.showsInfiniteScrolling = curTweets.canLoadMore;
//        }
//        [weakSelf.view configBlankPage:EaseBlankPageTypeTweet hasData:(curTweets.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
//            [weakSelf sendRequest];
//        }];
    }];
}

- (void)refreshheader {
    [[Coding_NetAPIManager sharedManager]request_TopicDetailsWithTopicID:_topicID block:^(id data, NSError *error) {
        if (data) {
            [self.tableHeader updateWithTopic:data];
        }
        
    }];
}

#pragma mark - table view

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
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [TweetCell cellHeightWithObj:[_curTweets.list objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.row != 0) {
//        Comment *toComment = [_curTweet.comment_list objectAtIndex:indexPath.row-1];
//        [self doCommentToComment:toComment sender:[tableView cellForRowAtIndexPath:indexPath]];
//    }
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
        [self.view addSubview:tableView];
        
        CSTopicHeaderView *header = [[CSTopicHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 191)];
        header.parentVC = self;
//        [header updateWithTopic:self.topic];
        tableView.tableHeaderView = header;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        _tableHeader = header;
        tableView;
    });
}

- (void)setupData {
    _curTweets = [Tweets tweetsWithType:TweetTypePublicTime];
//    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Tweet forIndexPath:indexPath];
}

- (void)sendTweet{
//    __weak typeof(self) weakSelf = self;
    TweetSendViewController *vc = [[TweetSendViewController alloc] init];
    vc.sendNextTweet = ^(Tweet *nextTweet){
        [nextTweet saveSendData];//发送前保存草稿
        [[Coding_NetAPIManager sharedManager] request_Tweet_DoTweet_WithObj:nextTweet andBlock:^(id data, NSError *error) {
            if (data) {
                [Tweet deleteSendData];//发送成功后删除草稿
//                Tweets *curTweets = [weakSelf getCurTweets];
//                if (curTweets.tweetType != TweetTypePublicHot) {
//                    Tweet *resultTweet = (Tweet *)data;
//                    resultTweet.owner = [Login curLoginUser];
//                    if (curTweets.list && [curTweets.list count] > 0) {
//                        [curTweets.list insertObject:data atIndex:0];
//                    }else{
//                        curTweets.list = [NSMutableArray arrayWithObject:resultTweet];
//                    }
//                    [self.myTableView reloadData];
//                }
//                [weakSelf.view configBlankPage:EaseBlankPageTypeTweet hasData:(curTweets.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
//                    [weakSelf sendRequest];
//                }];
            }
            
        }];
        
    };
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self.parentViewController presentViewController:nav animated:YES completion:nil];
}


@end


