//
//  WikiViewController.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/4/5.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "WikiViewController.h"
#import "Coding_NetAPIManager.h"
#import "WebContentManager.h"
#import "ODRefreshControl.h"
#import "WikiMenuListView.h"
#import "WikiHistoryListViewController.h"
#import "WikiEditViewController.h"
#import "WikiHeaderView.h"
#import "FunctionTipsManager.h"
#import "MartFunctionTipView.h"
#import "KxMenu.h"

@interface WikiViewController ()<UIWebViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@property (strong, nonatomic) NSNumber *iid, *version;
@property (strong, nonatomic) EAWiki *curWiki;
@property (strong, nonatomic) NSArray *wikiList;

@property (strong, nonatomic) WikiHeaderView *headerV;
@property (strong, nonatomic) WikiFooterView *footerV;

@property (strong, nonatomic) WikiMenuListView *menuListV;

@property (assign, nonatomic) BOOL isShowingFunctionTip;
@end

@implementation WikiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColorTableBG;
    self.title = _myProject.name;
    _version = _version ?: @(-1);
    {//用webView显示内容
        _webContentView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webContentView.delegate = self;
        _webContentView.scrollView.delegate = self;
        _webContentView.backgroundColor = [UIColor clearColor];
        _webContentView.opaque = NO;
        _webContentView.scalesPageToFit = YES;
        [self.view addSubview:_webContentView];
        //webview加载指示
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        [_activityIndicator setCenter:CGPointMake(CGRectGetWidth(_webContentView.frame)/2, CGRectGetHeight(_webContentView.frame)/2)];
        [_webContentView addSubview:_activityIndicator];
        [_webContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.webContentView.scrollView];
    [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [self addGesture];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)] animated:NO];
}

- (void)setCurWiki:(EAWiki *)curWiki{
    _curWiki = curWiki;
    if (_curWiki) {
        _iid = _curWiki.iid ?: _iid;
    }else{
        _iid = nil;
    }
    if (!_headerV) {
        _headerV = [WikiHeaderView new];
        [_webContentView.scrollView addSubview:_headerV];
    }
    if (!_footerV) {
        __weak typeof(self) weakSelf = self;
        _footerV = [WikiFooterView new];
        [self.view addSubview:_footerV];
        _footerV.buttonClickedBlock = ^(NSInteger index){
            [weakSelf handleFooterIndex:index];
        };
        _footerV.y = self.view.height - _footerV.height;
    }
    _headerV.curWiki = _footerV.curWiki = _curWiki;
    _webContentView.scrollView.contentInset = UIEdgeInsetsMake(_headerV.height, 0, _footerV.height, 0);
    
//    //新功能提示
//    [self showMenuTip];
}

- (void)setWikiIid:(NSNumber *)iid version:(NSNumber *)version{
    _iid = iid;
    _version = version;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self refreshWikiList];
}

#pragma mark Gesture
- (void)addGesture{
    UISwipeGestureRecognizer *swipeG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuListV)];
    swipeG.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeG];
}

#pragma mark Tip

//- (void)showMenuTip{
//    if (_footerV.menuBtnList.count < 3 ||
//        ![[FunctionTipsManager shareManager] needToTip:kFunctionTipStr_WikiMenu] ||
//        _isShowingFunctionTip) {
//        return;
//    }
//    
//    UIButton *originBtn = _footerV.menuBtnList[0];
//    CGRect fromFrame = [originBtn convertRect:originBtn.frame toView:self.view];
//    fromFrame.origin.y -= 3;
//    
//    _isShowingFunctionTip = YES;
//    __weak typeof(self) weakSelf = self;
//    [MartFunctionTipView showText:@"这里可查看页面目录" direction:AMPopTipDirectionUp  bubbleOffset:35 inView:self.view fromFrame:fromFrame dismissHandler:^{
//        weakSelf.isShowingFunctionTip = NO;
//        [[FunctionTipsManager shareManager] markTiped:kFunctionTipStr_WikiMenu];
//        [weakSelf showHistoryTip];
//    }];
//}
//
//- (void)showHistoryTip{
//    if (_footerV.menuBtnList.count < 3 ||
//        ![[FunctionTipsManager shareManager] needToTip:kFunctionTipStr_WikiHistory] ||
//        _isShowingFunctionTip) {
//        return;
//    }
//    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:@"Wiki_点击历史版本"];
//
//    UIButton *originBtn = _footerV.menuBtnList[1];
//    CGRect fromFrame = [originBtn convertRect:originBtn.frame toView:self.view];
//    fromFrame.origin.y -= 3;
//
//    _isShowingFunctionTip = YES;
//    __weak typeof(self) weakSelf = self;
//    [MartFunctionTipView showText:@"这里可查看历史版本" direction:AMPopTipDirectionUp  bubbleOffset:-35 inView:self.view fromFrame:fromFrame dismissHandler:^{
//        weakSelf.isShowingFunctionTip = NO;
//        [[FunctionTipsManager shareManager] markTiped:kFunctionTipStr_WikiHistory];
//    }];
//}

#pragma refresh Data

- (void)refresh{
    if (_wikiList) {
        [self refreshWikiList];
    }else{
        [self refreshWikiDetail];
    }
    if (![_myProject.id isKindOfClass:[NSNumber class]]) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:_myProject andBlock:^(id data, NSError *error) {
            if (data) {
                weakSelf.myProject = data;
            }
        }];
    }
}

- (void)refreshWikiList{
    if (!_curWiki) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_WikiListWithPro:_myProject andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.wikiList = data;
        }
        if (weakSelf.wikiList.count > 0) {
            weakSelf.iid = weakSelf.iid ?: [(EAWiki *)weakSelf.wikiList.firstObject iid];
            [weakSelf refreshWikiDetail];
        }else{
            [weakSelf doSomethingWithError:error];
        }
    }];
}

- (void)refreshWikiDetail{
    if (!_curWiki) {
        [self.view beginLoading];
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_WikiDetailWithPro:_myProject iid:_iid version:_version andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curWiki = data;
        }
        [weakSelf doSomethingWithError:error];
    }];
}

- (void)doSomethingWithError:(NSError *)error{
    [self.view endLoading];
    [self.myRefreshControl endRefreshing];
    
    NSString *contentStr = [WebContentManager wikiPatternedWithContent:_curWiki.html];
    [self.webContentView loadHTMLString:contentStr baseURL:nil];
    
    BOOL hasError = (error != nil && !_curWiki);
    [self.view configBlankPage:EaseBlankPageTypeWiki hasData:(_curWiki != nil) hasError:hasError reloadButtonBlock:^(id sender) {
        [self refresh];
    }];
    self.webContentView.hidden = hasError;
}

#pragma mark Footer Action

- (void)handleFooterIndex:(NSInteger)index{
    if (_curWiki.isHistoryVersion) {//恢复版本
        __weak typeof(self) weakSelf = self;
        [[UIActionSheet bk_actionSheetCustomWithTitle:@"确定要恢复到当前版本吗？" buttonTitles:@[@"确认恢复"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf revertWiki];
            }
        }] showInView:self.view];
    }else{
        if (index == 1) {//编辑
            WikiEditViewController *vc = [WikiEditViewController new];
            vc.curWiki = _curWiki;
            vc.myProject = _myProject;
            [self.navigationController pushViewController:vc animated:YES];
        }else if (index == 2){//查看历史版本
            WikiHistoryListViewController *vc = [WikiHistoryListViewController new];
            vc.curWiki = _curWiki;
            vc.myProject = _myProject;
            [self.navigationController pushViewController:vc animated:YES];
        }else{//目录
            [self showMenuListV];
        }
    }
}

- (void)showMenuListV{
    if (!_wikiList || !_curWiki) {
        return;
    }
    if (!_menuListV) {
        _menuListV = [WikiMenuListView new];
        __weak typeof(self) weakSelf = self;
        _menuListV.selectedWikiBlock = ^(EAWiki *wiki){
            [MobClick event:kUmeng_Event_Request_ActionOfLocal label:@"Wiki_点击目录"];
            
            weakSelf.curWiki = wiki;
            [weakSelf refreshWikiDetail];
        };
    }
    [_menuListV setWikiList:_wikiList selectedWiki:_curWiki];
    [_menuListV show];
}

- (void)revertWiki{
    __weak typeof(self) weakSelf = self;
    [NSObject showHUDQueryStr:@"请稍等..."];
    [[Coding_NetAPIManager sharedManager] request_RevertWiki:_iid toVersion:_version pro:_myProject andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"设置成功"];
            
            UINavigationController *nav = weakSelf.navigationController;
            for (NSInteger index = nav.viewControllers.count - 2; index >= 0; index--) {
                UIViewController *vc = nav.viewControllers[index];
                if ([vc isKindOfClass:[WikiViewController class]]) {
                    [nav popToViewController:vc animated:YES];
                    break;
                }
            }
        }
    }];
}

#pragma mark UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_isShowingFunctionTip) {
        return;
    }
    if (scrollView.contentSize.height <= CGRectGetHeight(scrollView.bounds)-50) {
        [self hideFooterV:NO];
        return;
    }else if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
        [self hideFooterV:velocity.y < 0];
    }
}

- (void)hideFooterV:(BOOL)hide{
    static BOOL isAnimating = NO;
    CGFloat footerY = self.view.height - (hide? 0: _footerV.height);
    if (fabs(_footerV.y - footerY) > .1 && !isAnimating) {
        isAnimating = YES;
        [UIView animateWithDuration:.3 animations:^{
            _footerV.y = footerY;
        } completion:^(BOOL finished) {
            isAnimating = NO;
        }];
    }
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    DebugLog(@"strLink=[%@]",request.URL.absoluteString);
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:request.URL.absoluteString];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_activityIndicator stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if([error code] == NSURLErrorCancelled)
        return;
    else
        DebugLog(@"%@", error.description);
}

#pragma mark nav
- (void)rightNavBtnClicked{
    if ([KxMenu isShowingInView:self.view]) {
        [KxMenu dismissMenu:YES];
    }else{
        [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
        [KxMenu setTintColor:[UIColor whiteColor]];
        [KxMenu setLineColor:kColorDDD];
        
        NSMutableArray *menuItems = [@[
                                       [KxMenuItem menuItem:@"共享链接" image:[UIImage imageNamed:@"wiki_menu_icon_share"] target:self action:@selector(goToShareFileLink)],
                                       [KxMenuItem menuItem:@"删除文件" image:[UIImage imageNamed:@"wiki_menu_icon_delete"] target:self action:@selector(showDeleteWikiTip)],
                                       ] mutableCopy];
        [menuItems setValue:kColor222 forKey:@"foreColor"];
        CGRect senderFrame = CGRectMake(kScreen_Width - (kDevice_Is_iPhone6Plus? 30: 26), 5, 0, 0);
        [KxMenu showMenuInView:self.view
                      fromRect:senderFrame
                     menuItems:menuItems];
    }
}

- (void)goToShareFileLink{
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet;
    if (_curWiki.share) {
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"该链接适用于所有人，无需登录" buttonTitles:@[@"拷贝链接"] destructiveTitle:@"关闭共享" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf doCopyShareUrl];
            }else if (index == 1) {
                [weakSelf doCloseShareUrl];
            }
        }];
    }else{
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"当前未开启共享，请先创建公开链接" buttonTitles:@[@"开启共享并拷贝链接"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf doOpenAndCopyShareUrl];
            }
        }];
    }
    [actionSheet showInView:self.view];
}

- (void)doCopyShareUrl{
    if (_curWiki.share) {
        [[UIPasteboard generalPasteboard] setString:_curWiki.share.url];
        [NSObject showHudTipStr:@"链接已拷贝到粘贴板"];
    }else{
        [NSObject showHudTipStr:@"文件还未打开共享"];
    }
}

- (void)doOpenAndCopyShareUrl{
    _curWiki.project_id = _myProject.id;
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_OpenShareOfWiki:_curWiki andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curWiki.share = [FileShare instanceWithUrl:data];
            [weakSelf doCopyShareUrl];
        }
    }];
}

- (void)doCloseShareUrl{
    NSString *hashStr = [[_curWiki.share.url componentsSeparatedByString:@"/"] lastObject];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CloseWikiShareHash:hashStr andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curWiki.share = nil;
            [NSObject showHudTipStr:@"共享链接已关闭"];
        }
    }];
}


- (void)showDeleteWikiTip{
    if (_iid) {
        __weak typeof(self) weakSelf = self;
        [[UIActionSheet bk_actionSheetCustomWithTitle:@"确定要删除 Wiki 文档吗？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf deleteWiki];
            }
        }] showInView:self.view];
    }
}

- (void)deleteWiki{
    __weak typeof(self) weakSelf = self;
    [NSObject showHUDQueryStr:@"请稍等..."];
    [[Coding_NetAPIManager sharedManager] request_DeleteWikiWithPro:_myProject iid:_iid andBlock:^(id data, NSError *error) {
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"删除成功"];
            weakSelf.curWiki = nil;
            [weakSelf refreshWikiList];
        }
    }];
}

@end

#pragma mark WikiFooterView

@interface WikiFooterView ()
@property (strong, nonatomic) UIButton *revertBtn;
@property (readwrite, strong, nonatomic) NSMutableArray<UIButton *> *menuBtnList;
@end

@implementation WikiFooterView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, kScreen_Width, 49);
        self.backgroundColor = kColorNavBG;
        [self addLineUp:YES andDown:NO];
    }
    return self;
}

- (void)setCurWiki:(EAWiki *)curWiki{
    _curWiki = curWiki;
    self.hidden = (_curWiki == nil);

    BOOL isHistoryVersion = _curWiki.isHistoryVersion;
    [_menuBtnList setValue:@(isHistoryVersion) forKey:@"hidden"];
    _revertBtn.hidden = !isHistoryVersion;
    
    __weak typeof(self) weakSelf = self;
    if (isHistoryVersion && !_revertBtn) {
        _revertBtn = [[UIButton alloc] initWithFrame:self.bounds];
        [_revertBtn bk_addEventHandler:^(id sender) {
            [weakSelf handleButtonClickedIndex:0];
        } forControlEvents:UIControlEventTouchUpInside];
        
        
        _revertBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_revertBtn setTitleColor:kColorDark3 forState:UIControlStateNormal];
        [_revertBtn setTitle:@"恢复至该版本" forState:UIControlStateNormal];
        [_revertBtn setImage:[UIImage imageNamed:@"wiki_revert"] forState:UIControlStateNormal];
        
        CGFloat padding = 16;
        _revertBtn.titleEdgeInsets = UIEdgeInsetsMake(0, padding/ 2, 0, -padding/ 2);
        _revertBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -padding/ 2, 0, padding/ 2);
        
        [self addSubview:_revertBtn];
    }else if (!isHistoryVersion && !_menuBtnList){
        _menuBtnList = @[].mutableCopy;
        NSInteger num = 3;
        CGFloat width = self.width/ num;
        CGFloat height = self.height;
        for (NSInteger index = 0; index < num; index++) {
            UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(index * width, 0, width, height)];
            [menuBtn bk_addEventHandler:^(id sender) {
                [weakSelf handleButtonClickedIndex:index];
            } forControlEvents:UIControlEventTouchUpInside];
            [menuBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"wiki_menu_%d", (int)index]] forState:UIControlStateNormal];
            [self addSubview:menuBtn];
            [_menuBtnList addObject:menuBtn];
        }
    }
}

- (void)handleButtonClickedIndex:(NSInteger)index{
    if (self.buttonClickedBlock) {
        self.buttonClickedBlock(index);
    }
}

@end
