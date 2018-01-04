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
#import "TweetSendLocationViewController.h"
#import "TweetSendLocation.h"
#import <TPKeyboardAvoiding/TPKeyboardAvoidingTableView.h>

@interface TweetSendViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBImagePickerControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation TweetSendViewController

+ (instancetype)presentWithParams:(NSDictionary *)params{
    NSString *callback, *content;
    BOOL has_image_in_pasteboard;
    UIImage *image;

    callback = params[@"callback"];
    content = [params[@"content"] URLDecoding];
    has_image_in_pasteboard = [params[@"has_image_in_pasteboard"] boolValue];
    if (has_image_in_pasteboard) {
        image = [UIPasteboard generalPasteboard].image;
    }
    
    Tweet *curTweet = [Tweet new];
    curTweet.callback = callback;
    curTweet.tweetContent = content;
    if (image) {
        curTweet.tweetImages = @[[TweetImage tweetImageWithAssetLocalIdentifier:nil andImage:image]].mutableCopy;
    }
    TweetSendViewController *vc = [TweetSendViewController new];
    vc.curTweet = curTweet;
    [BaseViewController presentVC:vc];
    return vc;
}

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
    if (!_curTweet) {
        _curTweet = [Tweet tweetForSend];
        _locationData = _curTweet.locationData;
    }

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
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TweetSendTextCell class] forCellReuseIdentifier:kCellIdentifier_TweetSendText];
        [tableView registerClass:[TweetSendImagesCell class] forCellReuseIdentifier:kCellIdentifier_TweetSendImages];
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self inputViewBecomeFirstResponder];
}

- (BOOL)inputViewBecomeFirstResponder{
    TweetSendTextCell *cell = (TweetSendTextCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell respondsToSelector:@selector(becomeFirstResponder)]) {
        [cell becomeFirstResponder];
    }
    return YES;
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
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        TweetSendTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetSendText forIndexPath:indexPath];
        cell.tweetContentView.text = _curTweet.tweetContent;
        [cell setLocationStr:self.locationData.displayLocaiton];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.curTweet.tweetContent = valueStr;
        };
        cell.photoBtnBlock = ^(){
            [weakSelf showActionForPhoto];
        };
        cell.locationBtnBlock = ^(){
            TweetSendLocationViewController *vc = [[TweetSendLocationViewController alloc] init];
            vc.responseData = self.locationData;
            UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
            [weakSelf presentViewController:nav animated:YES completion:nil];
        };
        return cell;
    }else {
        TweetSendImagesCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetSendImages forIndexPath:indexPath];
        cell.curTweet = _curTweet;
        cell.addPicturesBlock = ^(){
            [self showActionForPhoto];
        };
        cell.deleteTweetImageBlock = ^(TweetImage *toDelete){
            [weakSelf.curTweet deleteTweetImage:toDelete];
            [weakSelf.myTableView reloadData];
        };
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [TweetSendTextCell cellHeight];
    }else if(indexPath.row == 1){
        cellHeight = [TweetSendImagesCell cellHeightWithObj:_curTweet];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UIActionSheet M

- (void)showActionForPhoto{
    @weakify(self);
    [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"拍照", @"从相册选择"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        @strongify(self);
        [self photoActionSheet:sheet DismissWithButtonIndex:index];
    }] showInView:self.view];
}

- (void)photoActionSheet:(UIActionSheet *)sheet DismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //        拍照
        if (![Helper checkCameraAuthorizationStatus]) {
            return;
        }else if (_curTweet.tweetImages.count >= 6) {
            kTipAlert(@"最多只可选择6张照片，已经选满了。先去掉一张照片再拍照呗～");
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
        [imagePickerController.selectedAssets removeAllObjects];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:self.curTweet.selectedAssetLocalIdentifiers options:nil];
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [imagePickerController.selectedAssets addObject:obj];
        }];
        imagePickerController.mediaType = QBImagePickerMediaTypeImage;
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.maximumNumberOfSelection = 9;
        [self presentViewController:imagePickerController animated:YES completion:NULL];

    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *pickerImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    __block NSString *localId;
    [photoLibrary performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:pickerImage];
        localId = assetChangeRequest.placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [self.curTweet addSelectedAssetLocalIdentifier:localId];
            [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets{
    NSMutableArray *selectedAssetLocalIdentifiers = [NSMutableArray new];
    [imagePickerController.selectedAssets enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL *stop) {
        [selectedAssetLocalIdentifiers addObject:obj.localIdentifier];
    }];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.curTweet.selectedAssetLocalIdentifiers = selectedAssetLocalIdentifiers;
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        });
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Nav Btn M
- (void)cancelBtnClicked:(id)sender{
    if (_curTweet.callback) {
        [self handleCallBack:_curTweet.callback status:NO];
    }else if ([self isEmptyTweet] && !_curTweet.locationData) {//有位置
        [Tweet deleteSendData];
        [self dismissSelfWithCompletion:nil];
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
            [weakSelf dismissSelfWithCompletion:nil];
        }] showInView:self.view];
    }
}

- (void)dismissSelfWithCompletion:(void (^)(void))completion{
    [self.view endEditing:YES];
    TweetSendTextCell *cell = (TweetSendTextCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell.footerToolBar) {
        [cell.footerToolBar removeFromSuperview];
    }
    [self dismissViewControllerAnimated:YES completion:completion];
}

- (void)handleCallBack:(NSString *)callback status:(BOOL)handleStatus{
    NSString *schemeStr = [NSString stringWithFormat:@"%@://coding.net?type=%@&handle_result=%@", callback, @"handle_result", handleStatus? @(1): @(0)];
    if (handleStatus) {//弹出提示给用户选择
        UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"已发送" message:@"是否需要返回原来应用？"];
        [alertV bk_setCancelButtonWithTitle:@"返回原应用" handler:nil];
        [alertV bk_addButtonWithTitle:@"留在 Coding" handler:nil];
        alertV.bk_didDismissBlock = ^(UIAlertView *alertView, NSInteger buttonIndex){
            if (buttonIndex == 0) {//
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:schemeStr]];
            }
        };
        [alertV show];
    }else{//直接返回
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:schemeStr]];
        [self dismissSelfWithCompletion:nil];
    }
}

- (BOOL)isEmptyTweet{
    BOOL isEmptyTweet = YES;
    if ((_curTweet.tweetContent && ![_curTweet.tweetContent isEmptyOrListening])//内容不为空
        || _curTweet.tweetImages.count > 0)//有照片
    {
        isEmptyTweet = NO;
    }
    return isEmptyTweet;
}

- (void)sendTweet{
    for (TweetImage *tImg in _curTweet.tweetImages) {
        if (tImg.downloadState == TweetImageDownloadStateIng) {
            [NSObject showHudTipStr:@"iCloud 图片尚未下载完毕"];
            return;
        }
    }
    _curTweet.tweetContent = [_curTweet.tweetContent aliasedString];
    if (_sendNextTweet) {
        _sendNextTweet(_curTweet);
    }else{
        [self sendTweetToServer];//自己处理发送请求
    }
    
    __weak typeof(self) weakSelf = self;
    [self dismissSelfWithCompletion:^{
        if (weakSelf.curTweet.callback) {
            [weakSelf handleCallBack:weakSelf.curTweet.callback status:YES];
        }
    }];
}

- (void)sendTweetToServer{
    [[Coding_NetAPIManager sharedManager] request_Tweet_DoTweet_WithObj:_curTweet andBlock:^(id data, NSError *error) {
        //自己处理发送请求，不做后续操作
    }];
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

#pragma mark 
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.myTableView) {
        [self.view endEditing:YES];
    }
}

@end
