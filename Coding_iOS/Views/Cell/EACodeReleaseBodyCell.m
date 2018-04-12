//
//  EACodeReleaseBodyCell.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/23.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EACodeReleaseBodyCell.h"
#import "WebContentManager.h"

@interface EACodeReleaseBodyCell ()<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end


@implementation EACodeReleaseBodyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGFloat curWidth = kScreen_Width - 2 * kPaddingLeftWidth;
        if (!self.webContentView) {
            self.webContentView = [[UIWebView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, 1)];
            self.webContentView.delegate = self;
            self.webContentView.scrollView.scrollEnabled = NO;
            self.webContentView.scrollView.scrollsToTop = NO;
            self.webContentView.scrollView.bounces = NO;
            self.webContentView.backgroundColor = [UIColor clearColor];
            self.webContentView.opaque = NO;
            [self.contentView addSubview:self.webContentView];
        }
        if (!_activityIndicator) {
            _activityIndicator = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
            _activityIndicator.hidesWhenStopped = YES;
            [self.contentView addSubview:_activityIndicator];
            [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.contentView);
            }];
        }
    }
    return self;
}

- (void)setCurR:(EACodeRelease *)curR{
    _curR = curR;
    [self.webContentView setHeight:_curR.contentHeight];
    if (!_webContentView.isLoading) {
        [_activityIndicator startAnimating];
        [self.webContentView loadHTMLString:[WebContentManager markdownPatternedWithContent:_curR.markdownBody] baseURL:nil];
    }
}

+ (CGFloat)cellHeightWithObj:(EACodeRelease *)obj{
    return obj.contentHeight;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *strLink = request.URL.absoluteString;
    DebugLog(@"strLink=[%@]", strLink);
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
    CGFloat scrollHeight = MIN(webView.scrollView.contentSize.height, 20 * kScreen_Height);
    if (ABS(scrollHeight - _curR.contentHeight) > 5) {
        NSLog(@"scrollHeight: %.2f, contentHeight: %.2f, (scrollHeight - contentHeight): %.2f", scrollHeight, _curR.contentHeight, (scrollHeight - _curR.contentHeight));
        webView.scalesPageToFit = YES;
        _curR.contentHeight = scrollHeight;
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
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webContentView.frame)];
        [_webContentView stringByEvaluatingJavaScriptFromString:meta];
    }
}
@end
