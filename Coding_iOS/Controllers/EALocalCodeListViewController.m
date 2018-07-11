//
//  EALocalCodeListViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/28.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EALocalCodeListViewController.h"
#import "EALocalCodeViewController.h"
#import "EALocalCodeListCell.h"

@interface EALocalCodeListViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (strong, nonatomic) UISearchBar *mySearchBar;

@property (strong, nonatomic) NSArray *fileList, *searchedFileList;
@property (strong, nonatomic) NSMutableDictionary *isDirDict;
@property (strong, nonatomic, readonly) NSArray *dataList;
@property (assign, nonatomic, readonly) BOOL isSearching;
@end

@implementation EALocalCodeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myTableView = ({
        UITableView *tableView = [UITableView new];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[EALocalCodeListCell class] forCellReuseIdentifier:[EALocalCodeListCell nameOfClass]];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
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
    [self setupNavBtnAndTitle];
    [self setupData];
}

- (void)setupData{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    self.fileList = [[fileManager contentsOfDirectoryAtURL:_curURL includingPropertiesForKeys:nil options:0 error:nil] sortedArrayUsingComparator:^NSComparisonResult(NSURL *obj1, NSURL *obj2) {
        NSDictionary *attr1 = [obj1 resourceValuesForKeys:@[NSURLIsDirectoryKey] error:nil];
        BOOL isDir1 = [attr1[NSURLIsDirectoryKey] boolValue];
        NSDictionary *attr2 = [obj2 resourceValuesForKeys:@[NSURLIsDirectoryKey] error:nil];
        BOOL isDir2 = [attr2[NSURLIsDirectoryKey] boolValue];
        NSComparisonResult result = [(isDir1? @0: @1) compare:(isDir2? @0: @1)];
        if (result == NSOrderedSame) {
            result = [obj1.lastPathComponent compare:obj2.lastPathComponent];
        }
        return result;
    }];
    [self.myTableView reloadData];
}

- (BOOL)isSearching{
    return ![_mySearchBar.text isEmpty];
}

- (NSArray *)dataList{
    return self.isSearching? _searchedFileList: _fileList;
}

#pragma mark Nav
- (void)setupNavBtnAndTitle{
    if ([_curURL.absoluteString isEqualToString:_curPro.localURL.absoluteString]) {//根目录
        NSArray<GTBranch *> *branchList = [_curPro.localRepo localBranchesWithError:nil];
        self.title = branchList.count > 0? branchList.firstObject.shortName: _curURL.lastPathComponent;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(navBtnClicked)];
    }else{
        self.title = _curURL.lastPathComponent;
    }
}

- (void)navBtnClicked{
    __weak typeof(self) weakSelf = self;
    [[UIAlertController ea_actionSheetCustomWithTitle:nil buttonTitles:@[@"Pull"] destructiveTitle:@"删除本地 Repo" cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 0) {
            [weakSelf pullRepo];
        }else if (index == 1){
            [weakSelf deleteRepo];
        }
    }] showInView:self.view];
}

- (void)pullRepo{
    if (![_curURL.absoluteString isEqualToString:_curPro.localURL.absoluteString]) {//不是根目录不 pull，任性
        return;
    }
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = [NSObject showHUDQueryStr:@"正在 pull..."];
    [_curPro gitPullBlock:^(BOOL result, NSString *tipStr) {
        [NSObject hideHUDQuery];
        if (tipStr) {
            [NSObject showHudTipStr:tipStr];
        }else{
            [NSObject showHudTipStr:@"已更新"];
            [weakSelf setupData];
        }
    } progressBlock:^(const git_transfer_progress *progress, BOOL *stop) {
        hud.detailsLabelText = [NSString stringWithFormat:@"%d / %d", progress->received_objects, progress->total_objects];
    }];
}

- (void)deleteRepo{
    [_curPro deleteLocalRepo];
    [NSObject showHudTipStr:@"已删除"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.mySearchBar resignFirstResponder];
    }
}
#pragma mark Table

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.isSearching? 44.0: 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.isSearching) {
        UILabel *headerL = [UILabel labelWithSystemFontSize:14 textColorHexString:@"0xB5B5B5"];
        headerL.frame = CGRectMake(0, 0, kScreen_Width, 40);
        headerL.backgroundColor = [UIColor whiteColor];
        headerL.textAlignment = NSTextAlignmentCenter;
        headerL.text = [NSString stringWithFormat:@"共搜到 %lu 个与 \"%@\" 相关的文件", (unsigned long)self.searchedFileList.count, self.mySearchBar.text];
        [headerL doBorderWidth:kLine_MinHeight color:kColorDDD cornerRadius:0];
        return headerL;
    }else{
        return [UIView new];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EALocalCodeListCell *cell = [tableView dequeueReusableCellWithIdentifier:[EALocalCodeListCell nameOfClass] forIndexPath:indexPath];
    cell.curURL = self.dataList[indexPath.row];
    cell.searchText = [_mySearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth hasSectionLine:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSURL *itemURL = self.dataList[indexPath.row];
    NSDictionary *attributes = [itemURL resourceValuesForKeys:@[NSURLIsDirectoryKey] error:nil];
    BOOL isDir = [attributes[NSURLIsDirectoryKey] boolValue];
    if (isDir) {
        EALocalCodeListViewController *vc = [EALocalCodeListViewController new];
        vc.curPro = _curPro;
        vc.curRepo = _curRepo;
        vc.curURL = itemURL;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        EALocalCodeViewController *vc = [EALocalCodeViewController new];
        vc.curPro = _curPro;
        vc.curRepo = _curRepo;
        vc.curURL = itemURL;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark UISearchBarDelegate

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
    self.searchedFileList = [self.fileList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSURL * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString *shortPath = evaluatedObject.lastPathComponent;
        return ([shortPath rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound);
    }]];
    [self.myTableView reloadData];
}

@end
