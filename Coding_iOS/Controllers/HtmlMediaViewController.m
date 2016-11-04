//
//  HtmlMediaViewController.m
//  Coding_iOS
//
//  Created by Ease on 2016/11/4.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "HtmlMediaViewController.h"
#import "WebContentManager.h"

@interface HtmlMediaViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) HtmlMedia *htmlMedia;
@end

@implementation HtmlMediaViewController
+ (instancetype)instanceWithHtmlMedia:(HtmlMedia *)htmlMedia title:(NSString *)title{
    HtmlMediaViewController *vc = [self new];
    vc.htmlMedia = htmlMedia;
    vc.title = title ?: @"评论详情";
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColorTableBG;
    {//用webView显示内容
        _webContentView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webContentView.delegate = self;
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
    NSString *contentStr = [WebContentManager markdownPatternedWithContent:_htmlMedia.contentOrigional];
    [self.webContentView loadHTMLString:contentStr baseURL:nil];
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

@end
