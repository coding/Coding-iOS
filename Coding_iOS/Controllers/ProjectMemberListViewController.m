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
#import "SettingTextViewController.h"
#import "ValueListViewController.h"

@interface ProjectMemberListViewController ()<SWTableViewCellDelegate>

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

@property (strong, nonatomic) NSNumber *selfRoleType;
@end

@implementation ProjectMemberListViewController

- (void)setMyMemberArray:(NSMutableArray *)myMemberArray{
    _myMemberArray = myMemberArray;
    ProjectMember *mem = [_myMemberArray firstObject];
    if ([mem.user_id isEqualToNumber:[Login curLoginUser].id]) {
        _selfRoleType = mem.type;
    }else{
        _selfRoleType = @80;//普通成员
    }
}

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
    cell.type = _type;
    cell.curMember = curMember;
    if (_type == ProMemTypeProject) {
        [cell setRightUtilityButtons:[self rightButtonsWithObj:curMember] WithButtonWidth:[MemberCell cellHeight]];//编辑按钮
        cell.delegate = self;
    }else if (_type == ProMemTypeTaskWatchers) {
        [cell.leftBtn setImage:[UIImage imageNamed:[self.curTask hasWatcher:curMember.user]? @"btn_project_added": @"btn_project_add"] forState:UIControlStateNormal];
    }else if (_type == ProMemTypeTopicWatchers){
        [cell.leftBtn setImage:[UIImage imageNamed:[self.curTopic hasWatcher:curMember.user]? @"btn_project_added": @"btn_project_add"] forState:UIControlStateNormal];
    }
    cell.leftBtnClickedBlock = ^(UIButton *sender){
        if (tableView.isEditing) {
            return;
        }
        if (weakSelf.type == ProMemTypeProject) {
            if (curMember.user_id.intValue == [Login curLoginUser].id.intValue) {
                //                自己，退出项目
                UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定退出项目？" buttonTitles:nil destructiveTitle:@"确认退出" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                    if (index == 0) {
                        [weakSelf quitSelf_ProjectMember:curMember];
                    }
                }];
                [actionSheet showInView:weakSelf.view];
            }else{
                //                别人，发起私信
                if (weakSelf.cellBtnBlock) {
                    weakSelf.cellBtnBlock(curMember);
                }
            }
        }else if (weakSelf.type == ProMemTypeTaskWatchers){
            if (weakSelf.curTask.handleType == TaskHandleTypeEdit) {
                [sender startQueryAnimate];
                [[Coding_NetAPIManager sharedManager] request_ChangeWatcher:curMember.user ofTask:weakSelf.curTask andBlock:^(id data, NSError *error) {
                    if (cell.curMember == curMember) {
                        [sender stopQueryAnimate];
                        if (data) {
                            BOOL isAdded = [weakSelf.curTask hasWatcher:curMember.user] != nil;
                            [sender setImage:[UIImage imageNamed:isAdded? @"btn_project_added": @"btn_project_add"] forState:UIControlStateNormal];
                            if (weakSelf.cellBtnBlock) {
                                weakSelf.cellBtnBlock(curMember);
                            }
                        }
                    }
                }];
            }else{
                User *hasWatcher = [weakSelf.curTask hasWatcher:curMember.user];
                if (hasWatcher) {
                    [weakSelf.curTask.watchers removeObject:hasWatcher];
                }else{
                    [weakSelf.curTask.watchers addObject:curMember.user];
                }
                [sender setImage:[UIImage imageNamed:!hasWatcher? @"btn_project_added": @"btn_project_add"] forState:UIControlStateNormal];
                if (weakSelf.cellBtnBlock) {
                    weakSelf.cellBtnBlock(curMember);
                }
            }
        }else if (_type == ProMemTypeTopicWatchers){
            [sender startQueryAnimate];
            [[Coding_NetAPIManager sharedManager] request_ChangeWatcher:curMember.user ofTopic:weakSelf.curTopic andBlock:^(id data, NSError *error) {
                if (cell.curMember == curMember) {
                    [sender stopQueryAnimate];
                    if (data) {
                        BOOL isAdded = [weakSelf.curTopic hasWatcher:curMember.user] != nil;
                        [sender setImage:[UIImage imageNamed:isAdded? @"btn_project_added": @"btn_project_add"] forState:UIControlStateNormal];
                        if (weakSelf.cellBtnBlock) {
                            weakSelf.cellBtnBlock(curMember);
                        }
                    }
                }
            }];
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

#pragma mark - SWTableViewCellDelegate
- (NSArray *)rightButtonsWithObj:(ProjectMember *)mem{
    NSMutableArray *rightUtilityButtons = @[].mutableCopy;
    BOOL canAlias = (_selfRoleType.integerValue >= 90);
    BOOL canDelete = (canAlias && _selfRoleType.integerValue > mem.type.integerValue);
    if (canAlias) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xE5E5E5"] icon:[UIImage imageNamed:@"member_cell_edit_alias"]];
    }
    if (canDelete) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xF0F0F0"] icon:[UIImage imageNamed:@"member_cell_edit_type"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:kColorBrandRed icon:[UIImage imageNamed:@"member_cell_edit_remove"]];
    }
    return rightUtilityButtons;
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    if (state == kCellStateRight) {
        BOOL canAlias = (_selfRoleType.integerValue >= 90);
        return canAlias;
    }
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    ProjectMember *mem = [(MemberCell *)cell curMember];
    if (index == 0) {//修改备注
        [self editAliasOfMember:mem];
    }else if (index == 1){//修改权限
        [self editTypeOfMember:mem];
    }else if (index == 2){//移除成员
        [[UIActionSheet bk_actionSheetCustomWithTitle:@"移除该成员后，他将不再显示在项目中" buttonTitles:nil destructiveTitle:@"确认移除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [self removeMember:mem];
            }
        }] showInView:self.view];
    }
}

- (void)removeMember:(ProjectMember *)curMember{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectMember_Quit:curMember andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.myMemberArray removeObject:data];
            if (weakSelf.searchResults) {
                [weakSelf.searchResults removeObject:data];
            }
            [weakSelf.myTableView reloadData];
            [weakSelf.mySearchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (void)editAliasOfMember:(ProjectMember *)curMember{
    __weak typeof(self) weakSelf = self;
    __weak typeof(curMember) weakMember = curMember;
    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"设置备注" textValue:curMember.editAlias  doneBlock:^(NSString *textValue) {
        weakMember.editAlias = textValue;
        [[Coding_NetAPIManager sharedManager] request_EditAliasOfMember:weakMember inProject:weakSelf.myProject andBlock:^(id data, NSError *error) {
            if (data) {
                weakMember.alias = weakMember.editAlias;
                [weakSelf.myTableView reloadData];
                [weakSelf.mySearchDisplayController.searchResultsTableView reloadData];
            }
        }];
    }];
    vc.placeholderStr = @"备注名";
    [[BaseViewController presentingVC].navigationController pushViewController:vc animated:YES];
}

- (void)editTypeOfMember:(ProjectMember *)curMember{
    if (_myProject.is_public.boolValue) {
        [NSObject showHudTipStr:@"公开项目不开放项目权限"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(curMember) weakMember = curMember;
    ValueListViewController *vc = [ValueListViewController new];
    NSMutableArray *valueList = @[@"受限成员", @"项目成员"].mutableCopy;
    if (_selfRoleType.integerValue == 100) {
        [valueList addObject:@"项目管理员"];
    }
    NSArray *typeRawList = @[@75, @80, @90, @100];
    
    [vc setTitle:@"设置成员权限" valueList:valueList defaultSelectIndex:[typeRawList indexOfObject:curMember.editType] type:ValueListTypeProjectMemberType selectBlock:^(NSInteger index) {
        weakMember.editType = typeRawList[index];
        if (![weakMember.type isEqualToNumber:weakMember.editType]) {
            [[Coding_NetAPIManager sharedManager] request_EditTypeOfMember:weakMember inProject:weakSelf.myProject andBlock:^(id data, NSError *error) {
                if (data) {
                    weakMember.type = weakMember.editType;
                    [weakSelf.myTableView reloadData];
                    [weakSelf.mySearchDisplayController.searchResultsTableView reloadData];
                }
            }];
        }
    }];
    [[BaseViewController presentingVC].navigationController pushViewController:vc animated:YES];
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
        //        pinyin
        lhs = [NSExpression expressionForKeyPath:@"user.pinyinName"];
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
