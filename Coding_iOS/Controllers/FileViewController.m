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
#import "WebContentManager.h"
#import <MMMarkdown/MMMarkdown.h>

@interface FileViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIDocumentInteractionControllerDelegate, UIWebViewDelegate>
@property (strong, nonatomic) NSURL *fileUrl;
@property (strong, nonatomic) QLPreviewController *previewController;
@property (strong, nonatomic) FileDownloadView *downloadView;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@property (strong, nonatomic) UIWebView *contentWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.curFile.name;
    if ([self.curFile isEmpty]) {
        [self requestFileData];
    }else{
        [self configContent];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
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
    self.title = self.curFile.name;
    NSURL *fileUrl = [self.curFile hasBeenDownload];
    
    if (!fileUrl ) {
        [self showDownloadView];
        return;
    }
    
    self.fileUrl = fileUrl;
    [self setupDocumentControllerWithURL:fileUrl];
    
    if ([self.curFile.fileType isEqualToString:@"md"]
        || [self.curFile.fileType isEqualToString:@"html"]
        || [self.curFile.fileType isEqualToString:@"txt"]
        || [self.curFile.fileType isEqualToString:@"plist"]){
        [self loadWebView:fileUrl];
    }else if ([QLPreviewController canPreviewItem:fileUrl]) {
        [self showDiskFile:fileUrl];
    }else {
        [self showDownloadView];
    }
}


- (void)showDiskFile:(NSURL *)fileUrl{
    if (self.downloadView) {
        self.downloadView.hidden = YES;
    }
    
    QLPreviewController* preview = [[QLPreviewController alloc] init];
    preview.dataSource = self;
    preview.delegate = self;
    
    [self.view addSubview:preview.view];
    [preview.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.previewController = preview;
}

- (void)loadWebView:(NSURL *)fileUrl{
    if (self.downloadView) {
        self.downloadView.hidden = YES;
    }
    
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
    }
    if ([self.curFile.fileType isEqualToString:@"md"]){
        NSError  *error = nil;
        NSString *htmlStr;
        @try {
            NSString *mdStr = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:&error];
            htmlStr = [MMMarkdown HTMLStringWithMarkdown:mdStr error:&error];
        }
        @catch (NSException *exception) {
            htmlStr = @"加载失败！";
        }
        
        if (error) {
            htmlStr = @"加载失败！";
        }
        NSString *contentStr = [WebContentManager markdownPatternedWithContent:htmlStr];
        [self.contentWebView loadHTMLString:contentStr baseURL:nil];
    }else if ([self.curFile.fileType isEqualToString:@"html"]){
        NSString* htmlString = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:nil];
        [self.contentWebView loadHTMLString:htmlString baseURL:nil];
    }else if ([self.curFile.fileType isEqualToString:@"plist"]
              || [self.curFile.fileType isEqualToString:@"txt"]){
        NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
        [self.contentWebView loadData:fileData MIMEType:@"text/text" textEncodingName:@"UTF-8" baseURL:nil];
    }else{
        [self.contentWebView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
    }
}

- (void)showDownloadView{
    if (!self.downloadView) {
        self.downloadView = [[FileDownloadView alloc] initWithFrame:self.view.bounds];
        self.downloadView.file = self.curFile;
        [self.view addSubview:self.downloadView];
        [self.downloadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    __weak typeof(self) weakSelf = self;
    self.downloadView.hidden = NO;
    self.downloadView.completionBlock = ^(){
        [weakSelf configContent];
    };
    self.downloadView.goToFileBlock = ^(ProjectFile *file){
        [weakSelf.docInteractionController presentOpenInMenuFromBarButtonItem:weakSelf.navigationItem.rightBarButtonItem animated:YES];
    };
}

- (void)setupDocumentControllerWithURL:(NSURL *)url{
    if (self.docInteractionController == nil){
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    }else{
        self.docInteractionController.URL = url;
    }
    [self setupNavigationItem];
}

- (void)setupNavigationItem{
    if (self.fileUrl) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)] animated:NO];
    }else{
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

- (void)rightNavBtnClicked{
    __weak typeof(self) weakSelf = self;
    if (self.curFile.preview && self.curFile.preview.length > 0) {
        
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"保存到相册", @"用其他应用打开"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            switch (index) {
                case 0:
                    [weakSelf saveCurImg];
                    break;
                case 1:
                    [weakSelf.docInteractionController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
                    break;
                default:
                    break;
            }
        }];
        [actionSheet showInView:kKeyWindow];
    }else{
        [self.docInteractionController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    }
}

- (void)saveCurImg{
    SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.fileUrl]];
    if (!image) {
        [self showHudTipStr:@"提取图片失败"];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(image, self,selectorToCall, NULL);
}

- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        [self showHudTipStr:@"成功保存到相册"];
    } else {
        [self showHudTipStr:@"保存失败"];
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
    NSLog(@"strLink=[%@]",request.URL.absoluteString);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_activityIndicator stopAnimating];
    if ([self.curFile.fileType isEqualToString:@"plist"]
        || [self.curFile.fileType isEqualToString:@"txt"]){
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 3.0;"];
    }else if ([self.curFile.fileType isEqualToString:@"html"]){
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 2.0;"];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if([error code] == NSURLErrorCancelled)
        return;
    else{
        DebugLog(@"%@", error.description);
        [self showError:error];
    }
}
@end




