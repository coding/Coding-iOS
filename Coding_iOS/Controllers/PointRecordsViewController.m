//
//  PointRecordsViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "PointRecordsViewController.h"
#import "WebViewController.h"
#import "ShopViewController.h"
#import "Coding_NetAPIManager.h"

#import "SVPullToRefresh.h"
#import "ODRefreshControl.h"

#import "PointTopCell.h"
#import "PointShopCell.h"
#import "PointRecordCell.h"

@interface PointRecordsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) PointRecords *curRecords;

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (assign, nonatomic) BOOL isShowingTip;
@property (strong, nonatomic) UIView *tipContainerV;
@property (strong, nonatomic) UIImageView *tipBGV;
@property (strong, nonatomic) UILabel *tipL;
@end

@implementation PointRecordsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的码币";
    self.curRecords = [PointRecords new];
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[PointTopCell class] forCellReuseIdentifier:kCellIdentifier_PointTopCell];
        [tableView registerClass:[PointShopCell class] forCellReuseIdentifier:kCellIdentifier_PointShopCell];
        [tableView registerClass:[PointRecordCell class] forCellReuseIdentifier:kCellIdentifier_PointRecordCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tip_normal_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)];
    self.isShowingTip = NO;
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
    [self refresh];
}

- (void)refresh{
    if (_curRecords.isLoading) {
        return;
    }
    _curRecords.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore{
    if (_curRecords.isLoading || !_curRecords.canLoadMore) {
        return;
    }
    _curRecords.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest{
    if (_curRecords.list.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_PointRecords:_curRecords andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.view endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.curRecords configWithObj:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.curRecords.canLoadMore;
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.curRecords.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _curRecords.list.count <= 0? 0:2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0? 2: self.curRecords.list.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            PointRecord *record = [_curRecords.list firstObject];
            PointTopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_PointTopCell forIndexPath:indexPath];
            cell.pointLeftStr = [NSString stringWithFormat:@"%.2f", record.points_left.floatValue];
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0 hasSectionLine:NO];
            return cell;
        }else{
            PointShopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_PointShopCell forIndexPath:indexPath];
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
            return cell;
        }
    }else{
        PointRecord *record = [_curRecords.list objectAtIndex:indexPath.row];
        PointRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_PointRecordCell forIndexPath:indexPath];
        cell.curRecord = record;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = indexPath.row == 0? [PointTopCell cellHeight]: [PointShopCell cellHeight];
    }else{
        cellHeight = [PointRecordCell cellHeight];
    }
    return cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section == 0? 20.0 : 0.5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [UIView new];
    footerView.backgroundColor = kColorTableSectionBg;
    return footerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = kColorTableSectionBg;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        //商城入口
        ShopViewController *shopvc = [[ShopViewController alloc] init];
        [self.navigationController pushViewController:shopvc animated:YES];
    }
}

#pragma mark rightNavBtn
- (void)rightNavBtnClicked{
    CGRect originFrame = CGRectMake(kScreen_Width - 15, 0, 0, 0);
    if (_isShowingTip) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tipContainerV.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            self.tipBGV.frame = originFrame;
        } completion:^(BOOL finished) {
            [self.tipContainerV removeFromSuperview];
            self.isShowingTip = NO;
        }];
    }else{
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = kDevice_Is_iPhone4? 0: 5;
        if (!_tipContainerV) {
            _tipContainerV = [[UIView alloc] initWithFrame:self.view.bounds];
        }
        if (!_tipBGV) {
            _tipBGV = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tip_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 15, 20, 30) resizingMode:UIImageResizingModeStretch]];
            _tipBGV.frame = originFrame;
            _tipBGV.clipsToBounds = YES;
            [_tipContainerV addSubview:_tipBGV];
        }
        if (!_tipL) {
            _tipL = [UILabel new];
            _tipL.textColor = kColor222;
            _tipL.font = [UIFont systemFontOfSize:14];
            _tipL.numberOfLines = 0;
            NSString *tipStr =
@"1. 使用人民币 兑换 （请通过点击账户码币页面的”购买码币”，以充值的形式购买码币。码币与人民币的兑换标准是 1 码币= 50 元人民币（0.1 码币起购买）,支持支付宝及微信付款）\n\
2. 冒泡 被管理员推荐上广场 奖励 0.01\n\
3. 邀请好友 注册 Coding 并绑定手机号 奖励 0.02mb\n\
4. 过生日赠送 0.1mb\n\
5. 完善 个人信息 奖励 0.1mb\n\
6. 完成 手机验证 奖励 0.1mb\n\
7. 开启 两步验证 奖励 0.1mb\n\
8. App 首次登录 奖励 0.1mb\n\
9. 我们不定期发布的其他形式的码币悬赏活动（请关注 Coding冒泡，Coding微博 及 Coding微信公众号），数量不等\n\
10. 转发 Coding微博，每周抽 1 名转发用户赠送 0.5mb\n\
11. 给 Coding 博客 投稿 奖励 1-2mb";
            NSMutableAttributedString *tipAttrStr = [[NSMutableAttributedString alloc] initWithString:tipStr];
            [tipAttrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, tipStr.length)];
            _tipL.attributedText = tipAttrStr;
            _tipL.frame = CGRectMake(15, 40, kScreen_Width - 15 * 4, 0);
            [_tipBGV addSubview:_tipL];
        }
        CGFloat textHeight = [_tipL.text boundingRectWithSize:CGSizeMake(kScreen_Width - 15 * 4, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: _tipL.font} context:nil].size.height;
        _tipL.height = textHeight;
        [self.view addSubview:self.tipContainerV];
        [UIView animateWithDuration:0.3 animations:^{
            self.tipContainerV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            self.tipBGV.frame = CGRectMake(15, 0, kScreen_Width - 15 * 2, textHeight + 40 + 30);
        } completion:^(BOOL finished) {
            self.isShowingTip = YES;
        }];
    }
}

@end
