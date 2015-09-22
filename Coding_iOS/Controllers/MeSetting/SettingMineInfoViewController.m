//
//  SettingMineInfoViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-3.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "SettingMineInfoViewController.h"
#import "TitleValueMoreCell.h"
#import "TitleRImageMoreCell.h"
#import "Login.h"
#import "Coding_NetAPIManager.h"
#import "ActionSheetStringPicker.h"
#import "ActionSheetDatePicker.h"
#import "AddressManager.h"
#import "JobManager.h"
#import "TagsManager.h"
#import "SettingTagsViewController.h"
#import "SettingTextViewController.h"
#import "Helper.h"
#import "UserInfoDetailTagCell.h"
#import "JDStatusBarNotification.h"

@interface SettingMineInfoViewController ()
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) User *curUser;
@property (strong, nonatomic) JobManager *curJobManager;
@property (strong, nonatomic) TagsManager *curTagsManager;
@end

@implementation SettingMineInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"个人信息";
    self.curUser =[Login curLoginUser];
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
        [tableView registerClass:[TitleRImageMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleRImageMore];
        [tableView registerClass:[UserInfoDetailTagCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoDetailTagCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _curJobManager = [[JobManager alloc] init];
    _curTagsManager = [[TagsManager alloc] init];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_UserJobArrayWithBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curJobManager.jobDict = data;
        }
    }];
    [[Coding_NetAPIManager sharedManager] request_UserTagArrayWithBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curTagsManager.tagArray = data;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.myTableView = nil;
    self.curUser = nil;
    self.curJobManager = nil;
    self.curTagsManager = nil;
    self.view = nil;
}

#pragma mark TableM

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row;
    switch (section) {
        case 0:
            row = 6;
            break;
        case 1:
            row = 2;
            break;
        default:
            row = 1;
            break;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        TitleRImageMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleRImageMore forIndexPath:indexPath];
        cell.curUser = _curUser;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else if (indexPath.section == 2){
        UserInfoDetailTagCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoDetailTagCell forIndexPath:indexPath];
        [cell setTagStr:_curUser.tags_str];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
        switch (indexPath.section) {
            case 0:{
                switch (indexPath.row) {
                    case 1:
                        [cell setTitleStr:@"昵称" valueStr:_curUser.name];
                        break;
                    case 2:
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
                    case 3:
                        [cell setTitleStr:@"生日" valueStr:_curUser.birthday];
                        break;
                    case 4:
                        [cell setTitleStr:@"所在地" valueStr:_curUser.location];
                        break;
                    default:
                        [cell setTitleStr:@"座右铭" valueStr:_curUser.slogan];
                        break;
                }
            }
                break;
            case 1:{
                if (indexPath.row == 0) {
                    [cell setTitleStr:@"公司" valueStr:_curUser.company];
                }else{
                    [cell setTitleStr:@"职位" valueStr:_curUser.job_str];
                }
            }
                break;
            default:
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellHeight = [TitleRImageMoreCell cellHeight];
    }else if (indexPath.section == 2){
        cellHeight = [UserInfoDetailTagCell cellHeightWithObj:_curUser.tags_str];
    }else{
        cellHeight = [TitleValueMoreCell cellHeight];
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
    __weak typeof(self) weakSelf = self;
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:{//头像
                    if (![JDStatusBarNotification isVisible]) {
                        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
                        [actionSheet showInView:self.view];
                    }
                }
                    break;
                case 1:{//昵称
                    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"昵称" textValue:_curUser.name  doneBlock:^(NSString *textValue) {
                        NSString *preValue = weakSelf.curUser.name;
                        weakSelf.curUser.name = textValue;
                        [weakSelf.myTableView reloadData];
                        [[Coding_NetAPIManager sharedManager] request_UpdateUserInfo_WithObj:weakSelf.curUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                weakSelf.curUser = data;
                            }else{
                                weakSelf.curUser.name = preValue;
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    }];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2:{//性别
                    [ActionSheetStringPicker showPickerWithTitle:nil rows:@[@[@"男", @"女", @"未知"]] initialSelection:@[_curUser.sex] doneBlock:^(ActionSheetStringPicker *picker, NSArray * selectedIndex, NSArray *selectedValue) {
                        NSNumber *preValue = weakSelf.curUser.sex;
                        weakSelf.curUser.sex = [selectedIndex firstObject];
                        [weakSelf.myTableView reloadData];
                        [[Coding_NetAPIManager sharedManager] request_UpdateUserInfo_WithObj:weakSelf.curUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                weakSelf.curUser = data;
                            }else{
                                weakSelf.curUser.sex = preValue;
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    } cancelBlock:nil origin:self.view];
                }
                    break;
                case 3:{//生日
                    NSDate *curDate = [NSDate dateFromString:_curUser.birthday withFormat:@"yyyy-MM-dd"];
                    if (!curDate) {
                        curDate = [NSDate dateFromString:@"1990-01-01" withFormat:@"yyyy-MM-dd"];
                    }
                    ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:nil datePickerMode:UIDatePickerModeDate selectedDate:curDate doneBlock:^(ActionSheetDatePicker *picker, NSDate *selectedDate, id origin) {
                        NSString *preValue = weakSelf.curUser.birthday;
                        weakSelf.curUser.birthday = [selectedDate string_yyyy_MM_dd];
                        [weakSelf.myTableView reloadData];
                        [[Coding_NetAPIManager sharedManager] request_UpdateUserInfo_WithObj:weakSelf.curUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                weakSelf.curUser = data;
                            }else{
                                weakSelf.curUser.birthday = preValue;
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    } cancelBlock:^(ActionSheetDatePicker *picker) {
                        DebugLog(@"%@", picker.description);
                    } origin:self.view];
                    picker.minimumDate = [[NSDate date] offsetYear:-120];
                    picker.maximumDate = [NSDate date];
                    [picker showActionSheetPicker];
                }
                    break;
                case 4:{//所在地
                    NSNumber *firstLevel = nil, *secondLevel = nil;
                    if (_curUser.location && _curUser.location.length > 0) {
                        NSArray *locationArray = [_curUser.location componentsSeparatedByString:@" "];
                        if (locationArray.count == 2) {
                            firstLevel = [AddressManager indexOfFirst:[locationArray firstObject]];
                            secondLevel = [AddressManager indexOfSecond:[locationArray lastObject] inFirst:[locationArray firstObject]];
                        }
                    }
                    if (!firstLevel) {
                        firstLevel = [NSNumber numberWithInteger:0];
                    }
                    if (!secondLevel) {
                        secondLevel = [NSNumber numberWithInteger:0];
                    }
                    
                    [ActionSheetStringPicker showPickerWithTitle:nil rows:@[[AddressManager firstLevelArray], [AddressManager secondLevelMap]] initialSelection:@[firstLevel, secondLevel] doneBlock:^(ActionSheetStringPicker *picker, NSArray * selectedIndex, NSArray *selectedValue) {
                        NSString *preValue = weakSelf.curUser.location;
                        NSString *location = [selectedValue componentsJoinedByString:@" "];
                        weakSelf.curUser.location = location;
                        [weakSelf.myTableView reloadData];
                        [[Coding_NetAPIManager sharedManager] request_UpdateUserInfo_WithObj:weakSelf.curUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                weakSelf.curUser = data;
                            }else{
                                weakSelf.curUser.location = preValue;
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    } cancelBlock:nil origin:self.view];
                }
                    break;
                default:{//座右铭
                    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"座右铭" textValue:_curUser.slogan  doneBlock:^(NSString *textValue) {
                        NSString *preValue = weakSelf.curUser.slogan;
                        weakSelf.curUser.slogan = textValue;
                        [weakSelf.myTableView reloadData];
                        [[Coding_NetAPIManager sharedManager] request_UpdateUserInfo_WithObj:weakSelf.curUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                weakSelf.curUser = data;
                            }else{
                                weakSelf.curUser.slogan = preValue;
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    }];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
            }
        }
            break;
        case 1:{
            switch (indexPath.row) {
                case 0:{//公司
                    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"公司" textValue:_curUser.company  doneBlock:^(NSString *textValue) {
                        NSString *preValue = weakSelf.curUser.company;
                        weakSelf.curUser.company = textValue;
                        [weakSelf.myTableView reloadData];
                        [[Coding_NetAPIManager sharedManager] request_UpdateUserInfo_WithObj:weakSelf.curUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                weakSelf.curUser = data;
                            }else{
                                weakSelf.curUser.company = preValue;
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    }];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:{//职位
                    NSArray *jobNameArray = _curJobManager.jobNameArray;
                    NSNumber *index = [_curJobManager indexOfJobName:_curUser.job_str];
                    [ActionSheetStringPicker showPickerWithTitle:nil rows:@[jobNameArray] initialSelection:@[index] doneBlock:^(ActionSheetStringPicker *picker, NSArray *selectedIndex, NSArray *selectedValue) {
                        NSString *preValue = weakSelf.curUser.job_str;
                        NSString *preValueKey = weakSelf.curUser.job;

                        NSNumber *jobIndex = selectedIndex.firstObject;
                        NSString *job = [NSString stringWithFormat:@"%d", jobIndex.intValue +1];
                        NSString *job_str = selectedValue.firstObject;
                        _curUser.job = job;
                        _curUser.job_str = job_str;
                        [weakSelf.myTableView reloadData];
                        [[Coding_NetAPIManager sharedManager] request_UpdateUserInfo_WithObj:weakSelf.curUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                weakSelf.curUser = data;
                            }else{
                                weakSelf.curUser.job_str = preValue;
                                weakSelf.curUser.job = preValueKey;
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    } cancelBlock:nil origin:self.view];
                }
                    break;
            }
        }
            break;
        default:{//个性标签
            NSArray *selectedTags = nil;
            if (_curUser.tags && _curUser.tags.length > 0) {
                selectedTags = [_curUser.tags componentsSeparatedByString:@","];
            }
            SettingTagsViewController *vc = [SettingTagsViewController settingTagsVCWithAllTags:_curTagsManager.tagArray selectedTags:selectedTags doneBlock:^(NSArray *selectedTags) {
                NSString *preValue = weakSelf.curUser.tags_str;
                NSString *preValueKey = weakSelf.curUser.tags;
                
                NSString *tags = @"", *tags_str = @"";
                if (selectedTags.count > 0) {
                    tags = [selectedTags componentsJoinedByString:@","];
                    tags_str = [weakSelf.curTagsManager getTags_strWithTags:selectedTags];
                }

                weakSelf.curUser.tags = tags;
                weakSelf.curUser.tags_str = tags_str;
                [weakSelf.myTableView reloadData];
                [[Coding_NetAPIManager sharedManager] request_UpdateUserInfo_WithObj:weakSelf.curUser andBlock:^(id data, NSError *error) {
                    if (data) {
                        weakSelf.curUser = data;
                    }else{
                        weakSelf.curUser.tags_str = preValue;
                        weakSelf.curUser.tags = preValueKey;
                    }
                    [weakSelf.myTableView reloadData];
                }];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
}

#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
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
        
        [[Coding_NetAPIManager sharedManager] request_UpdateUserIconImage:editedImage successBlock:^(id responseObj) {
            weakSelf.curUser.avatar = responseObj;
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

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
