//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "BaseViewController.h"

@interface SVWebViewController : BaseViewController
@property (nonatomic, strong, readonly) UIWebView *webView;
@property (nonatomic, strong, readonly) NSURLRequest *request;

- (instancetype)initWithAddress:(NSString*)urlString;
- (instancetype)initWithURL:(NSURL*)URL;
- (instancetype)initWithURLRequest:(NSURLRequest *)request;
- (void)updateToolbarItems;

@property (nonatomic, weak) id<UIWebViewDelegate> delegate;
@end
