//
//  ProjectCodeListView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectCodeList @"ProjectCodeListCell"

#import "ProjectCodeListView.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "ProjectCodeListCell.h"

@interface ProjectCodeListView ()
@property (nonatomic, strong) Project *curProject;
@property (nonatomic , strong) CodeTree *myCodeTree;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@end

@implementation ProjectCodeListView

- (id)initWithFrame:(CGRect)frame project:(Project *)project andCodeTree:(CodeTree *)codeTree{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _curProject = project;
        if (codeTree) {
            _myCodeTree = codeTree;
        }else{
            _myCodeTree = [CodeTree codeTreeMaster];
        }
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = kColorTableBG;
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ProjectCodeListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectCodeList];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            tableView;
        });
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [self sendRequest];
    }
    return self;
}

- (void)refresh{
    if (_myCodeTree.isLoading) {
        return;
    }
    [self sendRequest];
}

- (void)sendRequest{
        if (_myCodeTree.files.count <= 0) {
            [self beginLoading];
        }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CodeTree:_myCodeTree withPro:_curProject codeTreeBlock:^(id codeTreeData, NSError *codeTreeError) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf endLoading];
        if (codeTreeData) {
            weakSelf.myCodeTree = codeTreeData;
            [weakSelf.myTableView reloadData];
        }
        BOOL hasError = NO;
        if (codeTreeError != nil && codeTreeError.code == 1024) {
            hasError = YES;
        }
        [weakSelf configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.myCodeTree.files.count > 0) hasError:hasError reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    } andCodeTreeInfoBlock:^(id codeTreeInfoData, NSError *codeTreeInfoError) {
        if (codeTreeInfoData) {
            [weakSelf.myCodeTree configWithCommitInfos:codeTreeInfoData];
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_myCodeTree && _myCodeTree.files) {
        row = _myCodeTree.files.count;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectCodeListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectCodeList forIndexPath:indexPath];
    cell.file = [self.myCodeTree.files objectAtIndex:indexPath.row];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectCodeListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_codeTreeFileOfRefBlock) {
        CodeTree_File *file = [self.myCodeTree.files objectAtIndex:indexPath.row];
        _codeTreeFileOfRefBlock(file, _myCodeTree.ref);
    }
}
@end
