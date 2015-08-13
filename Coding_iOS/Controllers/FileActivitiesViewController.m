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

#import "UIView+PressMenu.h"

#import "AddMDCommentViewController.h"


@interface FileActivitiesViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate, EaseToolBarDelegate>
@property (strong, nonatomic) ProjectFile *curFile;
@property (strong, nonatomic) Project *curProject;
@property (strong, nonatomic) NSMutableArray *activityList;

@property (strong, nonatomic) UITableView *myTableView;
@property (nonatomic, strong) EaseToolBar *myToolBar;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@property (assign, nonatomic) BOOL isLoading;
@end

@implementation FileActivitiesViewController
+ (instancetype)vcWithFile:(ProjectFile *)file{
    FileActivitiesViewController *vc = [self new];
    vc.curFile = file;
    return vc;
}

- (void)setCurFile:(ProjectFile *)curFile{
    _curFile = curFile;
    if (!_curProject) {
        NSString *project_id_str = [[[[_curFile.owner_preview componentsSeparatedByString:@"project/"] lastObject] componentsSeparatedByString:@"/"] firstObject];
        if (project_id_str.length > 0 && [project_id_str isPureInt]) {
            _curProject = [Project new];
            _curProject.id = [NSNumber numberWithInteger:project_id_str.integerValue];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _curFile.name;
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableBG;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[FileCommentCell class] forCellReuseIdentifier:kCellIdentifier_FileCommentCell];
        [tableView registerClass:[FileCommentCell class] forCellReuseIdentifier:kCellIdentifier_FileCommentCell_Media];
        [tableView registerClass:[FileActivityCell class] forCellReuseIdentifier:kCellIdentifier_FileActivityCell];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    _myToolBar = ({
        EaseToolBarItem *item = [EaseToolBarItem easeToolBarItemWithTitle:@" 发表评论..." image:@"button_file_comment" disableImage:nil];
        
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15],
                                     NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0xB5B5B5"]};
        [item setAttributes:attributes forUIControlState:UIControlStateNormal];
        
        EaseToolBar *toolBar = [EaseToolBar easeToolBarWithItems:@[item]];
        toolBar.delegate = self;
        [self.view addSubview:toolBar];
        [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
            make.size.mas_equalTo(toolBar.frame.size);
        }];
        toolBar;
    });
    
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(self.myToolBar.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _activityList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    ProjectActivity *curActivity = [self.activityList objectAtIndex:indexPath.row];
    if ([curActivity.target_type isEqualToString:@"ProjectFileComment"]) {
        cellHeight = [FileCommentCell cellHeightWithObj:curActivity.projectFileComment];
    }else{
        cellHeight = [FileActivityCell cellHeightWithObj:curActivity];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
            [weakSelf goToAddCommentVCToUser:curActivity.projectFileComment.owner.name];
        }
    }];
}


#pragma mark Comment
- (void)goToAddCommentVCToUser:(NSString *)userName{
    DebugLog(@"%@", userName);
    AddMDCommentViewController *vc = [AddMDCommentViewController new];
    
//    vc.curProject = _curProject;
//    vc.requestPath = [NSString stringWithFormat:@"api/user/%@/project/%@/git/line_notes", _curMRPR.des_owner_name, _curMRPR.des_project_name];
//    vc.requestParams = [@{
//                          @"noteable_type" : [self.curMRPRInfo.mrpr isMR]? @"MergeRequestBean" : @"PullRequestBean",
//                          @"noteable_id" : _curMRPRInfo.mrpr.id,
//                          } mutableCopy];
//    vc.contentStr = userName.length > 0? [NSString stringWithFormat:@"@%@ ", userName]: nil;
//    @weakify(self);
//    vc.completeBlock = ^(id data){
//        @strongify(self);
//        if (data && [data isKindOfClass:[ProjectLineNote class]]) {
//            [self.curMRPRInfo.discussions addObject:@[data]];
//            [self.myTableView reloadData];
//        }
//    };
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)deleteCommentOfActivity:(ProjectActivity *)lineNote{
//    __weak typeof(self) weakSelf = self;
//    [[Coding_NetAPIManager sharedManager] request_DeleteLineNote:lineNote.id inProject:_curMRPRInfo.mrpr.des_project_name ofUser:_curMRPRInfo.mrpr.des_owner_name andBlock:^(id data, NSError *error) {
//        if (data) {
//            [weakSelf.curMRPRInfo.discussions removeObject:@[lineNote]];
//            [weakSelf.myTableView reloadData];
//        }
//    }];
}


#pragma mark EaseToolBarDelegate
- (void)easeToolBar:(EaseToolBar *)toolBar didClickedIndex:(NSInteger)index{
    //去添加评论
    
}

@end
