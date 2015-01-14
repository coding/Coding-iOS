//
//  WebViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/1/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "WebViewController.h"
#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>

@interface WebViewController ()<NJKWebViewProgressDelegate, UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *myWebView;
@property (strong, nonatomic) NJKWebViewProgress *progressProxy;
@property (strong, nonatomic) NJKWebViewProgressView *progressView;
@end

@implementation WebViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"加载中...";
    
    _myWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_myWebView];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _myWebView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _progressView.progressBarView.backgroundColor = [UIColor colorWithHexString:@"0x3abd79"];
    
    [self loadCurUrl];
}

- (void)loadCurUrl{
    NSURL *curUrl;
    if (![self.curUrlStr hasPrefix:@"/"]) {
        curUrl = [NSURL URLWithString:self.curUrlStr];
    }else{
        curUrl = [NSURL URLWithString:self.curUrlStr relativeToURL:[NSURL URLWithString:kNetPath_Code_Base]];
    }

    NSURLRequest *request =[NSURLRequest requestWithURL:curUrl];
    [_myWebView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

+ (instancetype)webVCWithUrlStr:(NSString *)curUrlStr{
    WebViewController *vc = [[WebViewController alloc] init];
    vc.curUrlStr = curUrlStr;
    return vc;
}



#pragma mark NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress{
    [_progressView setProgress:progress animated:YES];
    NSString *titleStr = [_myWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (titleStr) {
        self.title = titleStr;
    }
}

@end
