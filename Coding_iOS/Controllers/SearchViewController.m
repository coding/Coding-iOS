//
//  SearchViewController.m
//  Coding_iOS
//
//  Created by jwill on 15/11/16.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "SearchViewController.h"
#import "CategorySearchBar.h"
#import "KxMenu.h"
#import "AllSearchDisplayVC.h"
#import "FileViewController.h"

@interface SearchViewController ()<UISearchDisplayDelegate>
@property (nonatomic,strong)UIView *searchView;
@property (strong, nonatomic) NSMutableArray *statusList;
@property (strong, nonatomic) CategorySearchBar *mySearchBar;
@property (strong, nonatomic) AllSearchDisplayVC *searchDisplayVC;
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) NSInteger selectIndex;
@property (nonatomic,assign) BOOL firstLoad;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectIndex=0;
    _statusList = @[@"项目",
                    @"任务",
                    @"讨论",
                    @"冒泡",
                    @"文档",
                    @"用户",
                    @"合并请求",
                    @"pull 请求"].mutableCopy;
    _firstLoad = TRUE;
    [self buildUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
    [self.navigationController.navigationBar addSubview:_mySearchBar];
    if (_firstLoad) {
        [_mySearchBar becomeFirstResponder];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mySearchBar resignFirstResponder];
    [_mySearchBar removeFromSuperview];
    _firstLoad = FALSE;
}

//基础化UI布局
-(void)buildUI{
//    self.view.backgroundColor=[UIColor colorWithHexString:@"0xeeeeee"];
    
    //添加搜索框
    _mySearchBar = ({
        CategorySearchBar *searchBar = [[CategorySearchBar alloc] initWithFrame:CGRectMake(20, 7, kScreen_Width-75, 31)];
        searchBar.layer.cornerRadius = 2;
        searchBar.layer.masksToBounds = TRUE;
        [searchBar insertBGColor:kColorTableSectionBg];
        [searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:kColorTableSectionBg] forState:UIControlStateNormal];
        [searchBar setHeight:30];
        [searchBar setPlaceholder:@"项目、任务、冒泡等"];
        searchBar;
    });
    
    
    //初始化选项
    NSMutableArray *menuItems = @[].mutableCopy;
    [_statusList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KxMenuItem *menuItem = [KxMenuItem menuItem:obj image:nil target:self action:@selector(menuItemClicked:)];
        menuItem.alignment = NSTextAlignmentLeft;
        menuItem.foreColor = kColorNavTitle;
        [menuItems addObject:menuItem];
    }];

    
    __weak typeof(self) weakSelf = self;
    [_mySearchBar patchWithCategoryWithSelectBlock:^{
        if ([KxMenu isShowingInView:[UIApplication sharedApplication].keyWindow]) {
            [KxMenu dismissMenu:YES];
            [weakSelf.mySearchBar becomeFirstResponder];
        }else{
            [weakSelf.mySearchBar resignFirstResponder];
            [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
            [KxMenu setTintColor:kColorNavBG];
            [KxMenu setOverlayColor:[UIColor clearColor]];
            
            CGRect senderFrame = CGRectMake(weakSelf.searchView.frame.origin.x+50, 64, 0, 0);
            [KxMenu showMenuInView:[UIApplication sharedApplication].keyWindow fromRect:senderFrame menuItems:menuItems];
        }
    }];
    [_mySearchBar setSearchCategory:[_statusList objectAtIndex:_selectIndex]];
    
    if (!_searchDisplayVC) {
        _searchDisplayVC = ({
            AllSearchDisplayVC *searchVC = [[AllSearchDisplayVC alloc] initWithSearchBar:_mySearchBar contentsController:self];
            //自定义uisearchbar 要在这里重新申明
            //需要重新调整下大小
            searchVC.searchBar.frame = CGRectMake(20, 7, kScreen_Width-75, 31);
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

- (void)menuItemClicked:(KxMenuItem *)item{
    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:[NSString stringWithFormat:@"全局搜索_%@", item.title]];
    NSInteger nowSelectIndex = [_statusList indexOfObject:item.title];
    if (nowSelectIndex == NSNotFound || nowSelectIndex == _selectIndex) {
        return;
    }
    _selectIndex = nowSelectIndex;
    
    _searchDisplayVC.curSearchType=_selectIndex;
    NSString *showStr=([[_statusList objectAtIndex:_selectIndex] length]>2)?[[_statusList objectAtIndex:_selectIndex] substringToIndex:[[_statusList objectAtIndex:_selectIndex] length]-2]:[_statusList objectAtIndex:_selectIndex];
    [_mySearchBar setSearchCategory:showStr];
    
    if (_searchDisplayVC.active&&(_mySearchBar.text.length>0)) {
        NSLog(@"active And can search");
        [_searchDisplayVC reloadDisplayData];
    }else{
        [_mySearchBar becomeFirstResponder];
    }
}


@end
