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

@interface CodeListViewController ()

@end

@implementation CodeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [[_myCodeTree.path componentsSeparatedByString:@"/"] lastObject];
    [self configRightNavBtn];
    
    ProjectCodeListView *listView = [[ProjectCodeListView alloc] initWithFrame:self.view.bounds project:_myProject andCodeTree:_myCodeTree];
    __weak typeof(self) weakSelf = self;
    listView.codeTreeFileOfRefBlock = ^(CodeTree_File *curCodeTreeFile, NSString *ref){
        [weakSelf goToVCWith:curCodeTreeFile andRef:ref];
    };
    [self.view addSubview:listView];
    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [listView addBranchTagButton];
    
}

- (void)configRightNavBtn{
    if (!self.navigationItem.rightBarButtonItem) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)] animated:NO];
    }
}

- (void)rightNavBtnClicked{
    __weak typeof(self) weakSelf = self;
    [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"退出代码查看"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        switch (index) {
            case 0:{
                [weakSelf.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
                    if (![obj isKindOfClass:[weakSelf class]]) {
                        if ([obj isKindOfClass:[ProjectViewController class]]) {
                            if ([(ProjectViewController *)obj curType] != ProjectViewTypeCodes) {
                                *stop = YES;
                            }
                        }else{
                            *stop = YES;
                        }
                    }
                    if (*stop) {
                        [weakSelf.navigationController popToViewController:obj animated:YES];
                    }
                }];
            }
                break;
            default:
                break;
        }
    }] showInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)goToVCWith:(CodeTree_File *)codeTreeFile andRef:(NSString *)ref{
    DebugLog(@"%@", codeTreeFile.path);
    if ([codeTreeFile.mode isEqualToString:@"tree"]) {//文件夹
        CodeTree *nextCodeTree = [CodeTree codeTreeWithRef:ref andPath:codeTreeFile.path];
        CodeListViewController *vc = [[CodeListViewController alloc] init];
        vc.myProject = _myProject;
        vc.myCodeTree = nextCodeTree;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([codeTreeFile.mode isEqualToString:@"file"] || [codeTreeFile.mode isEqualToString:@"image"]){//文件
        CodeFile *nextCodeFile = [CodeFile codeFileWithRef:ref andPath:codeTreeFile.path];
        CodeViewController *vc = [CodeViewController codeVCWithProject:_myProject andCodeFile:nextCodeFile];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self showHudTipStr:@"有些文件还不支持查看呢_(:з」∠)_"];
    }
}

@end
