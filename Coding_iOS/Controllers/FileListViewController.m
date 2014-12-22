//
//  FileListViewController.m
//  Coding_iOS
//
//  Created by Ease on 14/11/14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_FileListFolder @"FileListFolderCell"
#define kCellIdentifier_FileListFile @"FileListFileCell"

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

@interface FileListViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate, SWTableViewCellDelegate, EaseToolBarDelegate, QBImagePickerControllerDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (strong, nonatomic) ProjectFiles *myFiles;
@property (strong, nonatomic) NSMutableArray *previewFileUrls;
@property (nonatomic, strong) EaseToolBar *myToolBar;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.myTableView) {
        [self.myTableView reloadData];
    }
}

- (void)loadView{
    [super loadView];
    self.title = self.curFolder.name;
    _myFiles = [[ProjectFiles alloc] init];
    _previewFileUrls = [[NSMutableArray alloc] init];
    
    CGRect frame = [UIView frameWithOutNav];
    self.view = [[UIView alloc] initWithFrame:frame];
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[FileListFolderCell class] forCellReuseIdentifier:kCellIdentifier_FileListFolder];
        [tableView registerClass:[FileListFileCell class] forCellReuseIdentifier:kCellIdentifier_FileListFile];
        [self.view addSubview:tableView];
        tableView;
    });
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    if (!self.rootFolders) {
        self.rootFolders = [ProjectFolders emptyFolders];
    }
    [self refresh];
}

- (void)configToolBar{
    //添加底部ToolBar
    EaseToolBarItem *item1 = [EaseToolBarItem easeToolBarItemWithTitle:@" 新建文件夹" image:@"button_file_createFolder_enable" disableImage:@"button_file_createFolder_unable"];
    EaseToolBarItem *item2 = [EaseToolBarItem easeToolBarItemWithTitle:@" 上传文件" image:@"button_file_upload_enable" disableImage:nil];
    item1.enabled = [self canCreatNewFolder];
    item2.enabled = YES;
    
    _myToolBar = [EaseToolBar easeToolBarWithItems:@[item1, item2]];
    [_myToolBar setY:CGRectGetHeight(self.view.frame) - CGRectGetHeight(_myToolBar.frame)];
    _myToolBar.delegate = self;
    [self.view addSubview:_myToolBar];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myToolBar.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
}

- (BOOL)canCreatNewFolder{
    return (self.curFolder == nil || (self.curFolder.parent_id.intValue == 0 && self.curFolder.file_id.intValue != 0));
}

- (void)refresh{
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
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.view endLoading];
        if (data) {
            ProjectFolders *preRootFolders = weakSelf.rootFolders;
            weakSelf.rootFolders = data;
            ProjectFolder *curFolder = [weakSelf.rootFolders hasFolderWithId:weakSelf.curFolder.file_id];
            if (curFolder) {
                weakSelf.curFolder = curFolder;
                weakSelf.title = curFolder.name;
                [weakSelf configToolBar];
                [weakSelf.myTableView reloadData];
                [weakSelf refreshFileList];
            }else{
                weakSelf.rootFolders = preRootFolders;
                [weakSelf showHudTipStr:@"文件夹不存在"];
                [weakSelf.view configBlankPage:EaseBlankPageTypeFolderDleted hasData:([weakSelf totalDataRow] > 0) hasError:NO reloadButtonBlock:nil];
            }
        }else{
            [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:([weakSelf totalDataRow] > 0) hasError:YES reloadButtonBlock:^(id sender) {
                [weakSelf refresh];
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
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:([weakSelf totalDataRow] > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma EaseToolBarDelegate
- (void)easeToolBar:(EaseToolBar *)toolBar didClickedIndex:(NSInteger)index{
    switch (index) {
        case 0:
        {//新建文件夹
            NSLog(@"新建文件夹");
            __weak typeof(self) weakSelf = self;
            [SettingTextViewController showSettingFolderNameVCFromVC:self withTitle:@"新建文件夹" textValue:nil type:SettingTypeNewFolderName doneBlock:^(NSString *textValue) {
                NSLog(@"%@", textValue);
                [[Coding_NetAPIManager sharedManager] request_CreatFolder:textValue inFolder:weakSelf.curFolder inProject:weakSelf.curProject andBlock:^(id data, NSError *error) {
                    if (data) {
                        if (weakSelf.curFolder) {
                            [weakSelf.curFolder.sub_folders insertObject:data atIndex:0];
                        }else{
                            [weakSelf.rootFolders.list insertObject:data atIndex:1];
                        }
                        [weakSelf.myTableView reloadData];
                        [weakSelf showHudTipStr:@"创建文件夹成功"];
                    }
                }];
            }];
        }
            break;
        case 1:
        {//上传文件
            NSLog(@"上传文件");
            //        相册
            QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
            imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
            imagePickerController.delegate = self;
            imagePickerController.allowsMultipleSelection = YES;
            imagePickerController.maximumNumberOfSelection = 5;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
            [self presentViewController:navigationController animated:YES completion:NULL];
        }
            break;
        default:
            break;
    }
}
#pragma mark QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    for (ALAsset *assetItem in assets) {
        UIImage *highQualityImage = [UIImage fullResolutionImageFromALAsset:assetItem];
        
        kTipAlert(@"%@", assetItem.description);
        NSLog(@"assetItem-----%@", assetItem.description);
    }
    [_myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Table M
- (NSInteger)totalDataRow{
    return (_curFolder.sub_folders.count + _myFiles.list.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self totalDataRow];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _curFolder.sub_folders.count) {
        FileListFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileListFolder forIndexPath:indexPath];
        ProjectFolder *folder = [_curFolder.sub_folders objectAtIndex:indexPath.row];
        cell.folder = folder;
        [cell setRightUtilityButtons:[self rightButtonsWithObj:folder] WithButtonWidth:[FileListFolderCell cellHeight]];
        cell.delegate = self;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        __weak typeof(self) weakSelf = self;
        FileListFileCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileListFile forIndexPath:indexPath];
        ProjectFile *file = [_myFiles.list objectAtIndex:(indexPath.row - _curFolder.sub_folders.count)];
        cell.file = file;
        cell.showDiskFileBlock = ^(NSURL *fileUrl, ProjectFile *file){
//            [weakSelf showDiskFile:fileUrl];
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
    if (indexPath.row > _curFolder.sub_folders.count) {
        cellHeight = [FileListFolderCell cellHeight];
    }else{
        cellHeight = [FileListFileCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _curFolder.sub_folders.count) {
        ProjectFolder *clickedFolder = [_curFolder.sub_folders objectAtIndex:indexPath.row];;
        [self goToVCWithFolder:clickedFolder inProject:self.curProject];
    }else{
//        FileListFileCell *cell = (FileListFileCell *)[tableView cellForRowAtIndexPath:indexPath];
//        [cell clickedByUser];
        
        ProjectFile *file = [_myFiles.list objectAtIndex:(indexPath.row - _curFolder.sub_folders.count)];
        [self goToFileVC:file];
    }
}

#pragma mark Edit Table
- (NSArray *)rightButtonsWithObj:(id)obj{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if ([obj isKindOfClass:[ProjectFolder class]]) {
        ProjectFolder *folder = (ProjectFolder *)obj;
        if (![folder isDefaultFolder]) {
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:@"icon_file_cell_rename"]];
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xff5846"] icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
        }
    }else{
        ProjectFile *file = (ProjectFile *)obj;
        DebugLog(@"rightButtonsWithObj: %@", file.name);
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:@"icon_file_cell_move"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xff5846"] icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
    }
    return rightUtilityButtons;
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    if (state == kCellStateRight) {
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
        if (indexPath.row >= _curFolder.sub_folders.count) {
            ProjectFile *file = [_myFiles.list objectAtIndex:(indexPath.row - _curFolder.sub_folders.count)];
            Coding_DownloadTask *cTask = file.cTask;
            if (cTask && cTask.task && cTask.task.state == NSURLSessionTaskStateRunning) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    if (indexPath.row < _curFolder.sub_folders.count) {
        ProjectFolder *folder = [_curFolder.sub_folders objectAtIndex:indexPath.row];
        if (index == 0) {
            [self renameFolder:folder];
        }else{
            __weak typeof(self) weakSelf = self;
            
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:[NSString stringWithFormat:@"确定要删除文件夹:%@？",folder.name]];
            [actionSheet bk_setDestructiveButtonWithTitle:@"确认删除" handler:nil];
            [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
            [actionSheet bk_setDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                switch (index) {
                    case 0:
                        [weakSelf deleteFolder:folder];
                        break;
                    default:
                        break;
                }
            }];
            [actionSheet showInView:kKeyWindow];
        }
    }else{
        ProjectFile *file = [_myFiles.list objectAtIndex:(indexPath.row - _curFolder.sub_folders.count)];
        if (index == 0) {
            [self moveFile:file fromFolder:self.curFolder];
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
            [weakSelf.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}
- (void)renameFolder:(ProjectFolder *)folder{
    __weak typeof(self) weakSelf = self;
    @weakify(folder);
    [SettingTextViewController showSettingFolderNameVCFromVC:nil withTitle:@"重命名文件夹" textValue:folder.name type:SettingTypeFolderName doneBlock:^(NSString *textValue) {
        @strongify(folder);
        if (![textValue isEqualToString:folder.name]) {
            folder.next_name = textValue;
            [[Coding_NetAPIManager sharedManager] request_RenameFolder:folder andBlock:^(id data, NSError *error) {
                if (data) {
                    ProjectFolder *originalFolder = (ProjectFolder *)data;
                    DebugLog(@"重命名文件夹成功:%@", originalFolder.name);
                    
                    originalFolder.name = originalFolder.next_name;
                    [weakSelf.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
            
        }
    }];
}
- (void)deleteFile:(ProjectFile *)file{
    __weak typeof(self) weakSelf = self;
    __weak typeof(file) weakFile = file;

    NSURL *fileUrl = [file hasBeenDownload];
    Coding_DownloadTask *cTask = [file cTask];

    if (fileUrl) {
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"只是删除本地文件还是连同服务器文件一起删除？"];
        [actionSheet bk_addButtonWithTitle:@"仅删除本地文件" handler:nil];
        [actionSheet bk_setDestructiveButtonWithTitle:@"一起删除" handler:nil];
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [actionSheet bk_setDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
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
        [actionSheet showInView:kKeyWindow];
    }else if (cTask){
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"确定将服务器上的该文件删除？"];
        [actionSheet bk_addButtonWithTitle:@"只是取消下载" handler:nil];
        [actionSheet bk_setDestructiveButtonWithTitle:@"确认删除" handler:nil];
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [actionSheet bk_setDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
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
        [actionSheet showInView:kKeyWindow];
    }else{
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"确定将服务器上的该文件删除？"];
        [actionSheet bk_setDestructiveButtonWithTitle:@"确认删除" handler:nil];
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [actionSheet bk_setDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            switch (index) {
                case 0:
                    [weakSelf deleteFile:weakFile fromDisk:NO];
                    break;
                default:
                    break;
            }
        }];
        [actionSheet showInView:kKeyWindow];
    }
}
- (void)deleteFile:(ProjectFile *)file fromDisk:(BOOL)fromDisk{

    //    取消当前的下载任务
    Coding_DownloadTask *cTask = [file cTask];
    if (cTask) {
        [[Coding_FileManager sharedManager] removeCTaskForKey:file.storage_key];
    }
    //    删除本地文件
    NSURL *fileUrl = [file hasBeenDownload];
    NSString *filePath = fileUrl.path;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSError *fileError;
        [fm removeItemAtPath:filePath error:&fileError];
        if (fileError) {
            [self showError:fileError];
        }
    }
    [self.myTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    //    删除服务器文件
    if (!fromDisk) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_DeleteFile:file andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf.myFiles.list removeObject:data];
                weakSelf.curFolder.count = [NSNumber numberWithInt:weakSelf.curFolder.count.intValue-1];
                [weakSelf.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }
}
- (void)moveFile:(ProjectFile *)file fromFolder:(ProjectFolder *)folder{
    __weak typeof(self) weakSelf = self;

    FolderToMoveViewController *vc = [[FolderToMoveViewController alloc] init];
    vc.toMovedFile = file;
    vc.curProject = self.curProject;
    vc.rootFolders = self.rootFolders;
    vc.curFolder = nil;
    vc.moveToFolderBlock = ^(ProjectFolder *curFolder, ProjectFile *toMovedFile){
        __weak typeof(curFolder) weakCurFolder = curFolder;

        [[Coding_NetAPIManager sharedManager] request_MoveFile:toMovedFile toFolder:curFolder andBlock:^(id data, NSError *error) {
            if (data) {
                ProjectFile *movedFile = (ProjectFile *)data;
                if (![movedFile.parent_id.stringValue isEqualToString:weakCurFolder.file_id.stringValue]) {
                    [weakSelf.myFiles.list removeObject:movedFile];
                    weakSelf.curFolder.count = [NSNumber numberWithInt:weakSelf.curFolder.count.intValue -1];
                    weakCurFolder.count = [NSNumber numberWithInt:weakCurFolder.count.intValue +1];
                    [weakSelf.myTableView reloadData];
                    [weakSelf showHudTipStr:@"移动成功"];
                }else{
                    [weakSelf showHudTipStr:@"移动到原路径，何必呢？"];
                }
            }
        }];
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
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
    FileViewController *vc = [[FileViewController alloc] init];
    vc.curFile = file;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showDiskFile:(NSURL *)fileUrl{
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    
//    显示已下载的全部内容
//    [self.previewFileUrls removeAllObjects];
//    for (ProjectFile *file in self.myFiles.list) {
//        NSURL *tempUrl = [file hasBeenDownload];
//        if (tempUrl) {
//            [self.previewFileUrls addObject:tempUrl];
//        }
//    }
//    NSInteger index = [self.previewFileUrls indexOfObject:fileUrl];
//    if (index != NSNotFound) {
//        previewController.currentPreviewItemIndex = index;
//    }else{
//        [self.previewFileUrls removeAllObjects];
//        [self.previewFileUrls addObject:fileUrl];
//        previewController.currentPreviewItemIndex = 0;
//    }
    
//    只显示点击的内容
    [self.previewFileUrls removeAllObjects];
    [self.previewFileUrls addObject:fileUrl];
    previewController.currentPreviewItemIndex = 0;
    
//    [self.navigationController pushViewController:previewController animated:YES];
    [self presentViewController:previewController animated:YES completion:^{
    }];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return self.previewFileUrls.count;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
//    for (id object in controller.childViewControllers)
//    {
//        if ([object isKindOfClass:[UINavigationController class]])
//        {
//            [(UINavigationController *)object setNavigationBarHidden:YES];
//        }
//    }
    NSURL *curFileUrl = [self.previewFileUrls objectAtIndex:index];
    return [BasicPreviewItem itemWithUrl:curFileUrl];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
