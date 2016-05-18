//
//  CodingShareView.m
//  Coding_iOS
//
//  Created by Ease on 15/9/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCodingShareView_NumPerLine 4
#define kCodingShareView_NumPerScroll (2 * kCodingShareView_NumPerLine)
#define kCodingShareView_TopHeight 60.0
#define kCodingShareView_BottomHeight 65.0

#import "CodingShareView.h"
#import "SMPageControl.h"
#import <UMengSocial/UMSocial.h>
#import <evernote-cloud-sdk-ios/ENSDK/ENSDK.h>

#import "PrivateMessage.h"
#import "UsersViewController.h"
#import "Coding_NetAPIManager.h"
#import "ReportIllegalViewController.h"


@interface CodingShareView ()<UMSocialUIDelegate>
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *titleL;
@property (strong, nonatomic) UIButton *dismissBtn;
@property (strong, nonatomic) UIScrollView *itemsScrollView;
@property (strong, nonatomic) SMPageControl *myPageControl;

@property (strong, nonatomic) NSArray *shareSnsValues;
@property (weak, nonatomic) NSObject *objToShare;
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
                    scrollView.pagingEnabled = YES;
                    scrollView.showsHorizontalScrollIndicator = NO;
                    scrollView.showsVerticalScrollIndicator = NO;
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

- (SMPageControl *)myPageControl{
    if (!_myPageControl) {
        _myPageControl = ({
            SMPageControl *pageControl = [[SMPageControl alloc] init];
            pageControl.userInteractionEnabled = NO;
            pageControl.backgroundColor = [UIColor clearColor];
            pageControl.pageIndicatorImage = [UIImage imageNamed:@"banner__page_unselected"];
            pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"banner__page_selected"];
            pageControl;
        });
        [self addSubview:_myPageControl];
        [_myPageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_contentView);
            make.height.mas_equalTo(10);
            make.bottom.equalTo(_dismissBtn.mas_top).offset(-10);
        }];
        
        [RACObserve(self, itemsScrollView.contentOffset) subscribeNext:^(NSValue *point) {
            CGPoint contentOffset;
            [point getValue:&contentOffset];
            CGFloat pageWidth = kScreen_Width;
            NSUInteger page = MAX(0, floor((contentOffset.x + (pageWidth / 2)) / pageWidth));
            if (page != self.myPageControl.currentPage) {
                self.myPageControl.currentPage = page;
            }
        }];
    }
    return _myPageControl;
}

- (void)setShareSnsValues:(NSArray *)shareSnsValues{
    if (![_shareSnsValues isEqualToArray:shareSnsValues]) {
        _shareSnsValues = shareSnsValues;
        [[_itemsScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for (int index = 0; index < _shareSnsValues.count; index++) {
            NSInteger scrollIndex = index/kCodingShareView_NumPerScroll;
            NSInteger itemIndex = index % kCodingShareView_NumPerScroll;
            CGPoint pointO = CGPointZero;
            pointO.x = [CodingShareView_Item itemWidth] * (itemIndex % kCodingShareView_NumPerLine) + kScreen_Width * scrollIndex;
            pointO.y = [CodingShareView_Item itemHeight] * (itemIndex / kCodingShareView_NumPerLine);
            
            NSString *snsName = _shareSnsValues[index];
            CodingShareView_Item *item = [CodingShareView_Item itemWithSnsName:snsName];
            [item setOrigin:pointO];
            item.clickedBlock = ^(NSString *snsName){
                [self p_shareItemClickedWithSnsName:snsName];
            };
            [_itemsScrollView addSubview:item];
        }
        CGFloat scrollPageNum = 1 + (_shareSnsValues.count/kCodingShareView_NumPerScroll);
        [_itemsScrollView setContentSize:CGSizeMake(scrollPageNum * kScreen_Width, 2* [CodingShareView_Item itemHeight])];
        _itemsScrollView.scrollEnabled = scrollPageNum > 1;

        if (scrollPageNum > 1) {
            self.myPageControl.numberOfPages = scrollPageNum;
            self.myPageControl.hidden = NO;
        }else{
            _myPageControl.hidden = YES;
        }
        CGFloat contentHeight = kCodingShareView_TopHeight + kCodingShareView_BottomHeight + 2* [CodingShareView_Item itemHeight];
        [self.contentView setSize:CGSizeMake(kScreen_Width, contentHeight)];
    }
    [_itemsScrollView setContentOffset:CGPointZero];
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
                        @"inform": @"举报",
                        };
    });
    return snsNameDict;

}

+ (void)showShareViewWithObj:(Tweet *)curObj{
    [[self sharedInstance] showShareViewWithObj:curObj];
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
                                         @"inform",
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
//    if (![self p_canOpen:@"weibosdk://request"]) {
//        [resultSnsValues removeObjectsInArray:@[@"sina"]];
//    }
//    if (![self p_canOpen:@"evernote://"]) {
//        [resultSnsValues removeObjectsInArray:@[@"evernote"]];
//    }
    return resultSnsValues;
}

+(BOOL)p_canOpen:(NSString*)url{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
}

- (void)showShareViewWithObj:(NSObject *)curObj{
    self.objToShare = curObj;
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
        [NSObject showHudTipStr:@"链接已拷贝到粘贴板"];
    }else if ([snsName isEqualToString:@"coding"]){
        PrivateMessage *curMsg = [PrivateMessage privateMessageWithObj:[self p_shareLinkStr] andFriend:nil];
        [self willTranspondMessage:curMsg];
    }else if ([snsName isEqualToString:@"inform"]){
        [self goToInform];
    }else if ([snsName isEqualToString:@"evernote"]){
        __weak typeof(self) weakSelf = self;
        [self p_shareENNoteWithompletion:^(ENNote *note) {
            [weakSelf p_willUploadENNote:note];
        }];
    }else{
        [[UMSocialControllerService defaultControllerService] setSocialUIDelegate:self];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
        if (snsPlatform) {
            snsPlatform.snsClickHandler([BaseViewController presentingVC],[UMSocialControllerService defaultControllerService],YES);
        }
    }
}
- (void)p_willUploadENNote:(ENNote *)noteToSave{
    if (!noteToSave) {
        [NSObject showHudTipStr:@"不支持保存到印象笔记"];
        return;
    }
    if (![[ENSession sharedSession] isAuthenticated]) {
        [[ENSession sharedSession] authenticateWithViewController:[BaseViewController presentingVC] preferRegistration:NO completion:^(NSError *authenticateError) {
            if (!authenticateError) {
                [self p_doUploadENNote:noteToSave];
            }else if (authenticateError.code != ENErrorCodeCancelled){
                [NSObject showHudTipStr:@"授权失败"];
            }
        }];
    }else{
        [self p_doUploadENNote:noteToSave];
    }
}
- (void)p_doUploadENNote:(ENNote *)noteToSave{
    if (noteToSave) {
        [NSObject showStatusBarQueryStr:@"正在保存到印象笔记"];
        [[ENSession sharedSession] uploadNote:noteToSave notebook:nil completion:^(ENNoteRef *noteRef, NSError *uploadNoteError) {
            if (noteRef) {
                [NSObject showStatusBarSuccessStr:@"笔记保存成功"];
            }else{
                [NSObject showStatusBarError:uploadNoteError];
            }
        }];
    }
}
#pragma mark objToShare
- (void)p_checkTitle{
    NSString *title;
    if ([_objToShare isKindOfClass:[Tweet class]]) {
        title = @"冒泡分享到";
    }else if ([_objToShare isKindOfClass:[UIWebView class]]){
        title = @"链接分享到";
    }else{
        title = @"分享到";
    }
    _titleL.text = title;
}

- (NSString *)p_shareLinkStr{
    NSString *linkStr;
    if ([_objToShare isKindOfClass:[Tweet class]]) {
        linkStr = [(Tweet *)_objToShare toShareLinkStr];
    }else if ([_objToShare isKindOfClass:[UIWebView class]]){
        linkStr = [(UIWebView *)_objToShare request].URL.absoluteString;
    }else{
        linkStr = [NSObject baseURLStr];
    }
    return linkStr;
}
- (NSString *)p_shareTitle{
    NSString *title;
    if ([_objToShare isKindOfClass:[Tweet class]]) {
        title = [NSString stringWithFormat:@"%@ 的冒泡", [(Tweet *)_objToShare owner].name];
    }else if ([_objToShare isKindOfClass:[UIWebView class]]){
        title = @"Coding 链接";
    }else{
        title = @"Coding";
    }
    return title;
}
- (NSString *)p_shareText{
    NSString *text;
    if ([_objToShare isKindOfClass:[Tweet class]]) {
        text = [(Tweet *)_objToShare content];
    }else if ([_objToShare isKindOfClass:[UIWebView class]]){
        text =[(UIWebView *)_objToShare stringByEvaluatingJavaScriptFromString:@"document.title"];
    }else{
        text = @"Coding 让开发更简单！";
    }
    return text;
}
- (NSString *)p_imageUrlSquare:(BOOL)needSquare{
    __block NSString *imageUrl = nil;
    if ([_objToShare respondsToSelector:NSSelectorFromString(@"htmlMedia")]) {
        HtmlMedia *htmlMedia = [_objToShare valueForKey:@"htmlMedia"];
        [htmlMedia.imageItems enumerateObjectsUsingBlock:^(HtmlMediaItem *obj, NSUInteger idx, BOOL *stop) {
            if (obj.type == HtmlMediaItemType_Image) {
                if (needSquare) {
                    imageUrl = [obj.src urlImageWithCodePathResize:100 crop:YES].absoluteString;
                }else{
                    imageUrl = obj.src;
                }
                *stop = YES;//结束查询
            }else if (!needSquare && obj.type == HtmlMediaItemType_EmotionMonkey){
                imageUrl = obj.src;//赋值为猴子，继续查询
            }
        }];
    }
    return imageUrl;
}
- (void)p_shareENNoteWithompletion:(ENNotePopulateFromWebViewCompletionHandler)completion{
    if ([_objToShare respondsToSelector:NSSelectorFromString(@"htmlMedia")]) {
        ENNote *note = [ENNote new];
        note.title = [self p_shareTitle];
        NSString *htmlStr;
        HtmlMedia *htmlMedia = [_objToShare valueForKey:@"htmlMedia"];
        htmlStr = htmlMedia.contentOrigional;
        htmlStr = [htmlStr stringByAppendingFormat:@"<p><a href=\"%@\">原始链接</a></p>", [self p_shareLinkStr]];
        note.content = [ENNoteContent noteContentWithSanitizedHTML:htmlStr];
        completion(note);
    }else if ([_objToShare isKindOfClass:[UIWebView class]]){
        [ENNote populateNoteFromWebView:(UIWebView *)_objToShare completion:completion];
    }
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
            [NSObject showHudTipStr:@"已发送"];
        }
    }];
}

- (void)goToInform{
    [ReportIllegalViewController showReportWithIllegalContent:[self p_shareLinkStr] andType:IllegalContentTypeWebsite];
}

#pragma mark UMSocialUIDelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    NSLog(@"didFinishGetUMSocialDataInViewController : %@",response);
    if(response.responseCode == UMSResponseCodeSuccess){
        NSString *snsName = [[response.data allKeys] firstObject];
        NSLog(@"share to sns name is %@",snsName);
        [NSObject performSelector:@selector(showStatusBarSuccessStr:) withObject:@"分享成功" afterDelay:0.3];
    }else if (response.responseCode != UMSResponseCodeCancel){
        NSString *snsName = [[response.data allKeys] firstObject];
        NSString *errorTipStr = response.data[snsName][@"msg"];
        [NSObject performSelector:@selector(showStatusBarErrorStr:) withObject:errorTipStr ?: @"分享失败" afterDelay:0.3];
    }
}

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData{
    //设置分享内容，和回调对象
    {
        socialData.shareText = [self p_shareText];
        socialData.shareImage = [UIImage imageNamed:@"logo_about"];
        NSString *imageUrl = [self p_imageUrlSquare:![platformName isEqualToString:@"sina"]];
        socialData.urlResource.url = imageUrl;
        socialData.urlResource.resourceType = imageUrl.length > 0? UMSocialUrlResourceTypeImage: UMSocialUrlResourceTypeDefault;
    }
    if ([platformName isEqualToString:@"wxsession"]) {
        UMSocialWechatSessionData *wechatSessionData = [UMSocialWechatSessionData new];
        wechatSessionData.title = [self p_shareTitle];
        wechatSessionData.url = [self p_shareLinkStr];
        wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
        socialData.extConfig.wechatSessionData = wechatSessionData;
    }else if ([platformName isEqualToString:@"wxtimeline"]){
        UMSocialWechatTimelineData *wechatTimelineData = [UMSocialWechatTimelineData new];
        wechatTimelineData.shareText = [NSString stringWithFormat:@"「%@」%@", [self p_shareTitle], [self p_shareText]];
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
    }else if ([platformName isEqualToString:@"sina"]){
        NSString *shareTitle, *shareText, *shareTail;
        shareTitle = [NSString stringWithFormat:@"「%@」", [self p_shareTitle]];
        shareText = [self p_shareText];
        shareTail = [NSString stringWithFormat:@"%@（分享自@Coding）", [self p_shareLinkStr]];
        NSInteger maxShareLength = 140;
        NSInteger maxTextLength = maxShareLength - shareTitle.length - shareTail.length;
        if (shareText.length > maxTextLength) {
            shareText = [shareText stringByReplacingCharactersInRange:NSMakeRange(maxTextLength - 3, shareText.length - (maxTextLength - 3)) withString:@"..."];
        }
        NSString *shareContent = [NSString stringWithFormat:@"%@%@ %@", shareTitle, shareText, shareTail];

        socialData.shareText = shareContent;
        socialData.shareImage = nil;
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
        CGFloat padding_button = kScaleFrom_iPhone5_Desgin(kPaddingLeftWidth);
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(padding_button);
            make.right.equalTo(self).offset(-padding_button);
            make.height.mas_equalTo([CodingShareView_Item itemWidth] - 2*padding_button);
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
    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:[NSString stringWithFormat:@"umeng_social_%@", _snsName]];
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
