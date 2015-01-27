//
//  ProjectListView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectList @"ProjectListCell"
#import "ProjectListView.h"
#import "ProjectListCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"

@interface ProjectListView ()<UISearchBarDelegate>
@property (nonatomic, strong) Projects *myProjects;
@property (nonatomic , copy) ProjectListViewBlock block;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSString *searchString;

@end

@implementation ProjectListView

#pragma TabBar
- (void)tabBarItemClicked{
    if (_myTableView.contentOffset.y > 0) {
        [_myTableView setContentOffset:CGPointZero animated:YES];
    }else if (!self.myRefreshControl.isAnimating){
        [self.myRefreshControl beginRefreshing];
        [self.myTableView setContentOffset:CGPointMake(0, -44)];
        [self refresh];
    }
}

- (id)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(ProjectListViewBlock)block  tabBarHeight:(CGFloat)tabBarHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myProjects = projects;
        _block = block;
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] init];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ProjectListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectList];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            if (tabBarHeight != 0) {
                UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, tabBarHeight, 0);
                tableView.contentInset = insets;
                tableView.scrollIndicatorInsets = insets;
            }
            tableView;
        });
        _mySearchBar = ({
            UISearchBar *searchBar = [[UISearchBar alloc] init];
            searchBar.delegate = self;
            [searchBar sizeToFit];
            [searchBar setPlaceholder:@"项目名称/创建人"];
            searchBar.backgroundColor = [UIColor colorWithHexString:@"0x28303b"];
            searchBar;
        });
        _myTableView.tableHeaderView = _mySearchBar;
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
        if (_myProjects.list.count > 0) {
            [_myTableView reloadData];
        }else{
            [self sendRequest];
        }
    }
    return self;
}
- (void)setProjects:(Projects *)projects{
    self.myProjects = projects;
    [self refreshUI];
}
- (void)refreshUI{
    [_myTableView reloadData];
    [self refreshFirst];
}
- (void)refreshToQueryData{
    [self refresh];
}

- (void)refresh{
    if (_myProjects.isLoading) {
        return;
    }
    [self sendRequest];
}

- (void)refreshFirst{
    if (_myProjects && !_myProjects.list) {
        [self performSelector:@selector(refresh) withObject:nil afterDelay:0.3];
    }
}

- (void)sendRequest{
    if (_myProjects.list.count <= 0) {
        [self beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Projects_WithObj:_myProjects andBlock:^(Projects *data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [self endLoading];
        if (data) {
            [weakSelf.myProjects configWithProjects:data];
            [weakSelf updateFilteredContentForSearchString:weakSelf.searchString];
            [weakSelf.myTableView reloadData];
        }
        [weakSelf configBlankPage:EaseBlankPageTypeProject hasData:(weakSelf.myProjects.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}
#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchResults) {
        return [self.searchResults count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectList forIndexPath:indexPath];
    cell.project = [self.searchResults objectAtIndex:indexPath.row];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectListCell cellHeightWithObj:[self.searchResults objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_block) {
        _block([self.searchResults objectAtIndex:indexPath.row]);
    }
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
    self.searchString = string;
    [self updateFilteredContentForSearchString:string];
    [self.myTableView reloadData];
}

- (void)updateFilteredContentForSearchString:(NSString *)searchString{
    // start out with the entire list
    self.searchResults = [self.myProjects.list mutableCopy];
    
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
        
        //        owner_user_name field matching
        lhs = [NSExpression expressionForKeyPath:@"owner_user_name"];
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
