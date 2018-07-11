//
//  NProjectFileListView.m
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/5/11.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "NProjectFileListView.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "Coding_FileManager.h"

#import "FileListUploadCell.h"
#import "FileListFileCell.h"
#import "FileListFolderCell.h"

#import "SettingTextViewController.h"
#import "FolderToMoveViewController.h"
#import "QBImagePickerController.h"
#import "NFileListViewController.h"
#import "FileViewController.h"

#import "EaseToolBar.h"
#import "Helper.h"

@interface NProjectFileListView ()<UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, EaseToolBarDelegate, QBImagePickerControllerDelegate, UISearchBarDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) EaseToolBar *myToolBar, *myEditToolBar;
@property (strong, nonatomic) UISearchBar *mySearchBar;

@property (nonatomic, strong) Project *curProject;
@property (strong, nonatomic) ProjectFile *curFolder;
@property (strong, nonatomic) ProjectFiles *myFiles;

@property (strong, nonatomic) NSArray<NSString *> *uploadFiles;
@property (nonatomic, strong) NSMutableArray *fileList, *folderList;
@end

@implementation NProjectFileListView

- (id)initWithFrame:(CGRect)frame project:(Project *)project folder:(ProjectFile *)folder{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _curProject = project;
        _curFolder = folder ?: [[ProjectFile alloc] initWithFileId:@0 inProject:project.name ofUser:project.owner_user_name];
        _myFiles = [[ProjectFiles alloc] init];
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[FileListFolderCell class] forCellReuseIdentifier:kCellIdentifier_FileListFolder];
            [tableView registerClass:[FileListFileCell class] forCellReuseIdentifier:kCellIdentifier_FileListFile];
            [tableView registerClass:[FileListUploadCell class] forCellReuseIdentifier:kCellIdentifier_FileListUpload];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            tableView.allowsMultipleSelectionDuringEditing = YES;
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
            [searchBar setPlaceholderColor:kColorDarkA];
            [searchBar setSearchIcon:[UIImage imageNamed:@"icon_search_searchbar"]];
            searchBar;
        });
        _myTableView.tableHeaderView = _mySearchBar;
        
        _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [self refresh];
        
        __weak typeof(self) weakSelf = self;
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationUploadCompled object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
            //{NSURLResponse: response, NSError: error, ProjectFile: data}
            NSDictionary* userInfo = [aNotification userInfo];
            [weakSelf completionUploadWithResult:[userInfo objectForKey:@"data"] error:[userInfo objectForKey:@"error"]];
        }];

    }
    return self;
}

- (void)changeEditState{
    [self changeEditStateToEditing:!_myTableView.isEditing];
}

- (void)changeEditStateToEditing:(BOOL)isEditing{
    [_myTableView setEditing:isEditing animated:YES];
    NSArray *rightBarButtonItems;
    if (isEditing) {
        UIBarButtonItem *item1 = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(changeEditState)];
//        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        spaceItem.width = 20;
//        UIBarButtonItem *item2 = [UIBarButtonItem itemWithBtnTitle:@"反选" target:self action:@selector(reverseSelect)];
//        rightBarButtonItems = @[item1, spaceItem, item2];
        rightBarButtonItems = @[item1];
        _myTableView.tableHeaderView = nil;
    }else{
        UIBarButtonItem *item1 = [UIBarButtonItem itemWithBtnTitle:@"编辑" target:self action:@selector(changeEditState)];
        rightBarButtonItems = @[item1];
        _myTableView.tableHeaderView = _mySearchBar;
    }
    [self.containerVC.navigationItem setRightBarButtonItems:rightBarButtonItems animated:YES];
    [self configToolBar];
    [self.myTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (void)reverseSelect{
    if (_myTableView.isEditing) {
        NSArray *selectedIndexList = [_myTableView indexPathsForSelectedRows];
        NSInteger startIndex = _uploadFiles.count;
        NSInteger endIndex = [self totalDataRow];
        NSMutableArray *reverseIndexList = [[NSMutableArray alloc] init];
        for (NSInteger index = startIndex; index < endIndex; index++) {
            NSIndexPath *curIndex = [NSIndexPath indexPathForRow:index inSection:0];
            if (![selectedIndexList containsObject:curIndex]) {
                [reverseIndexList addObject:curIndex];
            }
        }
        for (NSIndexPath *indexPath in selectedIndexList) {
            [_myTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        for (NSIndexPath *indexPath in reverseIndexList) {
            [_myTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)configuploadFiles{
    self.uploadFiles = [Coding_FileManager uploadFilesInProject:self.curProject.id.stringValue andFolder:self.curFolder.file_id.stringValue];
    if (!self.uploadFiles) {
        self.uploadFiles = [NSArray array];
    }
    [self updateDataWithSearchStr];
    //更新空白页状态
    [self configBlankPage:EaseBlankPageTypeFile hasData:([self totalDataRow] > 0) hasError:NO reloadButtonBlock:^(id sender) {
        [self refresh];
    }];
}

- (void)configToolBar{
    //添加底部ToolBar
    if (!_myToolBar) {
        EaseToolBarItem *item1 = [EaseToolBarItem easeToolBarItemWithTitle:@"新建文件夹" image:@"button_file_createFolder_enable" disableImage:@"button_file_createFolder_unable"];
        EaseToolBarItem *item2 = [EaseToolBarItem easeToolBarItemWithTitle:@"上传文件" image:@"button_file_upload_enable" disableImage:nil];
        _myToolBar = [EaseToolBar easeToolBarWithItems:@[item1, item2]];
        _myToolBar.delegate = self;
        [self addSubview:_myToolBar];
        [_myToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom);
            make.size.mas_equalTo(_myToolBar.frame.size);
        }];
    }
    
    if (!_myEditToolBar) {
        EaseToolBarItem *item1 = [EaseToolBarItem easeToolBarItemWithTitle:@"下载" image:@"button_file_download_enable" disableImage:@"button_file_createFolder_unable"];
        EaseToolBarItem *item2 = [EaseToolBarItem easeToolBarItemWithTitle:@"移动" image:@"button_file_move_enable" disableImage:nil];
        EaseToolBarItem *item3 = [EaseToolBarItem easeToolBarItemWithTitle:@"删除" image:@"button_file_denete_enable" disableImage:nil];
        _myEditToolBar = [EaseToolBar easeToolBarWithItems:@[item1, item2, item3]];
        _myEditToolBar.delegate = self;
        [self addSubview:_myEditToolBar];
        [_myEditToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom);
            make.size.mas_equalTo(_myToolBar.frame.size);
        }];
    }
    
    if (_myTableView.isEditing) {
        _myToolBar.hidden = YES;
        _myEditToolBar.hidden = NO;
    }else{
        _myToolBar.hidden = NO;
        _myEditToolBar.hidden = YES;
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myToolBar.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
}

- (void)refresh{
    [self configuploadFiles];
    [self configToolBar];
    self.containerVC.title = _curFolder.name ?: _curFolder.project_name;
    if (![_curProject.id isKindOfClass:[NSNumber class]]) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:_curProject andBlock:^(id data, NSError *error) {
            weakSelf.curProject = data;
        }];
    }
    if (!_myFiles.isLoading) {
        if ([self totalDataRow] <= 0) {
            [self beginLoading];
        }
        __weak typeof(self) weakSelf = self;
        weakSelf.myFiles.isLoading = YES;
        [[Coding_NetAPIManager sharedManager] request_FilesInFolder:_curFolder andBlock:^(id data, NSError *error) {
            weakSelf.myFiles.isLoading = NO;
            [weakSelf.refreshControl endRefreshing];
            [weakSelf endLoading];
            if (data) {
                weakSelf.myFiles = data;
                if (weakSelf.curFolder.isDefaultFolder && weakSelf.myFiles.list.count > 0) {
                    [weakSelf.myFiles addSharedFolder];
                }
                [weakSelf updateDataWithSearchStr];
            }
            [weakSelf configBlankPage:EaseBlankPageTypeFile hasData:([weakSelf totalDataRow] > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
                [weakSelf refresh];
            }];
        }];
    }
}

#pragma mark EaseToolBarDelegate
- (void)easeToolBar:(EaseToolBar *)toolBar didClickedIndex:(NSInteger)index{
    if (toolBar == _myToolBar) {
        switch (index) {
            case 0:
                [self creatFolderBtnClicked];
                break;
            case 1:
                [self uploadFileBtnClicked];
                break;
            default:
                break;
        }
    }else if (toolBar == _myEditToolBar){
        switch (index) {
            case 0:
                [self downloadFilesBtnClicked];
                break;
            case 1:
                [self moveFilesBtnClicked];
                break;
            case 2:
                [self deleteFilesBtnClicked];
                break;
            default:
                break;
        }
    }
    
}

- (void)creatFolderBtnClicked{
    DebugLog(@"新建文件夹");
    __weak typeof(self) weakSelf = self;
    [SettingTextViewController showSettingFolderNameVCFromVC:self.containerVC withTitle:@"新建文件夹" textValue:nil type:SettingTypeNewFolderName doneBlock:^(NSString *textValue) {
        DebugLog(@"%@", textValue);
        [[Coding_NetAPIManager sharedManager] request_CreatFolder:textValue inFolder:weakSelf.curFolder inProject:weakSelf.curProject andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf.myFiles.folderList insertObject:data atIndex:0];
                [weakSelf updateDataWithSearchStr];
                [weakSelf configBlankPage:EaseBlankPageTypeFile hasData:([weakSelf totalDataRow] > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
                    [weakSelf refresh];
                }];
                [NSObject showHudTipStr:@"创建文件夹成功"];
            }
        }];
    }];
}

- (void)uploadFileBtnClicked{
    DebugLog(@"上传文件");
    //        相册
    if (![Helper checkPhotoLibraryAuthorizationStatus]) {
        return;
    }
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 6;
    [self.containerVC presentViewController:imagePickerController animated:YES completion:NULL];
}

- (NSArray *)selectedFiles{
    NSArray *selectedIndexPath = [_myTableView indexPathsForSelectedRows];
    NSMutableArray *selectedFiles = [[NSMutableArray alloc] initWithCapacity:selectedIndexPath.count];
    for (NSIndexPath *indexPath in selectedIndexPath) {
        if (indexPath.row >= _folderList.count + _uploadFiles.count) {
            ProjectFile *file = [_fileList objectAtIndex:(indexPath.row - _folderList.count - _uploadFiles.count)];
            [selectedFiles addObject:file];
        }else if (indexPath.row >= _uploadFiles.count){
            ProjectFile *file = [_folderList objectAtIndex:(indexPath.row - _uploadFiles.count)];
            [selectedFiles addObject:file];
        }
    }
    return selectedFiles;
}

- (void)downloadFilesBtnClicked{
    NSMutableArray *selectedFiles = [self selectedFiles].mutableCopy;
    [selectedFiles removeObjectsInArray:self.folderList];//文件夹暂时不支持批量下载
    if (selectedFiles.count > 0) {
        NSInteger downloadedCount = 0, downloadingCount = 0, addDownloadCount = 0;
        
        Coding_FileManager *manager = [Coding_FileManager sharedManager];
        for (ProjectFile *file in selectedFiles) {
            if ([file diskFileUrl]) {//已下载
                downloadedCount++;
                DebugLog(@"%@: 已在队列", file.name);
            }else if ([file cDownloadTask]) {//正在下载
                downloadingCount++;
                DebugLog(@"%@: 已在队列", file.name);
            }else{
                addDownloadCount++;
                [manager addDownloadTaskForObj:file completionHandler:nil];
            }
        }
        if (addDownloadCount == 0) {
            NSString *tipStr = downloadingCount == 0? @"所选的文件都已经下载到本地了" : @"所选的文件都已经在下载队列中了";
            [NSObject showHudTipStr:tipStr];
        }
    }
    [self changeEditStateToEditing:NO];
}

- (void)moveFilesBtnClicked{
    NSArray *selectedFiles = [self selectedFiles];
    if (selectedFiles.count > 0) {
        [self moveFiles:selectedFiles fromFolder:self.curFolder];
    }
}
- (void)deleteFilesBtnClicked{
    __weak typeof(self) weakSelf = self;
    NSArray *selectedFiles = [self selectedFiles];
    if (selectedFiles.count > 0) {
        [[UIAlertController ea_actionSheetCustomWithTitle:[NSString stringWithFormat:@"确认删除选定的 %lu 个文件？\n删除后将无法恢复!", (unsigned long)selectedFiles.count] buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
            if (index == 0) {
                [weakSelf deleteFiles:selectedFiles];
                [weakSelf changeEditStateToEditing:NO];
            }
        }] showInView:self];
    }
}

- (void)deleteFiles:(NSArray *)selectedFiles{
    NSMutableArray *fileIdList = [[NSMutableArray alloc] initWithCapacity:selectedFiles.count];
    for (ProjectFile *file in selectedFiles) {
        [fileIdList addObject:file.file_id];
        [self deleteFile:file fromDisk:YES];//先要处理正在下载的和已下载的文件
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteFiles:fileIdList inProject:self.curProject.id andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf refresh];
        }
    }];
}

#pragma mark QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets{
    NSMutableArray *needToUploads = [NSMutableArray arrayWithCapacity:assets.count];
    for (PHAsset *assetItem in assets) {
        //保存到app内
        NSString* originalFileName = assetItem.fileName;
        NSString *fileName = [NSString stringWithFormat:@"%@|||%@|||%@", self.curProject.id.stringValue, self.curFolder.file_id.stringValue, originalFileName];
        if ([Coding_FileManager writeUploadDataWithName:fileName andAsset:assetItem]) {
            [needToUploads addObject:fileName];
        }else{
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@ 文件处理失败", originalFileName]];
        }
    }
    for (NSString *fileName in needToUploads) {
        [self uploadFileWithFileName:fileName];
    }
    [self configBlankPage:EaseBlankPageTypeFile hasData:([self totalDataRow] > 0) hasError:NO reloadButtonBlock:^(id sender) {
        [self refresh];
    }];
    
    [self.containerVC dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [self.containerVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark uploadTask
- (void)uploadFileWithFileName:(NSString *)fileName{
    __weak typeof(self) weakSelf = self;
    if ([NSObject isPrivateCloud].boolValue) {
        [[Coding_FileManager sharedManager] addUploadTaskWithFileName:fileName projectIsPublic:_curProject.is_public.boolValue];
        [self configuploadFiles];
    }else{
        [[Coding_FileManager sharedManager] addUploadTaskWithFileName:fileName isQuick:NO resultBlock:^(Coding_UploadTask *uploadTask) {
            [weakSelf configuploadFiles];
        }];
    }
}

- (void)removeUploadTaskWithFileName:(NSString *)fileName{
    [Coding_FileManager cancelCUploadTaskForFile:fileName hasError:NO];
    [self configuploadFiles];
}

- (void)completionUploadWithResult:(id)responseObject error:(NSError *)error{
    if (!responseObject || ![responseObject isKindOfClass:[ProjectFile class]]) {
        return;
    }
    ProjectFile *curFile = responseObject;
    if (curFile.parent_id.integerValue != self.curFolder.file_id.integerValue) {
        return;
    }
    if (curFile.project_id && curFile.project_id.integerValue != self.curProject.id.integerValue) {
        return;
    }
    [self.myFiles.fileList insertObject:curFile atIndex:0];
    self.curFolder.count = @(self.curFolder.count.integerValue +1);
    [self configuploadFiles];
    [self configBlankPage:EaseBlankPageTypeFile hasData:([self totalDataRow] > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
        [self refresh];
    }];
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.mySearchBar resignFirstResponder];
    }
}

#pragma mark Table M
- (NSInteger)totalDataRow{
    return (_uploadFiles.count + _folderList.count + _fileList.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self totalDataRow];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (indexPath.row < _uploadFiles.count) {
        FileListUploadCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileListUpload forIndexPath:indexPath];
        cell.fileName = [self.uploadFiles objectAtIndex:indexPath.row];
        cell.reUploadBlock = ^(NSString *fileName){
            [weakSelf uploadFileWithFileName:fileName];
        };
        cell.cancelUploadBlock = ^(NSString *fileName){
            [weakSelf removeUploadTaskWithFileName:fileName];
        };
        return cell;
    }else if (indexPath.row < _folderList.count + _uploadFiles.count) {
        FileListFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileListFolder forIndexPath:indexPath];
        ProjectFile *folder = [_folderList objectAtIndex:indexPath.row - _uploadFiles.count];
        cell.folder = folder;
        [cell setRightUtilityButtons:[self rightButtonsWithObj:folder] WithButtonWidth:[FileListFolderCell cellHeight]];
        cell.delegate = self;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        FileListFileCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileListFile forIndexPath:indexPath];
        ProjectFile *file = [_fileList objectAtIndex:(indexPath.row - _folderList.count - _uploadFiles.count)];
        cell.file = file;
        cell.showDiskFileBlock = ^(NSURL *fileUrl, ProjectFile *file){
            [weakSelf goToFileVC:file];
        };
        [cell setRightUtilityButtons:[self rightButtonsWithObj:file] WithButtonWidth:[FileListFileCell cellHeight]];
        cell.delegate = self;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.row < _uploadFiles.count) {
        cellHeight = [FileListUploadCell cellHeight];
    }else if (indexPath.row < _folderList.count + _uploadFiles.count) {
        cellHeight = [FileListFolderCell cellHeight];
    }else{
        cellHeight = [FileListFileCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing) {
        if (indexPath.row < _uploadFiles.count) {
            [NSObject showHudTipStr:@"正在上传的不能批处理"];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }else if (indexPath.row < _folderList.count + _uploadFiles.count) {
            ProjectFile *clickedFolder = [_folderList objectAtIndex:indexPath.row - _uploadFiles.count];
            if (clickedFolder.isSharedFolder) {
                [NSObject showHudTipStr:@"分享中文件夹不支持编辑"];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row < _uploadFiles.count) {
            
        }else if (indexPath.row < _folderList.count + _uploadFiles.count) {
            ProjectFile *clickedFolder = [_folderList objectAtIndex:indexPath.row - _uploadFiles.count];
            [self goToVCWithFolder:clickedFolder inProject:self.curProject];
        }else{
            ProjectFile *file = [_fileList objectAtIndex:(indexPath.row - _folderList.count - _uploadFiles.count)];
            [self goToFileVC:file];
        }
    }
}

#pragma mark Edit Table
- (NSArray *)rightButtonsWithObj:(ProjectFile *)obj{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if (!obj.isSharedFolder) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:kColorD8DDE4 icon:[UIImage imageNamed:@"icon_file_cell_move"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xF2F4F6"] icon:[UIImage imageNamed:@"icon_file_cell_rename"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xF66262"] icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
    }
    return rightUtilityButtons;
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    if (state == kCellStateRight) {
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
        
        if (indexPath.row < _uploadFiles.count) {
            return NO;
        }else if (indexPath.row >= _folderList.count + _uploadFiles.count) {
            ProjectFile *file = [_fileList objectAtIndex:(indexPath.row - _folderList.count - _uploadFiles.count)];
            Coding_DownloadTask *cDownloadTask = file.cDownloadTask;
            if (cDownloadTask && cDownloadTask.task && cDownloadTask.task.state == NSURLSessionTaskStateRunning) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    if (indexPath.row < _folderList.count + _uploadFiles.count && indexPath.row >= _uploadFiles.count) {
        ProjectFile *folder = [_folderList objectAtIndex:indexPath.row - _uploadFiles.count];
        NSInteger buttonCount = cell.rightUtilityButtons.count;
        if (index == buttonCount - 3) {//移动
            [self moveFolder:folder fromFolder:self.curFolder];
        }else if (index == buttonCount - 2) {//重命名
            [self renameFolder:folder];
        }else{//删除
            __weak typeof(self) weakSelf = self;
            UIAlertController *actionSheet = [UIAlertController ea_actionSheetCustomWithTitle:[NSString stringWithFormat:@"确定要删除文件夹:%@？",folder.name] buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
                if (index == 0) {
                    [weakSelf deleteFolder:folder];
                }
            }];
            [actionSheet showInView:self];
        }
    }else{
        ProjectFile *file = [_fileList objectAtIndex:(indexPath.row - _folderList.count - _uploadFiles.count)];
        if (index == 0) {
            [self moveFiles:@[file] fromFolder:self.curFolder];
        }else if (index == 1){
            [self renameFile:file];
        }else{
            [self deleteFile:file];
        }
    }
}

- (void)deleteFolder:(ProjectFile *)folder{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteFolder:folder andBlock:^(id data, NSError *error) {
        if (data) {
            ProjectFile *originalFolder = (ProjectFile *)data;
            DebugLog(@"删除文件夹成功:%@", originalFolder.name);
            [weakSelf.myFiles.folderList removeObject:originalFolder];
            weakSelf.curFolder.count = [NSNumber numberWithInt:weakSelf.curFolder.count.intValue-1];
            [weakSelf updateDataWithSearchStr];
            [weakSelf configBlankPage:EaseBlankPageTypeFile hasData:([weakSelf totalDataRow] > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
                [weakSelf refresh];
            }];
        }
    }];
}
- (void)renameFolder:(ProjectFile *)folder{
    __weak typeof(self) weakSelf = self;
    @weakify(folder);
    [SettingTextViewController showSettingFolderNameVCFromVC:nil withTitle:@"重命名文件夹" textValue:folder.name type:SettingTypeFolderName doneBlock:^(NSString *textValue) {
        @strongify(folder);
        folder.next_name = textValue;
        [[Coding_NetAPIManager sharedManager] request_RenameFolder:folder andBlock:^(id data, NSError *error) {
            if (data) {
                ProjectFile *originalFolder = (ProjectFile *)data;
                originalFolder.name = originalFolder.next_name;
                [NSObject showHudTipStr:[NSString stringWithFormat:@"成功重命名为:%@", originalFolder.name]];
                [weakSelf updateDataWithSearchStr];
            }
        }];
    }];
}
- (void)renameFile:(ProjectFile *)file{
    __weak typeof(self) weakSelf = self;
    @weakify(file);
    NSString *nameValue = file.name;
    NSRange rangeOfType = [nameValue rangeOfString:[NSString stringWithFormat:@".%@", file.fileType] options:NSBackwardsSearch];
    if (rangeOfType.location != NSNotFound) {
        nameValue = [nameValue stringByReplacingCharactersInRange:rangeOfType withString:@""];
    }
    [SettingTextViewController showSettingFolderNameVCFromVC:nil withTitle:@"重命名文件" textValue:nameValue type:SettingTypeFolderName doneBlock:^(NSString *textValue) {
        textValue = [NSString stringWithFormat:@"%@.%@", textValue, file.fileType];
        @strongify(file);
        [[Coding_NetAPIManager sharedManager] request_RenameFile:file withName:textValue andBlock:^(id data, NSError *error) {
            if (data) {
                file.name = textValue;
                [NSObject showHudTipStr:[NSString stringWithFormat:@"成功重命名为:%@", file.name]];
                [weakSelf updateDataWithSearchStr];
            }
        }];
    }];
}
- (void)deleteFile:(ProjectFile *)file{
    __weak typeof(self) weakSelf = self;
    __weak typeof(file) weakFile = file;
    
    NSURL *fileUrl = [file diskFileUrl];
    Coding_DownloadTask *cDownloadTask = [file cDownloadTask];
    UIAlertController *actionSheet;
    
    if (fileUrl) {
        actionSheet = [UIAlertController ea_actionSheetCustomWithTitle:@"只是删除本地文件还是连同服务器文件一起删除？" buttonTitles:@[@"仅删除本地文件"] destructiveTitle:@"一起删除" cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
            switch (index) {
                case 0:
                    [weakSelf deleteFile:weakFile fromDisk:YES];
                    break;
                case 1:
                    [weakSelf deleteFile:weakFile fromDisk:NO];
                    break;
                default:
                    break;
            }
        }];
    }else if (cDownloadTask){
        actionSheet = [UIAlertController ea_actionSheetCustomWithTitle:@"确定将服务器上的该文件删除？" buttonTitles:@[@"只是取消下载"] destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
            switch (index) {
                case 0:
                    [weakSelf deleteFile:weakFile fromDisk:YES];
                    break;
                case 1:
                    [weakSelf deleteFile:weakFile fromDisk:NO];
                    break;
                default:
                    break;
            }
        }];
    }else{
        actionSheet = [UIAlertController ea_actionSheetCustomWithTitle:@"确定将服务器上的该文件删除？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
            if (index == 0) {
                [weakSelf deleteFile:weakFile fromDisk:NO];
            }
        }];
    }
    [actionSheet showInView:self];
}
- (void)deleteFile:(ProjectFile *)file fromDisk:(BOOL)fromDisk{
    
    //    取消当前的下载任务
    Coding_DownloadTask *cDownloadTask = [file cDownloadTask];
    if (cDownloadTask) {
        [Coding_FileManager cancelCDownloadTaskForKey:file.storage_key];
    }
    //    删除本地文件
    NSURL *fileUrl = [file diskFileUrl];
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
        [[Coding_NetAPIManager sharedManager] request_DeleteFiles:@[file.file_id] inProject:self.curProject.id andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf refresh];
            }
        }];
    }
}
- (void)moveFiles:(NSArray *)files fromFolder:(ProjectFile *)folder{
    NSMutableArray *fileIdList = [[NSMutableArray alloc] initWithCapacity:files.count];
    for (ProjectFile *file in files) {
        [fileIdList addObject:file.file_id];
    }
    __weak typeof(self) weakSelf = self;
    FolderToMoveViewController *vc = [[FolderToMoveViewController alloc] init];
    vc.fromFolder = folder;
    vc.toMovedIdList = fileIdList;
    vc.curProject = self.curProject;
    vc.curFolder = nil;
    vc.moveToFolderBlock = ^(ProjectFile *curFolder, NSArray *toMovedIdList){
        [weakSelf changeEditStateToEditing:NO];
        [[Coding_NetAPIManager sharedManager] request_MoveFiles:toMovedIdList toFolder:curFolder andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf refresh];
            }
        }];
    };
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self.containerVC presentViewController:nav animated:YES completion:nil];
}

- (void)moveFolder:(ProjectFile *)movedFolder fromFolder:(ProjectFile *)folder{
    __weak typeof(self) weakSelf = self;
    FolderToMoveViewController *vc = [[FolderToMoveViewController alloc] init];
    vc.isMoveFolder = YES;
    vc.fromFolder = folder;
    vc.toMovedIdList = @[movedFolder.file_id];
    vc.curProject = self.curProject;
    vc.curFolder = nil;
    vc.moveToFolderBlock = ^(ProjectFile *curFolder, NSArray *toMovedIdList){
        [weakSelf changeEditStateToEditing:NO];
        [[Coding_NetAPIManager sharedManager] request_MoveFolder:toMovedIdList.firstObject toFolder:curFolder  inProject:weakSelf.curProject andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf refresh];
            }
        }];
    };
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self.containerVC presentViewController:nav animated:YES completion:nil];
}
#pragma mark toVC
- (void)goToVCWithFolder:(ProjectFile *)folder inProject:(Project *)project{
    NFileListViewController *vc = [[NFileListViewController alloc] init];
    vc.curFolder = folder;
    vc.curProject = project;
    [self.containerVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToFileVC:(ProjectFile *)file{
    FileViewController *vc = [FileViewController vcWithFile:file andVersion:nil];
    @weakify(self);
    vc.fileHasBeenDeletedBlock = ^(){
        @strongify(self);
        [self refresh];
    };
    vc.fileHasChangedBlock = ^(){
        @strongify(self);
        [self refresh];
    };
    [self.containerVC.navigationController pushViewController:vc animated:YES];
}
#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self updateDataWithSearchStr];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)updateDataWithSearchStr{
    _fileList = _myFiles.fileList.mutableCopy;
    _folderList = _myFiles.folderList.mutableCopy;
    NSString *strippedStr = [_mySearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (strippedStr.length > 0 && ![strippedStr isEmpty]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", strippedStr];
        [_folderList filterUsingPredicate:predicate];
        [_fileList filterUsingPredicate:predicate];
    }
    [self.containerVC.navigationItem setRightBarButtonItem:self.fileList.count + self.folderList.count > 0? [UIBarButtonItem itemWithBtnTitle:@"编辑" target:self action:@selector(changeEditState)]: nil animated:YES];
    [_myTableView reloadData];
}


@end
