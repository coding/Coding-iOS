//
//  MRPRAcceptViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPRAcceptViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"

#import "MRPRAcceptEditCell.h"
#import "TextCheckMarkCell.h"


@interface MRPRAcceptViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UIButton *mergeBtn;

@property (strong, nonatomic) MRPR *curMRPR;
@end


@implementation MRPRAcceptViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"合并此请求";
    
    self.curMRPR = self.curMRPRInfo.mrpr;
    self.curMRPR.del_source_branch = YES;
    self.curMRPR.can_edit_src_branch = ([_curMRPR isMR] && _curMRPRInfo.can_edit_src_branch.boolValue);
    
    NSString *fromStr, *toStr;
    if (_curMRPR.isMR) {
        fromStr = [NSString stringWithFormat:@"  %@  ", _curMRPR.srcBranch];
        toStr = [NSString stringWithFormat:@"  %@  ", _curMRPR.desBranch];
    }else{
        fromStr = [NSString stringWithFormat:@"  %@ : %@  ", _curMRPR.src_owner_name, _curMRPR.srcBranch];
        toStr = [NSString stringWithFormat:@"  %@ : %@  ", _curMRPR.des_owner_name, _curMRPR.desBranch];
    }
    self.curMRPR.message = [NSString stringWithFormat:@"Accept Merge Request #%@ : (%@ -> %@)", _curMRPR.iid.stringValue, fromStr, toStr];
    
    self.curMRPR.message = [NSString stringWithFormat:
@"Accept Merge Request #%@ : %@\n\n\
From -> To: (%@ -> %@)\n\n\
Merge Request: %@\n\n\
Created By: @%@\n\
Accepted By: @%@\n\
URL:%@",
_curMRPR.iid.stringValue,
_curMRPR.title,
fromStr,
toStr,
_curMRPR.title,
_curMRPR.author.name,
[Login curLoginUser].name,
[NSURL URLWithString:_curMRPR.path relativeToURL:[NSURL URLWithString:[NSObject baseURLStr]]].absoluteString];
    
    _myTableView = ({
        UITableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[MRPRAcceptEditCell class] forCellReuseIdentifier:kCellIdentifier_MRPRAcceptEditCell];
        [tableView registerClass:[TextCheckMarkCell class] forCellReuseIdentifier:kCellIdentifier_TextCheckMarkCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _myTableView.tableFooterView = [self tableFooterView];
}

#pragma mark TableM
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([_curMRPR isMR] && _curMRPRInfo.can_edit_src_branch.boolValue) {
        return 2;
    }else{
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        MRPRAcceptEditCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MRPRAcceptEditCell forIndexPath:indexPath];
        cell.contentTextView.text = _curMRPR.message;
        cell.contentChangedBlock = ^(NSString *messageStr){
            _curMRPR.message = messageStr;
            _mergeBtn.enabled = messageStr.length > 0;
        };
        return cell;
    }else{
        TextCheckMarkCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TextCheckMarkCell forIndexPath:indexPath];
        cell.textStr = @"删除原分支";
        cell.checked = _curMRPR.del_source_branch;
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = [MRPRAcceptEditCell cellHeight];
    }else{
        cellHeight = [TextCheckMarkCell cellHeight];
    }
    return cellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    headerView.backgroundColor = kColorTableSectionBg;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        _curMRPR.del_source_branch = !_curMRPR.del_source_branch;
        [_myTableView reloadData];
    }
}

- (UIView*)tableFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 90)];
    _mergeBtn = [UIButton buttonWithStyle:StrapInfoStyle andTitle:@"确认合并" andFrame:CGRectMake(10, 0, kScreen_Width-10*2, 44) target:self action:@selector(mergeBtnClicked:)];
    [_mergeBtn setCenter:footerV.center];
    [footerV addSubview:_mergeBtn];
    return footerV;
}

- (void)mergeBtnClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_MRPRAccept:_curMRPR andBlock:^(id data, NSError *error) {
        if (data) {
            if (weakSelf.completeBlock) {
                weakSelf.completeBlock(data);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}







@end
