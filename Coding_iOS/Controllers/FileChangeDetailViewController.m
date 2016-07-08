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
#import "CodeViewController.h"
#import "AddMDCommentViewController.h"


@interface FileChangeDetailViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSDictionary *rawData, *commentsData;
@property (strong, nonatomic) NSString *linkRef;
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
    [self refresh];
}

- (void)refresh{
    [self.view beginLoading];
    [[Coding_NetAPIManager sharedManager] request_FileDiffDetailWithPath:self.linkUrlStr andBlock:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            self.rawData = data[@"rawData"];
            self.commentsData = data[@"commentsData"];
            if ([self.rawData isKindOfClass:[NSDictionary class]]) {
                self.linkRef = self.rawData[@"data"][@"linkRef"];
            }
            [self refreshUI];
        }
        [self.view configBlankPage:EaseBlankPageTypeView hasData:(self.rawData != nil) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [self refresh];
        }];
    }];
}

- (void)refreshUI{
    if (self.rawData) {
        NSData *JSONDataRaw = [NSJSONSerialization dataWithJSONObject:self.rawData options:NSJSONWritingPrettyPrinted error:nil];
        NSString *contentStr = [[[NSString alloc] initWithData:JSONDataRaw encoding:NSUTF8StringEncoding] stringByRemoveSpecailCharacters];
        
        NSData *JSONDataComments = [NSJSONSerialization dataWithJSONObject:self.commentsData options:NSJSONWritingPrettyPrinted error:nil];
        NSString *commentsStr = [[[NSString alloc] initWithData:JSONDataComments encoding:NSUTF8StringEncoding] stringByRemoveSpecailCharacters];
        
        contentStr = [WebContentManager diffPatternedWithContent:contentStr andComments:commentsStr];
        [self.webContentView loadHTMLString:contentStr baseURL:nil];
    }
    self.navigationItem.rightBarButtonItem = self.linkRef.length > 0? [UIBarButtonItem itemWithBtnTitle:@"查看文件" target:self action:@selector(rightBarButtonClicked:)]: nil;
}

- (void)rightBarButtonClicked:(id)item{
    CodeFile *codeFile = [CodeFile codeFileWithRef:self.linkRef andPath:_filePath];
    CodeViewController *vc = [CodeViewController codeVCWithProject:_curProject andCodeFile:codeFile];
    [self.navigationController pushViewController:vc animated:YES];
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
    NSString *strLink = request.URL.absoluteString;
    if ([strLink hasPrefix:@"coding://"]) {
        [self handleURL:request.URL];
        return NO;
    }
    else{
        return YES;
    }
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
#pragma mark Clicked One Line
- (void)handleURL:(NSURL *)curURL{
    NSMutableDictionary *params = [self getParamsFromURLStr:curURL.absoluteString];
    if ([curURL.absoluteString hasPrefix:@"coding://line_note?"]) {
        NSString *title = [NSString stringWithFormat:@"Line %@", params[@"line"]];
        [[UIActionSheet bk_actionSheetCustomWithTitle:title buttonTitles:@[@"添加评论"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [self goToAddCommentWithParams:params];
            }
        }] showInView:self.view];
    }else if ([curURL.absoluteString hasPrefix:@"coding://line_note_comment?"]){
        NSString *title = [NSString stringWithFormat:@"%@ 的评论", params[@"clicked_user_name"]];
        BOOL belongToSelf = [params[@"clicked_user_name"] isEqualToString:[Login curLoginUser].global_key];
        [[UIActionSheet bk_actionSheetCustomWithTitle:title buttonTitles:@[belongToSelf? @"删除": @"回复"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                if (belongToSelf) {
                    [self doDeleteCommentWithParams:params];
                }else{
                    [self goToAddCommentWithParams:params];
                }
            }
        }] showInView:self.view];
    }
}

- (NSMutableDictionary *)getParamsFromURLStr:(NSString *)urlStr{
    urlStr = [[urlStr componentsSeparatedByString:@"?"] lastObject];
    urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *param in [urlStr componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
    }
    return params;
}

- (void)goToAddCommentWithParams:(NSMutableDictionary *)params{
    AddMDCommentViewController *vc = [AddMDCommentViewController new];
    vc.curProject = _curProject;
    
    NSString *requestPath = [[self.linkUrlStr componentsSeparatedByString:@"/git"] firstObject];
    requestPath = [requestPath stringByAppendingString:@"/git/line_notes"];
    vc.requestPath = requestPath;
    
    vc.contentStr = params[@"clicked_user_name"]? [NSString stringWithFormat:@"@%@ ", params[@"clicked_user_name"]] : @"";
    
    [params removeObjectsForKeys:@[@"clicked_line_note_id", @"clicked_user_name", @"clicked_user_name"]];
    if (self.noteable_id) {
        params[@"noteable_id"] = self.noteable_id;
    }
    if (self.commitId) {
        params[@"commitId"] = self.commitId;
    }
    if ([params[@"noteable_type"] hasSuffix:@"Request"]) {
        params[@"noteable_type"] = [params[@"noteable_type"] stringByAppendingString:@"Bean"];
    }
    vc.requestParams = params;
    
    @weakify(self);
    vc.completeBlock = ^(id data){
        @strongify(self);
        if (data) {
            [self refresh];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)doDeleteCommentWithParams:(NSMutableDictionary *)params{
    NSString *requestPath = [[self.linkUrlStr componentsSeparatedByString:@"/git"] firstObject];
    requestPath = [requestPath stringByAppendingFormat:@"/git/line_notes/%@", params[@"clicked_line_note_id"]];
    [[Coding_NetAPIManager sharedManager] request_DeleteLineNoteWithPath:requestPath andBlock:^(id data, NSError *error) {
        [self refresh];
    }];
}

@end
