//
//  LocalFilesViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/9/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "LocalFilesViewController.h"
#import "LocalFileCell.h"
#import "LocalFileViewController.h"
#import "EaseToolBar.h"

@interface LocalFilesViewController ()<UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, EaseToolBarDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) EaseToolBar *myEditToolBar;

@end

@implementation LocalFilesViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = self.projectName;
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[LocalFileCell class] forCellReuseIdentifier:kCellIdentifier_LocalFileCell];
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
    [self changeEditStateToEditing:NO];
}

#pragma mark T
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LocalFileCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_LocalFileCell forIndexPath:indexPath];
    cell.fileUrl = _fileList[indexPath.row];
    cell.delegate = self;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [LocalFileCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing) {
        
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        LocalFileViewController *vc = [LocalFileViewController new];
        vc.projectName = self.projectName;
        vc.fileUrl = self.fileList[indexPath.row];
        
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
    NSURL *fileUrl = self.fileList[indexPath.row];
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定要删除本地文件吗？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [weakSelf deleteFilesWithUrlList:@[fileUrl]];
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
        for (NSInteger index = 0; index < _fileList.count; index++) {
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
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定要删除选中的本地文件吗？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakSelf deleteSelectedFiles];
                }
            }];
            [actionSheet showInView:self.view];
        }
    }
}

- (void)deleteSelectedFiles{
    NSArray *selectedIndexPath = [_myTableView indexPathsForSelectedRows];
    NSMutableArray *selectedFiles = [[NSMutableArray alloc] initWithCapacity:selectedIndexPath.count];
    for (NSIndexPath *indexPath in selectedIndexPath) {
        [selectedFiles addObject:_fileList[indexPath.row]];
    }
    [self deleteFilesWithUrlList:selectedFiles];
}

#pragma mark Delete
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
            [self.fileList removeObjectsInArray:urlList];
            [self changeEditStateToEditing:NO];
            [NSObject showHudTipStr:@"本地文件删除成功"];
        });
    });
}
@end
