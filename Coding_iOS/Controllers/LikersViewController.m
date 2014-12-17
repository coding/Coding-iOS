//
//  LikersViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-4.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_UserCell @"UserCell"


#import "LikersViewController.h"
#import "ODRefreshControl.h"
#import "User.h"
#import "Coding_NetAPIManager.h"
#import "UserCell.h"
#import "ConversationViewController.h"
#import "UserInfoViewController.h"


@interface LikersViewController ()

@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UISearchDisplayController *mySearchDisplayController;
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
    self.title = @"点赞的人";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier_UserCell];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        tableView;
    });
//    _mySearchBar = ({
//        UISearchBar *searchBar = [[UISearchBar alloc] init];
//        searchBar.delegate = self;
//        [searchBar sizeToFit];
//        [searchBar setPlaceholder:@"姓名/个性后缀"];
//        searchBar.backgroundColor = [UIColor colorWithHexString:@"0x28303b"];
//        
//        searchBar;
//    });
//    _myTableView.tableHeaderView = _mySearchBar;
//    _mySearchDisplayController = ({
//        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
//        [searchVC.searchResultsTableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier_UserCell];
//        searchVC.delegate = self;
//        searchVC.searchResultsDataSource = self;
//        searchVC.searchResultsDelegate = self;
//        if (kHigher_iOS_6_1) {
//            searchVC.displaysSearchBarInNavigationBar = NO;
//        }
//        searchVC;
//    });
    
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [self refresh];
}
- (void)refresh{
    if (_curTweet.isLoading) {
        return;
    }
    if (_curTweet.like_users.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [weakSelf.myRefreshControl beginRefreshing];
    [[Coding_NetAPIManager sharedManager] request_Tweet_Likers_WithObj:_curTweet andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.curTweet.like_users = data;
            weakSelf.curTweet.likes = [NSNumber numberWithInteger:weakSelf.curTweet.like_users.count];
            [weakSelf.myTableView reloadData];
        }
    }];
}
#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return [_searchResults count];
    }else{
        if (_curTweet.like_users) {
            return [_curTweet.like_users count];
        }else{
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserCell];
    if (cell == nil) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier_UserCell];
    }
    User *curUser;
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        curUser = [_searchResults objectAtIndex:indexPath.row];
    }else{
        curUser = [_curTweet.like_users objectAtIndex:indexPath.row];
    }
    cell.curUser = curUser;
    cell.usersType = UsersTypeTweetLikers;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
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
        user = [_curTweet.like_users objectAtIndex:indexPath.row];
    }
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.curUser = user;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UISearchDisplayDelegate M
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateFilteredContentForSearchString:searchString];
    return YES;
}
- (void)updateFilteredContentForSearchString:(NSString *)searchString{
    DebugLog(@"\n%@", searchString);
    // start out with the entire list
    self.searchResults = [self.curTweet.like_users mutableCopy];
    
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
