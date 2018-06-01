//
//  NFileListViewController.m
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/5/11.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "NFileListViewController.h"
#import "NProjectFileListView.h"

@interface NFileListViewController ()
@property (strong, nonatomic) NProjectFileListView *listView;
@end

@implementation NFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _curFolder.name ?: _curProject.name;
    _listView = [[NProjectFileListView alloc] initWithFrame:self.view.bounds project:_curProject folder:_curFolder];
    _listView.containerVC = self;
    [self.view addSubview:_listView];
    [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

@end
