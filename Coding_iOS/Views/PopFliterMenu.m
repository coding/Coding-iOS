//
//  PopFliterMenu.m
//  Coding_iOS
//
//  Created by jwill on 15/11/10.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "PopFliterMenu.h"
#import "XHRealTimeBlur.h"
#import "Coding_NetAPIManager.h"
#import "ProjectCount.h"

@interface PopFliterMenu()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong, readwrite) NSArray *items;
@property (nonatomic, strong) XHRealTimeBlur *realTimeBlur;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) ProjectCount *pCount;
@end

@implementation PopFliterMenu

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.items = @[@{@"all":@""},@{@"watched":@""},@{@"created":@""},@{@"joined":@""},@{@"stared":@""}];
        self.pCount=[ProjectCount new];
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
    }];
}

// 设置属性
- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    
    typeof(self) __weak weakSelf = self;
    _realTimeBlur = [[XHRealTimeBlur alloc] initWithFrame:self.bounds];
    _realTimeBlur.blurStyle = XHBlurStyleTranslucentWhite;
    _realTimeBlur.showDuration = 0.3;
    _realTimeBlur.disMissDuration = 0.5;
    _realTimeBlur.willShowBlurViewcomplted = ^(void) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    };
    
    _realTimeBlur.willDismissBlurViewCompleted = ^(void) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
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
        tableview;
    });
    [self addSubview:_tableview];
}

- (void)showMenuAtView:(UIView *)containerView {
    [containerView addSubview:self];
    [_realTimeBlur showBlurViewAtView:self];
}

#pragma mark -- uitableviewdelegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text=[[[_items objectAtIndex:indexPath.row] allKeys] firstObject];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

@end
