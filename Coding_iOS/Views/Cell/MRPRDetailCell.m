 //
//  MRPRDetailCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPRDetailCell.h"
#import "WebContentManager.h"

@interface MRPRDetailCell ()<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation MRPRDetailCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kColorTableBG;
        if (!_webContentView) {
            _webContentView = [UIWebView new];
            _webContentView.delegate = self;
            _webContentView.scrollView.scrollEnabled = NO;
            _webContentView.scrollView.scrollsToTop = NO;
            _webContentView.scrollView.bounces = NO;
            _webContentView.backgroundColor = [UIColor clearColor];
            _webContentView.opaque = NO;
            [self.contentView addSubview:_webContentView];
            [_webContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, kPaddingLeftWidth, 10, kPaddingLeftWidth));
            }];
        }
        if (!_activityIndicator) {
            _activityIndicator = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
            _activityIndicator.hidesWhenStopped = YES;
            [_webContentView addSubview:_activityIndicator];
            [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(_webContentView);
            }];
        }
    }
    return self;
}

- (void)setCurMRPRInfo:(MRPRBaseInfo *)curMRPRInfo{
    _curMRPRInfo = curMRPRInfo;
    if (!_curMRPRInfo) {
        return;
    }
    if (!_webContentView.isLoading) {
        [_activityIndicator startAnimating];
        if (_curMRPRInfo.htmlMedia.contentOrigional) {
            [self.webContentView loadHTMLString:[WebContentManager topicPatternedWithContent:_curMRPRInfo.htmlMedia.contentOrigional] baseURL:nil];
        }
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[MRPRBaseInfo class]]) {
        MRPRBaseInfo *curMRPRInfo = (MRPRBaseInfo *)obj;
        cellHeight += curMRPRInfo.contentHeight;
        cellHeight += 10;
    }
    return MAX(20, cellHeight);
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *strLink = request.URL.absoluteString;
    if ([strLink rangeOfString:@"about:blank"].location != NSNotFound) {
        return YES;
    } else {
        if (_loadRequestBlock) {
            _loadRequestBlock(request);
        }
        return NO;
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self refreshwebContentView];
    [_activityIndicator stopAnimating];
    CGFloat scrollHeight = webView.scrollView.contentSize.height;
    if (ABS(scrollHeight - _curMRPRInfo.contentHeight) > 5) {
        webView.scalesPageToFit = YES;
        _curMRPRInfo.contentHeight = scrollHeight;
        if (_cellHeightChangedBlock) {
            _cellHeightChangedBlock();
        }
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activityIndicator stopAnimating];
    if([error code] == NSURLErrorCancelled)
        return;
    else
        DebugLog(@"%@", error.description);
}

- (void)refreshwebContentView
{
    if (_webContentView) {
        //        NSString *js = @"window.onload = function(){ document.body.style.backgroundColor = '#333333';}";
        //        [_webContentView stringByEvaluatingJavaScriptFromString:js];
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webContentView.frame)];
        [_webContentView stringByEvaluatingJavaScriptFromString:meta];
    }
}
@end
