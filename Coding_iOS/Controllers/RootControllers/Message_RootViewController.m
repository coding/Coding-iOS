//
//  Message_RootViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Message_RootViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "PrivateMessages.h"
#import "ConversationCell.h"
#import "ConversationViewController.h"
#import "ToMessageCell.h"
#import "TipsViewController.h"
#import "UsersViewController.h"
#import "UnReadManager.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "SVPullToRefresh.h"

@interface Message_RootViewController ()
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (strong, nonatomic) PrivateMessages *myPriMsgs;
@property (strong, nonatomic) NSMutableDictionary *notificationDict;
@end

@implementation Message_RootViewController

#pragma mark TabBar
- (void)tabBarItemClicked{
    [super tabBarItemClicked];
    if (_myTableView.contentOffset.y > 0) {
        [_myTableView setContentOffset:CGPointZero animated:YES];
    }else if (!self.refreshControl.isAnimating){
        [self.refreshControl beginRefreshing];
        [self.myTableView setContentOffset:CGPointMake(0, -44)];
        [self refresh];
    }
}

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
    self.title = @"消息";
    _myPriMsgs = [[PrivateMessages alloc] init];

    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tweetBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(sendMsgBtnClicked:)] animated:NO];
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ConversationCell class] forCellReuseIdentifier:kCellIdentifier_Conversation];
        [tableView registerClass:[ToMessageCell class] forCellReuseIdentifier:kCellIdentifier_ToMessage];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        {
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
            tableView.contentInset = insets;
            tableView.scrollIndicatorInsets = insets;
        }
        tableView;
    });
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
    
    [self.refreshControl beginRefreshing];
    [self.myTableView setContentOffset:CGPointMake(0, -44)];
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

- (void)sendMsgBtnClicked:(id)sender{
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.curUsers = [Users usersWithOwner:[Login curLoginUser] Type:UsersTypeFriends_Message];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)refresh{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_UnReadNotificationsWithBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.notificationDict = [NSMutableDictionary dictionaryWithDictionary:data];
            [weakSelf.myTableView reloadData];
        }
    }];
    [[UnReadManager shareManager] updateUnRead];
    
    if (_myPriMsgs.isLoading) {
        return;
    }
    _myPriMsgs.willLoadMore = NO;
    [self sendRequest_PrivateMessages];
}

- (void)refreshMore{
    if (_myPriMsgs.isLoading || !_myPriMsgs.canLoadMore) {
        return;
    }
    _myPriMsgs.willLoadMore = YES;
    [self sendRequest_PrivateMessages];
}

- (void)sendRequest_PrivateMessages{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_PrivateMessages:_myPriMsgs andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myPriMsgs configWithObj:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myPriMsgs.canLoadMore;
        }
    }];
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 3;
    if (_myPriMsgs.list) {
        row += [_myPriMsgs.list count];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 3) {
        ToMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ToMessage forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                cell.type = ToMessageTypeAT;
                cell.unreadCount = [_notificationDict objectForKey:kUnReadKey_notification_AT];
                break;
            case 1:
                cell.type = ToMessageTypeComment;
                cell.unreadCount = [_notificationDict objectForKey:kUnReadKey_notification_Comment];
                break;
            default:
                cell.type = ToMessageTypeSystemNotification;
                cell.unreadCount = [_notificationDict objectForKey:kUnReadKey_notification_System];
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:75 hasSectionLine:NO];
        return cell;
    }else{
        ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Conversation forIndexPath:indexPath];
        PrivateMessage *msg = [_myPriMsgs.list objectAtIndex:indexPath.row-3];
        cell.curPriMsg = msg;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:75 hasSectionLine:NO];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight;
    if (indexPath.row < 3) {
        cellHeight = [ToMessageCell cellHeight];
    }else{
        cellHeight = [ConversationCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < 3) {
        TipsViewController *vc = [[TipsViewController alloc] init];
        vc.myCodingTips = [CodingTips codingTipsWithType:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        PrivateMessage *curMsg = [_myPriMsgs.list objectAtIndex:indexPath.row-3];
        ConversationViewController *vc = [[ConversationViewController alloc] init];
        User *curFriend = curMsg.friend;
        
        vc.myPriMsgs = [PrivateMessages priMsgsWithUser:curFriend];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//-----------------------------------Editing
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除会话";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row >= 3);
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView setEditing:NO animated:YES];
    PrivateMessage *msg = [_myPriMsgs.list objectAtIndex:indexPath.row-3];
    
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:[NSString stringWithFormat:@"这将删除你和 %@ 的所有私信", msg.friend.name] buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [weakSelf removeConversation:msg inTableView:tableView];
        }
    }];
    [actionSheet showInView:self.view];
}

- (void)removeConversation:(PrivateMessage *)curMsg inTableView:(UITableView *)tableView{
    DebugLog(@"removeConversationWithFriend : %@", curMsg.friend.name);
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeletePrivateMessagesWithObj:curMsg andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.myPriMsgs.list removeObject:data];
            [weakSelf.myTableView reloadData];
        }
    }];
}
@end
