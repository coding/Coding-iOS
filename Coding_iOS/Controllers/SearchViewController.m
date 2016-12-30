//
//  SearchViewController.m
//  Coding_iOS
//
//  Created by jwill on 15/11/16.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "SearchViewController.h"
#import "CategorySearchBar.h"
#import "AllSearchDisplayVC.h"
#import "FileViewController.h"

@interface SearchViewController ()<UISearchDisplayDelegate>
@property (nonatomic,strong)UIView *searchView;
@property (strong, nonatomic) CategorySearchBar *mySearchBar;
@property (strong, nonatomic) AllSearchDisplayVC *searchDisplayVC;
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) BOOL firstLoad;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _firstLoad = TRUE;
    [self buildUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
    [self.navigationController.navigationBar addSubview:_mySearchBar];
    [(BaseNavigationController *)self.navigationController hideNavBottomLine];
    if (_firstLoad) {
        [_mySearchBar becomeFirstResponder];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_mySearchBar resignFirstResponder];
    [_mySearchBar removeFromSuperview];
    [(BaseNavigationController *)self.navigationController showNavBottomLine];
    _firstLoad = FALSE;
}

//基础化UI布局
-(void)buildUI{
    _mySearchBar = ({
        CategorySearchBar *searchBar = [[CategorySearchBar alloc] initWithFrame:CGRectMake(20, 7, kScreen_Width-(80 * kScreen_Width / 375), 31)];
        [searchBar setPlaceholder:@" 搜索"];
        searchBar;
    });
    if (!_searchDisplayVC) {
        _searchDisplayVC = ({
            AllSearchDisplayVC *searchVC = [[AllSearchDisplayVC alloc] initWithSearchBar:_mySearchBar contentsController:self];
            //uisearchbar 需要重新调整下大小
            searchVC.searchBar.frame = CGRectMake(20, 7, kScreen_Width-(80 * kScreen_Width / 375), 31);
            searchVC.displaysSearchBarInNavigationBar = NO;
            searchVC.parentVC = self;
            searchVC.delegate = self;
            searchVC;
        });
    }
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(popToMainVCAction)];
}


#pragma mark - loadData
-(void)loadData{
    [_tableview reloadData];
}

#pragma mark - event
//弹出到首页
-(void)popToMainVCAction{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
