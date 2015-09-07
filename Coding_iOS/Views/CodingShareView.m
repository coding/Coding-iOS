//
//  CodingShareView.m
//  Coding_iOS
//
//  Created by Ease on 15/9/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCodingShareView_NumPerLine 4
#define kCodingShareView_TopHeight 60.0
#define kCodingShareView_BottomHeight 60.0

#import "CodingShareView.h"
#import <UMengSocial/UMSocial.h>
#import <evernote-cloud-sdk-ios/ENSDK/ENSDK.h>

#import "PrivateMessage.h"
#import "UsersViewController.h"
#import "Coding_NetAPIManager.h"

@interface CodingShareView ()<UMSocialUIDelegate>
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *titleL;
@property (strong, nonatomic) UIButton *dismissBtn;
@property (strong, nonatomic) UIScrollView *itemsScrollView;

@property (strong, nonatomic) NSObject *objToShare;
@property (strong, nonatomic) NSArray *shareSnsValues;
@end

@implementation CodingShareView
#pragma mark init M
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = kScreen_Bounds;
        
        if (!_bgView) {
            _bgView = ({
                UIView *view = [[UIView alloc] initWithFrame:kScreen_Bounds];
                view.backgroundColor = [UIColor blackColor];
                view.alpha = 0;
                [view bk_whenTapped:^{
                    [self p_dismiss];
                }];
                view;
            });
            [self addSubview:_bgView];
        }
        if (!_contentView) {
            _contentView = [UIView new];
            _contentView.backgroundColor = [UIColor colorWithHexString:@"0xF0F0F0"];
            if (!_titleL) {
                _titleL = ({
                    UILabel *label = [UILabel new];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.font = [UIFont systemFontOfSize:14];
                    label.textColor = [UIColor colorWithHexString:@"0x666666"];
                    label;
                });
                [_contentView addSubview:_titleL];
                [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.equalTo(_contentView);
                    make.top.equalTo(_contentView).offset(10);
                    make.height.mas_equalTo(20);
                }];
            }
            if (!_dismissBtn) {
                _dismissBtn = ({
                    UIButton *button = [UIButton new];
                    button.backgroundColor = [UIColor whiteColor];
                    button.layer.masksToBounds = YES;
                    button.layer.cornerRadius = 2.0;
                    button.titleLabel.font = [UIFont systemFontOfSize:15];
                    [button setTitle:@"取消" forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor colorWithHexString:@"0x808080"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateHighlighted];
                    [button addTarget:self action:@selector(p_dismiss) forControlEvents:UIControlEventTouchUpInside];
                    button;
                });
                [_contentView addSubview:_dismissBtn];
                [_dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(_contentView).offset(kPaddingLeftWidth);
                    make.right.equalTo(_contentView).offset(-kPaddingLeftWidth);
                    make.bottom.equalTo(_contentView).offset(-kPaddingLeftWidth);
                    make.height.mas_equalTo(40);
                }];
            }
            if (!_itemsScrollView) {
                _itemsScrollView = ({
                    UIScrollView *scrollView = [UIScrollView new];
                    scrollView;
                });
                [_contentView addSubview:_itemsScrollView];
                [_itemsScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.equalTo(_contentView);
                    make.top.equalTo(_contentView).offset(kCodingShareView_TopHeight);
                    make.bottom.equalTo(_contentView).offset(-kCodingShareView_BottomHeight);
                }];
            }
            [_contentView setY:kScreen_Height];
            [self addSubview:_contentView];
        }
    }
    return self;
}

- (void)setShareSnsValues:(NSArray *)shareSnsValues{
    if (![_shareSnsValues isEqualToArray:shareSnsValues]) {
        _shareSnsValues = shareSnsValues;
        [[_itemsScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for (int index = 0; index < _shareSnsValues.count; index++) {
            NSString *snsName = _shareSnsValues[index];
            CodingShareView_Item *item = [CodingShareView_Item itemWithSnsName:snsName];
            CGPoint pointO = CGPointZero;
            pointO.x = [CodingShareView_Item itemWidth] * (index%kCodingShareView_NumPerLine);
            pointO.y = [CodingShareView_Item itemHeight] * (index/kCodingShareView_NumPerLine);
            [item setOrigin:pointO];
            item.clickedBlock = ^(NSString *snsName){
                [self p_shareItemClickedWithSnsName:snsName];
            };
            [_itemsScrollView addSubview:item];
        }
        CGFloat contentHeight = kCodingShareView_TopHeight + kCodingShareView_BottomHeight + ((_shareSnsValues.count - 1)/kCodingShareView_NumPerLine + 1)* [CodingShareView_Item itemHeight];
        [self.contentView setSize:CGSizeMake(kScreen_Width, contentHeight)];
    }
}

#pragma mark common M
+ (instancetype)sharedInstance{
    static CodingShareView *shared_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_instance = [[self alloc] init];
    });
    return shared_instance;
}

+ (NSDictionary *)snsNameDict{
    static NSDictionary *snsNameDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        snsNameDict = @{
                        @"coding": @"Coding好友",
                        @"copylink": @"复制链接",
                        @"evernote": @"印象笔记",
                        @"sina": @"新浪微博",
                        @"qzone": @"QQ空间",
                        @"qq": @"QQ好友",
                        @"wxtimeline": @"朋友圈",
                        @"wxsession": @"微信好友",
                        };
    });
    return snsNameDict;

}

+ (void)showShareViewWithTweet:(Tweet *)curTweet{
    [[self sharedInstance] showShareViewWithTweet:curTweet];
}

+(NSArray *)supportSnsValues{
    NSMutableArray *resultSnsValues = [@[
                                         @"wxsession",
                                         @"wxtimeline",
                                         @"qq",
                                         @"qzone",
                                         @"sina",
                                         @"evernote",
                                         @"coding",
                                         @"copylink",
                                         ] mutableCopy];
    if (![self p_canOpen:@"weixin://"]) {
        [resultSnsValues removeObjectsInArray:@[
                                                @"wxsession",
                                                @"wxtimeline",
                                                ]];
    }
    if (![self p_canOpen:@"mqqapi://"]) {
        [resultSnsValues removeObjectsInArray:@[
                                                @"qq",
                                                @"qzone",
                                                ]];
    }
    if (![self p_canOpen:@"weibosdk://request"]) {
        [resultSnsValues removeObjectsInArray:@[@"sina"]];
    }
    if (![self p_canOpen:@"evernote://"]) {
        [resultSnsValues removeObjectsInArray:@[@"evernote"]];
    }
    return resultSnsValues;
}

+(BOOL)p_canOpen:(NSString*)url{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
}

- (void)showShareViewWithTweet:(Tweet *)curTweet{
    self.objToShare = curTweet;
    [self p_show];
}

- (void)p_show{
    [self p_checkTitle];
    [self p_checkShareSnsValues];
    [kKeyWindow addSubview:self];

    //animate to show
    CGPoint endCenter = self.contentView.center;
    endCenter.y -= CGRectGetHeight(self.contentView.frame);
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bgView.alpha = 0.3;
        self.contentView.center = endCenter;
    } completion:nil];
}
- (void)p_dismiss{
    //animate to dismiss
    CGPoint endCenter = self.contentView.center;
    endCenter.y += CGRectGetHeight(self.contentView.frame);
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bgView.alpha = 0.0;
        self.contentView.center = endCenter;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)p_dismissWithCompletionBlock:(void (^)(void))completionBlock{
    //animate to dismiss
    CGPoint endCenter = self.contentView.center;
    endCenter.y += CGRectGetHeight(self.contentView.frame);
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bgView.alpha = 0.0;
        self.contentView.center = endCenter;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completionBlock) {
            completionBlock();
        }
    }];
}
- (void)p_checkTitle{
    NSString *title;
    if ([_objToShare isKindOfClass:[Tweet class]]) {
        title = @"冒泡分享";
    }else{
        title = @"分享";
    }
    _titleL.text = title;
}
- (void)p_checkShareSnsValues{
    self.shareSnsValues = [CodingShareView supportSnsValues];
}

- (void)p_shareItemClickedWithSnsName:(NSString *)snsName{
    void (^completion)() = ^(){
        [self p_doShareToSnsName:snsName];
    };
    [self p_dismissWithCompletionBlock:completion];
}

- (void)p_doShareToSnsName:(NSString *)snsName{
    NSLog(@"p_doShareToSnsName : %@", snsName);

    if ([snsName isEqualToString:@"copylink"]) {
        [[UIPasteboard generalPasteboard] setString:[self p_shareLinkStr]];
        [self showHudTipStr:@"链接已拷贝到粘贴板"];
    }else if ([snsName isEqualToString:@"coding"]){
        PrivateMessage *curMsg = [PrivateMessage privateMessageWithObj:[self p_shareLinkStr] andFriend:nil];
        [self willTranspondMessage:curMsg];
    }else if ([snsName isEqualToString:@"sina"]){
        NSString *shareTitle, *shareText, *shareTail;
        shareTitle = [NSString stringWithFormat:@"【%@】", [self p_shareTitle]];
        shareText = [self p_shareText];
        shareTail = [NSString stringWithFormat:@"%@（分享自@Coding）", [self p_shareLinkStr]];
        NSInteger maxShareLength = 140;
        NSInteger maxTextLength = maxShareLength - shareTitle.length - shareTail.length;
        if (shareText.length > maxTextLength) {
            shareText = [shareText stringByReplacingCharactersInRange:NSMakeRange(maxTextLength - 3, shareText.length - (maxTextLength - 3)) withString:@"..."];
        }
        NSString *shareContent = [NSString stringWithFormat:@"%@%@%@", shareTitle, shareText, shareTail];
        [self showStatusBarQueryStr:@"正在分享到新浪微博"];
        [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToSina] content:shareContent image:nil location:nil urlResource:nil presentedController:[BaseViewController presentingVC] completion:^(UMSocialResponseEntity *response) {
            if (response.responseCode == UMSResponseCodeSuccess) {
                [self showStatusBarSuccessStr:@"分享成功"];
            }else{
                [self showStatusBarError:response.error];
            }
        }];
    }else if ([snsName isEqualToString:@"evernote"]){
        ENNote *noteToSave = [ENNote new];
        noteToSave.title = [self p_shareTitle];
        NSString *htmlStr;
        if ([_objToShare valueForKey:@"htmlMedia"]) {
            HtmlMedia *htmlMedia = [_objToShare valueForKey:@"htmlMedia"];
            htmlStr = htmlMedia.contentOrigional;
        }else{
            htmlStr = [self p_shareText];
        }
        htmlStr = [htmlStr stringByAppendingFormat:@"<p><a href=\"%@\">冒泡原始链接</a></p>", [self p_shareLinkStr]];
        noteToSave.content = [ENNoteContent noteContentWithSanitizedHTML:htmlStr];
        
        if (![[ENSession sharedSession] isAuthenticated]) {
            [[ENSession sharedSession] authenticateWithViewController:[BaseViewController presentingVC] preferRegistration:NO completion:^(NSError *authenticateError) {
                if (!authenticateError) {
                    [self p_uploadENNote:noteToSave];
                }else if (authenticateError.code != ENErrorCodeCancelled){
                    [self showHudTipStr:@"授权失败"];
                }
            }];
        }else{
            [self p_uploadENNote:noteToSave];
        }
    }else{
        [[UMSocialControllerService defaultControllerService] setSocialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
        if (snsPlatform) {
            snsPlatform.snsClickHandler([BaseViewController presentingVC],[UMSocialControllerService defaultControllerService],YES);
        }
    }
}

- (void)p_uploadENNote:(ENNote *)noteToSave{
    if (noteToSave) {
        [self showStatusBarQueryStr:@"正在保存到印象笔记"];
        [[ENSession sharedSession] uploadNote:noteToSave notebook:nil completion:^(ENNoteRef *noteRef, NSError *uploadNoteError) {
            if (noteRef) {
                [self showStatusBarSuccessStr:@"笔记保存成功"];
            }else{
                [self showStatusBarError:uploadNoteError];
            }
        }];
    }
}

- (NSString *)p_shareLinkStr{
    NSString *linkStr;
    if ([_objToShare isKindOfClass:[Tweet class]]) {
        linkStr = [(Tweet *)_objToShare toShareLinkStr];
    }else{
        linkStr = [NSObject baseURLStr];
    }
    return linkStr;
}
- (NSString *)p_shareTitle{
    NSString *title;
    if ([_objToShare isKindOfClass:[Tweet class]]) {
        title = [NSString stringWithFormat:@"%@ 的冒泡", [(Tweet *)_objToShare owner].name];
    }else{
        title = @"Coding";
    }
    return title;
}
- (NSString *)p_shareText{
    NSString *text;
    if ([_objToShare isKindOfClass:[Tweet class]]) {
        NSString *contentOrigional = [(Tweet *)_objToShare htmlMedia].contentOrigional;
        text = [contentOrigional stringByRemoveHtmlTag];
    }else{
        text = @"Coding 让开发更简单！";
    }
    return text;
}
#pragma mark TranspondMessage

- (void)willTranspondMessage:(PrivateMessage *)message{
    __weak typeof(self) weakSelf = self;
    [UsersViewController showTranspondMessage:message withBlock:^(PrivateMessage *curMessage) {
        DebugLog(@"%@, %@", curMessage.friend.name, curMessage.content);
        [weakSelf doTranspondMessage:curMessage];
    }];
}

- (void)doTranspondMessage:(PrivateMessage *)curMessage{
    [[Coding_NetAPIManager sharedManager] request_SendPrivateMessage:curMessage andBlock:^(id data, NSError *error) {
        if (data) {
            DebugLog(@"转发成功：%@, %@", curMessage.friend.name, curMessage.htmlMedia.contentOrigional);
            [self showHudTipStr:@"已发送"];
        }
    }];
}

#pragma mark UMSocialUIDelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    NSLog(@"didFinishGetUMSocialDataInViewController : %@",response);
    if(response.responseCode == UMSResponseCodeSuccess){
        NSString *snsName = [[response.data allKeys] firstObject];
        NSLog(@"share to sns name is %@",snsName);
        [self performSelector:@selector(showHudTipStr:) withObject:@"分享成功" afterDelay:0.3];
    }
}

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData{
    //设置分享内容，和回调对象
    {
        socialData.shareText = [self p_shareText];
        socialData.shareImage = [UIImage imageNamed:@"logo_about"];
    }
    if ([platformName isEqualToString:@"wxsession"]) {
        UMSocialWechatSessionData *wechatSessionData = [UMSocialWechatSessionData new];
        wechatSessionData.title = [self p_shareTitle];
        wechatSessionData.url = [self p_shareLinkStr];
        wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
        socialData.extConfig.wechatSessionData = wechatSessionData;
    }else if ([platformName isEqualToString:@"wxtimeline"]){
        UMSocialWechatTimelineData *wechatTimelineData = [UMSocialWechatTimelineData new];
        wechatTimelineData.url = [self p_shareLinkStr];
        wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
        socialData.extConfig.wechatTimelineData = wechatTimelineData;
    }else if ([platformName isEqualToString:@"qq"]){
        UMSocialQQData *qqData = [UMSocialQQData new];
        qqData.title = [self p_shareTitle];
        qqData.url = [self p_shareLinkStr];
        qqData.qqMessageType = UMSocialQQMessageTypeDefault;
        socialData.extConfig.qqData = qqData;
    }else if ([platformName isEqualToString:@"qzone"]){
        UMSocialQzoneData *qzoneData = [UMSocialQzoneData new];
        qzoneData.title = [self p_shareTitle];
        qzoneData.url = [self p_shareLinkStr];
        socialData.extConfig.qzoneData = qzoneData;
    }
    NSLog(@"%@ : %@", platformName, socialData);
}

-(BOOL)isDirectShareInIconActionSheet{
    return YES;
}

@end

@interface CodingShareView_Item ()
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UILabel *titleL;
@end

@implementation CodingShareView_Item

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [CodingShareView_Item itemWidth], [CodingShareView_Item itemHeight]);
        _button = [UIButton new];
        [self addSubview:_button];
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(kPaddingLeftWidth);
            make.right.equalTo(self).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo([CodingShareView_Item itemWidth] - 2*kPaddingLeftWidth);
        }];
        _titleL = ({
            UILabel *label = [UILabel new];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor colorWithHexString:@"0x666666"];
            label;
        });
        [self addSubview:_titleL];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(15);
            make.top.equalTo(self.button.mas_bottom).offset(kPaddingLeftWidth);
        }];
        [_button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonClicked{
    if (self.clickedBlock) {
        self.clickedBlock(_snsName);
    }
}

- (void)setSnsName:(NSString *)snsName{
    if (![_snsName isEqualToString:snsName]) {
        _snsName = snsName;
        NSString *imageName = [NSString stringWithFormat:@"share_btn_%@", snsName];
        NSString *title = [[CodingShareView snsNameDict] objectForKey:snsName];
        [_button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        _titleL.text = title;
    }
}

+ (instancetype)itemWithSnsName:(NSString *)snsName{
    CodingShareView_Item *item = [self new];
    item.snsName = snsName;
    return item;
}

+ (CGFloat)itemWidth{
    return kScreen_Width/kCodingShareView_NumPerLine;
}

+ (CGFloat)itemHeight{
    return [self itemWidth] + 20;
}

@end
