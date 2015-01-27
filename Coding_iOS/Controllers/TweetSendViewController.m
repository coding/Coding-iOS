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


#define kCellIdentifier_TweetSendText @"TweetSendTextCell"
#define kCellIdentifier_TweetSendImages @"TweetSendImagesCell"

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
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TweetSendTextCell class] forCellReuseIdentifier:kCellIdentifier_TweetSendText];
        [tableView registerClass:[TweetSendImagesCell class] forCellReuseIdentifier:kCellIdentifier_TweetSendImages];
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

#pragma mark Table M

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 2;
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
    }else{
        TweetSendImagesCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetSendImages forIndexPath:indexPath];
        cell.curTweet = _curTweet;
        cell.addPicturesBlock = ^(){
            [self.view endEditing:YES];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
            [actionSheet showInView:kKeyWindow];
        };
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [TweetSendTextCell cellHeight];
    }else{
        cellHeight = [TweetSendImagesCell cellHeightWithObj:_curTweet];
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
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
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
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(originalImage, self,selectorToCall, NULL);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
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
    if ([self isEmptyTweet]) {
        [self dismissSelf];
    }else{
        __weak typeof(self) weakSelf = self;
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示" message:@"确定放弃此次冒泡？"];
        [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertView bk_addButtonWithTitle:@"确定" handler:nil];
        [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
            switch (index) {
                case 1:
                    [weakSelf dismissSelf];
                    break;
                default:
                    break;
            }
        }];
        [alertView show];
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
        || (_curTweet.tweetImages.count > 0))//有照片
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
