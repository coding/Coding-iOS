//
//  EACodeReleaseViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/23.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EACodeReleaseViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "EACodeReleaseTopCell.h"
#import "EACodeReleaseBodyCell.h"
#import "EACodeReleaseAttachmentsOrReferencesCell.h"
#import "ProjectViewController.h"
#import "WebViewController.h"
#import "EAEditCodeReleaseViewController.h"

@interface EACodeReleaseViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@end

@implementation EACodeReleaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _curRelease.tag_name;
    self.view.backgroundColor = kColorTableBG;
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerNib:[UINib nibWithNibName:[EACodeReleaseTopCell nameOfClass] bundle:nil] forCellReuseIdentifier:[EACodeReleaseTopCell nameOfClass]];
        [tableView registerClass:[EACodeReleaseBodyCell class] forCellReuseIdentifier:[EACodeReleaseBodyCell nameOfClass]];
        [tableView registerClass:[EACodeReleaseAttachmentsOrReferencesCell class] forCellReuseIdentifier:[EACodeReleaseAttachmentsOrReferencesCell nameOfClass]];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
        tableView.contentInset = insets;
        tableView.scrollIndicatorInsets = insets;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"编辑" target:self action:@selector(editBtnClicked)] animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh];
}

#pragma Data
- (void)refresh{
    if (!_curRelease.author) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CodeRelease_WithObj:_curRelease andBlock:^(EACodeRelease *data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            if (weakSelf.curRelease.contentHeight > 1) {
                [(EACodeRelease *)data setContentHeight:weakSelf.curRelease.contentHeight];
            }
            weakSelf.curRelease = data;
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.curRelease.author != nil) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark TableM
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _curRelease.author != nil? 4: 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        EACodeReleaseTopCell *cell = [tableView dequeueReusableCellWithIdentifier:[EACodeReleaseTopCell nameOfClass] forIndexPath:indexPath];
        cell.curR = self.curRelease;
        __weak typeof(self) weakSelf = self;
        cell.tagClickedBlock = ^(EACodeRelease *curR) {
            ProjectViewController *vc = [ProjectViewController codeVCWithCodeRef:curR.tag_name andProject:curR.project];
            vc.hideBranchTagButton = YES;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        return cell;
    }else if (indexPath.row == 1){
        EACodeReleaseBodyCell *cell = [tableView dequeueReusableCellWithIdentifier:[EACodeReleaseBodyCell nameOfClass] forIndexPath:indexPath];
        cell.curR = self.curRelease;
        __weak typeof(self) weakSelf = self;
        cell.cellHeightChangedBlock = ^{
            [weakSelf.myTableView reloadData];
        };
        cell.loadRequestBlock = ^(NSURLRequest *curRequest) {
            [weakSelf loadRequest:curRequest];
        };
        return cell;
    }else{
        EACodeReleaseAttachmentsOrReferencesCell *cell = [tableView dequeueReusableCellWithIdentifier:[EACodeReleaseAttachmentsOrReferencesCell nameOfClass] forIndexPath:indexPath];
        [cell setupCodeRelease:_curRelease type:(indexPath.row - 2)];
        __weak typeof(self) weakSelf = self;
        cell.itemClickedBlock = ^(id item) {
            [weakSelf handleItem:item];
        };
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [EACodeReleaseTopCell cellHeightWithObj:_curRelease];
    }else if (indexPath.row == 1){
        cellHeight = [EACodeReleaseBodyCell cellHeightWithObj:_curRelease];
    }else{
        cellHeight = [EACodeReleaseAttachmentsOrReferencesCell cellHeightWithObj:_curRelease type:(indexPath.row - 2)];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark loadCellRequest
- (void)loadRequest:(NSURLRequest *)curRequest
{
    NSString *linkStr = curRequest.URL.absoluteString;
    [self analyseLinkStr:linkStr];
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

#pragma mark goTo

- (void)handleItem:(id)item{
    if ([item isKindOfClass:[EACodeReleaseAttachment class]]) {
        NSString *linkStr = [NSString stringWithFormat:@"/api/user/%@/project/%@/git/releases/attachments/download/%@", _curRelease.project.owner_user_name, _curRelease.project.name, ((EACodeReleaseAttachment *)item).id];
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }else if ([item isKindOfClass:[ResourceReferenceItem class]]){
        UIViewController *vc = [BaseViewController analyseVCFromLinkStr:((ResourceReferenceItem *)item).link];
        if (vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [NSObject showHudTipStr:@"暂时不支持查看该资源"];
        }
    }
}

- (void)editBtnClicked{
    EAEditCodeReleaseViewController *vc = [EAEditCodeReleaseViewController new];
    vc.curR = _curRelease;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
