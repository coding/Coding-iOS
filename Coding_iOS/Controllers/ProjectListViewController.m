//
//  ProjectListViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/3/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectListViewController.h"

@implementation ProjectListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _curUser.name;
    self.icarouselScrollEnabled = YES;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mySearchBar removeFromSuperview];
    //重置titleview
    self.navigationItem.titleView=[[[[self.navigationController viewControllers] lastObject] navigationItem] titleView];
}

- (void)setupNavBtn{
    
    self.useNewStyle=FALSE;
    
    [self.myCarousel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kMySegmentControl_Height, 0, 0, 0));
    }];

    
//    添加滑块
        __weak typeof(self.myCarousel) weakCarousel = self.myCarousel;
        self.mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height) Items:self.segmentItems selectedBlock:^(NSInteger index) {
            if (index == self.oldSelectedIndex) {
                return;
            }
            [weakCarousel scrollToItemAtIndex:index animated:NO];
        }];
        [self.view addSubview:self.mySegmentControl];

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)configSegmentItems{
    if ([_curUser.global_key isEqualToString:[Login curLoginUser].global_key]) {
        self.segmentItems = @[@"我参与的", @"我收藏的"];
    }else{
        self.segmentItems = @[@"Ta参与的", @"Ta收藏的"];
    }
}

- (Projects *)projectsWithIndex:(NSUInteger)index{
    return [Projects projectsWithType:(index+ProjectsTypeTaProject) andUser:self.curUser];
}

@end
