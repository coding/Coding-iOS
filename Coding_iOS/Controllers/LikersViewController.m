//
//  LikersViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-4.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "LikersViewController.h"
#import "ODRefreshControl.h"
#import "User.h"
#import "Coding_NetAPIManager.h"
#import "UserCell.h"
#import "ConversationViewController.h"
#import "UserInfoViewController.h"


@interface LikersViewController ()
@property (strong, nonatomic) NSArray *like_reward_users;

@property (strong, nonatomic) UITableView *myTableView;

@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSMutableArray *searchResults;

@end

@implementation LikersViewController

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
    self.title = @"赞赏的人";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        [tableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier_UserCell];
        tableView.delegate = self;
        tableView.dataSource = self;
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
    
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh{
    if (_curTweet.isLoading) {
        return;
    }
    if (_like_reward_users.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Tweet_LikesAndRewards_WithObj:_curTweet andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if ([data isKindOfClass:[NSDictionary class]]) {
            [weakSelf refreshWithData:data];
        }
    }];
}

- (void)refreshWithData:(NSDictionary *)data{
    if (data[@"likeUsers"]) {
        _curTweet.like_users = [NSObject arrayFromJSON:data[@"likeUsers"] ofObjects:@"User"];
    }
    if (data[@"rewardUsers"]) {
        _curTweet.reward_users = [NSObject arrayFromJSON:data[@"rewardUsers"] ofObjects:@"User"];
    }
    _like_reward_users = [_curTweet like_reward_users];
    [self.myTableView reloadData];
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_like_reward_users) {
        return [_like_reward_users count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserCell forIndexPath:indexPath];

    cell.userIconView.layer.borderColor = [UIColor colorWithHexString:@"0xFFAE03"].CGColor;
    
    User *curUser = [_like_reward_users objectAtIndex:indexPath.row];
    cell.curUser = curUser;
    cell.usersType = UsersTypeTweetLikers;
    
    cell.userIconView.layer.borderWidth = [_curTweet rewardedBy:curUser]? 1.0: 0;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UserCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    User *user = [_like_reward_users objectAtIndex:indexPath.row];
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.curUser = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}


@end
