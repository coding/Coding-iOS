//
//  ProjectMemberListViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectMemberListViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "MemberCell.h"
#import "ConversationViewController.h"

@interface ProjectMemberListViewController ()

@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UISearchDisplayController *mySearchDisplayController;
@property (strong, nonatomic) UITableView *myTableView;

@property (assign, nonatomic) CGRect viewFrame;
@property (strong, nonatomic) Project *myProject;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (copy, nonatomic) ProjectMemberListBlock refreshBlock;
@property (copy, nonatomic) ProjectMemberBlock selectBlock;
@property (copy, nonatomic) ProjectMemberCellBtnBlock cellBtnBlock;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (assign, nonatomic) ProMemType type;
@end

@implementation ProjectMemberListViewController

- (void)willHiden{
    [self.mySearchBar resignFirstResponder];
}

- (void)loadView{
    [super loadView];
    self.title = @"项目成员";
    _viewFrame.origin.y = 0.0;
    self.view = [[UIView alloc] initWithFrame:_viewFrame];
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[MemberCell class] forCellReuseIdentifier:kCellIdentifier_MemberCell];
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
        [searchVC.searchResultsTableView registerClass:[MemberCell class] forCellReuseIdentifier:kCellIdentifier_MemberCell];
        searchVC.delegate = self;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
        if (kHigher_iOS_6_1) {
            searchVC.displaysSearchBarInNavigationBar = NO;
        }
        searchVC;
    });
    if (self.type == ProMemTypeAT) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
    }
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    if (_type == ProMemTypeAT) {
        __weak typeof(self) weakSelf = self;
        //首先尝试加载本地数据，无数据的情况下才去服务器请求
        id resultData = [NSObject loadResponseWithPath:[_myProject localMembersPath]];
        resultData = [resultData objectForKey:@"list"];

        if (resultData) {
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectMember"];
            __block NSUInteger mineIndex = 0;
            [resultA enumerateObjectsUsingBlock:^(ProjectMember *obj, NSUInteger idx, BOOL *stop) {
                if (obj.user_id.integerValue == [Login curLoginUser].id.integerValue) {
                    mineIndex = idx;
                    *stop = YES;
                }
            }];
            if (mineIndex > 0) {
                [resultA exchangeObjectAtIndex:mineIndex withObjectAtIndex:0];
            }
            weakSelf.myMemberArray = resultA;
            [weakSelf.myTableView reloadData];
        }else{
            [self refreshFirst];
        }
    }else{
        [self refreshFirst];
    }
}
- (void)refreshMembersData{
    [self performSelector:@selector(refresh) withObject:nil afterDelay:0.3];
}

- (void)setFrame:(CGRect)frame project:(Project *)project type:(ProMemType)type refreshBlock:(ProjectMemberListBlock)refreshBlock selectBlock:(ProjectMemberBlock)selectBlock cellBtnBlock:(ProjectMemberCellBtnBlock)cellBtnBlock{
    _viewFrame = frame;
    _myProject = project;
    _refreshBlock = refreshBlock;
    _selectBlock = selectBlock;
    _cellBtnBlock = cellBtnBlock;
    _type = type;
    _myMemberArray = nil;
}

- (void)refresh{
    if (_myProject.isLoadingMember) {
        return;
    }
    if (!_myMemberArray || _myMemberArray.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;

    [[Coding_NetAPIManager sharedManager] request_ProjectMembers_WithObj:_myProject andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.view endLoading];
        if (data) {
            weakSelf.myMemberArray = data;
            [weakSelf.myTableView reloadData];
            if (weakSelf.refreshBlock) {
                weakSelf.refreshBlock(data);
            }
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.myMemberArray.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}
- (void)refreshFirst{
    if (!_myMemberArray) {
        [self performSelector:@selector(refresh) withObject:nil afterDelay:0.3];
    }
}
#pragma AT Member
+ (void)showATSomeoneWithBlock:(void(^)(User *curUser))block withProject:(Project *)project{
    ProjectMemberListViewController *vc = [[ProjectMemberListViewController alloc] init];
    [vc setFrame:[UIView frameWithOutNav] project:project type:ProMemTypeAT refreshBlock:nil selectBlock:nil cellBtnBlock:nil];
    vc.selectUserBlock = block;
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [[BaseViewController presentingVC] presentViewController:nav animated:YES completion:nil];
}

- (void)dismissSelf{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.selectUserBlock) {
            weakSelf.selectUserBlock(nil);
        }
    }];
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return [_searchResults count];
    }else{
        if (_myMemberArray) {
            return [_myMemberArray count];
        }else{
            return 0;
        }
    }
}

- (void)quitSelf_ProjectMember:(ProjectMember *)curMember{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectMember_Quit:curMember andBlock:^(id data, NSError *error) {
        if (data) {
            if (weakSelf.type == ProMemTypeProject) {
                if (weakSelf.cellBtnBlock) {
                    weakSelf.cellBtnBlock(curMember);
                }
            }
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MemberCell forIndexPath:indexPath];
    ProjectMember *curMember;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        curMember = [_searchResults objectAtIndex:indexPath.row];
    }else{
        curMember = [_myMemberArray objectAtIndex:indexPath.row];
    }
    __weak typeof(self) weakSelf = self;
    cell.curMember = curMember;
    cell.type = _type;
    cell.leftBtnClickedBlock = ^(id sender){
        if (tableView.isEditing) {
            return;
        }
        if (curMember.user_id.intValue == [Login curLoginUser].id.intValue) {
//                自己，退出项目
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定退出项目？" buttonTitles:nil destructiveTitle:@"确认退出" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakSelf quitSelf_ProjectMember:curMember];
                }
            }];
            [actionSheet showInView:self.view];
        }else{
//                别人，发起私信
            if (_type == ProMemTypeProject) {
                if (self.cellBtnBlock) {
                    self.cellBtnBlock(curMember);
                }
            }else if (_type == ProMemTypeTaskOwner){
                ConversationViewController *vc = [[ConversationViewController alloc] init];
                vc.myPriMsgs = [PrivateMessages priMsgsWithUser:curMember.user];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    };

    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MemberCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    ProjectMember *member;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        member = [_searchResults objectAtIndex:indexPath.row];
    }else{
        member = [_myMemberArray objectAtIndex:indexPath.row];
    }
    if (_type == ProMemTypeAT) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.selectUserBlock) {
                weakSelf.selectUserBlock(member.user);
            }
        }];
    }else{
        if (_selectBlock) {
            _selectBlock(member);
        }
        if (_type == ProMemTypeTaskOwner) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
//-----------------------------------Editing
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"移除成员";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL canEdit = NO;
    if (self.type == ProMemTypeProject && [Login isLoginUserGlobalKey:self.myProject.owner_user_name]) {
        ProjectMember *curMember;
        if (tableView == _mySearchDisplayController.searchResultsTableView) {
            curMember = [_searchResults objectAtIndex:indexPath.row];
        }else{
            curMember = [_myMemberArray objectAtIndex:indexPath.row];
        }
        canEdit = (curMember.user_id.intValue != [Login curLoginUser].id.intValue);
    }
    return canEdit;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView setEditing:NO animated:YES];

    ProjectMember *curMember;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        curMember = [_searchResults objectAtIndex:indexPath.row];
    }else{
        curMember = [_myMemberArray objectAtIndex:indexPath.row];
    }
    
    __weak typeof(self) weakSelf = self;
    
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"移除该成员后，他将不再显示在项目中" buttonTitles:nil destructiveTitle:@"确认移除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [weakSelf removeMember:curMember inTableView:tableView];
        }
    }];
    [actionSheet showInView:self.view];
}

- (void)removeMember:(ProjectMember *)curMember inTableView:(UITableView *)tableView{
    DebugLog(@"remove - ProjectMember : %@", curMember.user.name);
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectMember_Quit:curMember andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.myMemberArray removeObject:data];
            if (weakSelf.searchResults) {
                [weakSelf.searchResults removeObject:data];
            }
            [tableView reloadData];
        }
    }];
}

#pragma mark UISearchDisplayDelegate M
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    if (_type == ProMemTypeProject) {
        [tableView setContentInset:UIEdgeInsetsMake(kHigher_iOS_6_1_DIS(44), 0, 0, 0)];
    }
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    [self.myTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateFilteredContentForSearchString:searchString];
    return YES;
}
- (void)updateFilteredContentForSearchString:(NSString *)searchString{
    // start out with the entire list
    self.searchResults = [self.myMemberArray mutableCopy];
    
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
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"user.name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
//        global_key field matching
        lhs = [NSExpression expressionForKeyPath:@"user.global_key"];
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
