//
//  WikiHistoryListViewController.m
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/4/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "WikiHistoryListViewController.h"
#import "WikiHistoryCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "WikiViewController.h"

@interface WikiHistoryListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;

@property (strong, nonatomic) NSArray *historyList;
@end

@implementation WikiHistoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"历史版本";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        tableView.backgroundColor = kColorTableBG;
//        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[WikiHistoryCell class] forCellReuseIdentifier:kCellIdentifier_WikiHistoryCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)refresh{
    if (_historyList.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_WikiHistoryWithWiki:_curWiki pro:_myProject andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.historyList = data;
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.historyList.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}


#pragma mark Table Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _historyList.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0/[UIScreen mainScreen].scale;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WikiHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_WikiHistoryCell forIndexPath:indexPath];
    cell.curWiki = _historyList[indexPath.section];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [WikiHistoryCell cellHeightWithObj:_historyList[indexPath.section]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == _historyList.count - 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        EAWiki *wiki = _historyList[indexPath.section];
        WikiViewController *vc = [WikiViewController new];
        vc.myProject = _myProject;
        [vc setWikiIid:_curWiki.iid version:wiki.version];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
