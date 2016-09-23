//
//  FileVersionsViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/8/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileVersionsViewController.h"
#import "SettingTextViewController.h"
#import "FileViewController.h"

#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "Coding_FileManager.h"


#import "FileVersionCell.h"


@interface FileVersionsViewController ()<UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>
@property (strong, nonatomic) ProjectFile *curFile;
@property (strong, nonatomic) NSMutableArray *versionList;

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@property (assign, nonatomic) BOOL isLoading;

@end

@implementation FileVersionsViewController
+ (instancetype)vcWithFile:(ProjectFile *)file{
    FileVersionsViewController *vc = [self new];
    vc.curFile = file;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"历史版本";
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[FileVersionCell class] forCellReuseIdentifier:kCellIdentifier_FileVersionCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.allowsMultipleSelectionDuringEditing = YES;
        tableView;
    });
    
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.myTableView reloadData];
}

- (void)refresh{
    if (self.isLoading) {
        return;
    }
    [self sendRequest];
}

- (void)sendRequest{
    self.isLoading = YES;
    if (self.versionList.count <= 0) {
        [self.view beginLoading];
    }
    @weakify(self);
    [[Coding_NetAPIManager sharedManager] request_VersionListOfFile:_curFile andBlock:^(id data, NSError *error) {
        @strongify(self);
        self.isLoading = NO;
        [self.myRefreshControl endRefreshing];
        [self.view endLoading];
        if (data) {
            self.versionList = data;
            [self.myTableView reloadData];
        }
        [self.view configBlankPage:EaseBlankPageTypeView hasData:self.versionList.count > 0 hasError:error != nil reloadButtonBlock:^(id sender) {
            [self refresh];
        }];
    }];
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.versionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    
    FileVersionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileVersionCell forIndexPath:indexPath];
    FileVersion *curVersion = _versionList[indexPath.row];
    cell.curVersion = curVersion;
    cell.showDiskFileBlock = ^(NSURL *fileUrl, FileVersion *curVersion){
        [weakSelf goToFileVersionVC:curVersion];
    };
    [cell setRightUtilityButtons:[self rightButtonsWithObj:indexPath] WithButtonWidth:[FileVersionCell cellHeight]];
    cell.delegate = self;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [FileVersionCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self goToFileVersionVC:_versionList[indexPath.row]];
}

#pragma mark Edit Table
- (NSArray *)rightButtonsWithObj:(NSIndexPath *)indexPath{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:@"icon_file_cell_rename"]];
    if (indexPath.row != 0) {//当前版本不能删除
        [rightUtilityButtons sw_addUtilityButtonWithColor:kColorBrandRed icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
    }
    return rightUtilityButtons;
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    NSIndexPath *indexPath = [_myTableView indexPathForCell:cell];
    FileVersion *curVersion = _versionList[indexPath.row];
    Coding_DownloadTask *cDownloadTask = [Coding_FileManager cDownloadTaskForKey:curVersion.storage_key];
    if (cDownloadTask && cDownloadTask.task && cDownloadTask.task.state == NSURLSessionTaskStateRunning) {
        return NO;
    }else{
        return YES;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    NSIndexPath *indexPath = [_myTableView indexPathForCell:cell];
    FileVersion *curVersion = _versionList[indexPath.row];
    if (index == 0) {
        [self remarkFileVersion:curVersion];
    }else{
        [self deleteFileVersion:curVersion];
    }
}

- (void)remarkFileVersion:(FileVersion *)curVersion{
    __weak typeof(self) weakSelf = self;
    [SettingTextViewController showSettingFolderNameVCFromVC:nil withTitle:@"重命名文件夹" textValue:curVersion.remark type:SettingTypeFileVersionRemark doneBlock:^(NSString *textValue) {
        [weakSelf doRemarkFileVersion:curVersion withRemarkStr:textValue];
    }];
}

- (void)doRemarkFileVersion:(FileVersion *)curVersion withRemarkStr:(NSString *)remarkStr{
    if (remarkStr && ![remarkStr isEqualToString:curVersion.remark]) {
        @weakify(self);
        [[Coding_NetAPIManager sharedManager] request_RemarkFileVersion:curVersion withStr:remarkStr andBlock:^(id data, NSError *error) {
            @strongify(self);
            if (data) {
                curVersion.remark = remarkStr;
                [self.myTableView reloadData];
            }
        }];
    }
}

- (void)deleteFileVersion:(FileVersion *)curVersion{
    __weak typeof(self) weakSelf = self;
    
    NSURL *fileUrl = [Coding_FileManager diskDownloadUrlForKey:curVersion.storage_key];
    Coding_DownloadTask *cDownloadTask = [Coding_FileManager cDownloadTaskForKey:curVersion.storage_key];
    UIActionSheet *actionSheet;
    
    if (fileUrl) {
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"只是删除本地文件还是连同服务器版本一起删除？" buttonTitles:@[@"仅删除本地文件"] destructiveTitle:@"一起删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            switch (index) {
                case 0:
                    [weakSelf doDeleteFileVersion:curVersion fromDisk:YES];
                    break;
                case 1:
                    [weakSelf doDeleteFileVersion:curVersion fromDisk:NO];
                    break;
                default:
                    break;
            }
        }];
    }else if (cDownloadTask){
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定将服务器上的该版本删除？" buttonTitles:@[@"只是取消下载"] destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            switch (index) {
                case 0:
                    [weakSelf doDeleteFileVersion:curVersion fromDisk:YES];
                    break;
                case 1:
                    [weakSelf doDeleteFileVersion:curVersion fromDisk:NO];
                    break;
                default:
                    break;
            }
        }];
    }else{
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定将服务器上的该版本删除？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf doDeleteFileVersion:curVersion fromDisk:NO];
            }
        }];
    }
    [actionSheet showInView:self.view];
}

- (void)doDeleteFileVersion:(FileVersion *)curVersion fromDisk:(BOOL)fromDisk{
    //    取消当前的下载任务
    Coding_DownloadTask *cDownloadTask = [Coding_FileManager cDownloadTaskForKey:curVersion.storage_key];
    if (cDownloadTask) {
        [Coding_FileManager cancelCDownloadTaskForKey:curVersion.storage_key];
    }
    //    删除本地文件
    NSURL *fileUrl = [Coding_FileManager diskDownloadUrlForKey:curVersion.storage_key];
    NSString *filePath = fileUrl.path;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSError *fileError;
        [fm removeItemAtPath:filePath error:&fileError];
        if (fileError) {
            [NSObject showError:fileError];
        }
    }
    [self.myTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    //    删除服务器文件
    if (!fromDisk) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_DeleteFileVersion:curVersion andBlock:^(id data, NSError *error) {
            [weakSelf refresh];
        }];
    }
}

#pragma mark toVC
- (void)goToFileVersionVC:(FileVersion *)curVersion{
    FileViewController *vc = [FileViewController vcWithFile:_curFile andVersion:curVersion];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
