//
//  TaskSelectionView.m
//  Coding_iOS
//
//  Created by 张达棣 on 16/12/4.
//  Copyright © 2016年 Coding. All rights reserved.
//

#define kfirstRowNum 3

#import "TaskSelectionView.h"
#import "XHRealTimeBlur.h"
#import "Coding_NetAPIManager.h"
#import "ProjectCount.h"
#import "Projects.h"
#import "pop.h"
#import "TaskSelectionCell.h"

@interface TaskSelectionView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) XHRealTimeBlur *realTimeBlur;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) ProjectCount *pCount;
@property (nonatomic, assign) NSInteger selectNum;  //选中数据

@end

@implementation TaskSelectionView

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.items = items;
        self.pCount=[ProjectCount new];
        self.showStatus= NO;
        [self setup];
    }
    return self;
}

- (void)refreshMenuDate
{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectsCatergoryAndCounts_WithObj:_pCount andBlock:^(ProjectCount *data, NSError *error) {
        if (data) {
            [weakSelf.pCount configWithProjects:data];
            [weakSelf.tableview reloadData];
        }
        if(error)
        {
            NSLog(@"get count error");
        }
    }];
}

// 设置属性
- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    
    _realTimeBlur = [[XHRealTimeBlur alloc] initWithFrame:self.bounds];
    _realTimeBlur.clipsToBounds = YES;
    _realTimeBlur.blurStyle = XHBlurStyleTranslucentWhite;
    _realTimeBlur.showDuration = 0.1;
    _realTimeBlur.disMissDuration = 0.2;
    typeof(self) __weak weakSelf = self;
    
    _realTimeBlur.willShowBlurViewcomplted = ^(void) {
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.fromValue = @0.0;
        alphaAnimation.toValue = @1.0;
        alphaAnimation.duration = 0.3f;
        [weakSelf.tableview pop_addAnimation:alphaAnimation forKey:@"alphaAnimationS"];
    };
    
    _realTimeBlur.willDismissBlurViewCompleted = ^(void) {
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.fromValue = @1.0;
        alphaAnimation.toValue = @0.0;
        alphaAnimation.duration = 0.2f;
        [weakSelf.tableview pop_addAnimation:alphaAnimation forKey:@"alphaAnimationE"];
    };
    
    _realTimeBlur.didDismissBlurViewCompleted = ^(BOOL finished) {
        [weakSelf removeFromSuperview];
    };
    
    
    _realTimeBlur.hasTapGestureEnable = YES;
    
    _tableview = ({
        UITableView *tableview=[[UITableView alloc] initWithFrame:self.bounds];
        tableview.backgroundColor=[UIColor clearColor];
        tableview.delegate=self;
        tableview.dataSource=self;
        [tableview registerClass:[TaskSelectionCell class] forCellReuseIdentifier:kCellIdentifier_TaskSelectionCell];
        tableview.tableFooterView=[UIView new];
        tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
        tableview;
    });
    [self addSubview:_tableview];
    _tableview.contentInset=UIEdgeInsetsMake(15, 0,0,0);
    
    
    int contentHeight=100;
    if ((kScreen_Height-64)>contentHeight) {
        UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0,64+contentHeight , kScreen_Width, kScreen_Height-64-contentHeight)];
        contentView.backgroundColor=[UIColor clearColor];
        [self addSubview:contentView];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedContentView:)];
        [contentView addGestureRecognizer:tapGestureRecognizer];
    }
}

#pragma mark -- event & action
- (void)showMenuAtView:(UIView *)containerView {
    _showStatus= YES;
    [containerView addSubview:self];
    [_realTimeBlur showBlurViewAtView:self];
    [_tableview reloadData];
}

- (void)dismissMenu
{
    UIView *presentView=[[[UIApplication sharedApplication].keyWindow rootViewController] view];
    if ([[presentView.subviews firstObject] isMemberOfClass:NSClassFromString(@"RDVTabBar")]) {
        [presentView bringSubviewToFront:[presentView.subviews firstObject]];
    }
    _showStatus= NO;
    [_realTimeBlur disMiss];
}


#pragma mark -- uitableviewdelegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TaskSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TaskSelectionCell forIndexPath:indexPath];
    cell.title = _items[indexPath.row];
    cell.isSel = indexPath.row==_selectNum;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ((indexPath.row==0)&&(indexPath.section==1))||((indexPath.row==0)&&(indexPath.section==2))?30.5:50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectNum=indexPath.row;
    [self dismissMenu];
    _clickBlock(indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didClickedContentView:(UIGestureRecognizer *)sender {
    _closeBlock();
}


- (void)setItems:(NSArray *)items {
    _items = items;
    [_tableview reloadData];
}

@end
