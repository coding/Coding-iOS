//
//  ProjectCodeListView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectCodeListView.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "ProjectCodeListCell.h"
#import "ProjectCodeListSearchCell.h"
#import "CodeBranchTagButton.h"
#import "QBImagePickerController.h"

@interface ProjectCodeListView ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, QBImagePickerControllerDelegate>
@property (nonatomic, strong) Project *curProject;
@property (nonatomic , strong) CodeTree *myCodeTree;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) CodeBranchTagButton *branchTagButton;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) NSArray *searchedFileList;
@end

@implementation ProjectCodeListView

- (id)initWithFrame:(CGRect)frame project:(Project *)project andCodeTree:(CodeTree *)codeTree{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _curProject = project;
        if (codeTree) {
            _myCodeTree = codeTree;
        }else{
            self.myCodeTree = [CodeTree codeTreeMaster];
        }
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ProjectCodeListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectCodeList];
            [tableView registerClass:[ProjectCodeListSearchCell class] forCellReuseIdentifier:kCellIdentifier_ProjectCodeListSearchCell];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView;
        });
        _mySearchBar = ({
            UISearchBar *searchBar = [[UISearchBar alloc] init];
            searchBar.delegate = self;
            [searchBar sizeToFit];
            [searchBar setPlaceholder:@"寻找文件"];
            searchBar;
        });
        _myTableView.tableHeaderView = _mySearchBar;
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [self sendRequest];
    }
    return self;
}

- (void)refreshToQueryData{
    [self refresh];
}

- (void)setMyCodeTree:(CodeTree *)myCodeTree{
    _myCodeTree = myCodeTree;
    if (self.codeTreeChangedBlock){
        self.codeTreeChangedBlock(_myCodeTree);
    }
}

- (BOOL)isSearching{
    return ![_mySearchBar.text isEmpty];
}

- (CodeBranchTagButton *)branchTagButton{
    if (!_branchTagButton) {
        _branchTagButton = ({
            CodeBranchTagButton *button = [CodeBranchTagButton buttonWithProject:_curProject andTitleStr:_myCodeTree.ref];
            button.showingContainerView = self;
            button;
        });
    }
    __weak typeof(self) weakSelf = self;
    _branchTagButton.selectedBranchTagBlock = ^(NSString *branchTag){
        if ([weakSelf.myCodeTree.ref isEqualToString:branchTag]) {
            return ;
        }else{
            weakSelf.myCodeTree = [CodeTree codeTreeWithRef:branchTag andPath:weakSelf.myCodeTree.path];
            [weakSelf.myTableView reloadData];
            [weakSelf sendRequest];
        }
    };
    return _branchTagButton;
}

- (void)refresh{
    if (_myCodeTree.isLoading) {
        return;
    }
    [self sendRequest];
}

- (void)sendRequest{
    if (_myCodeTree.files.count <= 0) {
        [self beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CodeTree:_myCodeTree withPro:_curProject codeTreeBlock:^(id codeTreeData, NSError *codeTreeError) {
        
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf endLoading];
        if (codeTreeData) {
            weakSelf.myCodeTree = codeTreeData;
            [weakSelf.myTableView reloadData];
        }
        BOOL hasError = NO;
        if (codeTreeError != nil && codeTreeError.code == 1024) {
            hasError = YES;
        }
        [weakSelf configBlankPage:EaseBlankPageTypeCode hasData:(weakSelf.myCodeTree.files.count > 0) hasError:hasError reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.mySearchBar resignFirstResponder];
    }
}

#pragma mark Table

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([self isSearching]) {
        UILabel *headerL = [UILabel labelWithSystemFontSize:14 textColorHexString:@"0xB5B5B5"];
        headerL.frame = CGRectMake(0, 0, kScreen_Width, 40);
        headerL.backgroundColor = [UIColor whiteColor];
        headerL.textAlignment = NSTextAlignmentCenter;
        headerL.text = [NSString stringWithFormat:@"共搜到 %lu 个与 \"%@\" 相关的文件", (unsigned long)self.searchedFileList.count, self.mySearchBar.text];
        [headerL doBorderWidth:.5 color:kColorDDD cornerRadius:0];
        return headerL;
    }else{
        return self.branchTagButton;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if ([self isSearching]) {
        row = self.searchedFileList.count;
    }else{
        row = _myCodeTree.files.count;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isSearching]) {
        ProjectCodeListSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectCodeListSearchCell forIndexPath:indexPath];
        cell.treePath = _myCodeTree.path;
        cell.searchText = [_mySearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        cell.filePath = self.searchedFileList[indexPath.row];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth hasSectionLine:NO];
        return cell;
    }else{
        ProjectCodeListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectCodeList forIndexPath:indexPath];
        cell.file = self.myCodeTree.files[indexPath.row];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth hasSectionLine:NO];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self isSearching]? [ProjectCodeListSearchCell cellHeight]: [ProjectCodeListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_codeTreeFileOfRefBlock) {
        CodeTree_File *file;
        if ([self isSearching]) {
            file = [CodeTree_File new];
            file.path = self.searchedFileList[indexPath.row];
            file.mode = @"file";
        }else{
            file = [self.myCodeTree.files objectAtIndex:indexPath.row];
        }
        _codeTreeFileOfRefBlock(file, _myCodeTree.ref);
    }
}

#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [_branchTagButton dismissShowingList];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchFileWithStr:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self searchFileWithStr:searchBar.text];
}

- (void)searchFileWithStr:(NSString *)string{
    if ([string isEmpty]) {
        [self.myTableView reloadData];
    }else{
        NSString *strippedStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (strippedStr.length > 0) {
            [self updateFilteredContentForSearchString:strippedStr];
        }
    }
}

- (void)updateFilteredContentForSearchString:(NSString *)searchString{
    self.searchedFileList = [self.myCodeTree.treeList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString *shortPath = evaluatedObject;
        if (_myCodeTree.path.length > 0) {
            if ([shortPath hasPrefix:_myCodeTree.path]) {
                shortPath = [shortPath substringFromIndex:_myCodeTree.path.length + 1];// '/xxxx'
            }else{
                return NO;
            }
        }
        return ([shortPath rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound);
    }]];
    [self.myTableView reloadData];
}

#pragma mark Action
- (void)createFileClicked{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"创建文本文件" message:@"输入文件名称" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *fileName = alertCtrl.textFields[0].text;
        if (![fileName isFileName]) {
            [NSObject showHudTipStr:[fileName isEmpty]? @"文件名不能为空": @"文件名不能含有特殊符号"];
            [[BaseViewController presentingVC] presentViewController:alertCtrl animated:YES completion:nil];
        }else{
            [weakSelf goToCreatFileWithName:fileName];
        }
    }];
    [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"文件名";
    }];
    [alertCtrl addAction:cancelA];
    [alertCtrl addAction:confirmA];
    [[BaseViewController presentingVC] presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)goToCreatFileWithName:(NSString *)fileName{
    CodeFile *codeFile = [CodeFile codeFileToCommitWithRef:_myCodeTree.ref andPath:_myCodeTree.path name:fileName data:@"" message:[NSString stringWithFormat:@"new file %@", fileName] headCommit:_myCodeTree.headCommit];
    __weak typeof(self) weakSelf = self;
    [NSObject showHUDQueryStr:@"请稍等..."];
    [[Coding_NetAPIManager sharedManager] request_CreateCodeFile:codeFile withPro:_curProject andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"创建成功"];
            [weakSelf refresh];
        }
    }];
}

- (void)uploadImageClicked{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 6;
    [[BaseViewController presentingVC] presentViewController:imagePickerController animated:YES completion:NULL];
}

#pragma mark QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets{
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = [NSObject showHUDQueryStr:@"正在上传..."];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    [[Coding_NetAPIManager sharedManager] request_UploadAssets:assets inCodeTree:_myCodeTree withPro:_curProject andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"上传成功"];
            [weakSelf refresh];
        }
    } progerssBlock:^(CGFloat progressValue) {
        hud.progress = MAX(0, progressValue-0.05);
    }];
    
    [[BaseViewController presentingVC] dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [[BaseViewController presentingVC] dismissViewControllerAnimated:YES completion:nil];
}

@end
