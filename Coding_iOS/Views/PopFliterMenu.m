//
//  PopFliterMenu.m
//  Coding_iOS
//
//  Created by jwill on 15/11/10.
//  Copyright © 2015年 Coding. All rights reserved.
//
#define kfirstRowNum 3

#import "PopFliterMenu.h"
#import "XHRealTimeBlur.h"
#import "Coding_NetAPIManager.h"
#import "ProjectCount.h"
#import "Projects.h"
#import "pop.h"

@interface PopFliterMenu()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) XHRealTimeBlur *realTimeBlur;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) ProjectCount *pCount;
@end

@implementation PopFliterMenu

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.items = @[@{@"all":@""},@{@"created":@""},@{@"joined":@""},@{@"watched":@""},@{@"stared":@""}].mutableCopy;
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
            [weakSelf updateDateSource:weakSelf.pCount];
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

//组装cell标题
- (NSString*)formatTitleStr:(NSDictionary*)aDic
{
    NSString *keyStr=[[aDic allKeys] firstObject];
    NSMutableString *convertStr=[NSMutableString new];
    if ([keyStr isEqualToString:@"all"]) {
        [convertStr appendString:@"全部项目"];
    }else if ([keyStr isEqualToString:@"created"]) {
        [convertStr appendString:@"我创建的"];
    }else if ([keyStr isEqualToString:@"joined"]) {
        [convertStr appendString:@"我参与的"];
    }else if ([keyStr isEqualToString:@"watched"]) {
        [convertStr appendString:@"我关注的"];
    }else if ([keyStr isEqualToString:@"stared"]) {
        [convertStr appendString:@"我收藏的"];
    }else
    {
        NSLog(@"-------------error type:%@",keyStr);
    }
    if ([[aDic objectForKey:keyStr] length]>0) {
        [convertStr appendString:[NSString stringWithFormat:@" (%@)",[aDic objectForKey:keyStr]]];
    }
    return [convertStr copy];
}

//更新数据源
-(void)updateDateSource:(ProjectCount*)pCount
{
    _items = @[@{@"all":[pCount.all stringValue]},@{@"created":[pCount.created stringValue]},@{@"joined":[pCount.joined  stringValue]},@{@"watched":[pCount.watched stringValue]},@{@"stared":[pCount.stared stringValue]}].mutableCopy;
}


//转化为Projects类对应类型
-(NSInteger)convertToProjectType
{
    switch (_selectNum) {
        case 0:
            return ProjectsTypeAll;
            break;
        case 1:
            return ProjectsTypeCreated;
            break;
        case 2:
            return ProjectsTypeJoined;
            break;
        case 3:
            return ProjectsTypeWatched;
            break;
        case 4:
            return ProjectsTypeStared;
            break;
        default:
            NSLog(@"type error");
            return ProjectsTypeAll;
            break;
    }
}


#pragma mark -- uitableviewdelegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return kfirstRowNum;
            break;
        case 1:
            return 2+1;
            break;
        case 2:
            return 1+1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.backgroundColor=[UIColor clearColor];
    UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
    titleLab.font=[UIFont systemFontOfSize:15];
    [cell.contentView addSubview:titleLab];
    if (indexPath.section==0) {
        titleLab.textColor=(indexPath.row==_selectNum)?kColorBrandGreen:kColor222;
        titleLab.text=[self formatTitleStr:[_items objectAtIndex:indexPath.row]];
    }else if (indexPath.section==1) {
        if(indexPath.row==0){
            [titleLab removeFromSuperview];
            UIView *seperatorLine=[[UIView alloc] initWithFrame:CGRectMake(20, 15, self.bounds.size.width-40, 0.5)];
            seperatorLine.backgroundColor=kColorCCC;
            [cell.contentView addSubview:seperatorLine];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }else{
            titleLab.textColor=(indexPath.row+kfirstRowNum==_selectNum)?kColorBrandGreen:kColor222;
            titleLab.text=[self formatTitleStr:[_items objectAtIndex:3+indexPath.row-1]];
        }
    }else
    {
        if(indexPath.row==0){
            [titleLab removeFromSuperview];
            UIView *seperatorLine=[[UIView alloc] initWithFrame:CGRectMake(20, 15, self.bounds.size.width-40, 0.5)];
            seperatorLine.backgroundColor=kColorCCC;
            [cell.contentView addSubview:seperatorLine];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }else{
            [titleLab setX:45];
            titleLab.textColor=[UIColor colorWithHexString:@"0x727f8d"];
            titleLab.text=@"项目广场";
            UIImageView *projectSquareIcon=[[UIImageView alloc] initWithFrame:CGRectMake(20, 25-8, 16, 16)];
            projectSquareIcon.image=[UIImage imageNamed:@"fliter_square"];
            [cell.contentView addSubview:projectSquareIcon];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ((indexPath.row==0)&&(indexPath.section==1))||((indexPath.row==0)&&(indexPath.section==2))?30.5:50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        _selectNum=indexPath.row;
        [self dismissMenu];
        _clickBlock([self convertToProjectType]);
    }else if (indexPath.section==1) {
        if(indexPath.row==0){
            _closeBlock();
            return;
        }
        _selectNum=indexPath.row+kfirstRowNum-1;
        [self dismissMenu];
        _clickBlock([self convertToProjectType]);
    }else
    {
        if(indexPath.row==0){
            _closeBlock();
            return;
        }
        _clickBlock(1000);
        _closeBlock();
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didClickedContentView:(UIGestureRecognizer *)sender {
    _closeBlock();
}


@end
