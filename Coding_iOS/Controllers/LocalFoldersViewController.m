//
//  LocalFoldersViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/9/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "LocalFoldersViewController.h"
#import "Coding_FileManager.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "LocalFolderCell.h"
#import "LocalFilesViewController.h"
#import "EaseToolBar.h"

@interface LocalFoldersViewController ()<UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, EaseToolBarDelegate>
@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;

@property (nonatomic, strong) EaseToolBar *myEditToolBar;

@property (strong, nonatomic) NSMutableArray *projectId_list;
@property (strong, nonatomic) NSMutableDictionary *projectList_dict;
@end

@implementation LocalFoldersViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"本地文件";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[LocalFolderCell class] forCellReuseIdentifier:kCellIdentifier_LocalFolderCell];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = kColor666;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.allowsMultipleSelectionDuringEditing = YES;
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changeEditStateToEditing:NO];
    [self refresh];
}

- (void)refresh{
    BOOL hasData = [self findLocalFile];
    [self.view configBlankPage:EaseBlankPageTypeView hasData:hasData hasError:NO reloadButtonBlock:nil];
    if (!hasData) {
        [self.myRefreshControl endRefreshing];
        return;
    }
    if (_isLoading) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    weakSelf.isLoading = YES;
    [[Coding_NetAPIManager sharedManager] request_Projects_WithObj:[Projects projectsWithType:ProjectsTypeAll andUser:nil] andBlock:^(Projects *data, NSError *error) {
        weakSelf.isLoading = NO;
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf refreshProjectNameWithProjects:data];
    }];
}

- (BOOL)findLocalFile{
    if (_projectId_list) {
        [_projectId_list removeAllObjects];
    }else{
        _projectId_list = [NSMutableArray new];
    }
    
    if (_projectList_dict) {
        [[_projectList_dict allValues] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"list"] isKindOfClass:[NSMutableArray class]]) {
                [(NSMutableArray *)obj[@"list"] removeAllObjects];
            }
        }];
    }else{
        _projectList_dict = [NSMutableDictionary new];
    }
    
    NSArray *localFileUrlList = [Coding_FileManager localFileUrlList];
    if (localFileUrlList.count > 0) {
        for (NSURL *fileUrl in localFileUrlList) {
            NSArray *valueList = [[[fileUrl.path componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"|||"];
            if (valueList.count == 3) {
                NSString *projectId = valueList[1];
                if (![_projectId_list containsObject:projectId]) {
                    [_projectId_list addObject:projectId];
                }
                NSMutableDictionary *pro_dict = _projectList_dict[projectId];
                if (!pro_dict) {
                    pro_dict = [@{@"name" : @"...",
                                  @"list" : [@[] mutableCopy]} mutableCopy];
                    _projectList_dict[projectId] = pro_dict;
                }
                [pro_dict[@"list"] addObject:fileUrl];
            }
        }
    }
    [self.myTableView reloadData];
    return localFileUrlList.count > 0;
}

- (void)refreshProjectNameWithProjects:(Projects *)projects{
    if (!projects || projects.list.count <= 0) {
        return;
    }
    for (Project *curPro in projects.list) {
        if (_projectList_dict[curPro.id.stringValue]) {
            NSMutableDictionary *pro_dict = _projectList_dict[curPro.id.stringValue];
            pro_dict[@"name"] = curPro.name;
        }
    }
    [self.myTableView reloadData];
}

#pragma mark T
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _projectId_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LocalFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_LocalFolderCell forIndexPath:indexPath];
    
    NSString *key = _projectId_list[indexPath.row];
    NSDictionary *pro_dict = _projectList_dict[key];

    [cell setProjectName:pro_dict[@"name"] fileCount:[(NSArray *)pro_dict[@"list"] count]];
    cell.delegate = self;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [LocalFolderCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing) {
        
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        NSString *key = _projectId_list[indexPath.row];
        NSDictionary *pro_dict = _projectList_dict[key];
        
        LocalFilesViewController *vc = [LocalFilesViewController new];
        vc.projectName = pro_dict[@"name"];
        vc.fileList = pro_dict[@"list"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    NSString *projectId = _projectId_list[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定要删除该文件夹内所有本地文件吗？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [weakSelf deleteFilesWithProjectIdList:@[projectId]];
        }
    }];
    [actionSheet showInView:self.view];
}

#pragma mark Edit
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
- (void)changeEditState{
    [self changeEditStateToEditing:!_myTableView.isEditing];
}

- (void)reverseSelect{
    if (_myTableView.isEditing) {
        NSArray *selectedIndexList = [_myTableView indexPathsForSelectedRows];
        NSMutableArray *reverseIndexList = [NSMutableArray new];
        for (NSInteger index = 0; index < _projectId_list.count; index++) {
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

- (void)configToolBar{
    //添加底部ToolBar
    if (!_myEditToolBar) {
        EaseToolBarItem *item = [EaseToolBarItem easeToolBarItemWithTitle:@" 删除" image:@"button_file_denete_enable" disableImage:nil];
        _myEditToolBar = [EaseToolBar easeToolBarWithItems:@[item]];
        _myEditToolBar.delegate = self;
        [self.view addSubview:_myEditToolBar];
        [_myEditToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
            make.size.mas_equalTo(_myEditToolBar.frame.size);
        }];
    }
    _myEditToolBar.hidden = !_myTableView.isEditing;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,_myTableView.isEditing? CGRectGetHeight(_myEditToolBar.frame): 0.0, 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
}
#pragma mark EaseToolBarDelegate
- (void)easeToolBar:(EaseToolBar *)toolBar didClickedIndex:(NSInteger)index{
    NSArray *selectedIndexPath = [_myTableView indexPathsForSelectedRows];
    if (selectedIndexPath.count <= 0) {
        return;
    }
    if (toolBar == _myEditToolBar) {
        if (index == 0) {
            __weak typeof(self) weakSelf = self;
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定要删除选中文件夹内所有本地文件吗？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakSelf deleteSelectedFolders];
                }
            }];
            [actionSheet showInView:self.view];
        }
    }
}

- (void)deleteSelectedFolders{
    NSArray *selectedIndexPath = [_myTableView indexPathsForSelectedRows];
    NSMutableArray *selectedFolders = [[NSMutableArray alloc] initWithCapacity:selectedIndexPath.count];
    for (NSIndexPath *indexPath in selectedIndexPath) {
        NSString *projectId = _projectId_list[indexPath.row];
        if (projectId.length > 0) {
            [selectedFolders addObject:projectId];
        }
    }
    [self deleteFilesWithProjectIdList:selectedFolders];
}

#pragma mark Delete
- (void)deleteFilesWithProjectIdList:(NSArray *)projectIdList{
    NSMutableArray *urlList = [NSMutableArray new];
    for (NSString *key in projectIdList) {
        NSDictionary *pro_dict = _projectList_dict[key];
        NSArray *curList = pro_dict[@"list"];
        if (curList.count > 0) {
            [urlList addObjectsFromArray:curList];
        }
    }
    [self deleteFilesWithUrlList:urlList];
}

- (void)deleteFilesWithUrlList:(NSArray *)urlList{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        for (NSURL *fileUrl in urlList) {
            NSString *filePath = fileUrl.path;
            if ([fm fileExistsAtPath:filePath]) {
                NSError *fileError;
                [fm removeItemAtPath:filePath error:&fileError];
                if (fileError) {
                    [NSObject showError:fileError];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self findLocalFile];
            [self changeEditStateToEditing:NO];
            [NSObject showHudTipStr:@"本地文件删除成功"];
        });
    });
}
@end
