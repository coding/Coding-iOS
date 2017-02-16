//
//  CodeListViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "CodeListViewController.h"
#import "CodeViewController.h"
#import "ProjectViewController.h"
#import "ProjectCommitsViewController.h"
#import "ProjectViewController.h"

@interface CodeListViewController ()
@property (strong, nonatomic) ProjectCodeListView *listView;
@end

@implementation CodeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [[_myCodeTree.path componentsSeparatedByString:@"/"] lastObject];
    [self configRightNavBtn];
    
    _listView = [[ProjectCodeListView alloc] initWithFrame:self.view.bounds project:_myProject andCodeTree:_myCodeTree];
    __weak typeof(self) weakSelf = self;
    _listView.codeTreeFileOfRefBlock = ^(CodeTree_File *curCodeTreeFile, NSString *ref){
        [weakSelf goToVCWith:curCodeTreeFile andRef:ref];
    };
    _listView.codeTreeChangedBlock = ^(CodeTree *tree){
        weakSelf.myCodeTree = tree;
    };
    [self.view addSubview:_listView];
    [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)configRightNavBtn{
    if (!self.navigationItem.rightBarButtonItem) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)] animated:NO];
    }
}

- (void)rightNavBtnClicked{
    __weak typeof(self) weakSelf = self;
    [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"上传图片", @"创建文本文件", @"查看提交记录", @"退出代码查看"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [weakSelf.listView uploadImageClicked];
        }else if (index == 1){
            [weakSelf.listView createFileClicked];
        }else if (index == 2){
            [weakSelf goToCommitsVC];
        }else if (index == 3){
            [weakSelf popOutCodeVC];
        }
    }] showInView:self.view];
}

#pragma mark action
- (void)goToVCWith:(CodeTree_File *)codeTreeFile andRef:(NSString *)ref{
    DebugLog(@"%@", codeTreeFile.path);
    if ([codeTreeFile.mode isEqualToString:@"tree"]) {//文件夹
        CodeTree *nextCodeTree = [CodeTree codeTreeWithRef:ref andPath:codeTreeFile.path];
        CodeListViewController *vc = [[CodeListViewController alloc] init];
        vc.myProject = _myProject;
        vc.myCodeTree = nextCodeTree;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([@[@"file", @"image", @"sym_link", @"executable"] containsObject:codeTreeFile.mode]){//文件
        CodeFile *nextCodeFile = [CodeFile codeFileWithRef:ref andPath:codeTreeFile.path];
        CodeViewController *vc = [CodeViewController codeVCWithProject:_myProject andCodeFile:nextCodeFile];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([codeTreeFile.mode isEqualToString:@"git_link"]){
        UIViewController *vc = [BaseViewController analyseVCFromLinkStr:codeTreeFile.info.submoduleLink];
        if (vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [NSObject showHudTipStr:@"有些文件还不支持查看呢_(:з」∠)_"];
        }
    }else{
        [NSObject showHudTipStr:@"有些文件还不支持查看呢_(:з」∠)_"];
    }
}

- (void)goToCommitsVC{
    ProjectCommitsViewController *vc = [ProjectCommitsViewController new];
    vc.curProject = self.myProject;
    vc.curCommits = [Commits commitsWithRef:self.myCodeTree.ref Path:self.myCodeTree.path];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)popOutCodeVC{
    __weak typeof(self) weakSelf = self;
    [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[CodeViewController class]] &&
            ![obj isKindOfClass:[CodeListViewController class]] &&
            !([obj isKindOfClass:[ProjectViewController class]] && [(ProjectViewController *)obj curType] == ProjectViewTypeCodes)) {
            *stop = YES;
            [weakSelf.navigationController popToViewController:obj animated:YES];
        }
    }];
}

@end
