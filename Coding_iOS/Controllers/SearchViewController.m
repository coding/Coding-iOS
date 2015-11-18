//
//  SearchViewController.m
//  Coding_iOS
//
//  Created by jwill on 15/11/16.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "SearchViewController.h"
#import "CategorySearchBar.h"

@interface SearchViewController ()
@property (nonatomic,strong)UIView *searchView;
@property (strong, nonatomic) CategorySearchBar *mySearchBar;
@property (strong, nonatomic) UIPopoverController *curPopView;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"搜索";
    [self buildUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//基础化UI布局
-(void)buildUI{
    
    //添加搜索框
    _mySearchBar = ({
        CategorySearchBar *searchBar = [[CategorySearchBar alloc] initWithFrame:CGRectMake(20,7, kScreen_Width-75, 30)];
        searchBar.layer.cornerRadius=15;
        searchBar.layer.masksToBounds=TRUE;
        [searchBar.layer setBorderWidth:8];
        [searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];  //设置边框为白色
        [searchBar sizeToFit];
        searchBar.delegate = self;
        [searchBar setTintColor:[UIColor whiteColor]];
        [searchBar insertBGColor:[UIColor colorWithHexString:@"0xffffff"]];
        [searchBar setHeight:30];
        searchBar;
    });
    
    [self.navigationController.navigationBar addSubview:_mySearchBar];
    __weak typeof(self) weakSelf = self;
    [_mySearchBar patchWithCategoryWithSelectBlock:^{
        NSLog(@"click category");
//        weakSelf.curPopView=[[UIPopoverController alloc]initWithContentViewController:weakSelf];
    }];

    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(popToMainVCAction)];
    [_mySearchBar becomeFirstResponder];
}

#pragma mark - event
//弹出到首页
-(void)popToMainVCAction
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
