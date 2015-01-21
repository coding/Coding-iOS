//
//  WebViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/1/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "WebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

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
    
    _myWebView = [[UIWebView alloc] initWithFrame:[UIView frameWithOutNav]];
    _myWebView.scalesPageToFit = YES;
    _myWebView.backgroundColor = [UIColor clearColor];

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


#pragma M UI
- (void)configLeftBarButtonItems{
    //推送过来的
    if (self.navigationItem.leftBarButtonItems.count == 1 && [self.navigationItem.leftBarButtonItem.title isEqualToString:@"关闭"]) {
        return;
    }
    
    //正常push进来的
    NSInteger preCount = self.navigationItem.leftBarButtonItems.count;
    NSInteger curCount = self.myWebView.canGoBack? 3 : 2;
    if (preCount != curCount) {
        NSMutableArray *leftBarButtonItems = [NSMutableArray array];
        
        [leftBarButtonItems addObject:[self barItemSpacer]];
        [leftBarButtonItems addObject:[self backWebButtonItem]];
        if (self.myWebView.canGoBack) {
            [leftBarButtonItems addObject:[self backVCButtonItem]];
        }
        [self.navigationItem setLeftBarButtonItems:leftBarButtonItems animated:YES];
    }
}

-(UIBarButtonItem *)backVCButtonItem{
    NSDictionary*textAttributes;
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"关闭";
    temporaryBarButtonItem.target = self;
    if ([temporaryBarButtonItem respondsToSelector:@selector(setTitleTextAttributes:forState:)]){
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:kBackButtonFontSize],
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           };
        
        [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    }
    temporaryBarButtonItem.action = @selector(goBackVC);
    return temporaryBarButtonItem;
}

-(UIBarButtonItem *)backWebButtonItem{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* buttonImage = [UIImage imageNamed:@"backBtn_Nav"];
    button.frame = CGRectMake(0, 0, 55, 30);
    [button setImage:buttonImage forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:kBackButtonFontSize];
    [button.titleLabel setMinimumScaleFactor:0.5];
    button.titleLabel.shadowOffset = CGSizeMake(0,-1);
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [button addTarget:self action:@selector(goBackWebView) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (UIBarButtonItem *)barItemSpacer{
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -10.0f;
    return space ;
}


#pragma M Action
- (void)goBackWebView{
    if (self.myWebView.canGoBack) {
        [self configLeftBarButtonItems];
        [self.myWebView goBack];
    }else{
        [self goBackVC];
    }
}

- (void)goBackVC{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)canAndGoOutWithLinkStr:(NSString *)linkStr{
    BOOL canGoOut = NO;
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        canGoOut = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    return canGoOut;
}

#pragma M Data
- (void)loadCurUrl{
    
    NSString *proName = [NSString stringWithFormat:@"/%@.app/", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSURL *curUrl;
    if (![self.curUrlStr hasPrefix:@"/"] || [self.curUrlStr rangeOfString:proName].location != NSNotFound) {
        curUrl = [NSURL URLWithString:self.curUrlStr];
    }else{
        curUrl = [NSURL URLWithString:self.curUrlStr relativeToURL:[NSURL URLWithString:kNetPath_Code_Base]];
    }

    NSURLRequest *request =[NSURLRequest requestWithURL:curUrl];
    [_myWebView loadRequest:request];
}




#pragma mark NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress{
    [_progressView setProgress:progress animated:YES];
    NSString *titleStr = [_myWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (titleStr) {
        self.title = titleStr;
    }
}

#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self configLeftBarButtonItems];

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self configLeftBarButtonItems];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return ![self canAndGoOutWithLinkStr:request.URL.absoluteString];
}

@end
