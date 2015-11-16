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
        self.items = @[@{@"all":@""},@{@"created":@""},@{@"joined":@""},@{@"watched":@""},@{@"stared":@""}];
        self.pCount=[ProjectCount new];
        self.showStatus=FALSE;
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
    
//    typeof(self) __weak weakSelf = self;
    _realTimeBlur = [[XHRealTimeBlur alloc] initWithFrame:self.bounds];
    _realTimeBlur.blurStyle = XHBlurStyleTranslucentWhite;
    _realTimeBlur.showDuration = 0.2;
    _realTimeBlur.disMissDuration = 0.3;
//    _realTimeBlur.willShowBlurViewcomplted = ^(void) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//    };
//    
//    _realTimeBlur.willDismissBlurViewCompleted = ^(void) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
//    };
//    _realTimeBlur.didDismissBlurViewCompleted = ^(BOOL finished) {
////        [weakSelf removeFromSuperview];
//    };
    _realTimeBlur.hasTapGestureEnable = YES;
    
    _tableview = ({
        UITableView *tableview=[[UITableView alloc] initWithFrame:self.bounds];
        tableview.backgroundColor=[UIColor clearColor];
        tableview.delegate=self;
        tableview.dataSource=self;
        [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        tableview.tableFooterView=[UIView new];
        tableview.rowHeight=50;
        tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
        tableview;
    });
    [self addSubview:_tableview];
    _tableview.contentInset=UIEdgeInsetsMake(15, 0,0,0);

}

#pragma mark -- event & action
- (void)showMenuAtView:(UIView *)containerView {
    _showStatus=TRUE;
    [containerView addSubview:self];
    [_realTimeBlur showBlurViewAtView:self];
}

- (void)dismissMenu
{
    _showStatus=FALSE;
    [_realTimeBlur disMiss];
    [self removeFromSuperview];
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
    _items = @[@{@"all":[pCount.all stringValue]},@{@"created":[pCount.created stringValue]},@{@"joined":[pCount.joined  stringValue]},@{@"watched":[pCount.watched stringValue]},@{@"stared":[pCount.stared stringValue]}];
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
            return 2;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
    titleLab.font=[UIFont systemFontOfSize:15];
    [cell.contentView addSubview:titleLab];
    if (indexPath.section==0) {
        titleLab.textColor=[UIColor colorWithHexString:@"0x222222"];
        titleLab.text=[self formatTitleStr:[_items objectAtIndex:indexPath.row]];
    }else if (indexPath.section==1) {
        titleLab.textColor=[UIColor colorWithHexString:@"0x222222"];
        titleLab.text=[self formatTitleStr:[_items objectAtIndex:3+indexPath.row]];
    }else
    {
        [titleLab setX:45];
        titleLab.textColor=[UIColor colorWithHexString:@"0x727f8d"];
        titleLab.text=@"项目广场";
        
        UIImageView *projectSquareIcon=[[UIImageView alloc] initWithFrame:CGRectMake(20, 25-8, 16, 16)];
        projectSquareIcon.image=[UIImage imageNamed:@"fliter_square"];
        [cell.contentView addSubview:projectSquareIcon];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        _selectNum=indexPath.row;
        [self dismissMenu];
        _clickBlock([self convertToProjectType]);
    }else if (indexPath.section==1) {
        _selectNum=indexPath.row+kfirstRowNum;
        [self dismissMenu];
        _clickBlock([self convertToProjectType]);
    }else
    {
        _clickBlock(1000);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section!=0) {
        return ({
                 UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30.5)];
                 UIView *seperatorLine=[[UIView alloc] initWithFrame:CGRectMake(20, 15, self.bounds.size.width-40, 0.5)];
                 seperatorLine.backgroundColor=[UIColor colorWithHexString:@"0xcccccc"];
                 [view addSubview:seperatorLine];
                 view;
        });
    }else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section!=0)?30.5:0;
}


@end
