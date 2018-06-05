//
//  TeamMembersViewController.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TeamMembersViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "TeamMemberCell.h"
#import "UserInfoViewController.h"
#import "ValueListViewController.h"
#import "EditMemberTypeProjectListViewController.h"
#import <SDCAlertController.h>
#import <SDCAlertView.h>
#import <UIView+SDCAutoLayout.h>
#import "ProjectDeleteAlertControllerVisualStyle.h"

#import "Ease_2FA.h"


@interface TeamMembersViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UISearchDisplayDelegate, SWTableViewCellDelegate, UITextFieldDelegate>
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UISearchDisplayController *mySearchDisplayController;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *myMemberArray;

@property (strong, nonatomic) NSNumber *selfRoleType;
@property (strong, nonatomic) SDCAlertController *alert;

@end

@implementation TeamMembersViewController

- (void)setMyMemberArray:(NSMutableArray *)myMemberArray{
    _myMemberArray = myMemberArray;
    for (TeamMember *mem in _myMemberArray) {
        if ([mem.user_id isEqualToNumber:[Login curLoginUser].id]) {
            _selfRoleType = mem.role;
            break;
        }
    }
    if (!_selfRoleType) {
        _selfRoleType = @80;//普通成员
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"成员管理";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TeamMemberCell class] forCellReuseIdentifier:kCellIdentifier_TeamMemberCell];
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
        [searchBar setPlaceholder:@"昵称/用户名"];
        searchBar;
    });
    _myTableView.tableHeaderView = _mySearchBar;
    _mySearchDisplayController = ({
        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
        [searchVC.searchResultsTableView registerClass:[TeamMemberCell class] forCellReuseIdentifier:kCellIdentifier_TeamMemberCell];
        searchVC.delegate = self;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
        searchVC.displaysSearchBarInNavigationBar = NO;
        searchVC;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)refresh{
    if (_myMemberArray.count <= 0) {
        [self.view beginLoading];
    }
    ESWeak(self, weakSelf);
    [[Coding_NetAPIManager sharedManager] request_MembersInTeam:_curTeam andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.myMemberArray = data;
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.myTableView configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.myMemberArray.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return [_searchResults count];
    }else{
        return _myMemberArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TeamMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TeamMemberCell forIndexPath:indexPath];
    TeamMember *curMember;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        curMember = [_searchResults objectAtIndex:indexPath.row];
    }else{
        curMember = [_myMemberArray objectAtIndex:indexPath.row];
    }
    cell.curMember = curMember;
    [cell setRightUtilityButtons:[self rightButtonsWithObj:curMember] WithButtonWidth:[TeamMemberCell cellHeight]];//编辑按钮
    cell.delegate = self;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [TeamMemberCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TeamMember *member;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        member = [_searchResults objectAtIndex:indexPath.row];
    }else{
        member = [_myMemberArray objectAtIndex:indexPath.row];
    }
    UserInfoDetailViewController *vc = [UserInfoDetailViewController new];
    vc.curUser = member.user;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SWTableViewCellDelegate
- (NSArray *)rightButtonsWithObj:(TeamMember *)mem{
    if (_selfRoleType.integerValue < 90) {
        return nil;
    }
    NSMutableArray *rightUtilityButtons = @[].mutableCopy;
    if (_selfRoleType.integerValue >= 100 && mem.role.integerValue <= 90) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xD8DDE4"] icon:[UIImage imageNamed:@"team_cell_edit_team"]];
    }
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xF2F4F6"] icon:[UIImage imageNamed:@"team_cell_edit_pro"]];
    if (_selfRoleType.integerValue > mem.role.integerValue) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xF56061"] icon:[UIImage imageNamed:@"team_cell_edit_delete"]];
    }
    return rightUtilityButtons;
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    TeamMember *mem = [(TeamMemberCell *)cell curMember];
    if (_selfRoleType.integerValue >= 100 && mem.role.integerValue <= 90) {
        if (index == 0) {
            [self editTeamTypeOfMember:mem];
        }else if (index == 1){
            [self editProTypeOfMember:mem];
        }else{
            [self removeMember:mem];
        }
    }else{
        if (index == 0) {
            [self editProTypeOfMember:mem];
        }else{
            [self removeMember:mem];
        }
    }
}

- (void)editTeamTypeOfMember:(TeamMember *)curMember{
    __weak typeof(self) weakSelf = self;
    __weak typeof(curMember) weakMember = curMember;
    ValueListViewController *vc = [ValueListViewController new];
    NSMutableArray *valueList = @[@"管理员", @"普通成员"].mutableCopy;
    NSArray *typeRawList = @[@90, @80];
    [vc setTitle:@"设置企业角色" valueList:valueList defaultSelectIndex:[typeRawList indexOfObject:curMember.editRole] type:ValueListTypeTeamMemberType selectBlock:^(NSInteger index) {
        weakMember.editRole = typeRawList[index];
        if (![weakMember.role isEqualToNumber:weakMember.editRole]) {
            [[Coding_NetAPIManager sharedManager] request_EditTeamTypeOfMember:weakMember andBlock:^(id data, NSError *error) {
                if (data) {
                    weakMember.role = weakMember.editRole;
                    [weakSelf.myTableView reloadData];
                    [weakSelf.mySearchDisplayController.searchResultsTableView reloadData];
                }
            }];
        }
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editProTypeOfMember:(TeamMember *)curMember{
    EditMemberTypeProjectListViewController *vc = [EditMemberTypeProjectListViewController new];
    vc.curTeam = _curTeam;
    vc.curMember = curMember;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)removeMember:(TeamMember *)curMember{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_VerifyTypeWithBlock:^(VerifyType type, NSError *error) {
        if (!error) {
            [weakSelf showDeleteAlertWithType:type toDeleteMember:curMember];
        }
    }];
    //    __weak typeof(self) weakSelf = self;
    //    [[Coding_NetAPIManager sharedManager] request_TeamMember_Quit:curMember andBlock:^(id data, NSError *error) {
    //        if (data) {
    //            [weakSelf.myMemberArray removeObject:data];
    //            if (weakSelf.searchResults) {
    //                [weakSelf.searchResults removeObject:data];
    //            }
    //            [weakSelf.myTableView reloadData];
    //            [weakSelf.mySearchDisplayController.searchResultsTableView reloadData];
    //        }
    //    }];
}

- (void)showDeleteAlertWithType:(VerifyType)type toDeleteMember:(TeamMember *)curMember{
    if (self.alert) {//正在显示
        return;
    }
    NSString *title, *message, *placeHolder;
    if (type == VerifyTypePassword) {
        title = @"需要密码验证";
        message = @"这是一个危险操作，需要进行身份验证";
        placeHolder = @"请输入密码";
    }else if (type == VerifyTypeTotp){
        title = @"需要动态验证码";
        message = @"这是一个危险操作，需要进行身份验证";
        placeHolder = @"请输入动态验证码";
    }else{//不知道啥类型，不处理
        return;
    }
    
    _alert = [SDCAlertController alertControllerWithTitle:title message:message preferredStyle:SDCAlertControllerStyleAlert];
    
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, 240.0, 30.0)];
    passwordTextField.font = [UIFont systemFontOfSize:13];
    passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    passwordTextField.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6].CGColor;
    passwordTextField.layer.borderWidth = 1;
    passwordTextField.secureTextEntry = (type == VerifyTypePassword);
    passwordTextField.backgroundColor = [UIColor whiteColor];
    passwordTextField.placeholder = placeHolder;
    if (type == VerifyTypeTotp) {
        passwordTextField.text = [OTPListViewController otpCodeWithGK:[Login curLoginUser].global_key];
    }
    passwordTextField.delegate = self;
    
    [_alert.contentView addSubview:passwordTextField];
    
    NSDictionary* passwordViews = NSDictionaryOfVariableBindings(passwordTextField);
    
    [_alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[passwordTextField]-(>=14)-|" options:0 metrics:nil views:passwordViews]];
    
    // Style
    _alert.visualStyle = [ProjectDeleteAlertControllerVisualStyle new];
    
    // 添加密码框
    //    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    //        textField.secureTextEntry = YES;
    //    }];
    
    // 添加按钮
    @weakify(self);
    _alert.actionLayout = SDCAlertControllerActionLayoutHorizontal;
    [_alert addAction:[SDCAlertAction actionWithTitle:@"取消" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        @strongify(self);
        self.alert = nil;
    }]];
    [_alert addAction:[SDCAlertAction actionWithTitle:@"确定" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        @strongify(self);
        self.alert = nil;
        NSString *passCode = passwordTextField.text;
        if ([passCode length] > 0) {
            // 删除成员
            [[Coding_NetAPIManager sharedManager] request_DeleteTeamMember:curMember.user.global_key passCode:passCode type:type andBlock:^(id data, NSError *error) {
                @strongify(self);
                if (!error) {
                    [self refresh];
                }
            }];
        }
    }]];
    
    [_alert presentWithCompletion:^{
        [passwordTextField becomeFirstResponder];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UISearchDisplayDelegate M
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    //    if (_type == ProMemTypeProject) {
    //        [tableView setContentInset:UIEdgeInsetsMake(kHigher_iOS_6_1_DIS(44), 0, 0, 0)];
    //    }
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
@end
