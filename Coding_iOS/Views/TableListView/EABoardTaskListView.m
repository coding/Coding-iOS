//
//  EABoardTaskListView.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/27.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EABoardTaskListView.h"
#import "EATaskBoardListTaskCell.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "SVPullToRefresh.h"
#import "EditTaskViewController.h"
#import "SettingTextViewController.h"
#import "TaskBoardsViewController.h"
#import "EABoardTaskListBlankView.h"

@interface EABoardTaskListDefaultModel: NSObject
@property (strong, nonatomic) NSArray *defaultBoardTLTitleList;
@property (assign, nonatomic) NSInteger handledCount;
@end

@implementation EABoardTaskListDefaultModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _defaultBoardTLTitleList = @[@"需求分析",
                                     @"产品分析",
                                     @"开发中",
                                     @"产品测试",
                                     @"产品上线",
                                     ];
        _handledCount = 0;
    }
    return self;
}
@end

@interface EABoardTaskListView ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;

@end

@implementation EABoardTaskListView

- (instancetype)init{
    self = [super init];
    if (self) {
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[EATaskBoardListTaskCell class] forCellReuseIdentifier:EATaskBoardListTaskCell.nameOfClass];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 49, 0);
            tableView.contentInset = insets;
            tableView.scrollIndicatorInsets = insets;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView;
        });
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        __weak typeof(self) weakSelf = self;
        [_myTableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf refreshMore];
        }];
    }
    return self;
}

- (void)setMyBoardTL:(EABoardTaskList *)myBoardTL{
    _myBoardTL = myBoardTL;
    [self.myTableView reloadData];
    [self refresh];
}

- (void)refresh{
    _myTableView.scrollEnabled = !_myBoardTL.isBlankType;
    if (!_myBoardTL.isBlankType) {
        _myBoardTL.willLoadMore = NO;
        [self sendRequest];
    }else{
        [self.myTableView reloadData];
    }
}

- (void)refreshMore{
    _myBoardTL.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest{
    if (_myBoardTL.isLoading) {
        return;
    }
    if (self.myBoardTL.list.count <= 0) {
        [self beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_TaskInBoardTaskList:_myBoardTL andBlock:^(EABoardTaskList *data, NSError *error) {
        [weakSelf endLoading];
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myBoardTL configWithObj:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myBoardTL.canLoadMore;
        }
        [weakSelf configBlankPage:EaseBlankPageTypeTask hasData:(weakSelf.myBoardTL.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

#pragma mark Table

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_myBoardTL.isBlankType) {
        return self.height;
    }else{
        return 50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self p_headerV];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _myBoardTL.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EATaskBoardListTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:EATaskBoardListTaskCell.nameOfClass forIndexPath:indexPath];
    cell.task = _myBoardTL.list[indexPath.row];
    __weak typeof(self) weakSelf = self;
    cell.taskStatusChangedBlock = ^(Task *task) {
        [weakSelf refresh];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [EATaskBoardListTaskCell cellHeightWithObj:_myBoardTL.list[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EditTaskViewController *vc = [[EditTaskViewController alloc] init];
    vc.myTask = _myBoardTL.list[indexPath.row];
    __weak typeof(self) weakSelf = self;
    vc.taskChangedBlock = ^(){
        [weakSelf refresh];
    };
    [BaseViewController goToVC:vc];
}

#pragma mark header view

- (UIView *)p_headerV{
    if (_myBoardTL.isBlankType && !_myBoardTL.curPro.hasEverHandledBoard) {
        EABoardTaskListBlankView *blankV = [[NSBundle mainBundle] loadNibNamed:EABoardTaskListBlankView.nameOfClass owner:nil options:nil].firstObject;
        [blankV.addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [blankV.createDefaultBtn addTarget:self action:@selector(createDefaultBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        return blankV;
    }else{
        UIView *headerV = [UIView new];
        headerV.backgroundColor = kColorTableSectionBg;
        if (_myBoardTL.isBlankType) {
            UIButton *addBtn = [UIButton new];
            addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [addBtn setTitle:@"创建任务列表" forState:UIControlStateNormal];
            [addBtn setTitleColor:kColorDark2 forState:UIControlStateNormal];
            [addBtn setBackgroundColor:kColorD8DDE4];
            addBtn.cornerRadius = 2.0;
            addBtn.masksToBounds = YES;
            [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [headerV addSubview:addBtn];
            [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(20);
                make.left.offset(15);
                make.right.offset(-15);
                make.height.mas_equalTo(50);
            }];
        }else{
            UILabel *titleL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorDark7];
            titleL.text = [NSString stringWithFormat:@"%@ · %@", _myBoardTL.title ?: @"--", _myBoardTL.totalRow ?: @"--"];
            [headerV addSubview:titleL];
            [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(25);
                make.centerY.equalTo(headerV);
                make.right.lessThanOrEqualTo(headerV).offset(-70);
            }];
            if (_myBoardTL.canEdit) {
                UIButton *editBtn = [UIButton new];
                [editBtn setImage:[UIImage imageNamed:@"editBoardList"] forState:UIControlStateNormal];
                [editBtn addTarget:self action:@selector(editBtnClicked) forControlEvents:UIControlEventTouchUpInside];
                [headerV addSubview:editBtn];
                [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(44, 44));
                    make.right.offset(-20);
                    make.centerY.equalTo(headerV);
                }];
            }
        }
        return headerV;
    }
}

- (void)editBtnClicked{
    __weak typeof(self) weakSelf = self;
    [[UIAlertController ea_actionSheetCustomWithTitle:nil buttonTitles:@[@"编辑任务列表"] destructiveTitle:@"删除" cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 0) {
            [weakSelf editBoardTL];
        }else if (index == 1){
            [weakSelf showDeleteAlert];
        }
    }] showInView:self];
}

- (void)editBoardTL{
    __weak typeof(self) weakSelf = self;
    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"编辑任务列表" textValue:_myBoardTL.title doneBlock:^(NSString *textValue) {
        [NSObject showHUDQueryStr:@"正在修改..."];
        [[Coding_NetAPIManager sharedManager] request_RenameBoardTaskList:weakSelf.myBoardTL withTitle:textValue andBlock:^(EABoardTaskList *data, NSError *error) {
            [NSObject hideHUDQuery];
            if (data) {
                [NSObject showHudTipStr:@"已修改"];
                weakSelf.myBoardTL.title = data.title;
                [weakSelf.myTableView reloadData];
            }
        }];
    }];
    vc.placeholderStr = @"列表名";
    [BaseViewController presentVC:vc];
}

- (void)showDeleteAlert{
    __weak typeof(self) weakSelf = self;
    [[UIAlertController ea_actionSheetCustomWithTitle:@"你确定永远删除这个列表吗？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 0) {
            [weakSelf deleteBoardTL];
        }
    }] showInView:self];
}

- (void)deleteBoardTL{
    __weak typeof(self) weakSelf = self;
    [NSObject showHUDQueryStr:@"正在删除..."];
    [[Coding_NetAPIManager sharedManager] request_DeleteBoardTaskList:_myBoardTL andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"已删除"];
            if (weakSelf.boardTLsChangedBlock) {
                weakSelf.boardTLsChangedBlock();
            }
        }
    }];
}

- (void)addBtnClicked{
    if (!_myBoardTL.curPro.hasEverHandledBoard) {
        _myBoardTL.curPro.hasEverHandledBoard = YES;
        if (_boardTLsChangedBlock) {
            _boardTLsChangedBlock();
        }
    }
    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"创建任务列表" textValue:nil doneBlock:^(NSString *textValue) {
        [NSObject showHUDQueryStr:@"正在添加..."];
        [[Coding_NetAPIManager sharedManager] request_AddBoardTaskListsInPro:self.myBoardTL.curPro withTitle:textValue andBlock:^(EABoardTaskList *data, NSError *error) {
            [NSObject hideHUDQuery];
            if (data) {
                [NSObject showHudTipStr:@"已添加"];
                if (self.boardTLsChangedBlock) {
                    self.boardTLsChangedBlock();
                }
            }
        }];
    }];
    vc.placeholderStr = @"列表名";
    [BaseViewController presentVC:vc];
}

- (void)createDefaultBtnClicked{
    __weak typeof(self) weakSelf = self;
    EABoardTaskListDefaultModel *model = [EABoardTaskListDefaultModel new];
    [NSObject showHUDQueryStr:@"正在添加..."];
    for (NSString *title in model.defaultBoardTLTitleList) {
        [[Coding_NetAPIManager sharedManager] request_AddBoardTaskListsInPro:self.myBoardTL.curPro withTitle:title andBlock:^(EABoardTaskList *data, NSError *error) {
            model.handledCount += 1;
            if (model.handledCount == model.defaultBoardTLTitleList.count) {
                [NSObject hideHUDQuery];
                if (weakSelf.boardTLsChangedBlock) {
                    weakSelf.boardTLsChangedBlock();
                }
            }
        }];
    }
}

@end

