//
//  LocalFileViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/9/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import "LocalFileViewController.h"
#import "Coding_NetAPIManager.h"
#import "WebContentManager.h"
#import "BasicPreviewItem.h"

@interface LocalFileViewController ()<QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIDocumentInteractionControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) QLPreviewController *previewController;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@property (strong, nonatomic) UIWebView *contentWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSString *fileName, *fileType;

@end

@implementation LocalFileViewController

- (void)setFileUrl:(NSURL *)fileUrl{
    _fileUrl = fileUrl;
    if (_fileUrl.path.length > 0) {
        NSArray *valueList = [[[self.fileUrl.path componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"|||"];
        _fileName = valueList[0];
        _fileType = [[[_fileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
    }
}

- (UIDocumentInteractionController *)docInteractionController{
    if (_docInteractionController == nil){
        _docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.fileUrl];
    }
    return _docInteractionController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.fileName;
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)] animated:NO];

    if ([self.fileType isEqualToString:@"md"]
        || [self.fileType isEqualToString:@"html"]
        || [self.fileType isEqualToString:@"txt"]
        || [self.fileType isEqualToString:@"plist"]){
        [self loadWebView:self.fileUrl];
    }else if ([QLPreviewController canPreviewItem:self.fileUrl]) {
        [self showDiskFile:self.fileUrl];
    }else {
        [self.view configBlankPage:EaseBlankPageTypeFileTypeCannotSupport hasData:NO hasError:NO reloadButtonBlock:nil];
    }
}
- (void)rightNavBtnClicked{
    [self openByOtherApp];
}

- (void)openByOtherApp{
    [self.docInteractionController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

#pragma mark HandleData
- (void)loadWebView:(NSURL *)fileUrl{
    self.previewController.view.hidden = YES;
    
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
            make.top.left.right.bottom.equalTo(self.view);
        }];
    }
    if ([self.fileType isEqualToString:@"md"]){
        NSString *mdStr = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:nil];
        [self.activityIndicator startAnimating];
        [[Coding_NetAPIManager sharedManager] request_MDHtmlStr_WithMDStr:mdStr inProject:nil andBlock:^(id data, NSError *error) {
            [self.activityIndicator stopAnimating];
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

- (void)showDiskFile:(NSURL *)fileUrl{
    self.contentWebView.hidden = YES;
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
            make.top.left.right.bottom.equalTo(self.view);
        }];
        self.previewController = preview;
    }
    self.previewController.view.hidden = NO;
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

@end
