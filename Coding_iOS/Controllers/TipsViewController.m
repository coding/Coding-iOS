//
//  TipsViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TipsViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "CodingTipCell.h"
#import "RegexKitLite.h"
#import "UserInfoViewController.h"
#import "TopicDetailViewController.h"
#import "TweetDetailViewController.h"
#import "ProjectViewController.h"
#import "SVPullToRefresh.h"
#import "EditTaskViewController.h"
#import "WebViewController.h"
#import "KxMenu.h"

@interface TipsViewController ()
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@end

@implementation TipsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *titleStr;
    switch (self.myCodingTips.type) {
        case 0:
            titleStr = @"@我的";
            break;
        case 1:
            titleStr = @"评论";
            break;
        case 2:
            titleStr = @"系统通知";
            break;
        default:
            break;
    }
    self.title = titleStr;
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)] animated:NO];
    
//    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[CodingTipCell class] forCellReuseIdentifier:kCellIdentifier_CodingTip];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh{
    _myCodingTips.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore{
    if (!_myCodingTips.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _myCodingTips.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest{
    if (_myCodingTips.list.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CodingTips:_myCodingTips andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.view endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myCodingTips configWithObj:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myCodingTips.canLoadMore;
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeViewTips hasData:(weakSelf.myCodingTips.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_myCodingTips.list) {
        row += [_myCodingTips.list count];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CodingTipCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_CodingTip forIndexPath:indexPath];
    CodingTip *tip = [_myCodingTips.list objectAtIndex:indexPath.row];
    cell.curTip = tip;
    __weak typeof(self) weakSelf = self;
    cell.linkClickedBlock = ^(HtmlMediaItem *item, CodingTip *tip){
        [weakSelf analyseHtmlMediaItem:item andTip:tip];
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:2* kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [CodingTipCell cellHeightWithObj:[_myCodingTips.list objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CodingTip *tip = [_myCodingTips.list objectAtIndex:indexPath.row];
    [self p_markReadTip:tip];
}

- (void)p_markReadTip:(CodingTip *)tip{
    if (tip.status.boolValue) {//已读
        return;
    }
    @weakify(self);
    [[Coding_NetAPIManager sharedManager] request_markReadWithCodingTipIdStr:tip.id.stringValue andBlock:^(id data, NSError *error) {
        @strongify(self);
        DebugLog(@"%@: %@", data, error);
        if (data) {
            tip.status = @(YES);
            [self.myTableView reloadData];
        }
    }];
}

- (void)rightNavBtnClicked{
    
    if ([KxMenu isShowingInView:self.view]) {
        [KxMenu dismissMenu:YES];
    }else{
        [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
        [KxMenu setTintColor:[UIColor whiteColor]];
        [KxMenu setLineColor:kColorDDD];
        NSArray *menuItems = @[
                               [KxMenuItem menuItem:_myCodingTips.onlyUnread? @"查看全部": @"查看未读" image:[UIImage imageNamed:@"tips_menu_icon_status"] target:self action:@selector(p_changeTipStatus)],
                               [KxMenuItem menuItem:@"全部标注已读" image:[UIImage imageNamed:@"tips_menu_icon_mkread"] target:self action:@selector(p_markReadAll)],
                               ];
        [menuItems setValue:kColor222 forKey:@"foreColor"];
        CGRect senderFrame = CGRectMake(kScreen_Width - (kDevice_Is_iPhone6Plus? 30: 26), 0, 0, 0);
        [KxMenu showMenuInView:self.view
                      fromRect:senderFrame
                     menuItems:menuItems];
    }
    
//    @weakify(self);
//    [[UIActionSheet bk_actionSheetCustomWithTitle:@"将本页的未读通知全部标记为已读？" buttonTitles:@[@"全部标为已读"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
//        if (index == 0) {
//            @strongify(self);
//            [self p_markReadAll];
//        }
//    }] showInView:self.view];
}

- (void)p_markReadAll{
    @weakify(self);
    [[Coding_NetAPIManager sharedManager] request_markReadWithCodingTips:_myCodingTips andBlock:^(id data, NSError *error) {
        @strongify(self);
        DebugLog(@"%@: %@", data, error);
        if (data) {
//            [self refresh];
            for (CodingTip *tempTip in self.myCodingTips.list) {
                tempTip.status = @(YES);
            }
            [self.myTableView reloadData];
        }
    }];
}

- (void)p_changeTipStatus{
    _myCodingTips.onlyUnread = !_myCodingTips.onlyUnread;
    [_myTableView reloadData];
    [self refresh];
}

#pragma mark analyseHtmlMediaItem
- (void)analyseHtmlMediaItem:(HtmlMediaItem *)item andTip:(CodingTip *)tip{
    
    [self p_markReadTip:tip];
    
    NSString *linkStr = item.href;
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        //网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
