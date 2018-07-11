//
//  TeamSettingViewController.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/2/17.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "TeamSettingViewController.h"
#import "SettingTextViewController.h"
#import "TitleValueMoreCell.h"
#import "TitleRImageMoreCell.h"
#import "JDStatusBarNotification.h"
#import "Helper.h"
#import "Coding_NetAPIManager.h"

@interface TeamSettingViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation TeamSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"企业设置";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.tableFooterView = [UIView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
        [tableView registerClass:[TitleRImageMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleRImageMore];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

#pragma mark Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0? 1: 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TitleRImageMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleRImageMore forIndexPath:indexPath];
        cell.curTeam = _curTeam;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
        (indexPath.row == 0? [cell setTitleStr:@"企业名称" valueStr:_curTeam.name]:
         [cell setTitleStr:@"企业域名" valueStr:[NSURL URLWithString:[NSObject baseURLStr]].host]);
        cell.accessoryType = indexPath.row == 0? UITableViewCellAccessoryDisclosureIndicator: UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0? [TitleRImageMoreCell cellHeight]: [TitleValueMoreCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        //头像
        if (![JDStatusBarNotification isVisible]) {
            __weak typeof(self) weakSelf = self;
            [[UIAlertController ea_actionSheetCustomWithTitle:@"更换头像" buttonTitles:@[@"拍照", @"从相册选择"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIAlertAction *action, NSInteger index) {
                [weakSelf actionSheetDidDismissWithButtonIndex:index];
            }] showInView:self.view];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            //企业名称
            __weak typeof(self) weakSelf = self;
            SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"企业名称" textValue:_curTeam.name  doneBlock:^(NSString *textValue) {
                NSString *preValue = weakSelf.curTeam.name;
                weakSelf.curTeam.name = textValue;
                [weakSelf.myTableView reloadData];
                [[Coding_NetAPIManager sharedManager] request_UpdateTeamInfo_WithObj:weakSelf.curTeam andBlock:^(id data, NSError *error) {
                    if (data) {
                        weakSelf.curTeam = data;
                    }else{
                        weakSelf.curTeam.name = preValue;
                    }
                    [weakSelf.myTableView reloadData];
                }];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark UIActionSheetDelegate M
- (void)actionSheetDidDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    
    if (buttonIndex == 0) {
        //        拍照
        if (![Helper checkCameraAuthorizationStatus]) {
            return;
        }
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else if (buttonIndex == 1){
        //        相册
        if (![Helper checkPhotoLibraryAuthorizationStatus]) {
            return;
        }
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentViewController:picker animated:YES completion:nil];//进入照相界面
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *editedImage, *originalImage;
        editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        __weak typeof(self) weakSelf = self;
        
        [[Coding_NetAPIManager sharedManager] request_UpdateTeamIconImage:editedImage successBlock:^(id responseObj) {
            weakSelf.curTeam.avatar = [(Team *)responseObj avatar];
            [weakSelf.myTableView reloadData];
        } failureBlock:^(NSError *error) {
            [NSObject showError:error];
        } progerssBlock:^(CGFloat progressValue) {
        }];
        
        // 保存原图片到相册中
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, NULL);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
