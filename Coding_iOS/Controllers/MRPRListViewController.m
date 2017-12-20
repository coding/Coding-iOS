//
//  MRPRListViewController.m
//  Coding_iOS
//
//  Created by Ease on 2017/2/14.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "MRPRListViewController.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "MRPRS.h"
#import "Coding_NetAPIManager.h"
#import "MRPRListCell.h"
#import "PRDetailViewController.h"
#import "MRDetailViewController.h"
#import "EAFliterMenu.h"

@interface MRPRListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSMutableDictionary *dataDict;
@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (strong, nonatomic) UIButton *titleBtn;
@property (nonatomic, strong) EAFliterMenu *myFliterMenu;

@end

@implementation MRPRListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.view.backgroundColor = kColorTableBG;
    _dataDict = [NSMutableDictionary new];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[MRPRListCell class] forCellReuseIdentifier:kCellIdentifier_MRPRListCell];
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
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore:YES];
    }];
    self.selectedIndex = 0;
    
    //初始化过滤目录
    _myFliterMenu = [[EAFliterMenu alloc] initWithFrame:CGRectMake(0, 44 + kSafeArea_Top, kScreen_Width, kScreen_Height - (44 + kSafeArea_Top)) items:[self titleList]];
    _myFliterMenu.clickBlock = ^(NSInteger selectIndex){
        if (weakSelf.selectedIndex != selectIndex) {
            weakSelf.selectedIndex = selectIndex;
        }
    };
    
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_myFliterMenu.isShowing) {
        [_myFliterMenu dismissMenu];
    }
}

#pragma mark Fliter

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
    [self setupTitleBtn];

    [self.myTableView reloadData];
    
    __weak typeof(self) weakSelf = self;
    [self.view configBlankPage:EaseBlankPageTypeView hasData:YES hasError:NO reloadButtonBlock:^(id sender) {
        [weakSelf refreshMore:NO];
    }];
    if ([self curMRPRS].list.count <= 0) {
        [self refresh];
    }else{
        self.myTableView.showsInfiniteScrolling = [self curMRPRS].canLoadMore;
    }
}

- (NSArray *)titleList{
    NSArray *titleList = (_isMR? @[@"默认",
                                   @"可合并",
                                   @"不可自动合并",
                                   @"已拒绝",
                                   @"已合并",
                                   ]:
                          @[@"未处理",
                            @"已处理",
                            @"全部",
                            ]);
    return titleList;
}

- (void)setupTitleBtn{
    if (!_titleBtn) {
        _titleBtn = [UIButton new];
        [_titleBtn setTitleColor:kColorNavTitle forState:UIControlStateNormal];
        [_titleBtn.titleLabel setFont:[UIFont systemFontOfSize:kNavTitleFontSize]];
        [_titleBtn addTarget:self action:@selector(fliterClicked) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = _titleBtn;
    }
    
    NSString *titleStr = [self titleList][_selectedIndex];
    CGFloat titleWidth = [titleStr getWidthWithFont:_titleBtn.titleLabel.font constrainedToSize:CGSizeMake(kScreen_Width, 30)];
    CGFloat imageWidth = 12;
    CGFloat btnWidth = titleWidth +imageWidth;
    _titleBtn.frame = CGRectMake((kScreen_Width-btnWidth)/2, (44-30)/2, btnWidth, 30);
    _titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
    _titleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth, 0, -titleWidth);
    [_titleBtn setTitle:titleStr forState:UIControlStateNormal];
    [_titleBtn setImage:[UIImage imageNamed:@"btn_fliter_down"] forState:UIControlStateNormal];
}

-(void)fliterClicked{
    if (_myFliterMenu.isShowing) {
        [_myFliterMenu dismissMenu];
    }else{
        _myFliterMenu.selectIndex = self.selectedIndex;
        [_myFliterMenu showMenuInView:kKeyWindow];
    }
}

#pragma mark Data

- (MRPRS *)curMRPRS{
    MRPRS *curMRPRS = [_dataDict objectForKey:@(_selectedIndex)];
    if (!curMRPRS) {
        
        curMRPRS = [[MRPRS alloc] initWithType:_isMR? _selectedIndex: _selectedIndex + MRPRSTypePROpen userGK:_curProject.owner_user_name projectName:_curProject.name];
        [_dataDict setObject:curMRPRS forKey:@(_selectedIndex)];
    }
    return curMRPRS;
}

- (void)refresh{
    [self refreshMore:NO];
}
- (void)refreshMore:(BOOL)willLoadMore{
    MRPRS *curMRPRS = [self curMRPRS];
    if (curMRPRS.isLoading) {
        return;
    }
    if (willLoadMore && !curMRPRS.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    curMRPRS.willLoadMore = willLoadMore;
    [self sendRequest:curMRPRS];
}

- (void)sendRequest:(MRPRS *)curMRPRS{
    if (curMRPRS.list.count <= 0) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(curMRPRS) weakMRPRS = curMRPRS;
    [[Coding_NetAPIManager sharedManager] request_MRPRS_WithObj:curMRPRS andBlock:^(MRPRS *data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakMRPRS configWithMRPRS:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = [weakSelf curMRPRS].canLoadMore;
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:([weakSelf curMRPRS].list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refreshMore:NO];
        }];
    }];
}


#pragma mark TableM
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self curMRPRS].list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MRPR *curMRPR = [[self curMRPRS].list objectAtIndex:indexPath.row];
    MRPRListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRPRListCell forIndexPath:indexPath];
    cell.curMRPR = curMRPR;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MRPRListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MRPR *curMRPR = [[self curMRPRS].list objectAtIndex:indexPath.row];
    if(curMRPR.isPR) {
        PRDetailViewController *vc = [PRDetailViewController new];
        vc.curMRPR = curMRPR;
        vc.curProject = _curProject;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        MRDetailViewController *vc = [MRDetailViewController new];
        vc.curMRPR = curMRPR;
        vc.curProject = _curProject;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
