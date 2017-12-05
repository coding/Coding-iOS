//
//  AddUserViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-15.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#import "AddUserViewController.h"
#import "UserCell.h"
#import "UserInfoViewController.h"
#import "Coding_NetAPIManager.h"
#import "ToMessageCell.h"
#import "ODRefreshControl.h"


@interface AddUserViewController ()
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) Users *curUsers;
@end

@implementation AddUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.type < AddUserTypeFollow) {
        self.title = (self.type == AddUserTypeProjectRoot? @"添加成员":
                      self.type == AddUserTypeProjectFollows? @"我的关注":
                      @"我的粉丝");
        _queryingArray = [NSMutableArray array];
        _searchedArray = [NSMutableArray array];
    }else if (self.type == AddUserTypeFollow){
        self.title = @"添加好友";
    }
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier_UserCell];
        [tableView registerClass:[ToMessageCell class] forCellReuseIdentifier:kCellIdentifier_ToMessage];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
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
    if (self.type == AddUserTypeProjectFollows || self.type == AddUserTypeProjectFans) {
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        _curUsers = [Users usersWithOwner:[Login curLoginUser] Type:self.type == AddUserTypeProjectFollows? UsersTypeFriends_Attentive: UsersTypeFollowers];
        [self refresh];
    }
}

- (void)refresh{
    if (_curUsers.isLoading) {
        return;
    }
    _curUsers.willLoadMore = NO;
    if (_curUsers.list.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_FollowersOrFriends_WithObj:self.curUsers andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.view endLoading];
        if (data) {
            [weakSelf.curUsers configWithObj:data];
            [weakSelf searchUserWithStr:weakSelf.mySearchBar.text];
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.popSelfBlock) {
        self.popSelfBlock();
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_mySearchBar) {
        [self searchUserWithStr:_mySearchBar.text];
    }
}

- (void)configAddedArrayWithMembers:(NSArray *)memberArray{
    if (!_addedArray) {
        _addedArray = [NSMutableArray array];
    }
    for (ProjectMember *member in memberArray) {
        [_addedArray addObject:member.user];
    }
}
- (BOOL)userIsInProject:(User *)curUser{
    for (User *item in _addedArray) {
        if ([item.global_key isEqualToString:curUser.global_key]) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)userIsQuering:(User *)curUser{
    for (User *item in _queryingArray) {
        if ([item.global_key isEqualToString:curUser.global_key]) {
            return YES;
        }
    }
    return NO;
}
#pragma mark Table M
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return _type == AddUserTypeFollow? 0: 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_type == AddUserTypeFollow) {
        return [UIView new];
    }else{
        NSInteger leftNum = _curProject.max_member.integerValue - _addedArray.count;
        UILabel *label = [UILabel labelWithSystemFontSize:13 textColorHexString:leftNum > 0? @"0x999999": @"0xF34A4A"];
        label.backgroundColor = self.view.backgroundColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = leftNum > 0? [NSString stringWithFormat:@"你还可以添加 %lu 个项目成员", leftNum]: @"已达到成员最大数，不能再继续选择成员！";
        return label;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.type == AddUserTypeProjectRoot && _searchedArray.count == 0) {
        return 2;
    }else{
        return _searchedArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type == AddUserTypeProjectRoot && _searchedArray.count == 0) {
        ToMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ToMessage forIndexPath:indexPath];
        cell.type = ToMessageTypeProjectFollows + indexPath.row;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        __weak typeof(self) weakSelf = self;
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserCell forIndexPath:indexPath];
        User *curUser = [_searchedArray objectAtIndex:indexPath.row];
        cell.curUser = curUser;
        if (self.type < AddUserTypeFollow) {
            cell.usersType = UsersTypeAddToProject;
            cell.isInProject = [self userIsInProject:curUser];
            cell.isQuerying = [self userIsQuering:curUser];
            cell.leftBtnClickedBlock = ^(User *clickedUser){
                NSLog(@"add %@ to pro:%@", clickedUser.name, weakSelf.curProject.name);
                if (![weakSelf userIsQuering:clickedUser]) {
                    //            添加改用户到项目
                    [weakSelf.queryingArray addObject:clickedUser];
                    [weakSelf.myTableView reloadData];
                    
                    [[Coding_NetAPIManager sharedManager] request_AddUser:clickedUser ToProject:weakSelf.curProject andBlock:^(id data, NSError *error) {
                        if (data) {
                            [weakSelf.addedArray addObject:clickedUser];
                        }
                        [weakSelf.queryingArray removeObject:clickedUser];
                        [weakSelf.myTableView reloadData];
                    }];
                }
            };
        }else{
            cell.usersType = UsersTypeAddFriend;
            cell.leftBtnClickedBlock = nil;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type == AddUserTypeProjectRoot && _searchedArray.count == 0) {
        return [ToMessageCell cellHeight];
    }else{
        return [UserCell cellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.type == AddUserTypeProjectRoot && _searchedArray.count == 0) {
        AddUserViewController *vc = [AddUserViewController new];
        vc.curProject = _curProject;
        vc.type = AddUserTypeProjectFollows + indexPath.row;
        vc.addedArray = self.addedArray;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self goToUserInfo:[_searchedArray objectAtIndex:indexPath.row]];
    }
}

- (void)goToUserInfo:(User *)user{
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.curUser = user;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.mySearchBar resignFirstResponder];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"textDidChange: %@", searchText);
    [self searchUserWithStr:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked: %@", searchBar.text);
    [searchBar resignFirstResponder];
    [self searchUserWithStr:searchBar.text];
}

- (void)searchUserWithStr:(NSString *)string{
    NSString *strippedStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.type == AddUserTypeProjectRoot || self.type == AddUserTypeFollow) {
        if (strippedStr.length > 0) {
            __weak typeof(self) weakSelf = self;
            [[Coding_NetAPIManager sharedManager] request_Users_WithSearchString:string andBlock:^(id data, NSError *error) {
                if (data) {
                    weakSelf.searchedArray = data;
                    [weakSelf.myTableView reloadData];
                }
            }];
        }else{
            _searchedArray = nil;
            [_myTableView reloadData];
        }
    }else{
        if (strippedStr.length > 0) {
            [self updateFilteredContentForSearchString:strippedStr];
        }else{
            _searchedArray = _curUsers.list.copy;
            [_myTableView reloadData];
        }
    }
}

- (void)updateFilteredContentForSearchString:(NSString *)searchString{
    // start out with the entire list
    NSMutableArray *searchResults = [self.curUsers.list mutableCopy];
    
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
    
    self.searchedArray = [searchResults filteredArrayUsingPredicate:finalCompoundPredicate].copy;
    [self.myTableView reloadData];
}

@end
