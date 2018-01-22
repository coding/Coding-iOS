//
//  WikiEditViewController.m
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/4/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "WikiEditViewController.h"
#import "Coding_NetAPIManager.h"
#import "WebContentManager.h"
#import "WikiHeaderView.h"
#import "EaseMarkdownTextView.h"
#import "UIViewController+BackButtonHandler.h"


@interface WikiEditViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (assign, nonatomic) NSInteger curIndex;

@property (strong, nonatomic) UIWebView *preview;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) WikiHeaderView *headerV;

@property (strong, nonatomic) UIView *editView;
@property (strong, nonatomic) UITextField *inputTitleView;
@property (strong, nonatomic) EaseMarkdownTextView *inputContentView;
@property (strong, nonatomic) UIView *lineView;

@end

@implementation WikiEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColorTableBG;
    if (!_segmentedControl) {
        _segmentedControl = ({
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"编辑", @"预览"]];
            [segmentedControl setWidth:80 forSegmentAtIndex:0];
            [segmentedControl setWidth:80 forSegmentAtIndex:1];
            [segmentedControl setTitleTextAttributes:@{
                                                       NSFontAttributeName: [UIFont systemFontOfSize:16],
                                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                                       }
                                            forState:UIControlStateSelected];
            [segmentedControl setTitleTextAttributes:@{
                                                       NSFontAttributeName: [UIFont systemFontOfSize:16],
                                                       NSForegroundColorAttributeName: kColorNavTitle
                                                       } forState:UIControlStateNormal];
            [segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
            segmentedControl;
        });
        
        self.navigationItem.titleView = _segmentedControl;
    }
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"保存" target:self action:@selector(saveBtnClicked)] animated:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
        if (self.inputContentView) {
            NSDictionary* userInfo = [aNotification userInfo];
            CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            self.inputContentView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(keyboardEndFrame), 0);
            self.inputContentView.scrollIndicatorInsets = self.inputContentView.contentInset;
        }
    }];
    
    self.curIndex = 0;
    if ([self.curWiki hasDraft]) {
        BOOL versionChanged = [self.curWiki draftVersionChanged];
        __weak typeof(self) weakSelf = self;
        [[UIAlertView bk_showAlertViewWithTitle:@"提示" message:versionChanged? @"有最新版本更新，您是否继续编辑上次保存的草稿？": @"是否启用上次保存的草稿？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"编辑草稿"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [weakSelf.curWiki readDraft];
                [weakSelf refreshUI];
            }else{
                [weakSelf.curWiki deleteDraft];
            }
        }] show];
    }
}

- (void)refreshUI{
    self.inputTitleView.text = self.curWiki.mdTitle;
    self.inputContentView.text = self.curWiki.mdContent;
    if (_curIndex == 1) {
        [self loadPreview];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_curIndex == 0) {
        [self loadEditView];
    } else {
        [self loadPreview];
    }
    //禁用屏幕左滑返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //开启屏幕左滑返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (BOOL)navigationShouldPopOnBackButton{
    self.curWiki.mdTitle = _inputTitleView.text;
    self.curWiki.mdContent = _inputContentView.text;
    if ([self.curWiki hasChanged]) {
        __weak typeof(self) weakSelf = self;
        [[UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"是否需要保存草稿？" cancelButtonTitle:@"不保存" otherButtonTitles:@[@"保存"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [weakSelf.curWiki saveDraft];
            }else{
                [weakSelf.curWiki deleteDraft];
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }] show];
        return NO;
    }else{
        return YES;
    }
}

- (void)saveWikiDraft{
    self.curWiki.mdTitle = _inputTitleView.text;
    self.curWiki.mdContent = _inputContentView.text;
    if ([self.curWiki hasChanged]) {
        [self.curWiki saveDraft];
    }
}

#pragma mark UISegmentedControl
- (void)segmentedControlSelected:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.curIndex = segmentedControl.selectedSegmentIndex;
}

#pragma mark index_view
- (void)setCurIndex:(NSInteger)curIndex{
    _curIndex = curIndex;
    if (_segmentedControl.selectedSegmentIndex != curIndex) {
        [_segmentedControl setSelectedSegmentIndex:_curIndex];
    }
    
    if (_curIndex == 0) {
        [self loadEditView];
    } else {
        [self loadPreview];
    }
}

#pragma mark PreView

- (void)loadPreview{
    if (!_preview) {
        _preview = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _preview.delegate = self;
        _preview.backgroundColor = [UIColor clearColor];
        _preview.opaque = NO;
        _preview.scalesPageToFit = YES;
        [self.view addSubview:_preview];
        //webview加载指示
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        [_activityIndicator setCenter:CGPointMake(CGRectGetWidth(_preview.frame)/2, CGRectGetHeight(_preview.frame)/2)];
        [_preview addSubview:_activityIndicator];
        [_preview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        if (!_headerV) {
            _headerV = [WikiHeaderView new];
            _headerV.isForEdit = YES;
            [_preview.scrollView addSubview:_headerV];
        }
    }
    self.curWiki.mdTitle = _inputTitleView.text;
    self.curWiki.mdContent = _inputContentView.text;
    
    _headerV.curWiki = _curWiki;
    _preview.scrollView.contentInset = UIEdgeInsetsMake(_headerV.height, 0, 0, 0);

    _preview.hidden = NO;
    _editView.hidden = YES;
    [self.view endEditing:YES];
    [self previewLoadMDData];
}

- (void)previewLoadMDData{
    NSString *mdStr = self.curWiki.mdContent;
    @weakify(self);
    [[Coding_NetAPIManager sharedManager] request_MDHtmlStr_WithMDStr:mdStr inProject:self.myProject andBlock:^(id data, NSError *error) {
        @strongify(self);
        NSString *htmlStr = data? data : error.description;
        NSString *contentStr = [WebContentManager wikiPatternedWithContent:htmlStr];
        [self.preview loadHTMLString:contentStr baseURL:nil];
    }];
}
#pragma mark EditView


- (void)loadEditView{
    if (!_editView) {
        //控件
        _editView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_editView];

        _inputTitleView = [UITextField new];
        _inputTitleView.textColor = kColor222;
        _inputTitleView.font = [UIFont systemFontOfSize:18];
         [_editView addSubview:_inputTitleView];

        _lineView = [UIView new];
        _lineView.backgroundColor = kColorDDD;
        [_editView addSubview:_lineView];

        _inputContentView = [[EaseMarkdownTextView alloc] initWithFrame:CGRectZero];
        _inputContentView.curProject = self.myProject;
        _inputContentView.textColor = kColor222;
        _inputContentView.placeholder = @"页面内容";
        _inputContentView.backgroundColor = [UIColor clearColor];
        _inputContentView.font = [UIFont systemFontOfSize:15];
        _inputContentView.textContainerInset = UIEdgeInsetsMake(10, kPaddingLeftWidth - 5, 8, kPaddingLeftWidth - 5);
        [_editView addSubview:_inputContentView];

        [self.view addSubview:_editView];
        // 布局
        [_editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [_inputTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_editView.mas_top).offset(10.0);
            make.height.mas_equalTo(30);
            make.left.equalTo(_editView).offset(kPaddingLeftWidth);
            make.right.equalTo(_editView).offset(-kPaddingLeftWidth);
        }];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_inputTitleView.mas_bottom).offset(12.0);
            make.left.equalTo(_editView).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(1.0);
            make.right.equalTo(_editView);
        }];
        [_inputContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_lineView.mas_bottom).offset(5.0);
            make.left.right.bottom.equalTo(_editView);
        }];
        // 内容
        @weakify(self);
        RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[self.inputTitleView.rac_textSignal,
                                                                                          self.inputContentView.rac_textSignal]
                                                                                 reduce:^id (NSString *title, NSString *content) {
            @strongify(self);
            title = self.inputTitleView.text;
            content = self.inputContentView.text;
            BOOL enabled = ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0
                            && (![title isEqualToString:self.curWiki.mdTitle] || ![content isEqualToString:self.curWiki.mdContent]));
            return @(enabled);
        }];
        _inputTitleView.text = _curWiki.mdTitle;
        _inputContentView.text = _curWiki.mdContent;
    }
    _editView.hidden = NO;
    _preview.hidden = YES;
}

#pragma mark - click
- (void)saveBtnClicked{
    self.curWiki.mdTitle = _inputTitleView.text;
    self.curWiki.mdContent = _inputContentView.text;

    self.navigationItem.rightBarButtonItem.enabled = NO;
    [NSObject showHUDQueryStr:@"正在保存..."];
    @weakify(self);
    [[Coding_NetAPIManager sharedManager] request_ModifyWiki:_curWiki pro:_myProject andBlock:^(id data, NSError *error) {
        @strongify(self);
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [NSObject hideHUDQuery];
        if (data) {
            [NSObject showHudTipStr:@"保存成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
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
    if([error code] == NSURLErrorCancelled)
        return;
    else
        DebugLog(@"%@", error.description);
}


@end
