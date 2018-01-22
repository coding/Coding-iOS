//
//  FileViewController.m
//  Coding_iOS
//
//  Created by Ease on 14/12/15.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "FileViewController.h"
#import "BasicPreviewItem.h"
#import "FileDownloadView.h"
#import "Coding_NetAPIManager.h"
#import "Coding_FileManager.h"
#import "WebContentManager.h"
#import "FunctionTipsManager.h"
#import "EaseToolBar.h"

#import "FileActivitiesViewController.h"
#import "FileVersionsViewController.h"
#import "FileInfoViewController.h"
#import "FileEditViewController.h"
#import "KxMenu.h"

@interface FileViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIDocumentInteractionControllerDelegate, UIWebViewDelegate, EaseToolBarDelegate>
@property (strong, nonatomic, readwrite) ProjectFile *curFile;
@property (strong, nonatomic, readwrite) FileVersion *curVersion;


@property (strong, nonatomic) NSURL *fileUrl;
@property (strong, nonatomic) QLPreviewController *previewController;
@property (strong, nonatomic) FileDownloadView *downloadView;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@property (strong, nonatomic) UIWebView *contentWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) EaseToolBar *myToolBar;

@end

@implementation FileViewController

+ (instancetype)vcWithFile:(ProjectFile *)file andVersion:(FileVersion *)version{
    FileViewController *vc = [self new];
    vc.curFile = file;
    vc.curVersion = version;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = [self titleStr];
    if ([self.curFile isEmpty]) {
        [self requestFileData];
    }else{
        [self configContent];
    }
}

- (EaseToolBar *)myToolBar{
    if (!_myToolBar) {
        EaseToolBarItem *item1 = [EaseToolBarItem easeToolBarItemWithTitle:@" 文件动态" image:@"button_file_activity" disableImage:nil];
        EaseToolBarItem *item2 = [EaseToolBarItem easeToolBarItemWithTitle:@" 历史版本" image:@"button_file_history" disableImage:nil];
        _myToolBar = [EaseToolBar easeToolBarWithItems:@[item1, item2]];
        _myToolBar.delegate = self;
        [self.view addSubview:_myToolBar];
        [_myToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom);
            make.size.mas_equalTo(_myToolBar.frame.size);
        }];
    }
    return _myToolBar;
}

- (void)requestFileData{
    [self.view beginLoading];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_FileDetail:self.curFile andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];

        if (data) {
            weakSelf.curFile = data;
            [weakSelf configContent];
        }else{
            if (error.code == 1304) {
                [weakSelf.view configBlankPage:EaseBlankPageTypeFileDleted hasData:NO hasError:NO reloadButtonBlock:nil];
            }else{
                [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:NO hasError:(error != nil) reloadButtonBlock:^(id sender) {
                    [weakSelf requestFileData];
                }];
            }
        }
    }];
}

- (void)configContent{
    self.title = [self titleStr];
    [self setupNavigationItem];

    NSURL *fileUrl = [self diskFileUrl];
    if (!fileUrl) {
        [self showDownloadView];
    }else{
        self.fileUrl = fileUrl;
        [self setupDocumentControllerWithURL:fileUrl];
        if ([self.fileType isEqualToString:@"md"]
            || [self.fileType isEqualToString:@"html"]
            || [self.fileType isEqualToString:@"txt"]
            || [self.fileType isEqualToString:@"plist"]){
            [self loadWebView:fileUrl];
        }else if ([QLPreviewController canPreviewItem:fileUrl]) {
            [self showDiskFile:fileUrl];
        }else if (!_downloadView || _downloadView.hidden) {
            [self showDownloadView];
        }
    }
    if (_curVersion) {
        _myToolBar.hidden = YES;
    }else{
        self.myToolBar.hidden = NO;
    }
}


- (void)showDiskFile:(NSURL *)fileUrl{
    self.downloadView.hidden = self.contentWebView.hidden = YES;
    if (!self.previewController) {
        QLPreviewController* preview = [[QLPreviewController alloc] init];
        preview.dataSource = self;
        preview.delegate = self;
        if ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending) {
            [self addChildViewController:preview];
            [preview didMoveToParentViewController:self];
        }
        [self.view addSubview:preview.view];
        [preview.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-[self toolBarHeight]);
        }];
        self.previewController = preview;
    }
    self.previewController.view.hidden = NO;
}

- (void)loadWebView:(NSURL *)fileUrl{
    self.downloadView.hidden = self.previewController.view.hidden = YES;
    
    if (!_contentWebView) {
        //用webView显示内容
        _contentWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _contentWebView.delegate = self;
        _contentWebView.backgroundColor = [UIColor clearColor];
        _contentWebView.opaque = NO;
        _contentWebView.scalesPageToFit = YES;
        //webview加载指示
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        [_activityIndicator setCenter:CGPointMake(CGRectGetWidth(_contentWebView.frame)/2, CGRectGetHeight(_contentWebView.frame)/2)];
        [_contentWebView addSubview:_activityIndicator];
        [self.view addSubview:_contentWebView];
        [_contentWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-[self toolBarHeight]);
        }];
    }
    if ([self.fileType isEqualToString:@"md"]){
        NSString *mdStr = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:nil];
        [self.activityIndicator startAnimating];
        [[Coding_NetAPIManager sharedManager] request_MDHtmlStr_WithMDStr:mdStr inProject:nil andBlock:^(id data, NSError *error) {
            NSString *htmlStr;
            htmlStr = data? data: @"加载失败";
            NSString *contentStr = [WebContentManager markdownPatternedWithContent:htmlStr];
            [self.contentWebView loadHTMLString:contentStr baseURL:nil];
        }];
    }else if ([self.fileType isEqualToString:@"html"]){
        NSString* htmlString = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:nil];
        [self.contentWebView loadHTMLString:htmlString baseURL:nil];
    }else if ([self.fileType isEqualToString:@"plist"]
              || [self.fileType isEqualToString:@"txt"]){
        NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
        [self.contentWebView loadData:fileData MIMEType:@"text/text" textEncodingName:@"UTF-8" baseURL:fileUrl];
    }else{
        [self.contentWebView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
    }
    self.contentWebView.hidden = NO;
}

- (void)showDownloadView{
    self.contentWebView.hidden = self.previewController.view.hidden = YES;
    if (!self.downloadView) {
        self.downloadView = [[FileDownloadView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.downloadView];
        [self.downloadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-[self toolBarHeight]);
        }];
    }
    
    self.downloadView.file = self.curFile;
    self.downloadView.version = self.curVersion;
    [self.downloadView reloadData];
    
    __weak typeof(self) weakSelf = self;
    self.downloadView.completionBlock = ^(){
        [weakSelf configContent];
    };
    self.downloadView.otherMethodOpenBlock = ^(){
        [weakSelf openByOtherApp];
    };
    self.downloadView.hidden = NO;
}

- (void)setupDocumentControllerWithURL:(NSURL *)url{
    if (self.docInteractionController == nil){
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    }else{
        self.docInteractionController.URL = url;
    }
    [self setupNavigationItem];
}

#pragma mark nav M
- (void)setupNavigationItem{
    if (!self.curVersion ||
        (self.curVersion && self.fileUrl)) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)] animated:NO];
    }else{
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
}

- (void)rightNavBtnClicked{
    __weak typeof(self) weakSelf = self;
    if (!_curVersion) {
        if ([KxMenu isShowingInView:self.view]) {
            [KxMenu dismissMenu:YES];
        }else{
            [KxMenu setTitleFont:[UIFont systemFontOfSize:15]];
            [KxMenu setTintColor:[UIColor whiteColor]];
            [KxMenu setLineColor:kColorDDD];
            
            NSMutableArray *menuItems = [@[
                                          [KxMenuItem menuItem:@"共享链接" image:[UIImage imageNamed:@"file_menu_icon_share"] target:self action:@selector(goToShareFileLink)],
                                          [KxMenuItem menuItem:@"文件信息" image:[UIImage imageNamed:@"file_menu_icon_info"] target:self action:@selector(goToFileInfo)],
                                          [KxMenuItem menuItem:@"删除文件" image:[UIImage imageNamed:@"file_menu_icon_delete"] target:self action:@selector(deleteCurFile)],
                                          ] mutableCopy];
            if ([self fileCanEdit]) {
                [menuItems insertObject:[KxMenuItem menuItem:@"编辑文件" image:[UIImage imageNamed:@"file_menu_icon_edit"] target:self action:@selector(goToEditFile)]
                                atIndex:0];
            }else if (self.preview.length > 0 && self.fileUrl){
                [menuItems insertObject:[KxMenuItem menuItem:@"保存到相册" image:[UIImage imageNamed:@"file_menu_icon_edit"] target:self action:@selector(saveCurImg)]
                                atIndex:0];
            }
            if (self.fileUrl) {
                [menuItems addObject:[KxMenuItem menuItem:@"其它应用打开" image:[UIImage imageNamed:@"file_menu_icon_open"] target:self action:@selector(openByOtherApp)]];
            }
            [menuItems setValue:kColorDark4 forKey:@"foreColor"];
            CGRect senderFrame = CGRectMake(kScreen_Width - (kDevice_Is_iPhone6Plus? 30: 26), 0, 0, 0);
            [KxMenu showMenuInView:self.view
                          fromRect:senderFrame
                         menuItems:menuItems];
        }
    }else{
        if (self.preview.length > 0) {
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"保存到相册", @"用其他应用打开"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                switch (index) {
                    case 0:
                        [weakSelf saveCurImg];
                        break;
                    case 1:
                        [weakSelf openByOtherApp];
                        break;
                    default:
                        break;
                }
            }];
            [actionSheet showInView:self.view];
        }else{
            [self openByOtherApp];
        }
    }
}

- (void)goToEditFile{
    __weak typeof(self) weakSelf = self;
    FileEditViewController *vc = [FileEditViewController new];
    vc.curFile = _curFile;
    vc.completeBlock = ^(){
        [weakSelf requestFileData];
        if (weakSelf.fileHasChangedBlock) {
            weakSelf.fileHasChangedBlock();
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToShareFileLink{
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet;
    if (_curFile.share) {
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
    if (_curFile.share) {
        [[UIPasteboard generalPasteboard] setString:_curFile.share.url];
        [NSObject showHudTipStr:@"链接已拷贝到粘贴板"];
    }else{
        [NSObject showHudTipStr:@"文件还未打开共享"];
    }
}

- (void)doOpenAndCopyShareUrl{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_OpenShareOfFile:_curFile andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curFile.share = [FileShare instanceWithUrl:data];
            [weakSelf doCopyShareUrl];
        }
    }];
}

- (void)doCloseShareUrl{
    NSString *hashStr = [[_curFile.share.url componentsSeparatedByString:@"/"] lastObject];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CloseFileShareHash:hashStr andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.curFile.share = nil;
            [NSObject showHudTipStr:@"共享链接已关闭"];
        }
    }];
}


- (void)goToFileInfo{
    FileInfoViewController *vc = [FileInfoViewController vcWithFile:_curFile];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteCurFile{
    UIActionSheet *actionSheet;
    NSURL *fileUrl = [_curFile diskFileUrl];
    Coding_DownloadTask *cDownloadTask = [_curFile cDownloadTask];

    if (fileUrl) {
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"只是删除本地文件还是连同服务器文件一起删除？" buttonTitles:@[@"仅删除本地文件"] destructiveTitle:@"一起删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            switch (index) {
                case 0:
                    [self doDeleteCurFile:self.curFile fromDisk:YES];
                    break;
                case 1:
                    [self doDeleteCurFile:self.curFile fromDisk:NO];
                    break;
                default:
                    break;
            }
        }];
    }else if (cDownloadTask){
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定将服务器上的该文件删除？" buttonTitles:@[@"只是取消下载"] destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            switch (index) {
                case 0:
                    [self doDeleteCurFile:self.curFile fromDisk:YES];
                    break;
                case 1:
                    [self doDeleteCurFile:self.curFile fromDisk:NO];
                    break;
                default:
                    break;
            }
        }];
    }else{
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定将服务器上的该文件删除？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [self doDeleteCurFile:self.curFile fromDisk:NO];
            }
        }];
    }
    [actionSheet showInView:self.view];
}

- (void)doDeleteCurFile:(ProjectFile *)file fromDisk:(BOOL)fromDisk{
    //    取消当前的下载任务
    Coding_DownloadTask *cDownloadTask = [file cDownloadTask];
    if (cDownloadTask) {
        [Coding_FileManager cancelCDownloadTaskForKey:file.storage_key];
    }
    //    删除本地文件
    NSURL *fileUrl = [file diskFileUrl];
    NSString *filePath = fileUrl.path;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSError *fileError;
        [fm removeItemAtPath:filePath error:&fileError];
        if (fileError) {
            [NSObject showError:fileError];
        }else if (fromDisk){
            [self.navigationController popViewControllerAnimated:YES];
            if (self.fileHasBeenDeletedBlock) {
                self.fileHasBeenDeletedBlock();
            }
        }
    }
    //    删除服务器文件
    if (!fromDisk) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_DeleteFiles:@[file.file_id] inProject:self.curFile.project_id andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
                if (weakSelf.fileHasBeenDeletedBlock) {
                    weakSelf.fileHasBeenDeletedBlock();
                }
            }
        }];
    }
}


- (void)openByOtherApp{
    [self.docInteractionController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)saveCurImg{
    SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.fileUrl]];
    if (!image) {
        [NSObject showHudTipStr:@"提取图片失败"];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(image, self, selectorToCall, NULL);
}

- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        [NSObject showHudTipStr:@"成功保存到相册"];
    } else {
        [NSObject showHudTipStr:@"保存失败"];
    }
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    NSInteger num = 0;
    if (self.fileUrl) {
        num = 1;
    }
    return num;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    return [BasicPreviewItem itemWithUrl:self.fileUrl];
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    DebugLog(@"strLink=[%@]",request.URL.absoluteString);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_activityIndicator stopAnimating];
    if ([self.fileType isEqualToString:@"plist"]
        || [self.fileType isEqualToString:@"txt"]){
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 3.0;"];
    }else if ([self.fileType isEqualToString:@"html"]){
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 2.0;"];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if([error code] == NSURLErrorCancelled)
        return;
    else{
        DebugLog(@"%@", error.description);
        [NSObject showError:error];
    }
}

#pragma mark EaseToolBarDelegate
- (void)easeToolBar:(EaseToolBar *)toolBar didClickedIndex:(NSInteger)index{
    if (index == 0) {
        FileActivitiesViewController *vc = [FileActivitiesViewController vcWithFile:_curFile];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (index == 1){
        FileVersionsViewController *vc = [FileVersionsViewController vcWithFile:_curFile];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark Data Value
- (NSURL *)diskFileUrl{
    NSURL *fileUrl;
    if (self.curVersion) {
        fileUrl = [self.curVersion diskFileUrl];
    }else{
        fileUrl = [self.curFile diskFileUrl];
    }
    return fileUrl;
}
- (NSString *)fileType{
    if (_curVersion) {
        return _curVersion.fileType;
    }else{
        return _curFile.fileType;
    }
}
- (NSString *)preview{
    if (_curVersion) {
        return _curVersion.preview;
    }else{
        return _curFile.preview;
    }
}
- (NSString *)titleStr{
    if (_curVersion) {
        return _curVersion.remark;
    }else{
        return _curFile.name;
    }
}
- (CGFloat)toolBarHeight{
    if (_curVersion) {
        return 0;
    }else{
        return 49.0;
    }
}
- (BOOL)fileCanEdit{
    NSArray *supportTypeList = @[@"md", @"txt"];
    if ([supportTypeList containsObject:_curFile.fileType]) {
        return YES;
    }else{
        return NO;
    }
}
@end




