//
//  ConversationViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ConversationViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "MessageCell.h"
#import "UserInfoViewController.h"
#import "QBImagePickerController.h"
#import "UsersViewController.h"
#import "Helper.h"
#import "WebViewController.h"
#import "NSTimer+Common.h"
#import "AudioManager.h"

@interface ConversationViewController ()<TTTAttributedLabelDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@property (nonatomic, assign) CGFloat preContentHeight;
@property (nonatomic, strong) PrivateMessage *messageToResendOrDelete;
@property (strong, nonatomic) NSTimer *pollTimer;
@end

@implementation ConversationViewController

static const NSTimeInterval kPollTimeInterval = 3.0;

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
        [tableView registerClass:[MessageCell class] forCellReuseIdentifier:kCellIdentifier_MessageVoice];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
//    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
//    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypePriMsg placeHolder:@"请输入私信内容"];
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
    [self stopPolling];
    [[AudioManager shared] stopAll];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    键盘
    if (_myMsgInputView) {
        [_myMsgInputView prepareToShow];
    }
    [self.myTableView reloadData];
    [self startPolling];
}

- (void)dataChangedWithError:(BOOL)hasError scrollToBottom:(BOOL)scrollToBottom animated:(BOOL)animated{
    [self.myTableView reloadData];
    if (scrollToBottom) {
        [self scrollToBottomAnimated:animated];
    }
    __weak typeof(self) weakSelf = self;
    [self.view configBlankPage:EaseBlankPageTypePrivateMsg hasData:(self.myPriMsgs.dataList.count > 0) hasError:hasError reloadButtonBlock:^(id sender) {
        [weakSelf refreshLoadMore:NO];
    }];
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

- (void)messageInputView:(UIMessageInputView *)inputView sendVoice:(NSString *)file duration:(NSTimeInterval)duration {
    VoiceMedia *vm = [[VoiceMedia alloc] init];
    vm.file = file;
    vm.duration = duration;
    [self sendPrivateMessage:vm];
}

- (void)messageInputView:(UIMessageInputView *)inputView addIndexClicked:(NSInteger)index{
    [self inputViewAddIndex:index];
}

- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom{
    UIEdgeInsets contentInsets= UIEdgeInsetsMake(0.0, 0.0, MAX(CGRectGetHeight(inputView.frame), heightToBottom), 0.0);;
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
    //调整内容
    static BOOL keyboard_is_down = YES;
    static CGPoint keyboard_down_ContentOffset;
    static CGFloat keyboard_down_InputViewHeight;
    if (heightToBottom > CGRectGetHeight(inputView.frame)) {
        if (keyboard_is_down) {
            keyboard_down_ContentOffset = self.myTableView.contentOffset;
            keyboard_down_InputViewHeight = CGRectGetHeight(inputView.frame);
        }
        keyboard_is_down = NO;
        
        CGPoint contentOffset = keyboard_down_ContentOffset;
        CGFloat spaceHeight = MAX(0, CGRectGetHeight(self.myTableView.frame) - self.myTableView.contentSize.height - keyboard_down_InputViewHeight);
        contentOffset.y += MAX(0, heightToBottom - keyboard_down_InputViewHeight - spaceHeight);
        NSLog(@"\nspaceHeight:%.2f heightToBottom:%.2f diff:%.2f Y:%.2f", spaceHeight, heightToBottom, MAX(0, heightToBottom - CGRectGetHeight(inputView.frame) - spaceHeight), contentOffset.y);
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.myTableView.contentOffset = contentOffset;
        } completion:nil];
    }else{
        keyboard_is_down = YES;
    }
}

#pragma mark refresh
- (void)refreshLoadMore:(BOOL)willLoadMore{
    if (!_myPriMsgs ||  _myPriMsgs.isLoading) {
        return;
    }
    _myPriMsgs.willLoadMore = willLoadMore;
    if (willLoadMore) {
        if (!_myPriMsgs.canLoadMore) {
            [_refreshControl endRefreshing];
            return;
        }else{
            [_refreshControl beginRefreshing];
        }
    }
    __weak typeof(self) weakSelf = self;
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
        [weakSelf.view configBlankPage:EaseBlankPageTypePrivateMsg hasData:(weakSelf.myPriMsgs.dataList.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refreshLoadMore:NO];
        }];
    }];
}

#pragma mark Poll

- (void)startPolling{
    [self stopPolling];
    __weak ConversationViewController *weakSelf = self;
    _pollTimer = [NSTimer scheduledTimerWithTimeInterval:kPollTimeInterval block:^{
        __strong ConversationViewController *strongSelf = weakSelf;
        [strongSelf doPoll];
    } repeats:YES];
}

- (void)stopPolling{
    [_pollTimer invalidate];
    _pollTimer = nil;
}

- (void)doPoll{
    if (!_myPriMsgs ||  _myPriMsgs.isLoading) {
        return;
    }
    if (_myPriMsgs.list.count <= 0) {
        [self refreshLoadMore:NO];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Fresh_PrivateMessages:_myPriMsgs andBlock:^(id data, NSError *error) {
        if (data && [(NSArray *)data count] > 0) {
            [weakSelf.myPriMsgs configWithPollArray:data];
            [weakSelf dataChangedWithError:NO scrollToBottom:YES animated:YES];
        }
    }];
}

#pragma mark Table M

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_myPriMsgs.dataList) {
        row = [_myPriMsgs.dataList count];
    }
    return row;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *cell;
    NSUInteger curIndex = ([_myPriMsgs.dataList count] -1) - indexPath.row;
    PrivateMessage *curMsg = [_myPriMsgs.dataList objectAtIndex:curIndex];
    if (curMsg.hasMedia) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MessageMedia forIndexPath:indexPath];
    }else if (curMsg.file || curMsg.voiceMedia) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MessageVoice forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Message forIndexPath:indexPath];
    }
    cell.contentLabel.delegate = self;
    PrivateMessage *preMsg = nil;
    if (curIndex +1 < _myPriMsgs.dataList.count) {
        preMsg = [_myPriMsgs.dataList objectAtIndex:curIndex+1];
    }
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
        [actionSheet showInView:self.view];
    };
    [cell setCurPriMsg:curMsg andPrePriMsg:preMsg];
    cell.refreshMessageMediaCCellBlock = ^(CGFloat diff){
        if (ABS(diff) > 1) {
            ESStrongSelf;
            [_self.myTableView reloadData];
        }
    };
    NSMutableArray *menuItemArray = [[NSMutableArray alloc] init];
    BOOL hasTaxtToCopy = (curMsg.content && ![curMsg.content isEmpty]);
    BOOL canDelete = (curMsg.sendStatus != PrivateMessageStatusSending);
    if (curMsg.hasMedia) {//有图片
        if (hasTaxtToCopy) {
            [menuItemArray addObject:@"拷贝文字"];
        }
    }else{
        if (!(curMsg.voiceMedia || curMsg.file)) {
            [menuItemArray addObject:@"拷贝"];
        }
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
    [actionSheet showInView:self.view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    PrivateMessage *preMessage = nil;
    NSUInteger curIndex = ([_myPriMsgs.dataList count] -1) - indexPath.row;
    if (curIndex +1 < _myPriMsgs.dataList.count) {
        preMessage = [_myPriMsgs.dataList objectAtIndex:curIndex+1];
    }
    return [MessageCell cellHeightWithObj:[_myPriMsgs.dataList objectAtIndex:curIndex] preObj:preMessage];
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

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *clickedItem = [components objectForKey:@"value"];
    [self analyseLinkStr:clickedItem.href];
}

- (void)analyseLinkStr:(NSString *)linkStr{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        //网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}

#pragma mark UIMessageInputView M
- (void)willTranspondMessage:(PrivateMessage *)message{
    __weak typeof(self) weakSelf = self;
    [UsersViewController showTranspondMessage:message withBlock:^(PrivateMessage *curMessage) {
        DebugLog(@"%@, %@", curMessage.friend.name, curMessage.content);
        [weakSelf doTranspondMessage:curMessage];
    }];
}

- (void)doTranspondMessage:(PrivateMessage *)curMessage{
    if ([curMessage.friend.global_key isEqualToString:_myPriMsgs.curFriend.global_key]) {
        [self sendPrivateMessageWithMsg:curMessage];
    }else{
        [[Coding_NetAPIManager sharedManager] request_SendPrivateMessage:curMessage andBlock:^(id data, NSError *error) {
            if (data) {
                [NSObject showHudTipStr:@"已发送"];
                DebugLog(@"转发成功：%@, %@", curMessage.friend.name, curMessage.htmlMedia.contentOrigional);
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
    [self dataChangedWithError:NO scrollToBottom:YES animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_SendPrivateMessage:nextMsg andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.myPriMsgs sendSuccessMessage:data andOldMessage:nextMsg];
        }
        [weakSelf dataChangedWithError:NO scrollToBottom:YES animated:YES];
    } progerssBlock:^(CGFloat progressValue) {
    }];
}
- (void)deletePrivateMessageWithMsg:(PrivateMessage *)curMsg{
    __weak typeof(self) weakSelf = self;
    if (curMsg.sendStatus == PrivateMessageStatusSendFail) {
        [_myPriMsgs deleteMessage:curMsg];
        [self dataChangedWithError:NO scrollToBottom:NO animated:NO];
    }else if (curMsg.sendStatus == PrivateMessageStatusSendSucess) {
        [[Coding_NetAPIManager sharedManager] request_DeletePrivateMessage:curMsg andBlock:^(id data, NSError *error) {
            [weakSelf.myPriMsgs deleteMessage:curMsg];
            [self dataChangedWithError:NO scrollToBottom:NO animated:NO];
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
            UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:imagePickerController];
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
    UIImage *originalImage;
    originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self sendPrivateMessage:originalImage];

    // 保存原图片到相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, NULL);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    for (ALAsset *assetItem in assets) {
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *highQualityImage = [UIImage fullScreenImageALAsset:assetItem];
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self sendPrivateMessage:highQualityImage];
            });
        });
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
    }
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
    [_pollTimer invalidate];
}
@end
