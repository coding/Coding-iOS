//
//  FileChangeDetailViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileChangeDetailViewController.h"
#import "Coding_NetAPIManager.h"
#import "WebContentManager.h"


@interface FileChangeDetailViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end


@implementation FileChangeDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [[self.filePath componentsSeparatedByString:@"/"] lastObject];
    
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
    
    NSString *contentStr = [WebContentManager diffPatternedWithContent:[self requestPathParams]];
    [self.webContentView loadHTMLString:contentStr baseURL:nil];
    
    
    //    [self sendRequest];
}

- (NSString *)requestPathParams{
    NSString *requestPathParams = [NSString stringWithFormat:@"%@%@", kNetPath_Code_Base, self.requestPath];
    
    if (self.requestParams.count > 0) {
        NSMutableArray *paramsArray = [NSMutableArray new];
        [self.requestParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            [paramsArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }];
        
        NSString *paramsStr = [paramsArray componentsJoinedByString:@"&"];
        requestPathParams = [NSString stringWithFormat:@"%@?%@", requestPathParams, paramsStr];
    }
    return requestPathParams;
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
    [[Coding_NetAPIManager sharedManager] request_FileLineChanges_WithPath:self.requestPath params:self.requestParams andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        [weakSelf refreshViewWithData:data];
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(data != nil) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf sendRequest];
        }];
    }];
}

- (void)refreshViewWithData:(id)data{
    
    if (!data) {
        return;
    }
    NSDictionary *resultData = data;
//    NSArray *resultA = [NSObject arrayFromJSON:[resultData valueForKeyPath:@"data"] ofObjects:@"FileLineChange"];
    
    NSString *contentStr = [WebContentManager markdownPatternedWithContent:resultData.description];
    [self.webContentView loadHTMLString:contentStr baseURL:nil];
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
