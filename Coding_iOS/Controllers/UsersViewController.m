//
//  UsersViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UsersViewController.h"
#import "ODRefreshControl.h"
#import "User.h"
#import "Coding_NetAPIManager.h"
#import "UserCell.h"
#import "ConversationViewController.h"
#import "UserInfoViewController.h"
#import "SVPullToRefresh.h"
#import "AddUserViewController.h"

@interface UsersViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UISearchDisplayDelegate>
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UISearchDisplayController *mySearchDisplayController;
@property (strong, nonatomic) UITableView *myTableView;

@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSMutableArray *searchResults;

@property (strong, nonatomic) NSDictionary *groupedDict;
@end

@implementation UsersViewController
+ (void)showATSomeoneWithBlock:(void(^)(User *curUser))block{
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.curUsers = [Users usersWithOwner:[Login curLoginUser] Type:UsersTypeFriends_At];
    vc.selectUserBlock = block;
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [[BaseViewController presentingVC] presentViewController:nav animated:YES completion:nil];
}
+ (void)showTranspondMessage:(PrivateMessage *)curMessage withBlock:(void(^)(PrivateMessage *curMessage))block{
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.curUsers = [Users usersWithOwner:[Login curLoginUser] Type:UsersTypeFriends_Transpond];
    vc.curMessage = curMessage;
    vc.transpondMessageBlock = block;
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [[BaseViewController presentingVC] presentViewController:nav animated:YES completion:nil];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    BOOL isMe = [_curUsers.owner.global_key isEqualToString:[Login curLoginUser].global_key];

    
    switch (_curUsers.type) {
        case UsersTypeFollowers:
            self.title = isMe? @"关注我的人": [NSString stringWithFormat:@"%@的粉丝", _curUsers.owner.name];
            break;
        case UsersTypeFriends_Attentive:
            self.title = isMe? @"我关注的人": [NSString stringWithFormat:@"%@关注的人", _curUsers.owner.name];
            break;
        case UsersTypeFriends_Message:
            self.title = @"我的好友";
            break;
        case UsersTypeFriends_At:
        case UsersTypeFriends_Transpond:{
            self.title = @"我的好友";
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
        }
            break;
        case UsersTypeProjectStar:
            self.title = @"收藏项目的人";
            break;
        case UsersTypeProjectWatch:
            self.title = @"关注项目的人";
            break;
        default:
            break;
    }

    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier_UserCell];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = kColor666;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _mySearchBar = ({
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        [searchBar sizeToFit];
        [searchBar setPlaceholder:@"昵称/个性后缀"];
        searchBar;
    });
    _myTableView.tableHeaderView = _mySearchBar;
    _mySearchDisplayController = ({
        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
        [searchVC.searchResultsTableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier_UserCell];
        searchVC.delegate = self;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
        if (kHigher_iOS_6_1) {
            searchVC.displaysSearchBarInNavigationBar = NO;
        }
        searchVC;
    });
    
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
    if (_curUsers.type == UsersTypeFriends_At || _curUsers.type == UsersTypeFriends_Transpond) {
        //首先尝试加载本地数据，无数据的情况下才去服务器请求
        id resultData = [NSObject loadResponseWithPath:[[Login curLoginUser] localFriendsPath]];
        if (resultData) {
            Users *users = [NSObject objectOfClass:@"Users" fromJSON:resultData];
            [self.curUsers configWithObj:users];
            self.groupedDict = [weakSelf.curUsers dictGroupedByPinyin];
            [self.myTableView reloadData];
            self.myTableView.showsInfiniteScrolling = weakSelf.curUsers.canLoadMore;
        }else{
            [self refresh];
        }
    }else{
        [self refresh];
    }
}

- (void)dismissSelf{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.selectUserBlock) {
            weakSelf.selectUserBlock(nil);
        }
    }];
}

- (void)refresh{
    if (_curUsers.isLoading) {
        return;
    }
    _curUsers.willLoadMore = NO;
    if (_curUsers.list.count <= 0) {
        [self.view beginLoading];
    }
    [self sendRequest];
}
- (void)refreshMore{
    if (_curUsers.isLoading || !_curUsers.canLoadMore) {
        return;
    }
    _curUsers.willLoadMore = YES;
    [self sendRequest];
}
- (void)sendRequest{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_FollowersOrFriends_WithObj:self.curUsers andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.view endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.curUsers configWithObj:data];
            weakSelf.groupedDict = [weakSelf.curUsers dictGroupedByPinyin];
            
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.curUsers.canLoadMore;
        }
    }];
}
#pragma mark Table M
- (NSArray *)groupedKeyList{
    if (self.groupedDict.count <= 0) {
        return nil;
    }
    NSMutableArray *keyList = [NSMutableArray arrayWithArray:self.groupedDict.allKeys];
    [keyList sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    if ([keyList containsObject:@"#"]) {
        [keyList removeObject:@"#"];
        [keyList addObject:@"#"];
    }
    [keyList insertObject:UITableViewIndexSearch atIndex:0];
    return keyList;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index == 0) {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    return index;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return nil;
    }else{
        return [self groupedKeyList];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return nil;
    }else{
        if ([self groupedKeyList].count > section && section > 0) {
            return [[self groupedKeyList] objectAtIndex:section];
        }else{
            return nil;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return 0;
    }else{
        if (section == 0) {
            return 0;
        }
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    if (height <= 0) {
        return nil;
    }
    
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, height)];
    headerV.backgroundColor = kColorTableSectionBg;
    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.font = [UIFont systemFontOfSize:12];
    titleL.textColor = kColor999;
    titleL.text = [self tableView:tableView titleForHeaderInSection:section];
    [headerV addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headerV).insets(UIEdgeInsetsMake(4, kPaddingLeftWidth, 4, kPaddingLeftWidth));
    }];
    return headerV;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger section;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        section = 1;
    }else{
        if (self.groupedDict) {
            section = [[self groupedKeyList] count];
        }else{
            section = 1;
        }
    }
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        row = [_searchResults count];
    }else{
        if ([self groupedKeyList] && [[self groupedKeyList] count] > section) {
            if (section == 0 && _curUsers.type == UsersTypeFriends_Message) {
                return 1;
            }
            NSArray *dataList = [self.groupedDict objectForKey:[[self groupedKeyList] objectAtIndex:section]];
            row = [dataList count];
        }else{
            row = 0;
        }
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserCell forIndexPath:indexPath];
    User *curUser;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        curUser = [_searchResults objectAtIndex:indexPath.row];
    }else{
        if (indexPath.section == 0 && _curUsers.type == UsersTypeFriends_Message) {
            curUser = nil;
        }
        NSArray *dataList = [self.groupedDict objectForKey:[[self groupedKeyList] objectAtIndex:indexPath.section]];
        curUser = [dataList objectAtIndex:indexPath.row];
    }
    cell.curUser = curUser;
    cell.usersType = _curUsers.type;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:66 hasSectionLine:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UserCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    User *user;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        user = [_searchResults objectAtIndex:indexPath.row];
    }else{
        NSArray *dataList = [self.groupedDict objectForKey:[[self groupedKeyList] objectAtIndex:indexPath.section]];
        user = [dataList objectAtIndex:indexPath.row];
    }
    __weak typeof(self) weakSelf = self;
    if (_curUsers.type == UsersTypeFriends_Message) {
        if (user) {
            ConversationViewController *vc = [[ConversationViewController alloc] init];
            vc.myPriMsgs = [PrivateMessages priMsgsWithUser:user];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            AddUserViewController *vc = [[AddUserViewController alloc] init];
            vc.type = AddUserTypeFollow;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (_curUsers.type == UsersTypeFriends_At){
        [self dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.selectUserBlock) {
                weakSelf.selectUserBlock(user);
            }
        }];
    }else if (_curUsers.type == UsersTypeFriends_Transpond){
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"确定发送给：" message:user.name];
        [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertView bk_addButtonWithTitle:@"确定" handler:nil];
        [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
            switch (index) {
                case 1:
                {
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        if (weakSelf.transpondMessageBlock) {
                            PrivateMessage *nextMsg = [PrivateMessage privateMessageWithObj:weakSelf.curMessage andFriend:user];
                            weakSelf.transpondMessageBlock(nextMsg);
                        }
                    }];
                }
                    break;
                default:
                    break;
            }
        }];
        [alertView show];
    }else{
        UserInfoViewController *vc = [[UserInfoViewController alloc] init];
        vc.curUser = user;
        vc.followChanged = ^(User *curUser){
            user.followed = curUser.followed;
            [weakSelf.myTableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [searchBar insertBGColor:kColorNavBG];
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [searchBar insertBGColor:nil];
    return YES;
}

#pragma mark UISearchDisplayDelegate M
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateFilteredContentForSearchString:searchString];
    return YES;
}
- (void)updateFilteredContentForSearchString:(NSString *)searchString{
    // start out with the entire list
    self.searchResults = [self.curUsers.list mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedStr = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedStr.length > 0)
    {
        searchItems = [strippedStr componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems)
    {
        // each searchString creates an OR predicate for: name, global_key
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        //        pinyinName field matching
        lhs = [NSExpression expressionForKeyPath:@"pinyinName"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        //        global_key field matching
        lhs = [NSExpression expressionForKeyPath:@"global_key"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        // at this OR predicate to ourr master AND predicate
        NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    NSCompoundPredicate *finalCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    
    self.searchResults = [[self.searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
