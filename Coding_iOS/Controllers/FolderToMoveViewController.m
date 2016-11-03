//
//  FolderToMoveViewController.m
//  Coding_iOS
//
//  Created by Ease on 14/11/27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "FolderToMoveViewController.h"
#import "ProjectFolderListCell.h"
#import "EaseToolBar.h"
#import "SettingTextViewController.h"
#import "Coding_NetAPIManager.h"

@interface FolderToMoveViewController ()<UITableViewDataSource, UITableViewDelegate, EaseToolBarDelegate>
@property (nonatomic, strong) UITableView *myTableView;
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
    }else{
        self.title = @"选择目标文件夹";
    }
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ProjectFolderListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectFolderList];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    [self configToolBar];
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(dismissSelf)] animated:YES];
}

- (void)configToolBar{
    //添加底部ToolBar
    if (!_myToolBar) {
        //添加底部ToolBar
        EaseToolBarItem *item1 = [EaseToolBarItem easeToolBarItemWithTitle:@" 新建文件夹" image:@"button_file_createFolder_enable" disableImage:@"button_file_createFolder_unable"];
        EaseToolBarItem *item2 = [EaseToolBarItem easeToolBarItemWithTitle:@" 移动到这里" image:@"button_file_move_enable" disableImage:@"button_file_move_unable"];
        item1.enabled = [self canCreatNewFolder];
        item2.enabled = [self canMovedHere];
        
        _myToolBar = [EaseToolBar easeToolBarWithItems:@[item1, item2]];
        _myToolBar.delegate = self;
        [self.view addSubview:_myToolBar];
        [_myToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
            make.size.mas_equalTo(_myToolBar.frame.size);
        }];
    }else{
        EaseToolBarItem *item1 = [_myToolBar itemOfIndex:0];
        EaseToolBarItem *item2 = [_myToolBar itemOfIndex:1];
        item1.enabled = [self canCreatNewFolder];
        item2.enabled = [self canMovedHere];
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myToolBar.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
}


- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark Data Thing
- (NSMutableArray *)dataList{
    if (!_dataList) {
        if (self.curFolder) {
            _dataList = _isMoveFolder? nil: self.curFolder.sub_folders;
        }else{
            _dataList = _rootFolders.list.mutableCopy;
            [_dataList removeObjectAtIndex:0];//移除「分享中」文件夹
            if (_isMoveFolder) {
                ProjectFolder *outFolder = [ProjectFolder outFolder];
                [_dataList replaceObjectAtIndex:0 withObject:outFolder];
            }
        }
        if (_dataList.count > 0) {
            //移除 fromFolder
            ProjectFolder *folderToRemove = _fromFolder ?: [ProjectFolder defaultFolder];
            folderToRemove = [_dataList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"file_id = %@", folderToRemove.file_id]].firstObject;
            if (folderToRemove) {
                [_dataList removeObject:folderToRemove];
            }
            if (_isMoveFolder) {//移除 要移动的 Folder
                for (NSNumber *folderId in _toMovedIdList) {
                    folderToRemove = [_dataList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"file_id = %@", folderId]].firstObject;
                    if (folderToRemove) {
                        [_dataList removeObject:folderToRemove];
                    }
                }
            }
        }
    }
    return _dataList;
}
- (BOOL)canMovedHere{
    return (self.curFolder != nil);
}
- (BOOL)canCreatNewFolder{
    return (self.curFolder == nil || (!_isMoveFolder && self.curFolder.parent_id.intValue == 0 && self.curFolder.file_id.intValue != 0));
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if ([self dataList]) {
        row = [[self dataList] count];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectFolderListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectFolderList forIndexPath:indexPath];
    cell.useToMove = YES;
    ProjectFolder *folder = [[self dataList] objectAtIndex:indexPath.row];
    cell.folder = folder;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectFolderListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ProjectFolder *clickedFolder = [[self dataList] objectAtIndex:indexPath.row];

    FolderToMoveViewController *vc = [[FolderToMoveViewController alloc] init];
    vc.isMoveFolder = _isMoveFolder;
    vc.toMovedIdList = self.toMovedIdList;
    vc.curProject = self.curProject;
    vc.rootFolders = self.rootFolders;
    vc.curFolder = clickedFolder;
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
                        if (weakSelf.curFolder) {
                            [weakSelf.curFolder.sub_folders insertObject:data atIndex:0];
                        }else{
                            [weakSelf.rootFolders.list insertObject:data atIndex:1];
                        }
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
