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
#import "SVPullToRefresh.h"

@interface ProjectSquareViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) Projects *curPros;
@property (strong, nonatomic) Projects *searchPros;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UISearchDisplayController *mySearchDisplayController;
@property (strong, nonatomic) NSMutableArray *dateSource;
@property (nonatomic, assign) BOOL      isLoading;
@property (nonatomic, assign) BOOL      canLoadMore;
@property (nonatomic, assign) NSInteger curPage;
@property (strong, nonatomic) NSString *curSearchStr;

@end

@implementation ProjectSquareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"项目广场";
    self.curPros = [Projects projectsWithType:ProjectsTypeAllPublic andUser:nil];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    
    __weak typeof(self) weakSelf = self;
    ProjectListView *listView = [[ProjectListView alloc] initWithFrame:self.view.bounds projects:self.curPros block:^(Project *project) {
        [weakSelf goToProject:project];
    } tabBarHeight:0];
    listView.useNewStyle=TRUE;
    [self.view addSubview:listView];
    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
    [self.view addSubview:self.mySearchBar];
    
//    _mySearchBar = ({
//        UISearchBar *searchBar = [[UISearchBar alloc] init];
//        searchBar.delegate = self;
//        [searchBar sizeToFit];
//        [searchBar setPlaceholder:@"搜索项目"];
//        searchBar;
//    });

    _mySearchDisplayController = ({
        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:self.mySearchBar contentsController:self];
        [searchVC.searchResultsTableView addInfiniteScrollingWithActionHandler:^{
            weakSelf.curPage++;
            [weakSelf requestPubProjects];
        }];
        [searchVC.searchResultsTableView registerClass:[ProjectAboutMeListCell class] forCellReuseIdentifier:@"ProjectAboutMeListCell"];
//        searchVC.searchResultsTableView.separatorStyle=UITableViewCellAccessoryNone;
        searchVC.searchResultsTableView.tableFooterView=[UIView new];
        searchVC.delegate = self;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
        searchVC.searchResultsTableView.rowHeight=kProjectAboutMeListCellHeight;
        searchVC;
    });
    _dateSource=[NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resetTableview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UISearchBar *)mySearchBar
{
    if (!_mySearchBar) {
        _mySearchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _mySearchBar.delegate = self;
        _mySearchBar.placeholder = @"搜索项目";
        _mySearchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    return _mySearchBar;
}


#pragma mark - Table view data source
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return kProjectAboutMeListCellHeight;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    tableView.contentSize=CGSizeMake(kScreen_Width,[_dateSource count]*kProjectAboutMeListCellHeight+60);
//    tableView.contentOffset=CGPointZero;
    NSLog(@"content offset %@",NSStringFromUIEdgeInsets(tableView.contentInset));
    return [_dateSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectAboutMeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectAboutMeListCell"];
    cell.openKeywords=TRUE;
    cell.hidePrivateIcon=TRUE;
    Project *project=_dateSource[indexPath.row];
    [cell setProject:project hasSWButtons:NO hasBadgeTip:YES hasIndicator:NO];
//    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self goToPubProject:_dateSource[indexPath.row]];
}


#pragma mark -- evnt

- (void)goToProject:(Project *)project{
    NProjectViewController *vc = [[NProjectViewController alloc] init];
    vc.myProject = project;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToPubProject:(Project *)project{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:project.project_path];
    [self.navigationController pushViewController:vc animated:TRUE];
}

-(void)requestPubProjects{
    if(_isLoading){
        [_mySearchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
        return;
    }
    
    _isLoading=YES;
    
    __weak typeof(self) weakSelf = self;
    _curSearchStr=_mySearchBar.text;
    
    
    [[Coding_NetAPIManager sharedManager] requestWithSearchString:_curSearchStr typeStr:@"public_project" andPage:_curPage andBlock:^(id data, NSError *error) {
        if(data) {
            if(weakSelf.curPage==1){
                [weakSelf.dateSource removeAllObjects];
            }

            NSDictionary *dataDic = (NSDictionary *)data;
            [weakSelf.dateSource addObjectsFromArray: [NSObject arrayFromJSON:dataDic[@"list"] ofObjects:@"Project"]];
            weakSelf.canLoadMore=(dataDic[@"page"]<dataDic[@"totalPage"]);
            weakSelf.isLoading = NO;
            [weakSelf.mySearchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
            weakSelf.mySearchDisplayController.searchResultsTableView.showsInfiniteScrolling = weakSelf.canLoadMore;
            [weakSelf resetTableview];
            [weakSelf.mySearchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

-(void)resetTableview{
    _mySearchDisplayController.searchResultsTableView.contentInset=UIEdgeInsetsMake(0, 0, 60, 0);
    _mySearchDisplayController.searchResultsTableView.scrollIndicatorInsets=UIEdgeInsetsZero;
    _mySearchDisplayController.searchResultsTableView.height=kScreen_Height-64;
}


#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar insertBGColor:kColorNavBG];
    [searchBar setShowsCancelButton:YES animated:YES];
    [self resetTableview];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [searchBar insertBGColor:[_mySearchDisplayController isActive]? kColorNavBG: nil];
    
    if(!_isLoading){
        if ([_curSearchStr isEqualToString:_mySearchBar.text]) {
            return YES;
        }
        _isLoading=NO;
        _curPage=1;
        [self requestPubProjects];
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    _curSearchStr=nil;
    if (!_isLoading) {
        [_dateSource removeAllObjects];
        [_mySearchDisplayController.searchResultsTableView reloadData];
    }
    [searchBar insertBGColor:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if ([_curSearchStr isEqualToString:_mySearchBar.text]) {
        return;
    }
    _isLoading=NO;
    _curPage=1;
    [self requestPubProjects];
}

#pragma mark UISearchDisplayDelegate M
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
//    [controller.searchResultsTableView endEditing:YES];
////    controller.active=NO;
//    _curPage=1;
//    [self requestPubProjects];
//    NSLog(@"content fram =[%@]",NSStringFromCGSize(controller.searchResultsTableView.contentSize));
    return FALSE;
}

//- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
//    tableView.frame=self.view.bounds;
//}

//- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView{
//}
//
@end
