//
//  ProjectReadMeCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kProjectReadMeCell_TitleHeight 40

#import "ProjectReadMeCell.h"
#import "WebContentManager.h"

@interface ProjectReadMeCell ()<UIWebViewDelegate>
@property (strong, nonatomic) UILabel *titleL;
@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation ProjectReadMeCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        if (!_titleL) {
            _titleL = [[UILabel alloc] initWithFrame:CGRectMake(12, 15, 200, 15)];
            _titleL.font = [UIFont systemFontOfSize:14];
            _titleL.textColor = [UIColor colorWithHexString:@"0x222222"];
            _titleL.text = @"README.md";
            [self.contentView addSubview:_titleL];
        }
        if (!_lineView) {
            _lineView = [[UIView alloc] initWithFrame:CGRectMake(12, kProjectReadMeCell_TitleHeight-1, kScreen_Width - 12, 1)];
            _lineView.backgroundColor = kColorTableSectionBg;
            [self.contentView addSubview:_lineView];
        }


        if (!_webContentView) {
            _webContentView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kProjectReadMeCell_TitleHeight, kScreen_Width, 1)];
            _webContentView.delegate = self;
            _webContentView.scrollView.scrollEnabled = NO;
            _webContentView.scrollView.scrollsToTop = NO;
            _webContentView.scrollView.bounces = NO;
            _webContentView.backgroundColor = [UIColor clearColor];
            _webContentView.opaque = NO;
            [self.contentView addSubview:_webContentView];
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

- (void)setCurProject:(Project *)curProject{
    _curProject = curProject;
    if (!_curProject) {
        return;
    }
    [_webContentView setHeight:_curProject.readMeHeight];
    [_activityIndicator startAnimating];
    NSString *webDataStr = _curProject.readMeHtml? _curProject.readMeHtml: @"";
    [self.webContentView loadHTMLString:[WebContentManager markdownPatternedWithContent:webDataStr] baseURL:nil];
}
+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Project class]]) {
        cellHeight = kProjectReadMeCell_TitleHeight;
        
        Project *curProject = (Project *)obj;
        cellHeight += curProject.readMeHeight;
    }
    return cellHeight;
}
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *strLink = request.URL.absoluteString;
    NSLog(@"strLink=[%@]",strLink);
    if ([strLink rangeOfString:@"about:blank"].location != NSNotFound) {
        return YES;
    }else{
        if (_loadRequestBlock) {
            _loadRequestBlock(request);
        }
        return NO;
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self refreshWebContentView];
    [_activityIndicator stopAnimating];
    CGFloat scrollHeight = webView.scrollView.contentSize.height;
    if (ABS(scrollHeight - _curProject.readMeHeight) > 5) {
        webView.scalesPageToFit = YES;
        _curProject.readMeHeight = scrollHeight;
        if (_cellHeightChangedBlock) {
            _cellHeightChangedBlock();
        }
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_activityIndicator stopAnimating];
    if([error code] == NSURLErrorCancelled)
        return;
    else
        DebugLog(@"%@", error.description);
}

- (void)refreshWebContentView{
    if (_webContentView) {
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webContentView.frame)];
        [_webContentView stringByEvaluatingJavaScriptFromString:meta];
    }
}


@end
