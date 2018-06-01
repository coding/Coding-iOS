//
//  TeamSupportViewController.m
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2018/3/15.
//  Copyright © 2018年 Coding. All rights reserved.
//

#define kTeamSupport_Phone @"400-930-9163"
#define kTeamSupport_Mail @"Enterprise@coding.net"
#define kTeamSupport_QQ @"2847276903"

#import "TeamSupportViewController.h"

#import "TeamSupportCell.h"

@interface TeamSupportViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation TeamSupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"售后支持";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        [tableView registerClass:[TeamSupportCell class] forCellReuseIdentifier:kCellIdentifier_TeamSupportCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

#pragma mark Table
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TeamSupportCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TeamSupportCell forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.leftL.text = @"联系电话";
        cell.rightL.text = kTeamSupport_Phone;
    }else if (indexPath.row == 1){
        cell.leftL.text = @"联系邮箱";
        cell.rightL.text = kTeamSupport_Mail;
    }else{
        cell.leftL.text = @"技术支持";
        cell.rightL.text = [NSString stringWithFormat:@"QQ：%@", kTeamSupport_QQ];
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSURL *destinationURL;
    if (indexPath.row == 0) {
        destinationURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", kTeamSupport_Phone]];
    }else if (indexPath.row == 1){
        destinationURL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", kTeamSupport_Mail]];
    }else{
        destinationURL = [NSURL URLWithString:[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web", kTeamSupport_QQ]];
    }
    if ([[UIApplication sharedApplication] canOpenURL:destinationURL]) {
        [[UIApplication sharedApplication] openURL:destinationURL];
    }else{
        [[UIPasteboard generalPasteboard] setString:(indexPath.row == 0? kTeamSupport_Phone: indexPath.row == 1? kTeamSupport_Mail: kTeamSupport_QQ)];
        [NSObject showHudTipStr:@"已复制"];
    }
}

@end
