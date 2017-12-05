//
//  EAFliterMenu.m
//  Coding_iOS
//
//  Created by Ease on 2017/2/15.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "EAFliterMenu.h"
#import "XHRealTimeBlur.h"
#import "pop.h"

@interface EAFliterMenu ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) XHRealTimeBlur *realTimeBlur;
@property (nonatomic, strong) UITableView *tableview;

@end

@implementation EAFliterMenu

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.items = items;
        [self setup];
    }
    return self;
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
        [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        tableview.tableFooterView=[UIView new];
        tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
        tableview.estimatedRowHeight = 0;
        tableview.estimatedSectionHeaderHeight = 0;
        tableview.estimatedSectionFooterHeight = 0;
        tableview;
    });
    [self addSubview:_tableview];
    _tableview.contentInset=UIEdgeInsetsMake(15, 0,0,0);
    
    
    int contentHeight=320;
    if ((kScreen_Height-64)>contentHeight) {
        UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0,64+contentHeight , kScreen_Width, kScreen_Height-64-contentHeight)];
        contentView.backgroundColor=[UIColor clearColor];
        [self addSubview:contentView];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedContentView:)];
        [contentView addGestureRecognizer:tapGestureRecognizer];
    }
}

#pragma mark -- event & action
- (void)showMenuInView:(UIView *)containerView{
    _isShowing= YES;
    [containerView addSubview:self];
    [_realTimeBlur showBlurViewAtView:self];
    [_tableview reloadData];
}

- (void)dismissMenu{
    UIView *presentView=[[[UIApplication sharedApplication].keyWindow rootViewController] view];
    if ([[presentView.subviews firstObject] isMemberOfClass:NSClassFromString(@"RDVTabBar")]) {
        [presentView bringSubviewToFront:[presentView.subviews firstObject]];
    }
    _isShowing= NO;
    [_realTimeBlur disMiss];
}

#pragma mark table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    cell.tintColor = kColorBrandGreen;
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UILabel *titleL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:indexPath.row == _selectIndex? kColorBrandGreen: kColor222];
    titleL.text = _items[indexPath.row];
    [cell.contentView addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell);
        make.left.equalTo(cell).offset(20);
    }];
    cell.accessoryType = indexPath.row == _selectIndex? UITableViewCellAccessoryCheckmark: UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissMenu];
    _selectIndex = indexPath.row;
    if (_clickBlock) {
        _clickBlock(_selectIndex);
    }
}

- (void)didClickedContentView:(UIGestureRecognizer *)sender {
    [self dismissMenu];
}

@end
