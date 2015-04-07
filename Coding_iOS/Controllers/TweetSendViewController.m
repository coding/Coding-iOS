//
//  TweetSendViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "TweetSendViewController.h"
#import "TweetSendTextCell.h"
#import "TweetSendImagesCell.h"
#import "Coding_NetAPIManager.h"
#import "UsersViewController.h"
#import "Helper.h"
#import "TweetSendLocationCell.h"
#import "TweetSendLocationViewController.h"
#import "TweetSendLocation.h"
#import <TPKeyboardAvoiding/TPKeyboardAvoidingTableView.h>

@interface TweetSendViewController ()
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) Tweet *curTweet;;
@end

@implementation TweetSendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _curTweet = [Tweet tweetForSend];
    _locationData = _curTweet.locationData;

    [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(cancelBtnClicked:)] animated:YES];
    
    UIBarButtonItem *buttonItem = [UIBarButtonItem itemWithBtnTitle:@"发送" target:self action:@selector(sendTweet)];
    [self.navigationItem setRightBarButtonItem:buttonItem animated:YES];
    @weakify(self);
    RAC(self.navigationItem.rightBarButtonItem, enabled) =
    [RACSignal combineLatest:@[RACObserve(self, curTweet.tweetContent),
                               RACObserve(self, curTweet.tweetImages)] reduce:^id (NSString *mdStr){
                                   @strongify(self);
                                   return @(![self isEmptyTweet]);
                               }];
    self.title = [NSString stringWithFormat:@"发冒泡"];
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TweetSendTextCell class] forCellReuseIdentifier:kCellIdentifier_TweetSendText];
        [tableView registerClass:[TweetSendImagesCell class] forCellReuseIdentifier:kCellIdentifier_TweetSendImages];
        [tableView registerClass:[TweetSendLocationCell class] forCellReuseIdentifier:kCellIdentifier_TweetSendLocation];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLocationData:(TweetSendLocationResponse *)locationData
{
    _locationData = locationData;
    _curTweet.locationData = locationData;
    [self.myTableView reloadData];
}

#pragma mark Table M

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 3;
    return row;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        __weak typeof(self) weakSelf = self;
        TweetSendTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetSendText forIndexPath:indexPath];
        cell.tweetContentView.text = _curTweet.tweetContent;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.curTweet.tweetContent = valueStr;
        };
        cell.atSomeoneBlock = ^(UITextView *tweetContentView){
            [tweetContentView resignFirstResponder];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UsersViewController showATSomeoneWithBlock:^(User *curUser) {
                    if (curUser) {
                        NSString *appendingStr = [NSString stringWithFormat:@"@%@ ", curUser.name];
                        weakSelf.curTweet.tweetContent = [weakSelf.curTweet.tweetContent stringByAppendingString:appendingStr];
                    }
                    [tweetContentView becomeFirstResponder];
                    tweetContentView.text = weakSelf.curTweet.tweetContent;
                }];
            });
        };
        return cell;
    }else if(indexPath.row == 1){
        TweetSendImagesCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetSendImages forIndexPath:indexPath];
        cell.curTweet = _curTweet;
        cell.addPicturesBlock = ^(){
            [self.view endEditing:YES];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
            [actionSheet showInView:self.view];
        };
        return cell;
    }else if(indexPath.row == 2){
        __weak typeof (self)weakSelf = self;
        TweetSendLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetSendLocation forIndexPath:indexPath];
        if (self.locationData) {

            [cell setButtonText:self.locationData.displayLocaiton button:cell.locationButton];
            
            [cell.iconImageView setImage:[UIImage imageNamed:@"icon_locationed"]];
        }else {
        
            [cell setButtonText:@"所在位置" button:cell.locationButton];
            
            [cell.iconImageView setImage:[UIImage imageNamed:@"icon_not_locationed"]];
        }
        
        cell.locationClickBlock = ^(){
            TweetSendLocationViewController *vc = [[TweetSendLocationViewController alloc] init];
            vc.responseData = self.locationData;
            UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
            [weakSelf presentViewController:nav animated:YES completion:nil];
        };
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [TweetSendTextCell cellHeight];
    }else if(indexPath.row == 1){
        cellHeight = [TweetSendImagesCell cellHeightWithObj:_curTweet];
    }else if (indexPath.row == 2){
        cellHeight = [TweetSendLocationCell cellHeight];
    }
    return cellHeight;
}


#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //        拍照
        if (![Helper checkCameraAuthorizationStatus]) {
            return;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];//进入照相界面
    }else if (buttonIndex == 1){
        //        相册
        if (![Helper checkPhotoLibraryAuthorizationStatus]) {
            return;
        }
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.maximumNumberOfSelection = 6-_curTweet.tweetImages.count;
        UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
    
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    NSLog(@"%@", info);
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    TweetImage *tweetImg = [TweetImage tweetImageWithImage:[originalImage scaledToSize:kScreen_Bounds.size highQuality:YES]];
    
    NSMutableArray *tweetImages = [self.curTweet mutableArrayValueForKey:@"tweetImages"];
    [tweetImages addObject:tweetImg];
    // 保存原图片到相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, NULL);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    for (ALAsset *assetItem in assets) {
        UIImage *highQualityImage = [UIImage fullResolutionImageFromALAsset:assetItem];
        TweetImage *tweetImg = [TweetImage tweetImageWithImage:[highQualityImage scaledToSize:kScreen_Bounds.size highQuality:YES]];
        NSMutableArray *tweetImages = [self.curTweet mutableArrayValueForKey:@"tweetImages"];
        [tweetImages addObject:tweetImg];
    }
    [_myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Nav Btn M
- (void)cancelBtnClicked:(id)sender{
    if ([self isEmptyTweet] && !_curTweet.locationData) {//有位置
        [self dismissSelf];
    }else{
        __weak typeof(self) weakSelf = self;
        [[UIActionSheet bk_actionSheetCustomWithTitle:@"是否保存草稿" buttonTitles:@[@"保存"] destructiveTitle:@"不保存" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf.curTweet saveSendData];
            }else if (index == 1){
                [Tweet deleteSendData];
            }else{
                return ;
            }
            [weakSelf dismissSelf];
        }] showInView:self.view];
    }
}

- (void)dismissSelf{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.view endEditing:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}

- (BOOL)isEmptyTweet{
    BOOL isEmptyTweet = YES;
    if ((_curTweet.tweetContent && ![_curTweet.tweetContent isEmpty])//内容不为空
        || _curTweet.tweetImages.count > 0)//有照片
    {
        isEmptyTweet = NO;
    }
    return isEmptyTweet;
}

- (void)sendTweet{
    _curTweet.tweetContent = [_curTweet.tweetContent aliasedString];
    if (_sendNextTweet) {
        _sendNextTweet(_curTweet);
    }
    [self dismissSelf];
}

- (void)enableNavItem:(BOOL)isEnable{
    self.navigationItem.leftBarButtonItem.enabled = isEnable;
    self.navigationItem.rightBarButtonItem.enabled = isEnable;
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
