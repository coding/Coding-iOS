//
//  EALocalCodeViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/28.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EALocalCodeViewController.h"
#import "WebContentManager.h"

@interface EALocalCodeViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation EALocalCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _curURL.lastPathComponent;
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
    [self loadData];
}

- (void)loadData{
    if ([_curURL isTextData]) {
        CodeFile *file = [CodeFile codeFileWithLocalURL:_curURL];
        NSString *codeStr = [WebContentManager codePatternedWithContent:file isEdit:NO];
        [self.webContentView loadHTMLString:codeStr baseURL:nil];
    }else{
        [self.webContentView loadRequest:[NSURLRequest requestWithURL:_curURL]];
    }
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
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
    [_activityIndicator stopAnimating];
    if (error.code == NSURLErrorCancelled) {
        NSLog(@"Canceled request: %@", webView.request.URL);
    }else if ([error.domain isEqualToString:@"WebKitErrorDomain"] && (error.code == 102 || error.code == 204)) {
        NSLog(@"ignore: %@", error);
    }else {
        [NSObject showError:error];
    }
}

@end
