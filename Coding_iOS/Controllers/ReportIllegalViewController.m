//
//  ReportIllegalViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/2/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ReportIllegalViewController.h"
#import "ValueListCell.h"
#import "Login.h"
#import "Coding_NetAPIManager.h"


@interface ReportIllegalViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) NSInteger selectedIndex;
@property (strong, nonatomic) NSArray *dataList;
@property (strong, nonatomic) UITableView *myTableView;

@end


@implementation ReportIllegalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    _selectedIndex = NSNotFound;
    _dataList = @[
                  @"淫秽色情",
                  @"垃圾广告",
                  @"敏感信息",
                  @"抄袭内容",
                  @"侵犯版权",
                  @"骚扰我"
                  ];
    
    self.title = @"举报";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"提交" target:self action:@selector(submitClicked:)];
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ValueListCell class] forCellReuseIdentifier:kCellIdentifier_ValueList];
        tableView.backgroundColor = kColorTableSectionBg;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    @weakify(self);
    
    [RACObserve(self, selectedIndex) subscribeNext:^(id x) {
        @strongify(self);
        self.navigationItem.rightBarButtonItem.enabled = (self.selectedIndex >= 0
                                                          && self.selectedIndex < [self.dataList count]);
    }];
    
    
}
- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)submitClicked:(id)sender{
    if (_illegalContent.length > 0) {
        NSString *user_globalKey = [Login curLoginUser].global_key;
        NSString *reasonStr = [self.dataList objectAtIndex:self.selectedIndex];
        NSDictionary *params = @{
                                 @"user": user_globalKey,
                                 @"content" : _illegalContent,
                                 @"reason" : reasonStr
                                 };
        [[CodingNetAPIClient sharedJsonClient] reportIllegalContentWithType:self.type withParams:params];
    }
    [NSObject showHudTipStr:@"举报信息已发送"];
    [self dismissSelf];
}

#pragma mark Show
+ (void)showReportWithIllegalContent:(NSString *)illegalContent andType:(IllegalContentType)type{
    ReportIllegalViewController *vc = [[ReportIllegalViewController alloc] init];
    vc.illegalContent = illegalContent;
    vc.type = type;
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [[BaseViewController presentingVC] presentViewController:nav animated:YES completion:nil];
}


#pragma mark TableM

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ValueListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ValueList forIndexPath:indexPath];
    
    [cell setTitleStr:[_dataList objectAtIndex:indexPath.row] imageStr:nil isSelected:(_selectedIndex == indexPath.row)];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    headerView.backgroundColor = kColorTableSectionBg;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.font = [UIFont systemFontOfSize:15];
    headerLabel.textColor = [UIColor lightGrayColor];
    [headerView addSubview:headerLabel];
    [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(20);
        make.right.equalTo(headerView).offset(-20);
        make.bottom.equalTo(headerView).offset(-5);
        make.height.mas_equalTo(20);
    }];
    
    headerLabel.text = @"举报类型";
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    [self.myTableView reloadData];
}

@end
