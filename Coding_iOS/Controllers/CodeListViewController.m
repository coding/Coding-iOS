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
    listView.refChangedBlock = ^(NSString *ref){
        weakSelf.myCodeTree.ref = ref;
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
    [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"查看提交记录", @"退出代码查看"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        switch (index) {
            case 0:{
                [weakSelf goToCommitsVC];
            }
                break;
            case 1:{
                [weakSelf.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
                    if (![obj isKindOfClass:[CodeViewController class]] &&
                        ![obj isKindOfClass:[CodeListViewController class]] &&
                        !([obj isKindOfClass:[ProjectViewController class]] && [(ProjectViewController *)obj curType] == ProjectViewTypeCodes)) {
                        *stop = YES;
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
    }else if ([@[@"file", @"image", @"sym_link", @"executable"] containsObject:codeTreeFile.mode]){//文件
        CodeFile *nextCodeFile = [CodeFile codeFileWithRef:ref andPath:codeTreeFile.path];
        CodeViewController *vc = [CodeViewController codeVCWithProject:_myProject andCodeFile:nextCodeFile];
        [self.navigationController pushViewController:vc animated:YES];
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

@end
