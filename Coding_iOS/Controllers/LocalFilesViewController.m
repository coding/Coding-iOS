//
//  LocalFilesViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/9/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "LocalFilesViewController.h"
#import "LocalFileCell.h"
#import "LocalFileViewController.h"

@interface LocalFilesViewController ()<UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>
@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation LocalFilesViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = self.projectName;
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[LocalFileCell class] forCellReuseIdentifier:kCellIdentifier_LocalFileCell];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = [UIColor colorWithHexString:@"0x666666"];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

#pragma mark T
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LocalFileCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_LocalFileCell forIndexPath:indexPath];
    cell.fileUrl = _fileList[indexPath.row];
    cell.delegate = self;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [LocalFileCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LocalFileViewController *vc = [LocalFileViewController new];
    vc.projectName = self.projectName;
    vc.fileUrl = self.fileList[indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    NSURL *fileUrl = self.fileList[indexPath.row];
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定要删除本地文件吗？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [weakSelf deleteFilesWithUrlList:@[fileUrl]];
        }
    }];
    [actionSheet showInView:self.view];
}

#pragma mark Delete
- (void)deleteFilesWithUrlList:(NSArray *)urlList{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        for (NSURL *fileUrl in urlList) {
            NSString *filePath = fileUrl.path;
            if ([fm fileExistsAtPath:filePath]) {
                NSError *fileError;
                [fm removeItemAtPath:filePath error:&fileError];
                if (fileError) {
                    [NSObject showError:fileError];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.fileList removeObjectsInArray:urlList];
            [self.myTableView reloadData];
            [NSObject showHudTipStr:@"本地文件删除成功"];
        });
    });
}
@end
