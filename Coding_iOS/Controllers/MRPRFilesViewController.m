//
//  MRPRFilesViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPRFilesViewController.h"

#import "FileChangesIntroduceCell.h"
#import "FileChangeListCell.h"

#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"

#import "FileChangeDetailViewController.h"

@interface MRPRFilesViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) FileChanges *curFileChanges;
@property (strong, nonatomic) NSMutableDictionary *listGroups;
@property (strong, nonatomic) NSMutableArray *listGroupKeys;

@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@end

@implementation MRPRFilesViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"#%@", _curMRPR.iid.stringValue];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableBG;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[FileChangesIntroduceCell class] forCellReuseIdentifier:kCellIdentifier_FileChangesIntroduceCell];
        [tableView registerClass:[FileChangeListCell class] forCellReuseIdentifier:kCellIdentifier_FileChangeListCell];
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
    if (_curMRPR.isLoading) {
        return;
    }
    if (!_curFileChanges) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_MRPRFileChanges_WithObj:_curMRPR andBlock:^(FileChanges *data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.curFileChanges = data;
            [weakSelf configListGroups];
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.curFileChanges != nil) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

- (void)configListGroups{
    if (!_listGroupKeys) {
        _listGroupKeys = [NSMutableArray new];
    }
    if (!_listGroups) {
        _listGroups = [NSMutableDictionary new];
    }
    [_listGroupKeys removeAllObjects];
    [_listGroups removeAllObjects];
    
    for (FileChange *curFileChange in _curFileChanges.paths) {
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
    if (section != 0) {
        return kScaleFrom_iPhone5_Desgin(24);
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        return [tableView getHeaderViewWithStr:[_listGroupKeys objectAtIndex:section - 1] andBlock:^(id obj) {
            NSLog(@"%@", [_listGroupKeys objectAtIndex:section -1]);
        }];
    }else{
        return nil;
    }
}

#pragma mark Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_curFileChanges) {
        return _listGroupKeys.count + 1;
    }else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        NSString *curKey = [_listGroupKeys objectAtIndex:section -1];
        NSArray *curList = [_listGroups objectForKey:curKey];
        return curList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        FileChangesIntroduceCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileChangesIntroduceCell forIndexPath:indexPath];
        [cell setFilesCount:_curFileChanges.paths.count insertions:_curFileChanges.insertions.integerValue deletions:_curFileChanges.deletions.integerValue];
        return cell;
    }else{
        NSString *curKey = [_listGroupKeys objectAtIndex:indexPath.section -1];
        NSArray *curList = [_listGroups objectForKey:curKey];
        FileChange *curFileChange = [curList objectAtIndex:indexPath.row];
        FileChangeListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileChangeListCell forIndexPath:indexPath];
        cell.curFileChange = curFileChange;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [FileChangesIntroduceCell cellHeight];
    }else{
        return [FileChangeListCell cellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section > 0) {
        NSString *curKey = [_listGroupKeys objectAtIndex:indexPath.section -1];
        NSArray *curList = [_listGroups objectForKey:curKey];
        FileChange *curFileChange = [curList objectAtIndex:indexPath.row];
        
        FileChangeDetailViewController *vc = [FileChangeDetailViewController new];
        vc.linkUrlStr = [NSString stringWithFormat:@"%@?path=%@", [_curMRPR toFileLineChangesPath], curFileChange.path];
        vc.curProject = _curProject;
        vc.commitId = curFileChange.commitId;
        vc.filePath = curFileChange.path;
        vc.noteable_id = _curMRPRInfo.mrpr.id.stringValue;
        [self.navigationController pushViewController:vc animated:YES];
    }
}




@end
