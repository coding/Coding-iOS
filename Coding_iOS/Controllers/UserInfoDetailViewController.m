//
//  UserInfoDetailViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/3/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "UserInfoDetailViewController.h"

#import "UserInfoDetailTagCell.h"
#import "UserInfoDetailUserCell.h"
#import "TitleValueCell.h"


@interface UserInfoDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation UserInfoDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _curUser.name;
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UserInfoDetailUserCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoDetailUserCell];
        [tableView registerClass:[TitleValueCell class] forCellReuseIdentifier:kCellIdentifier_TitleValue];
        [tableView registerClass:[UserInfoDetailTagCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoDetailTagCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
}

#pragma mark TableM

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row;
    switch (section) {
        case 0:
            row = 1;
            break;
        case 1:
            row = 3;
            break;
        case 2:
            row = 4;
            break;
        case 3:
            row = 4;
            break;
        default:
            row = 1;
            break;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UserInfoDetailUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoDetailUserCell forIndexPath:indexPath];
        [cell setName:_curUser.name icon:_curUser.avatar];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if (indexPath.section == 4 || indexPath.section == 5){
        UserInfoDetailTagCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoDetailTagCell forIndexPath:indexPath];
        [cell setTitleStr:indexPath.section == 4? @"开发技能": @"个性标签"];
        [cell setTagStr:indexPath.section == 4? _curUser.skills_str: _curUser.tags_str];
        cell.accessoryType = UITableViewCellAccessoryNone;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        TitleValueCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValue forIndexPath:indexPath];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        
        switch (indexPath.section) {
            case 1:
                switch (indexPath.row) {
                    case 0:
                        [cell setTitleStr:@"加入时间" valueStr:[_curUser.created_at string_yyyy_MM_dd]];
                        break;
                    case 1:
                        [cell setTitleStr:@"最后活动" valueStr:[_curUser.last_activity_at string_yyyy_MM_dd]];
                        break;
                    default:
                        [cell setTitleStr:@"个性后缀" valueStr:_curUser.global_key];
                        break;
                }
                break;
            case 2:
                switch (indexPath.row) {
                    case 0:
                        if (_curUser.sex.intValue == 0) {
                            //        男
                            [cell setTitleStr:@"性别" valueStr:@"男"];
                        }else if (_curUser.sex.intValue == 1){
                            //        女
                            [cell setTitleStr:@"性别" valueStr:@"女"];
                        }else{
                            //        未知
                            [cell setTitleStr:@"性别" valueStr:@"未知"];
                        }
                        break;
                    case 1:
                        [cell setTitleStr:@"生日" valueStr:_curUser.birthday];
                        break;
                    case 2:
                        [cell setTitleStr:@"所在地" valueStr:_curUser.location];
                        break;
                    default:
                        [cell setTitleStr:@"座右铭" valueStr:_curUser.slogan];
                        break;
                }
                break;
            default:
                if (indexPath.row == 0) {
                    [cell setTitleStr:@"学历" valueStr:_curUser.degree_str];
                }else if (indexPath.row == 1){
                    [cell setTitleStr:@"学校" valueStr:_curUser.school];
                }else if (indexPath.row == 2){
                    [cell setTitleStr:@"公司" valueStr:_curUser.company];
                }else{
                    [cell setTitleStr:@"工作" valueStr:_curUser.job_str];
                }
                break;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight;
    if (indexPath.section == 0) {
        cellHeight = [UserInfoDetailUserCell cellHeight];
    }else if (indexPath.section == 4 || indexPath.section == 5){
        cellHeight = [UserInfoDetailTagCell cellHeightWithObj:indexPath.section == 4? _curUser.skills_str: _curUser.tags_str];
    }else{
        cellHeight = 44;
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
    headerView.backgroundColor = kColorTableSectionBg;
    [headerView setHeight:20.0];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
