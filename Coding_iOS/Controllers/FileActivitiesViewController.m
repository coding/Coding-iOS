//
//  FileActivitiesViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/8/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileActivitiesViewController.h"

#import "Coding_NetAPIManager.h"

#import "EaseToolBar.h"
#import "ODRefreshControl.h"
#import "FileCommentCell.h"
#import "FileActivityCell.h"
#import "AddCommentCell.h"

#import "UIView+PressMenu.h"

#import "AddMDCommentViewController.h"


@interface FileActivitiesViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate, EaseToolBarDelegate>
@property (strong, nonatomic) ProjectFile *curFile;
@property (strong, nonatomic) NSMutableArray *activityList;

@property (strong, nonatomic) UITableView *myTableView;
//@property (nonatomic, strong) EaseToolBar *myToolBar;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@property (assign, nonatomic) BOOL isLoading;
@end

@implementation FileActivitiesViewController
+ (instancetype)vcWithFile:(ProjectFile *)file{
    FileActivitiesViewController *vc = [self new];
    vc.curFile = file;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _curFile.name;
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[FileCommentCell class] forCellReuseIdentifier:kCellIdentifier_FileCommentCell];
        [tableView registerClass:[FileCommentCell class] forCellReuseIdentifier:kCellIdentifier_FileCommentCell_Media];
        [tableView registerClass:[FileActivityCell class] forCellReuseIdentifier:kCellIdentifier_FileActivityCell];
        [tableView registerClass:[AddCommentCell class] forCellReuseIdentifier:kCellIdentifier_AddCommentCell];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
//    _myToolBar = ({
//        EaseToolBarItem *item = [EaseToolBarItem easeToolBarItemWithTitle:@" 发表评论..." image:@"button_file_comment" disableImage:nil];
//        
//        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15],
//                                     NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0xB5B5B5"]};
//        [item setAttributes:attributes forUIControlState:UIControlStateNormal];
//        
//        EaseToolBar *toolBar = [EaseToolBar easeToolBarWithItems:@[item]];
//        toolBar.delegate = self;
//        [self.view addSubview:toolBar];
//        [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo(self.view.mas_bottom);
//            make.size.mas_equalTo(toolBar.frame.size);
//        }];
//        toolBar;
//    });    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(self.myToolBar.frame), 0.0);
//    self.myTableView.contentInset = contentInsets;
//    self.myTableView.scrollIndicatorInsets = contentInsets;
    
    [self refresh];
}

- (void)refresh{
    if (self.isLoading) {
        return;
    }
    [self sendRequest];
}

- (void)sendRequest{
    self.isLoading = YES;
    if (self.activityList.count <= 0) {
        [self.view beginLoading];
    }
    @weakify(self);
    [[Coding_NetAPIManager sharedManager] request_ActivityListOfFile:_curFile andBlock:^(id data, NSError *error) {
        @strongify(self);
        self.isLoading = NO;
        [self.myRefreshControl endRefreshing];
        [self.view endLoading];
        if (data) {
            self.activityList = data;
            [self.myTableView reloadData];
        }
        [self.view configBlankPage:EaseBlankPageTypeView hasData:self.activityList.count > 0 hasError:error != nil reloadButtonBlock:^(id sender) {
            [self refresh];
        }];
    }];
}

#pragma mark Table M

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = kColorTableSectionBg;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0? _activityList.count: 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ProjectActivity *curActivity = [self.activityList objectAtIndex:indexPath.row];
        if ([curActivity.target_type isEqualToString:@"ProjectFileComment"]) {
            FileComment *curComment = curActivity.projectFileComment;
            curComment.created_at = curActivity.created_at;
            FileCommentCell *cell;
            if (curComment.htmlMedia.imageItems.count > 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileCommentCell_Media forIndexPath:indexPath];
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileCommentCell forIndexPath:indexPath];
            }
            cell.curComment = (TaskComment *)curComment;
            cell.contentLabel.delegate = self;
            cell.backgroundColor = kColorTableBG;
            [cell configTop:(indexPath.row == 0) andBottom:(indexPath.row == _activityList.count - 1)];
            return cell;
        }else{
            FileActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FileActivityCell forIndexPath:indexPath];
            cell.curActivity = curActivity;
            cell.backgroundColor = kColorTableBG;
            [cell configTop:(indexPath.row == 0) andBottom:(indexPath.row == _activityList.count - 1)];
            return cell;
        }
    }else{
        AddCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AddCommentCell forIndexPath:indexPath];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        ProjectActivity *curActivity = [self.activityList objectAtIndex:indexPath.row];
        if ([curActivity.target_type isEqualToString:@"ProjectFileComment"]) {
            cellHeight = [FileCommentCell cellHeightWithObj:curActivity.projectFileComment];
        }else{
            cellHeight = [FileActivityCell cellHeightWithObj:curActivity];
        }
    }else{
        cellHeight = [AddCommentCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        ProjectActivity *curActivity = [self.activityList objectAtIndex:indexPath.row];
        if (![curActivity.target_type isEqualToString:@"ProjectFileComment"]) {
            return;
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell.contentView isMenuVCVisible]) {
            [cell.contentView removePressMenu];
            return;
        }
        NSArray *menuTitles;
        if ([curActivity.projectFileComment.owner.global_key isEqualToString:[Login curLoginUser].global_key]) {
            menuTitles = @[@"拷贝文字", @"删除"];
        }else{
            menuTitles = @[@"拷贝文字", @"回复"];
        }
        __weak typeof(self) weakSelf = self;
        [cell.contentView showMenuTitles:menuTitles menuClickedBlock:^(NSInteger index, NSString *title) {
            if ([title hasPrefix:@"拷贝"]) {
                [[UIPasteboard generalPasteboard] setString:curActivity.projectFileComment.content];
            }else if ([title isEqualToString:@"删除"]){
                [weakSelf deleteCommentOfActivity:curActivity];
            }else if ([title isEqualToString:@"回复"]){
                [weakSelf goToAddCommentVCToActivity:curActivity];
            }
        }];
    }else{
        [self goToAddCommentVCToActivity:nil];
    }
}

#pragma mark Comment
- (void)goToAddCommentVCToActivity:(ProjectActivity *)curActivity{
    Project *curProject;
    if (curActivity.project) {
        curProject = curActivity.project;
    }
    if (!curProject && _activityList.count > 0) {
        curProject = [(ProjectActivity *)[_activityList firstObject] project];
    }
    if (!curProject) {
        curProject = [Project new];
    }
    curProject.id = _curFile.project_id;
    
    AddMDCommentViewController *vc = [AddMDCommentViewController new];

    vc.curProject = curProject;
    
    vc.requestPath = [NSString stringWithFormat:@"api/project/%@/files/%@/comment", _curFile.project_id.stringValue, _curFile.file_id.stringValue];
    vc.requestParams = [@{} mutableCopy];
    vc.contentStr = curActivity? [NSString stringWithFormat:@"@%@ ", curActivity.user.name]: nil;
    
    @weakify(self);
    vc.completeBlock = ^(id data){
        @strongify(self);
        if (data) {
            [self refresh];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)deleteCommentOfActivity:(ProjectActivity *)curActivity{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeleteComment:curActivity.projectFileComment.id inFile:_curFile andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.activityList removeObject:curActivity];
            [weakSelf.myTableView reloadData];
        }
    }];
}

#pragma mark EaseToolBarDelegate
- (void)easeToolBar:(EaseToolBar *)toolBar didClickedIndex:(NSInteger)index{
    //去添加评论
    [self goToAddCommentVCToActivity:nil];
}

@end
