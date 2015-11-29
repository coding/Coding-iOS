//
//  ProjectSquareViewController.m
//  Coding_iOS
//
//  Created by jwill on 15/11/11.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ProjectSquareViewController.h"
#import "ProjectListView.h"
#import "NProjectViewController.h"
#import "ProjectAboutMeListCell.h"
#import "Coding_NetAPIManager.h"

@interface ProjectSquareViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) Projects *curPros;
@property (strong, nonatomic) Projects *searchPros;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UISearchDisplayController *mySearchDisplayController;
@property (strong, nonatomic) NSMutableArray *dateSource;

@end

@implementation ProjectSquareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"项目广场";
    self.curPros = [Projects projectsWithType:ProjectsTypeAllPublic andUser:nil];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    __weak typeof(self) weakSelf = self;
    _mySearchBar = ({
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        [searchBar sizeToFit];
        [searchBar setPlaceholder:@"搜索项目"];
        searchBar;
    });
    
    _mySearchDisplayController = ({
        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
        [searchVC.searchResultsTableView registerClass:[ProjectAboutMeListCell class] forCellReuseIdentifier:@"ProjectAboutMeListCell"];
        [searchVC.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

        searchVC.delegate = self;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
        searchVC.displaysSearchBarInNavigationBar = NO;
        searchVC;
    });

    _dateSource=[NSMutableArray array];

//    ProjectListView *listView = [[ProjectListView alloc] initWithFrame:self.view.bounds projects:self.curPros block:^(Project *project) {
//        [weakSelf goToProject:project];
//    } tabBarHeight:0];
//    listView.useNewStyle=TRUE;
//    [self.view addSubview:listView];
//    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(self.view);
//        make.top.equalTo(self.view);
//    }];
    
    [self.view addSubview:_mySearchBar];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kProjectAboutMeListCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectAboutMeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectAboutMeListCell"];
    cell.textLabel.text=@"搜索记录";
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark -- evnt

- (void)goToProject:(Project *)project{
    NProjectViewController *vc = [[NProjectViewController alloc] init];
    vc.myProject = project;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)requestAll{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] requestWithSearchString:_mySearchBar.text typeStr:@"public_project" andPage:1 andBlock:^(id data, NSError *error) {
        if(data) {
//            _searchPros = [NSObject objectOfClass:@"Projects" fromJSON:data];
//            NSDictionary *dataDic = (NSDictionary *)data;
//
//            //topic 处理 content 关键字
//            NSArray *resultTopic =[dataDic[@"project_topics"] objectForKey:@"list"] ;
//            for (int i=0;i<[_searchPros.project_topics.list count];i++) {
//                ProjectTopic *curTopic=[_searchPros.project_topics.list objectAtIndex:i];
//                if ([resultTopic count]>i) {
//                    curTopic.contentStr= [[[resultTopic objectAtIndex:i] objectForKey:@"content"] firstObject];
//                }
//            }
//            
//            //task 处理 description 关键字
//            NSArray *resultTask =[dataDic[@"tasks"] objectForKey:@"list"] ;
//            for (int i=0;i<[weakSelf.searchPros.tasks.list count];i++) {
//                Task *curTask=[weakSelf.searchPros.tasks.list objectAtIndex:i];
//                if ([resultTask count]>i) {
//                    curTask.descript= [[[resultTask objectAtIndex:i] objectForKey:@"description"] firstObject];
//                }
//            }
//            
//            [weakSelf.searchTableView configBlankPage:EaseBlankPageTypeProject_SEARCH hasData:[weakSelf noEmptyList] hasError:(error != nil) reloadButtonBlock:^(id sender) {
//            }];
//            
//            [weakSelf.searchTableView reloadData];
//            [weakSelf.searchTableView.infiniteScrollingView stopAnimating];
//            weakSelf.searchTableView.showsInfiniteScrolling = [weakSelf showTotalPage];
        }
    }];
}



#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar insertBGColor:[UIColor colorWithHexString:@"0x28303b"]];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [searchBar insertBGColor:nil];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self requestAll];
}

#pragma mark UISearchDisplayDelegate M
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
//    [self updateFilteredContentForSearchString:searchString];
    return NO;
}
- (void)updateFilteredContentForSearchString:(NSString *)searchString{
    // start out with the entire list
//    self.searchResults = [self.curUsers.list mutableCopy];
//    
//    // strip out all the leading and trailing spaces
//    NSString *strippedStr = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    
//    // break up the search terms (separated by spaces)
//    NSArray *searchItems = nil;
//    if (strippedStr.length > 0)
//    {
//        searchItems = [strippedStr componentsSeparatedByString:@" "];
//    }
//    
//    // build all the "AND" expressions for each value in the searchString
//    NSMutableArray *andMatchPredicates = [NSMutableArray array];
//    
//    for (NSString *searchString in searchItems)
//    {
//        // each searchString creates an OR predicate for: name, global_key
//        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
//        
//        // name field matching
//        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
//        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
//        NSPredicate *finalPredicate = [NSComparisonPredicate
//                                       predicateWithLeftExpression:lhs
//                                       rightExpression:rhs
//                                       modifier:NSDirectPredicateModifier
//                                       type:NSContainsPredicateOperatorType
//                                       options:NSCaseInsensitivePredicateOption];
//        [searchItemsPredicate addObject:finalPredicate];
//        //        pinyinName field matching
//        lhs = [NSExpression expressionForKeyPath:@"pinyinName"];
//        rhs = [NSExpression expressionForConstantValue:searchString];
//        finalPredicate = [NSComparisonPredicate
//                          predicateWithLeftExpression:lhs
//                          rightExpression:rhs
//                          modifier:NSDirectPredicateModifier
//                          type:NSContainsPredicateOperatorType
//                          options:NSCaseInsensitivePredicateOption];
//        [searchItemsPredicate addObject:finalPredicate];
//        //        global_key field matching
//        lhs = [NSExpression expressionForKeyPath:@"global_key"];
//        rhs = [NSExpression expressionForConstantValue:searchString];
//        finalPredicate = [NSComparisonPredicate
//                          predicateWithLeftExpression:lhs
//                          rightExpression:rhs
//                          modifier:NSDirectPredicateModifier
//                          type:NSContainsPredicateOperatorType
//                          options:NSCaseInsensitivePredicateOption];
//        [searchItemsPredicate addObject:finalPredicate];
//        // at this OR predicate to ourr master AND predicate
//        NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
//        [andMatchPredicates addObject:orMatchPredicates];
//    }
//    
//    NSCompoundPredicate *finalCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
//    
//    self.searchResults = [[self.searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
}


@end
