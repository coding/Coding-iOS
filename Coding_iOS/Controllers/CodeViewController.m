//
//  CodeViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "CodeViewController.h"
#import "Coding_NetAPIManager.h"
#import "WebContentManager.h"

@interface CodeViewController ()
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation CodeViewController

+ (CodeViewController *)codeVCWithProject:(Project *)project andCodeFile:(CodeFile *)codeFile{
    CodeViewController *vc = [[CodeViewController alloc] init];
    vc.myProject = project;
    vc.myCodeFile = codeFile;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [[_myCodeFile.path componentsSeparatedByString:@"/"] lastObject];
    
    {
        //用webView显示内容
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
    [self sendRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark Request

- (void)sendRequest{
    [self.view beginLoading];
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CodeFile:_myCodeFile withPro:_myProject andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        if (data) {
            weakSelf.myCodeFile = data;
            [weakSelf refreshCodeViewData];
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(data != nil) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf sendRequest];
        }];
    }];
}

- (void)refreshCodeViewData{
    if ([_myCodeFile.file.mode isEqualToString:@"image"]) {
        NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@u/%@/p/%@/git/raw/%@/%@", kNetPath_Code_Base, _myProject.owner_user_name, _myProject.name, _myCodeFile.ref, _myCodeFile.file.path]];
        DebugLog(@"imageUrl: %@", imageUrl);
        [self.webContentView loadRequest:[NSURLRequest requestWithURL:imageUrl]];
    }else if ([_myCodeFile.file.mode isEqualToString:@"file"]){
        NSString *contentStr = [WebContentManager codePatternedWithContent:_myCodeFile];
        [self.webContentView loadHTMLString:contentStr baseURL:nil];
    }
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
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if([error code] == NSURLErrorCancelled)
        return;
    else
        DebugLog(@"%@", error.description);
}



@end
