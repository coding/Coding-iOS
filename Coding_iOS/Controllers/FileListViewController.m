//
//  FileListViewController.m
//  Coding_iOS
//
//  Created by Ease on 14/11/14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "FileListViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "FileListFolderCell.h"
#import "FileListFileCell.h"
#import "ProjectFiles.h"
#import "BasicPreviewItem.h"
#import "SettingTextViewController.h"
#import "FolderToMoveViewController.h"
#import "FileViewController.h"
#import "EaseToolBar.h"
#import "QBImagePickerController.h"
#import "Helper.h"
#import "FileListUploadCell.h"
#import "Coding_FileManager.h"


@interface FileListViewController () <SWTableViewCellDelegate, EaseToolBarDelegate, QBImagePickerControllerDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (strong, nonatomic) ProjectFiles *myFiles;
@property (nonatomic, strong) EaseToolBar *myToolBar, *myEditToolBar;
@property (strong, nonatomic) NSArray *uploadFiles;

@end

@implementation FileListViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.curFolder.name;
    _myFiles = [[ProjectFiles alloc] init];
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[FileListFolderCell class] forCellReuseIdentifier:kCellIdentifier_FileListFolder];
        [tableView registerClass:[FileListFileCell class] forCellReuseIdentifier:kCellIdentifier_FileListFile];
        [tableView registerClass:[FileListUploadCell class] forCellReuseIdentifier:kCellIdentifier_FileListUpload];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.allowsMultipleSelectionDuringEditing = YES;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refreshRootFolders) forControlEvents:UIControlEventValueChanged];
    
    if (!self.rootFolders) {
        self.rootFolders = [ProjectFolders emptyFolders];
    }
    [self refresh];
    
    __weak typeof(self) weakSelf = self;
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationUploadCompled object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
        //{NSURLResponse: response, NSError: error, ProjectFile: data}
        NSDictionary* userInfo = [aNotification userInfo];
        [weakSelf completionUploadWithResult:[userInfo objectForKey:@"data"] error:[userInfo objectForKey:@"error"]];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_myTableView.isEditing) {
        [_myTableView reloadData];
    }
}

- (void)changeEditState{
    [self changeEditStateToEditing:!_myTableView.isEditing];
}

- (void)changeEditStateToEditing:(BOOL)isEditing{
    [_myTableView setEditing:isEditing animated:YES];
    NSArray *rightBarButtonItems;
    if (isEditing) {
        UIBarButtonItem *item1 = [UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(changeEditState)];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = 20;
        UIBarButtonItem *item2 = [UIBarButtonItem itemWithBtnTitle:@"反选" target:self action:@selector(reverseSelect)];
        rightBarButtonItems = @[item1, spaceItem, item2];
    }else{
        UIBarButtonItem *item1 = [UIBarButtonItem itemWithBtnTitle:@"编辑" target:self action:@selector(changeEditState)];
        rightBarButtonItems = @[item1];
    }
    [self.navigationItem setRightBarButtonItems:rightBarButtonItems animated:YES];
    [self configToolBar];
    [self.myTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (void)reverseSelect{
    if (_myTableView.isEditing) {
        NSArray *selectedIndexList = [_myTableView indexPathsForSelectedRows];
        NSInteger startIndex = _curFolder.sub_folders.count + _uploadFiles.count;
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
    [self.myTableView reloadData];
}

- (void)configToolBar{
    //添加底部ToolBar
    if (!_myToolBar) {
        EaseToolBarItem *item1 = [EaseToolBarItem easeToolBarItemWithTitle:@" 新建文件夹" image:@"button_file_createFolder_enable" disableImage:@"button_file_createFolder_unable"];
        EaseToolBarItem *item2 = [EaseToolBarItem easeToolBarItemWithTitle:@" 上传文件" image:@"button_file_upload_enable" disableImage:nil];
        _myToolBar = [EaseToolBar easeToolBarWithItems:@[item1, item2]];
        _myToolBar.delegate = self;
        [self.view addSubview:_myToolBar];
        [_myToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
            make.size.mas_equalTo(_myToolBar.frame.size);
        }];
    }
    
    if (!_myEditToolBar) {
        EaseToolBarItem *item1 = [EaseToolBarItem easeToolBarItemWithTitle:@" 下载" image:@"button_file_download_enable" disableImage:@"button_file_createFolder_unable"];
        EaseToolBarItem *item2 = [EaseToolBarItem easeToolBarItemWithTitle:@" 移动" image:@"button_file_move_enable" disableImage:nil];
        EaseToolBarItem *item3 = [EaseToolBarItem easeToolBarItemWithTitle:@" 删除" image:@"button_file_denete_enable" disableImage:nil];
        _myEditToolBar = [EaseToolBar easeToolBarWithItems:@[item1, item2, item3]];
        _myEditToolBar.delegate = self;
        [self.view addSubview:_myEditToolBar];
        [_myEditToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
            make.size.mas_equalTo(_myToolBar.frame.size);
        }];
    }
    
    if (_myTableView.isEditing) {
        _myToolBar.hidden = YES;
        _myEditToolBar.hidden = NO;
    }else{
        _myToolBar.hidden = NO;
        _myEditToolBar.hidden = YES;
        
        EaseToolBarItem *item1 = [_myToolBar itemOfIndex:0];
        item1.enabled = [self canCreatNewFolder];
        EaseToolBarItem *item2 = [_myToolBar itemOfIndex:1];
        item2.enabled = [self canUploadNewFile];
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myToolBar.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
}

- (BOOL)canCreatNewFolder{
    return (self.curFolder == nil || (self.curFolder.parent_id.intValue == 0 && ![_curFolder isDefaultFolder] && ![_curFolder isShareFolder]));
}

- (BOOL)canUploadNewFile{
    return ![self.curFolder isShareFolder];
}

- (void)refresh{
    [self configuploadFiles];
    if (![self.rootFolders isEmpty]) {
        [self configToolBar];
        [self refreshFileList];
    }else{
        [self refreshRootFolders];
    }
}

- (void)refreshRootFolders{
    if (_rootFolders.isLoading) {
        return;
    }
    [self sendRequestRootFolders];
}

- (void)sendRequestRootFolders{
    if ([self totalDataRow] <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Folders:_rootFolders inProject:_curProject andBlock:^(id data, NSError *error) {
        if (data) {
            ProjectFolders *preRootFolders = weakSelf.rootFolders;
            weakSelf.rootFolders = data;
            ProjectFolder *curFolder = [weakSelf.rootFolders hasFolderWithId:weakSelf.curFolder.file_id];
            if (curFolder) {
                weakSelf.curFolder = curFolder;
                weakSelf.title = curFolder.name;
                [weakSelf configuploadFiles];
                [weakSelf configToolBar];
                [weakSelf refreshFileList];
            }else{
                [weakSelf.refreshControl endRefreshing];
                [weakSelf.view endLoading];
                weakSelf.rootFolders = preRootFolders;
                [NSObject showHudTipStr:@"文件夹不存在"];
                weakSelf.navigationItem.rightBarButtonItem = nil;
                [weakSelf.view configBlankPage:EaseBlankPageTypeFolderDleted hasData:([weakSelf totalDataRow] > 0) hasError:NO reloadButtonBlock:nil];
            }
        }else{
            [weakSelf.refreshControl endRefreshing];
            [weakSelf.view endLoading];
            [weakSelf.view configBlankPage:EaseBlankPageTypeFile hasData:([weakSelf totalDataRow] > 0) hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf refreshRootFolders];
            }];
        }
    }];
}

- (void)refreshFileList{
    if (_myFiles.isLoading) {
        return;
    }
    [self sendRequestFileList];
}

- (void)sendRequestFileList{
    if ([self totalDataRow] <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    weakSelf.myFiles.isLoading = YES;
    [[Coding_NetAPIManager sharedManager] request_FilesInFolder:_curFolder andBlock:^(id data, NSError *error) {
        weakSelf.myFiles.isLoading = NO;
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.view endLoading];
        if (data) {
            weakSelf.myFiles = data;
            
            self.navigationItem.rightBarButtonItem = weakSelf.myFiles.list.count > 0? [UIBarButtonItem itemWithBtnTitle:@"编辑" target:self action:@selector(changeEditState)]: nil;

            [weakSelf.myTableView reloadData];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeFile hasData:([weakSelf totalDataRow] > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refreshRootFolders];
        }];
    }];
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
    [SettingTextViewController showSettingFolderNameVCFromVC:self withTitle:@"新建文件夹" textValue:nil type:SettingTypeNewFolderName doneBlock:^(NSString *textValue) {
        DebugLog(@"%@", textValue);
        [[Coding_NetAPIManager sharedManager] request_CreatFolder:textValue inFolder:weakSelf.curFolder inProject:weakSelf.curProject andBlock:^(id data, NSError *error) {
            if (data) {
                if (weakSelf.curFolder) {
                    [weakSelf.curFolder.sub_folders insertObject:data atIndex:0];
                }else{
                    [weakSelf.rootFolders.list insertObject:data atIndex:1];
                }
                [weakSelf.myTableView reloadData];
                [weakSelf.view configBlankPage:EaseBlankPageTypeFile hasData:([weakSelf totalDataRow] > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
                    [weakSelf refreshRootFolders];
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
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

- (NSArray *)selectedFiles{
    NSArray *selectedIndexPath = [_myTableView indexPathsForSelectedRows];
    NSMutableArray *selectedFiles = [[NSMutableArray alloc] initWithCapacity:selectedIndexPath.count];
    for (NSIndexPath *indexPath in selectedIndexPath) {
        if (indexPath.row >= _curFolder.sub_folders.count + _uploadFiles.count) {
            ProjectFile *file = [_myFiles.list objectAtIndex:(indexPath.row - _curFolder.sub_folders.count - _uploadFiles.count)];
            [selectedFiles addObject:file];
        }
    }
    return selectedFiles;
}

- (void)downloadFilesBtnClicked{
    NSArray *selectedFiles = [self selectedFiles];
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
        [self changeEditStateToEditing:NO];
    }
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
        [[UIActionSheet bk_actionSheetCustomWithTitle:[NSString stringWithFormat:@"确认删除选定的 %lu 个文件？\n删除后将无法恢复!", (unsigned long)selectedFiles.count] buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf deleteFiles:selectedFiles];
                [weakSelf changeEditStateToEditing:NO];
            }
        }] showInView:self.view];
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
            [weakSelf refreshRootFolders];
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
    [self.view configBlankPage:EaseBlankPageTypeFile hasData:([self totalDataRow] > 0) hasError:NO reloadButtonBlock:^(id sender) {
        [self refreshRootFolders];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark uploadTask
- (void)uploadFileWithFileName:(NSString *)fileName{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    [manager addUploadTaskWithFileName:fileName projectIsPublic:_curProject.is_public.boolValue];
    [self configuploadFiles];
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
    
    NSRange range = [curFile.owner_preview rangeOfString:@"project/"];
    if (curFile.owner_preview && range.location != NSNotFound) {
        NSString *project_id = [[[curFile.owner_preview substringFromIndex:(range.location+range.length)] componentsSeparatedByString:@"/"] firstObject];
        if (project_id && project_id.integerValue != self.curProject.id.integerValue) {
            return;
        }
    }
    
    curFile.project_id = self.curProject.id;
    [self.myFiles.list insertObject:curFile atIndex:0];
    self.curFolder.count = @(self.curFolder.count.integerValue +1);
    [self configuploadFiles];
    [self.view configBlankPage:EaseBlankPageTypeFile hasData:([self totalDataRow] > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
        [self refreshRootFolders];
    }];
    if (self.navigationItem.rightBarButtonItem == nil) {
        self.navigationItem.rightBarButtonItem = self.myFiles.list.count > 0? [UIBarButtonItem itemWithBtnTitle:@"编辑" target:self action:@selector(changeEditState)]: nil;
    }
}


#pragma mark Table M
- (NSInteger)totalDataRow{
    return (_uploadFiles.count + _curFolder.sub_folders.count + _myFiles.list.count);
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
    }else if (indexPath.row < _curFolder.sub_folders.count + _uploadFiles.count) {
        FileListFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileListFolder forIndexPath:indexPath];
        ProjectFolder *folder = [_curFolder.sub_folders objectAtIndex:indexPath.row - _uploadFiles.count];
        cell.folder = folder;
        [cell setRightUtilityButtons:[self rightButtonsWithObj:folder] WithButtonWidth:[FileListFolderCell cellHeight]];
        cell.delegate = self;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        FileListFileCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileListFile forIndexPath:indexPath];
        ProjectFile *file = [_myFiles.list objectAtIndex:(indexPath.row - _curFolder.sub_folders.count - _uploadFiles.count)];
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
    }else if (indexPath.row < _curFolder.sub_folders.count + _uploadFiles.count) {
        cellHeight = [FileListFolderCell cellHeight];
    }else{
        cellHeight = [FileListFileCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing) {
        if (indexPath.row < _curFolder.sub_folders.count + _uploadFiles.count) {
            if (indexPath.row < _uploadFiles.count) {
                [NSObject showHudTipStr:@"正在上传的不能批处理"];
            }else{
                [NSObject showHudTipStr:@"文件夹不能批处理"];
            }
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row < _uploadFiles.count) {
            
        }else if (indexPath.row < _curFolder.sub_folders.count) {
            ProjectFolder *clickedFolder = [_curFolder.sub_folders objectAtIndex:indexPath.row - _uploadFiles.count];;
            [self goToVCWithFolder:clickedFolder inProject:self.curProject];
        }else{
            ProjectFile *file = [_myFiles.list objectAtIndex:(indexPath.row - _curFolder.sub_folders.count - _uploadFiles.count)];
            [self goToFileVC:file];
        }
    }
}

#pragma mark Edit Table
- (NSArray *)rightButtonsWithObj:(id)obj{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if ([obj isKindOfClass:[ProjectFolder class]]) {
        ProjectFolder *folder = (ProjectFolder *)obj;
        if (![folder isDefaultFolder] && ![folder isShareFolder]) {
            if (folder.sub_folders.count <= 0) {
                [rightUtilityButtons sw_addUtilityButtonWithColor:kColorD8DDE4 icon:[UIImage imageNamed:@"icon_file_cell_move"]];
            }
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xF2F4F6"] icon:[UIImage imageNamed:@"icon_file_cell_rename"]];
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xF66262"] icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
        }
    }else{
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
        }else if (indexPath.row >= _curFolder.sub_folders.count + _uploadFiles.count) {
            ProjectFile *file = [_myFiles.list objectAtIndex:(indexPath.row - _curFolder.sub_folders.count - _uploadFiles.count)];
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
    if (indexPath.row < _curFolder.sub_folders.count && indexPath.row >= _uploadFiles.count) {
        ProjectFolder *folder = [_curFolder.sub_folders objectAtIndex:indexPath.row - _uploadFiles.count];
        NSInteger buttonCount = cell.rightUtilityButtons.count;
        if (index == buttonCount - 3) {//移动
            [self moveFolder:folder fromFolder:self.curFolder];
        }else if (index == buttonCount - 2) {//重命名
            [self renameFolder:folder];
        }else{//删除
            __weak typeof(self) weakSelf = self;
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:[NSString stringWithFormat:@"确定要删除文件夹:%@？",folder.name] buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakSelf deleteFolder:folder];
                }
            }];
            [actionSheet showInView:self.view];
        }
    }else{
        ProjectFile *file = [_myFiles.list objectAtIndex:(indexPath.row - _curFolder.sub_folders.count - _uploadFiles.count)];
        if (index == 0) {
            [self moveFiles:@[file] fromFolder:self.curFolder];
        }else if (index == 1){
            [self renameFile:file];
        }else{
            [self deleteFile:file];
        }
    }
}

- (void)deleteFolder:(ProjectFolder *)folder{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteFolder:folder andBlock:^(id data, NSError *error) {
        if (data) {
            ProjectFolder *originalFolder = (ProjectFolder *)data;
            DebugLog(@"删除文件夹成功:%@", originalFolder.name);
            [weakSelf.curFolder.sub_folders removeObject:originalFolder];
            weakSelf.curFolder.count = [NSNumber numberWithInt:weakSelf.curFolder.count.intValue-1];
            [weakSelf.myTableView reloadData];
            [weakSelf.view configBlankPage:EaseBlankPageTypeFile hasData:([weakSelf totalDataRow] > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
                [weakSelf refreshRootFolders];
            }];
        }
    }];
}
- (void)renameFolder:(ProjectFolder *)folder{
    __weak typeof(self) weakSelf = self;
    @weakify(folder);
    [SettingTextViewController showSettingFolderNameVCFromVC:nil withTitle:@"重命名文件夹" textValue:folder.name type:SettingTypeFolderName doneBlock:^(NSString *textValue) {
        @strongify(folder);
        folder.next_name = textValue;
        [[Coding_NetAPIManager sharedManager] request_RenameFolder:folder andBlock:^(id data, NSError *error) {
            if (data) {
                ProjectFolder *originalFolder = (ProjectFolder *)data;
                originalFolder.name = originalFolder.next_name;
                [NSObject showHudTipStr:[NSString stringWithFormat:@"成功重命名为:%@", originalFolder.name]];
                [weakSelf.myTableView reloadData];
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
                [weakSelf.myTableView reloadData];
            }
        }];
    }];
}
- (void)deleteFile:(ProjectFile *)file{
    __weak typeof(self) weakSelf = self;
    __weak typeof(file) weakFile = file;

    NSURL *fileUrl = [file diskFileUrl];
    Coding_DownloadTask *cDownloadTask = [file cDownloadTask];
    UIActionSheet *actionSheet;
    
    if (fileUrl) {
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"只是删除本地文件还是连同服务器文件一起删除？" buttonTitles:@[@"仅删除本地文件"] destructiveTitle:@"一起删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
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
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定将服务器上的该文件删除？" buttonTitles:@[@"只是取消下载"] destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
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
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定将服务器上的该文件删除？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf deleteFile:weakFile fromDisk:NO];
            }
        }];
    }
    [actionSheet showInView:self.view];
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
                [weakSelf refreshRootFolders];
            }
        }];
    }
}
- (void)moveFiles:(NSArray *)files fromFolder:(ProjectFolder *)folder{
    NSMutableArray *fileIdList = [[NSMutableArray alloc] initWithCapacity:files.count];
    for (ProjectFile *file in files) {
        [fileIdList addObject:file.file_id];
    }
    __weak typeof(self) weakSelf = self;
    FolderToMoveViewController *vc = [[FolderToMoveViewController alloc] init];
    vc.fromFolder = folder;
    vc.toMovedIdList = fileIdList;
    vc.curProject = self.curProject;
    vc.rootFolders = self.rootFolders;
    vc.curFolder = nil;
    vc.moveToFolderBlock = ^(ProjectFolder *curFolder, NSArray *toMovedIdList){
        [weakSelf changeEditStateToEditing:NO];
        [[Coding_NetAPIManager sharedManager] request_MoveFiles:toMovedIdList toFolder:curFolder andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf refreshRootFolders];
            }
        }];
    };
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)moveFolder:(ProjectFolder *)movedFolder fromFolder:(ProjectFolder *)folder{
    __weak typeof(self) weakSelf = self;
    FolderToMoveViewController *vc = [[FolderToMoveViewController alloc] init];
    vc.isMoveFolder = YES;
    vc.fromFolder = folder;
    vc.toMovedIdList = @[movedFolder.file_id];
    vc.curProject = self.curProject;
    vc.rootFolders = self.rootFolders;
    vc.curFolder = nil;
    vc.moveToFolderBlock = ^(ProjectFolder *curFolder, NSArray *toMovedIdList){
        [weakSelf changeEditStateToEditing:NO];
        [[Coding_NetAPIManager sharedManager] request_MoveFolder:toMovedIdList.firstObject toFolder:curFolder  inProject:weakSelf.curProject andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf refreshRootFolders];
            }
        }];
    };
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark toVC
- (void)goToVCWithFolder:(ProjectFolder *)folder inProject:(Project *)project{
    FileListViewController *vc = [[FileListViewController alloc] init];
    vc.curFolder = folder;
    vc.curProject = project;
    vc.rootFolders = self.rootFolders;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToFileVC:(ProjectFile *)file{
    FileViewController *vc = [FileViewController vcWithFile:file andVersion:nil];
    @weakify(self);
    vc.fileHasBeenDeletedBlock = ^(){
        @strongify(self);
        [self refreshFileList];
    };
    vc.fileHasChangedBlock = ^(){
        @strongify(self);
        [self refreshFileList];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
