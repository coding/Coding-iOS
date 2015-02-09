//
//  ConversationViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_Message @"MessageCell"
#define kCellIdentifier_MessageMedia @"MessageMediaCell"

#import "ConversationViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "MessageCell.h"
#import "UserInfoViewController.h"
#import "QBImagePickerController.h"
#import "UsersViewController.h"
#import "Helper.h"

@interface ConversationViewController ()
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@property (nonatomic, assign) CGFloat preContentHeight;
@property (nonatomic, strong) PrivateMessage *messageToResendOrDelete;
@end

@implementation ConversationViewController

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
    self.title = _myPriMsgs.curFriend.name;
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[MessageCell class] forCellReuseIdentifier:kCellIdentifier_Message];
        [tableView registerClass:[MessageCell class] forCellReuseIdentifier:kCellIdentifier_MessageMedia];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
//    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
//    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewTypeMedia placeHolder:@"请输入私信内容"];
    _myMsgInputView.contentType = UIMessageInputViewContentTypePriMsg;
    _myMsgInputView.isAlwaysShow = YES;
    _myMsgInputView.delegate = self;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myMsgInputView.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
    
    if (self.myPriMsgs.curFriend.id) {
        _myMsgInputView.toUser = self.myPriMsgs.curFriend;
    }else{
        [self refreshUserInfo];
    }
    [self refreshLoadMore:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_myMsgInputView) {
        [_myMsgInputView prepareToDismiss];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    键盘
    if (_myMsgInputView) {
        [_myMsgInputView prepareToShow];
    }
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshUserInfo{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_UserInfo_WithObj:self.myPriMsgs.curFriend andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.myPriMsgs.curFriend = data;
            weakSelf.myMsgInputView.toUser = weakSelf.myPriMsgs.curFriend;
            weakSelf.title = weakSelf.myPriMsgs.curFriend.name;
        }
    }];
}

#pragma mark UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text{
    [self sendPrivateMessage:text];
}

- (void)messageInputView:(UIMessageInputView *)inputView sendBigEmotion:(NSString *)emotionName{
    [self sendPrivateMessage:emotionName];
}

- (void)messageInputView:(UIMessageInputView *)inputView addIndexClicked:(NSInteger)index{
    [self inputViewAddIndex:index];
}

- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom{
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        UIEdgeInsets contentInsets= UIEdgeInsetsMake(0.0, 0.0, heightToBottom, 0.0);;
        self.myTableView.contentInset = contentInsets;
        self.myTableView.scrollIndicatorInsets = contentInsets;
        if (heightToBottom > 60) {
            [self scrollToBottomAnimated:NO];
        }
    } completion:nil];
}

#pragma mark refresh
- (void)refreshLoadMore:(BOOL)willLoadMore{
    
    if (_myPriMsgs.isLoading) {
        return;
    }
    _myPriMsgs.willLoadMore = willLoadMore;
    if (!_myPriMsgs.canLoadMore) {
        [_refreshControl endRefreshing];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [_refreshControl beginRefreshing];
    [[Coding_NetAPIManager sharedManager] request_PrivateMessages:_myPriMsgs andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        if (data) {
            [weakSelf.myPriMsgs configWithObj:data];
            [weakSelf.myTableView reloadData];
            if (!weakSelf.myPriMsgs.willLoadMore) {
                [weakSelf scrollToBottomAnimated:NO];
            }else{
                CGFloat curContentHeight = weakSelf.myTableView.contentSize.height;
                [weakSelf.myTableView setContentOffset:CGPointMake(0, (curContentHeight -_preContentHeight)+weakSelf.myTableView.contentOffset.y)];
            }
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypePrivateMsg hasData:(weakSelf.myPriMsgs.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refreshLoadMore:NO];
        }];
    }];
}




#pragma mark Table M

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_myPriMsgs.list) {
        row = [_myPriMsgs.list count];
    }
    return row;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *cell;
    NSUInteger curIndex = ([_myPriMsgs.list count] -1) - indexPath.row;
    PrivateMessage *curMsg = [_myPriMsgs.list objectAtIndex:curIndex];
    if (curMsg.hasMedia) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MessageMedia forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Message forIndexPath:indexPath];
    }
    PrivateMessage *preMsg = nil;
    if (curIndex +1 < _myPriMsgs.list.count) {
        preMsg = [_myPriMsgs.list objectAtIndex:curIndex+1];
    }
    [cell setCurPriMsg:curMsg andPrePriMsg:preMsg];
    cell.tapUserIconBlock = ^(User *sender){
        UserInfoViewController *vc = [[UserInfoViewController alloc] init];
        vc.curUser = sender;
        [self.navigationController pushViewController:vc animated:YES];
    };
    ESWeakSelf;
    cell.resendMessageBlock = ^(PrivateMessage *curMessage){
        ESStrongSelf;
        _self.messageToResendOrDelete = curMessage;
        [_self.myMsgInputView isAndResignFirstResponder];
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"重新发送" buttonTitles:@[@"发送"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0 && _self.messageToResendOrDelete) {
                [_self sendPrivateMessageWithMsg:_messageToResendOrDelete];

            }
        }];
        [actionSheet showInView:kKeyWindow];
    };
    cell.refreshMessageMediaCCellBlock = ^(CGFloat diff){
//        ESStrongSelf;
//        static int count = 0;
//        NSLog(@"\ncount : ----------------%d", count++);
//        [_self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        [_self.myTableView setContentOffset:CGPointMake(0, diff+_self.myTableView.contentOffset.y)];
    };
    NSMutableArray *menuItemArray = [[NSMutableArray alloc] init];
    BOOL hasTaxtToCopy = (curMsg.content && ![curMsg.content isEmpty]);
    BOOL canDelete = (curMsg.sendStatus != PrivateMessageStatusSending);
    if (curMsg.hasMedia) {//有图片
        if (hasTaxtToCopy) {
            [menuItemArray addObject:@"拷贝文字"];
        }
    }else{
        [menuItemArray addObject:@"拷贝"];
    }
    if (canDelete) {
        [menuItemArray addObject:@"删除"];
    }
    if (curMsg.sendStatus == PrivateMessageStatusSendSucess) {
        [menuItemArray addObject:@"转发"];
    }

    [cell.bgImgView addLongPressMenu:menuItemArray clickBlock:^(NSInteger index, NSString *title) {
        ESStrongSelf;
        if ([title hasPrefix:@"拷贝"]) {
            [[UIPasteboard generalPasteboard] setString:curMsg.content];
        }else if ([title isEqualToString:@"删除"]){
            [_self showAlertToDeleteMessage:curMsg];
        }else if ([title isEqualToString:@"转发"]){
            [_self willTranspondMessage:curMsg];
        }
    }];
    
    return cell;
}

- (void)showAlertToDeleteMessage:(PrivateMessage *)toDeleteMsg{
    self.messageToResendOrDelete = toDeleteMsg;
    [self.myMsgInputView isAndResignFirstResponder];
    ESWeakSelf
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除后将不会出现在你的私信记录中" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        ESStrongSelf
        if (index == 0 && _self.messageToResendOrDelete) {
            [_self deletePrivateMessageWithMsg:_messageToResendOrDelete];
        }
    }];
    [actionSheet showInView:kKeyWindow];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    PrivateMessage *preMessage = nil;
    NSUInteger curIndex = ([_myPriMsgs.list count] -1) - indexPath.row;
    if (curIndex +1 < _myPriMsgs.list.count) {
        preMessage = [_myPriMsgs.list objectAtIndex:curIndex+1];
    }
    return [MessageCell cellHeightWithObj:[_myPriMsgs.list objectAtIndex:curIndex] preObj:preMessage];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.myTableView numberOfRowsInSection:0];
    if(rows > 0) {
        [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

#pragma mark UIMessageInputView M
- (void)willTranspondMessage:(PrivateMessage *)message{
    __weak typeof(self) weakSelf = self;
    [UsersViewController showTranspondMessage:message withBlock:^(PrivateMessage *curMessage) {
        NSLog(@"%@, %@", curMessage.friend.name, curMessage.content);
        [weakSelf doTranspondMessage:curMessage];
    }];
}

- (void)doTranspondMessage:(PrivateMessage *)curMessage{
    [self showHudTipStr:@"已发送"];
    if ([curMessage.friend.global_key isEqualToString:_myPriMsgs.curFriend.global_key]) {
        [self sendPrivateMessageWithMsg:curMessage];
    }else{
        [[Coding_NetAPIManager sharedManager] request_SendPrivateMessage:curMessage andBlock:^(id data, NSError *error) {
            if (data) {
                NSLog(@"转发成功：%@, %@", curMessage.friend.name, curMessage.htmlMedia.contentOrigional);
            }
        }];
    }
}



- (void)sendPrivateMessage:(id)obj{
    PrivateMessage *nextMsg = [PrivateMessage privateMessageWithObj:obj andFriend:_myPriMsgs.curFriend];
    [self sendPrivateMessageWithMsg:nextMsg];
}

- (void)sendPrivateMessageWithMsg:(PrivateMessage *)nextMsg{
    [_myPriMsgs sendNewMessage:nextMsg];
    [self.myTableView reloadData];
    [self scrollToBottomAnimated:YES];
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_SendPrivateMessage:nextMsg andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.myPriMsgs sendSuccessMessage:data andOldMessage:nextMsg];
        }
        [weakSelf.myTableView reloadData];
        [weakSelf scrollToBottomAnimated:YES];
    } progerssBlock:^(CGFloat progressValue) {
        DebugLog(@"\n%.2f", progressValue);
    }];
    [weakSelf.view configBlankPage:EaseBlankPageTypePrivateMsg hasData:(weakSelf.myPriMsgs.list.count > 0) hasError:NO reloadButtonBlock:^(id sender) {
        [weakSelf refreshLoadMore:NO];
    }];
}
- (void)deletePrivateMessageWithMsg:(PrivateMessage *)curMsg{
    __weak typeof(self) weakSelf = self;
    if (curMsg.sendStatus == PrivateMessageStatusSendFail) {
        [_myPriMsgs deleteMessage:curMsg];
        [_myTableView reloadData];
    }else if (curMsg.sendStatus == PrivateMessageStatusSendSucess) {
        [[Coding_NetAPIManager sharedManager] request_DeletePrivateMessage:curMsg andBlock:^(id data, NSError *error) {
            [weakSelf.myPriMsgs deleteMessage:curMsg];
            [weakSelf.myTableView reloadData];
        }];
    }
}
- (void)inputViewAddIndex:(NSInteger)index{
    switch (index) {
        case 0:
        {//        相册
            if (![Helper checkPhotoLibraryAuthorizationStatus]) {
                return;
            }
            QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
            imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
            imagePickerController.delegate = self;
            imagePickerController.allowsMultipleSelection = YES;
            imagePickerController.maximumNumberOfSelection = 6;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
            [self presentViewController:navigationController animated:YES completion:NULL];
        }
            break;
        case 1:
        {//        拍照
            if (![Helper checkCameraAuthorizationStatus]) {
                return;
            }
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;//设置不可编辑
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];//进入照相界面
        }
            break;
        default:
            break;
    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    NSLog(@"%@", info);
    UIImage *originalImage;
//    editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self sendPrivateMessage:originalImage];

    // 保存原图片到相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(originalImage, self,selectorToCall, NULL);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.\nError = %@", paramError);
    }
}

#pragma mark QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    for (ALAsset *assetItem in assets) {
        UIImage *highQualityImage = [UIImage fullResolutionImageFromALAsset:assetItem];
        highQualityImage = [highQualityImage scaledToSize:kScreen_Bounds.size highQuality:YES];
        [self sendPrivateMessage:highQualityImage];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [_myMsgInputView isAndResignFirstResponder];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentSize.height >CGRectGetHeight(scrollView.bounds)
        && scrollView.contentOffset.y < 5) {
        _preContentHeight = self.myTableView.contentSize.height;
        [self refreshLoadMore:YES];
        DebugLog(@"加载更多");
    }
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}
@end
