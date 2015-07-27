//
//  CSLikesVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/27.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSLikesVC.h"
#import "User.h"
#import "UserCell.h"
#import "UserInfoViewController.h"

@interface CSLikesVC ()

@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *searchResults;

@end

@implementation CSLikesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"全部参与者";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        [tableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier_UserCell];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    [self.myTableView reloadData];
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _userlist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserCell];
    if (cell == nil) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier_UserCell];
    }
    User *curUser = [_userlist objectAtIndex:indexPath.row];
    cell.curUser = curUser;
    cell.usersType = UsersTypeTweetLikers;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UserCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    User *user = [_userlist objectAtIndex:indexPath.row];
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.curUser = user;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
