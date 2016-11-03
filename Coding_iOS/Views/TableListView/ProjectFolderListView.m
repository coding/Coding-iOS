//
//  ProjectFolderListView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectFolderListView.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "ProjectFolderListCell.h"
#import "SettingTextViewController.h"
#import "FolderToMoveViewController.h"

@interface ProjectFolderListView () <SWTableViewCellDelegate>
@property (nonatomic, strong) Project *curProject;
@property (strong, nonatomic) ProjectFolders *myFolders;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@end
@implementation ProjectFolderListView
- (id)initWithFrame:(CGRect)frame project:(Project *)project{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _curProject = project;
        _myFolders = [ProjectFolders emptyFolders];
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ProjectFolderListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectFolderList];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            tableView;
        });
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [self sendRequest];
    }
    return self;
}
- (void)refresh{
    if (_myFolders.isLoading) {
        return;
    }
    [self sendRequest];
}

- (void)sendRequest{
    if (_myFolders.list.count <= 0) {
        [self beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Folders:_myFolders inProject:_curProject andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf endLoading];
        if (data) {
            weakSelf.myFolders = data;
            [weakSelf.myTableView reloadData];
        }
        [weakSelf configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.myFolders.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}
- (void)reloadData{
    if (self.myTableView) {
        [self.myTableView reloadData];
    }
}
- (void)refreshToQueryData{
    [self refresh];
}
#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_myFolders && _myFolders.list) {
        row = _myFolders.list.count;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectFolderListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectFolderList forIndexPath:indexPath];
    ProjectFolder *folder = [self.myFolders.list objectAtIndex:indexPath.row];
    cell.folder = folder;
    [cell setRightUtilityButtons:[self rightButtonsWithObj:folder] WithButtonWidth:[ProjectFolderListCell cellHeight]];
    cell.delegate = self;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectFolderListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_folderInProjectBlock) {
        ProjectFolder *folder = [self.myFolders.list objectAtIndex:indexPath.row];
        _folderInProjectBlock(_myFolders, folder, _curProject);
    }
}
#pragma mark Edit Table
- (NSArray *)rightButtonsWithObj:(id)obj{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if ([obj isKindOfClass:[ProjectFolder class]]) {
        ProjectFolder *folder = (ProjectFolder *)obj;
        if (![folder isDefaultFolder] && ![folder isShareFolder]) {
            if (folder.sub_folders.count <= 0) {
                [rightUtilityButtons sw_addUtilityButtonWithColor:kColorDDD icon:[UIImage imageNamed:@"icon_file_cell_move"]];
            }
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] icon:[UIImage imageNamed:@"icon_file_cell_rename"]];
            [rightUtilityButtons sw_addUtilityButtonWithColor:kColorBrandRed icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
        }
    }
    return rightUtilityButtons;
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    ProjectFolder *folder = [self.myFolders.list objectAtIndex:indexPath.row];
    if ([folder isDefaultFolder]) {
        [NSObject showHudTipStr:@"‘默认文件夹’不可以编辑"];
    }else{
        NSInteger buttonCount = cell.rightUtilityButtons.count;
        if (index == buttonCount - 3) {//移动
            [self moveFolder:folder fromFolder:nil];
        }else if (index == buttonCount - 2) {//重命名
            [self renameFolder:folder];
        }else{//删除
            __weak typeof(self) weakSelf = self;
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:[NSString stringWithFormat:@"确定要删除文件夹:%@？",folder.name] buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakSelf deleteFolder:folder];
                }
            }];
            [actionSheet showInView:self];
        }
    }
}
- (void)deleteFolder:(ProjectFolder *)folder{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteFolder:folder andBlock:^(id data, NSError *error) {
        if (data) {
            ProjectFolder *originalFolder = (ProjectFolder *)data;
            DebugLog(@"删除文件夹成功:%@", originalFolder.name);
            
            [weakSelf.myFolders.list removeObject:originalFolder];
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

- (void)moveFolder:(ProjectFolder *)movedFolder fromFolder:(ProjectFolder *)folder{
    if (!self.containerVC) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    FolderToMoveViewController *vc = [[FolderToMoveViewController alloc] init];
    vc.isMoveFolder = YES;
    vc.fromFolder = folder;
    vc.toMovedIdList = @[movedFolder.file_id];
    vc.curProject = self.curProject;
    vc.rootFolders = self.myFolders;
    vc.curFolder = nil;
    vc.moveToFolderBlock = ^(ProjectFolder *curFolder, NSArray *toMovedIdList){
        [[Coding_NetAPIManager sharedManager] request_MoveFolder:toMovedIdList.firstObject toFolder:curFolder  inProject:weakSelf.curProject andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf refresh];
            }
        }];
    };
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self.containerVC presentViewController:nav animated:YES completion:nil];
}

@end
