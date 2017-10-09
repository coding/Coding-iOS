//
//  CommitFilesViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CommitFilesViewController.h"

#import "FileChangesIntroduceCell.h"
#import "FileChangeListCell.h"
#import "CommitContentCell.h"
#import "CommitCommentCell.h"
#import "AddCommentCell.h"

#import "CommitInfo.h"

#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"

#import "FileChangeDetailViewController.h"
#import "AddMDCommentViewController.h"
#import "WebViewController.h"

#import "UIView+PressMenu.h"

@interface CommitFilesViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (strong, nonatomic) CommitInfo *curCommitInfo;
@property (strong, nonatomic) NSMutableDictionary *listGroups;
@property (strong, nonatomic) NSMutableArray *listGroupKeys;

@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@property (assign, nonatomic) BOOL isLoading;
@end

@implementation CommitFilesViewController

+ (CommitFilesViewController *)vcWithPath:(NSString *)path{
    
    NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
    if (pathComponents.count != 8) {
        return nil;
    }
    CommitFilesViewController *vc = [CommitFilesViewController new];
    vc.ownerGK = pathComponents[2];
    vc.projectName = pathComponents[4];
    vc.commitId = pathComponents[7];
    return vc;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = _commitId.length> 10? [_commitId substringToIndex:10]: _commitId;
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[FileChangesIntroduceCell class] forCellReuseIdentifier:kCellIdentifier_FileChangesIntroduceCell];
        [tableView registerClass:[FileChangeListCell class] forCellReuseIdentifier:kCellIdentifier_FileChangeListCell];
        [tableView registerClass:[CommitContentCell class] forCellReuseIdentifier:kCellIdentifier_CommitContentCell];
        [tableView registerClass:[CommitCommentCell class] forCellReuseIdentifier:kCellIdentifier_CommitCommentCell];
        [tableView registerClass:[CommitCommentCell class] forCellReuseIdentifier:kCellIdentifier_CommitCommentCell_Media];
        [tableView registerClass:[AddCommentCell class] forCellReuseIdentifier:kCellIdentifier_AddCommentCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)refresh{
    if (_isLoading) {
        return;
    }
    if (!_curCommitInfo) {
        [self.view beginLoading];
    }
    _isLoading = YES;
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CommitInfo_WithUserGK:_ownerGK projectName:_projectName commitId:_commitId andBlock:^(CommitInfo *data, NSError *error) {
        weakSelf.isLoading = NO;
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.curCommitInfo = data;
            [weakSelf configListGroups];
            [weakSelf.myTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.curCommitInfo.commitDetail != nil) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
    //推送过来的页面，可能 curProject 对象为空
    if (!_curProject) {
        _curProject = [Project new];
        _curProject.owner_user_name = _ownerGK;
        _curProject.name = _projectName;
    }
    if (![_curProject.id isKindOfClass:[NSNumber class]]) {
        [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:_curProject andBlock:^(id data, NSError *error) {
            if (data) {
                weakSelf.curProject = data;
            }
        }];
    }
}

- (void)configListGroups{
    if (_curCommitInfo && !_curCommitInfo.commitDetail) {
        kTipAlert(@"此 commit 改动太多，不宜在客户端上展示");
        return;
    }
    if (!_listGroupKeys) {
        _listGroupKeys = [NSMutableArray new];
    }
    if (!_listGroups) {
        _listGroups = [NSMutableDictionary new];
    }
    [_listGroupKeys removeAllObjects];
    [_listGroups removeAllObjects];
    
    for (FileChange *curFileChange in _curCommitInfo.commitDetail.diffStat.paths) {
        NSString *curKey = curFileChange.displayFilePath;
        NSMutableArray *curList = [_listGroups objectForKey:curKey];
        if (curList.count > 0) {
            [curList addObject:curFileChange];
        }else{
            [_listGroupKeys addObject:curKey];
            curList = [NSMutableArray arrayWithObject:curFileChange];
            [_listGroups setObject:curList forKey:curKey];
        }
    }
    [_listGroupKeys sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
}

#pragma mark TableM Header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0? 0: kScaleFrom_iPhone5_Desgin(24);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        if (section > 0 && section < _listGroupKeys.count+ 1){
            return [tableView getHeaderViewWithStr:[_listGroupKeys objectAtIndex:section - 1] andBlock:^(id obj) {
                NSLog(@"%@", [_listGroupKeys objectAtIndex:section -1]);
            }];
        }else{
            return [tableView getHeaderViewWithStr:nil andBlock:^(id obj) {
            }];
        }
    }else{
        return nil;
    }
}

#pragma mark Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger section = 0;
    if (_curCommitInfo.commitDetail) {
        section = 1+ _listGroupKeys.count+ 1;
        if (_curCommitInfo.commitComments.count > 0) {
            section += 1;
        }
    }
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else if (section > 0 && section < _listGroupKeys.count+ 1){
        NSString *curKey = [_listGroupKeys objectAtIndex:section -1];
        NSArray *curList = [_listGroups objectForKey:curKey];
        return curList.count;
    }else if (section == _listGroupKeys.count+ 1 && _curCommitInfo.commitComments.count > 0){
        return _curCommitInfo.commitComments.count;
    }else{
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            CommitContentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_CommitContentCell forIndexPath:indexPath];
            cell.curCommitInfo = _curCommitInfo;
            return cell;
        }else{
            FileChanges * curFileChanges = _curCommitInfo.commitDetail.diffStat;
            FileChangesIntroduceCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileChangesIntroduceCell forIndexPath:indexPath];
            [cell setFilesCount:curFileChanges.paths.count insertions:curFileChanges.insertions.integerValue deletions:curFileChanges.deletions.integerValue];
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
            return cell;
        }
    }else if (indexPath.section > 0 && indexPath.section < _listGroupKeys.count+ 1){
        NSString *curKey = [_listGroupKeys objectAtIndex:indexPath.section -1];
        NSArray *curList = [_listGroups objectForKey:curKey];
        FileChange *curFileChange = [curList objectAtIndex:indexPath.row];
        FileChangeListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileChangeListCell forIndexPath:indexPath];
        cell.curFileChange = curFileChange;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }else if (indexPath.section == _listGroupKeys.count+ 1 && _curCommitInfo.commitComments.count > 0){
        ProjectLineNote*curCommentItem = [_curCommitInfo.commitComments objectAtIndex:indexPath.row];
        CommitCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:curCommentItem.htmlMedia.imageItems.count> 0? kCellIdentifier_CommitCommentCell_Media: kCellIdentifier_CommitCommentCell forIndexPath:indexPath];
        cell.curItem = curCommentItem;
        cell.contentLabel.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        NSArray *menuTitles;
        if ([curCommentItem.author.global_key isEqualToString:[Login curLoginUser].global_key]) {
            menuTitles = @[@"拷贝文字", @"回复", @"删除"];
        }else{
            menuTitles = @[@"拷贝文字", @"回复"];
        }
        [cell.contentView addPressMenuTitles:menuTitles menuClickedBlock:^(NSInteger index, NSString *title) {
            if ([title hasPrefix:@"拷贝"]) {
                [[UIPasteboard generalPasteboard] setString:curCommentItem.content];
            }else if ([title isEqualToString:@"删除"]){
                [weakSelf deleteComment:curCommentItem];
            }else if ([title isEqualToString:@"回复"]){
                [weakSelf goToAddCommentVCToUser:curCommentItem.author.name];
            }
        }];
        
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        AddCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AddCommentCell forIndexPath:indexPath];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cellHeight = [CommitContentCell cellHeightWithObj:_curCommitInfo];
        }else{
            cellHeight = [FileChangesIntroduceCell cellHeight];
        }
    }else if (indexPath.section > 0 && indexPath.section < _listGroupKeys.count+ 1){
        cellHeight = [FileChangeListCell cellHeight];
    }else if (indexPath.section == _listGroupKeys.count+ 1 && _curCommitInfo.commitComments.count > 0){
        ProjectLineNote*curCommentItem = [_curCommitInfo.commitComments objectAtIndex:indexPath.row];
        cellHeight = [CommitCommentCell cellHeightWithObj:curCommentItem];
    }else{
        cellHeight = [AddCommentCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
    }else if (indexPath.section > 0 && indexPath.section < _listGroupKeys.count+ 1){
        NSString *curKey = [_listGroupKeys objectAtIndex:indexPath.section -1];
        NSArray *curList = [_listGroups objectForKey:curKey];
        FileChange *curFileChange = [curList objectAtIndex:indexPath.row];
        
        FileChangeDetailViewController *vc = [FileChangeDetailViewController new];
        vc.linkUrlStr = [NSString stringWithFormat:@"api/user/%@/project/%@/git/commitDiffContent/%@", _ownerGK, _projectName, [NSString handelRef:_commitId path:curFileChange.path]];

        vc.curProject = _curProject;
        vc.commitId = curFileChange.commitId;
        vc.filePath = curFileChange.path;
        vc.noteable_id = nil;

        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == _listGroupKeys.count+ 1 && _curCommitInfo.commitComments.count > 0){
        ProjectLineNote*curCommentItem = [_curCommitInfo.commitComments objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell.contentView isMenuVCVisible]) {
            [cell.contentView removePressMenu];
            return;
        }
        NSArray *menuTitles;
        if ([curCommentItem.author.global_key isEqualToString:[Login curLoginUser].global_key]) {
            menuTitles = @[@"拷贝文字", @"删除"];
        }else{
            menuTitles = @[@"拷贝文字", @"回复"];
        }
        __weak typeof(self) weakSelf = self;
        [cell.contentView showMenuTitles:menuTitles menuClickedBlock:^(NSInteger index, NSString *title) {
            if ([title hasPrefix:@"拷贝"]) {
                [[UIPasteboard generalPasteboard] setString:curCommentItem.content];
            }else if ([title isEqualToString:@"删除"]){
                [weakSelf deleteComment:curCommentItem];
            }else if ([title isEqualToString:@"回复"]){
                [weakSelf goToAddCommentVCToUser:curCommentItem.author.name];
            }
        }];
    }else{
        [self goToAddCommentVCToUser:nil];
    }
}

#pragma mark Comment
- (void)goToAddCommentVCToUser:(NSString *)userName{
    DebugLog(@"%@", userName);
    AddMDCommentViewController *vc = [AddMDCommentViewController new];
    
    vc.curProject = _curProject;
    vc.requestPath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/line_notes", _ownerGK, _projectName];
    vc.requestParams = [@{
                          @"noteable_type" : @"Commit",
                          @"commitId" : _commitId,
                          } mutableCopy];
    vc.contentStr = userName.length > 0? [NSString stringWithFormat:@"@%@ ", userName]: nil;
    @weakify(self);
    vc.completeBlock = ^(id data){
        @strongify(self);
        if (data && [data isKindOfClass:[ProjectLineNote class]]) {
            [self.curCommitInfo.commitComments addObject:data];
            [self.myTableView reloadData];
        }
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteComment:(ProjectLineNote *)lineNote{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteLineNote:lineNote.id inProject:_projectName ofUser:_ownerGK andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.curCommitInfo.commitComments removeObject:lineNote];
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *clickedItem = [components objectForKey:@"value"];
    [self analyseLinkStr:clickedItem.href];
}

- (void)analyseLinkStr:(NSString *)linkStr
{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        // 跳转去网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}

@end
