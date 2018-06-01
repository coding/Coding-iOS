//
//  FolderToMoveViewController.m
//  Coding_iOS
//
//  Created by Ease on 14/11/27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "FolderToMoveViewController.h"
#import "FileListFolderCell.h"
#import "EaseToolBar.h"
#import "SettingTextViewController.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"

@interface FolderToMoveViewController ()<UITableViewDataSource, UITableViewDelegate, EaseToolBarDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) EaseToolBar *myToolBar;
@property (strong, nonatomic) NSMutableArray *dataList;
@end

@implementation FolderToMoveViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.curFolder) {
        self.title = self.curFolder.name;
    }else if (self.curProject){
        self.title = self.curProject.name;
        self.curFolder = [[ProjectFile alloc] initWithFileId:@0 inProject:self.curProject.name ofUser:self.curProject.owner_user_name];
    }else{
        self.title = @"选择目标文件夹";
    }
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(dismissSelf)] animated:YES];
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[FileListFolderCell class] forCellReuseIdentifier:kCellIdentifier_FileListFolder];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)refresh{
    if (self.dataList.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_FoldersInFolder:_curFolder andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.refreshControl endRefreshing];
        if (data) {
            weakSelf.dataList = data;
            [weakSelf.myTableView reloadData];
            [weakSelf configToolBar];
        }
    }];
}

- (void)configToolBar{
    //添加底部ToolBar
    if (!_myToolBar) {
        //添加底部ToolBar
        EaseToolBarItem *item1 = [EaseToolBarItem easeToolBarItemWithTitle:@"新建文件夹" image:@"button_file_createFolder_enable" disableImage:@"button_file_createFolder_unable"];
        EaseToolBarItem *item2 = [EaseToolBarItem easeToolBarItemWithTitle:@"移动到这里" image:@"button_file_move_enable" disableImage:@"button_file_move_unable"];
        _myToolBar = [EaseToolBar easeToolBarWithItems:@[item1, item2]];
        _myToolBar.delegate = self;
        [self.view addSubview:_myToolBar];
        [_myToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
            make.size.mas_equalTo(_myToolBar.frame.size);
        }];
    }
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myToolBar.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
}


- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark Data Thing

- (void)setDataList:(NSMutableArray *)dataList{
    if (dataList.count > 0 && _isMoveFolder) {
        for (NSNumber *folderId in _toMovedIdList) {
            ProjectFile *folderToRemove = [dataList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"file_id = %@", folderId]].firstObject;
            if (folderToRemove) {
                [dataList removeObject:folderToRemove];
            }
        }
    }
    _dataList = dataList;
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FileListFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileListFolder forIndexPath:indexPath];
    ProjectFile *folder = [[self dataList] objectAtIndex:indexPath.row];
    cell.folder = folder;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [FileListFolderCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ProjectFile *clickedFolder = [[self dataList] objectAtIndex:indexPath.row];
    
    FolderToMoveViewController *vc = [[FolderToMoveViewController alloc] init];
    vc.isMoveFolder = _isMoveFolder;
    vc.toMovedIdList = self.toMovedIdList;
    vc.curProject = self.curProject;
    vc.curFolder = clickedFolder;
    vc.fromFolder = self.fromFolder;
    vc.moveToFolderBlock = self.moveToFolderBlock;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma EaseToolBarDelegate
- (void)easeToolBar:(EaseToolBar *)toolBar didClickedIndex:(NSInteger)index{
    switch (index) {
        case 0:
        {//新建文件夹
            DebugLog(@"新建文件夹");
            __weak typeof(self) weakSelf = self;
            [SettingTextViewController showSettingFolderNameVCFromVC:self withTitle:@"新建文件夹" textValue:nil type:SettingTypeNewFolderName doneBlock:^(NSString *textValue) {
                DebugLog(@"%@", textValue);
                [[Coding_NetAPIManager sharedManager] request_CreatFolder:textValue inFolder:weakSelf.curFolder inProject:weakSelf.curProject andBlock:^(id data, NSError *error) {
                    if (data) {
                        [weakSelf.dataList insertObject:data atIndex:0];
                        [weakSelf.myTableView reloadData];
                        [NSObject showHudTipStr:@"创建文件夹成功"];
                    }
                }];
            }];
        }
            break;
        case 1:
        {//移动文件
            DebugLog(@"移动文件");
            if (self.moveToFolderBlock) {
                self.moveToFolderBlock(self.curFolder, self.toMovedIdList);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
