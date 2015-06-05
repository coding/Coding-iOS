//
//  MRPRDetailViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kMRPRDetailViewController_BottomViewHeight 49.0

#import "MRPRDetailViewController.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"

#import "MRPRTopCell.h"
#import "MRPRDetailCell.h"
#import "MRPRDisclosureCell.h"
#import "MRPRCommentCell.h"
#import "AddCommentCell.h"

#import "WebViewController.h"
#import "MJPhotoBrowser.h"

#import "MRPRCommitsViewController.h"
#import "MRPRFilesViewController.h"
#import "AddMDCommentViewController.h"

@interface MRPRDetailViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (strong, nonatomic) MRPRBaseInfo *curMRPRInfo;
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;
@property (strong, nonatomic) UIView *bottomView;
@end

@implementation MRPRDetailViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"#%@", _curMRPR.iid.stringValue];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [tableView registerClass:[MRPRTopCell class] forCellReuseIdentifier:kCellIdentifier_MRPRTopCell];
        [tableView registerClass:[MRPRDetailCell class] forCellReuseIdentifier:kCellIdentifier_MRPRDetailCell];
        [tableView registerClass:[MRPRDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_MRPRDisclosureCell];
        [tableView registerClass:[MRPRCommentCell class] forCellReuseIdentifier:kCellIdentifier_MRPRCommentCell];
        [tableView registerClass:[MRPRCommentCell class] forCellReuseIdentifier:kCellIdentifier_MRPRCommentCell_Media];
        [tableView registerClass:[AddCommentCell class] forCellReuseIdentifier:kCellIdentifier_AddCommentCell];
        
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

- (void)configBottomView{
    if (_bottomView) {
        [_bottomView removeFromSuperview];
    }
    if (_curMRPR.status <= MRPRStatusCannotMerge) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = [UIColor redColor];
        [self.view addSubview:_bottomView];
        
        

        
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(kMRPRDetailViewController_BottomViewHeight);
        }];

    }
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0,
                                           _curMRPR.status <= MRPRStatusCannotMerge? kMRPRDetailViewController_BottomViewHeight: 0,
                                           0);
    _myTableView.contentInset = insets;
    _myTableView.scrollIndicatorInsets = insets;
    
}
- (void)refresh{
    if (_curMRPR.isLoading) {
        return;
    }
    if (!_curMRPRInfo) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_MRPRBaseInfo_WithObj:_curMRPR andBlock:^(MRPRBaseInfo *data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        if (data) {
            weakSelf.curMRPRInfo = data;
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(_curMRPRInfo != nil) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark TableM Footer Header
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    return view;
}

#pragma mark TableM
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _curMRPRInfo == nil? 0: _curMRPRInfo.discussions.count <= 0? 3: 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (section == 0 || section == 1) {
        row = 2;
    }else if (_curMRPRInfo.discussions.count > 0 && section == 2){
        row = _curMRPRInfo.discussions.count;
    }else{
        row = 1;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {//Content
        if (indexPath.row == 0) {
            MRPRTopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRPRTopCell forIndexPath:indexPath];
            cell.curMRPRInfo = _curMRPRInfo;
            return cell;
        }else{
            MRPRDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRPRDetailCell forIndexPath:indexPath];
            cell.curMRPRInfo = _curMRPRInfo;
            cell.cellHeightChangedBlock = ^(){
                [weakSelf.myTableView reloadData];
            };
            cell.loadRequestBlock = ^(NSURLRequest *curRequest){
                [weakSelf loadRequest:curRequest];
            };
            return cell;
        }
    }else if (indexPath.section == 1){//Disclosure
        MRPRDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRPRDisclosureCell forIndexPath:indexPath];
        if (indexPath.row == 0) {
            [cell setImageStr:@"mrpr_icon_commit" andTitle:@"提交记录"];
        }else{
            [cell setImageStr:@"mrpr_icon_fileChange" andTitle:@"文件改动"];
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }else if (_curMRPRInfo.discussions.count > 0 && indexPath.section == 2){//Comment
        ProjectLineNote *curCommentItem = [[_curMRPRInfo.discussions objectAtIndex:indexPath.row] firstObject];
        MRPRCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:curCommentItem.htmlMedia.imageItems.count> 0? kCellIdentifier_MRPRCommentCell_Media: kCellIdentifier_MRPRCommentCell forIndexPath:indexPath];
        cell.curItem = curCommentItem;
        cell.contentLabel.delegate = self;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }else{//Add Comment
        AddCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AddCommentCell forIndexPath:indexPath];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {//Content
        if (indexPath.row == 0) {
            return [MRPRTopCell cellHeightWithObj:_curMRPRInfo];
        }else{
            return [MRPRDetailCell cellHeightWithObj:_curMRPRInfo];
        }
    }else if (indexPath.section == 1){//Disclosure
        return [MRPRDisclosureCell cellHeight];
    }else if (_curMRPRInfo.discussions.count > 0 && indexPath.section == 2){//Comment
        ProjectLineNote *curCommentItem = [[_curMRPRInfo.discussions objectAtIndex:indexPath.row] firstObject];
        return [MRPRCommentCell cellHeightWithObj:curCommentItem];
    }else{//Add Comment
        return [AddCommentCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {//Content
    }else if (indexPath.section == 1){//Disclosure
        if (indexPath.row == 0) {
            MRPRCommitsViewController *vc = [MRPRCommitsViewController new];
            vc.curMRPR = _curMRPR;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            MRPRFilesViewController *vc = [MRPRFilesViewController new];
            vc.curMRPR = _curMRPR;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (_curMRPRInfo.discussions.count > 0 && indexPath.section == 2){//Comment
        ProjectLineNote *curCommentItem = [[_curMRPRInfo.discussions objectAtIndex:indexPath.row] firstObject];
        [self goToAddCommentVCToUser:curCommentItem.author.name];
    }else{//Add Comment
        [self goToAddCommentVCToUser:nil];
    }
}

#pragma mark Comment
- (void)goToAddCommentVCToUser:(NSString *)userName{
    DebugLog(@"%@", userName);
    AddMDCommentViewController *vc = [AddMDCommentViewController new];
    
    vc.requestPath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/line_notes", _curMRPR.des_owner_name, _curMRPR.des_project_name];
    vc.requestParams = [@{
                         @"noteable_type" : @"MergeRequestBean",
                         @"noteable_id" : _curMRPRInfo.mrpr.id,
                         } mutableCopy];
    vc.contentStr = userName;
    @weakify(self);
    vc.completeBlock = ^(id data, NSError *error){
        @strongify(self);
        if (data && [data isKindOfClass:[ProjectLineNote class]]) {
            [self.curMRPRInfo.discussions addObject:[NSArray arrayWithObject:data]];
        }
    };
    
    [self.navigationController pushViewController:vc animated:YES];
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
        // 可能是图片链接
        HtmlMedia *htmlMedia = self.curMRPRInfo.htmlMedia;
        if (htmlMedia.imageItems.count > 0) {
            for (HtmlMediaItem *item in htmlMedia.imageItems) {
                if ((item.src.length > 0 && [item.src isEqualToString:linkStr])
                    || (item.href.length > 0 && [item.href isEqualToString:linkStr])) {
                    [MJPhotoBrowser showHtmlMediaItems:htmlMedia.imageItems originalItem:item];
                    return;
                }
            }
        }
        // 跳转去网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *clickedItem = [components objectForKey:@"value"];
    [self analyseLinkStr:clickedItem.href];
}


@end
