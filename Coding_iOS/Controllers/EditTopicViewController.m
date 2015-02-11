//
//  EditTopicViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "EditTopicViewController.h"
#import "ProjectTopic.h"
#import "Coding_NetAPIManager.h"
#import "EaseMarkdownTextView.h"
#import "WebContentManager.h"

@interface EditTopicViewController ()<UIWebViewDelegate>


@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (assign, nonatomic) NSInteger curIndex;

@property (strong, nonatomic) UIWebView *preview;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UIView *editView;
@property (strong, nonatomic) UITextField *inputTitleView;
@property (strong, nonatomic) EaseMarkdownTextView *inputContentView;


@end

@implementation EditTopicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!_segmentedControl) {
        _segmentedControl = ({
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"编辑", @"预览"]];
            [segmentedControl setWidth:80 forSegmentAtIndex:0];
            [segmentedControl setWidth:80 forSegmentAtIndex:1];
            [segmentedControl setTitleTextAttributes:@{
                                                       NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                       NSForegroundColorAttributeName: [UIColor colorWithHexString:@"0x28303b"]
                                                       }
                                            forState:UIControlStateSelected];
            [segmentedControl setTitleTextAttributes:@{
                                                       NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                                       } forState:UIControlStateNormal];
            [segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
            segmentedControl;
        });
        
        self.navigationItem.titleView = _segmentedControl;
    }
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:self.type == TopicEditTypeFeedBack? @"发送": @"完成" target:self action:@selector(saveBtnClicked)] animated:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    

    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
        if (self.inputContentView) {
            NSDictionary* userInfo = [aNotification userInfo];
            CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            self.inputContentView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(keyboardEndFrame), 0);
        }
    }];
    
    self.curIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }else{
        [self loadPreview];
    }
}

- (void)loadEditView{
    if (!_editView) {
        //控件
        _editView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        _inputTitleView = [[UITextField alloc] initWithFrame:CGRectZero];
        _inputTitleView.textColor = [UIColor colorWithHexString:@"0x222222"];
        
        
        _inputTitleView.font = [UIFont systemFontOfSize:18];
        [_editView addSubview:_inputTitleView];
        
        _inputContentView = [[EaseMarkdownTextView alloc] initWithFrame:CGRectZero];
        _inputContentView.textColor = [UIColor colorWithHexString:@"0x666666"];
        
        _inputContentView.backgroundColor = [UIColor clearColor];
        _inputContentView.font = [UIFont systemFontOfSize:15];
        [_editView addSubview:_inputContentView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = kColorTableSectionBg;
        [_editView addSubview:lineView];
        
        [self.view addSubview:_editView];

        //布局
        _inputContentView.textContainerInset = UIEdgeInsetsMake(10, kPaddingLeftWidth - 5, 8, kPaddingLeftWidth - 5);

        [_editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [_inputTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_editView.mas_top).offset(10.0);
            make.height.mas_equalTo(30);

            make.left.equalTo(_editView).offset(kPaddingLeftWidth);
            make.right.equalTo(_editView).offset(-kPaddingLeftWidth);
        }];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_inputTitleView.mas_bottom).offset(5.0);
            make.left.equalTo(_editView).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(1.0);
            make.right.equalTo(_editView);
        }];
        [_inputContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView.mas_bottom);
            make.left.right.bottom.equalTo(_editView);
        }];
        
        //内容
        @weakify(self);
        RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[self.inputTitleView.rac_textSignal, self.inputContentView.rac_textSignal] reduce:^id (NSString *title, NSString *content){
            //刚开始编辑content的时候，title传过来的总是nil
            @strongify(self);
            title = self.inputTitleView.text;
            content = self.inputContentView.text;
            BOOL enabled = ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0
                            && [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0
                            && (![title isEqualToString:self.curProTopic.mdTitle] || ![content isEqualToString:self.curProTopic.mdContent]));
            return @(enabled);
        }];
        _inputTitleView.placeholder = self.type == TopicEditTypeFeedBack? @"反馈标题": @"讨论标题";
        [_inputTitleView setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        _inputContentView.placeholder = self.type == TopicEditTypeFeedBack? @"反馈内容": @"讨论内容";
        
        _inputTitleView.text = _curProTopic.mdTitle;
        _inputContentView.text = _curProTopic.mdContent;
    }
    _editView.hidden = NO;
    _preview.hidden = YES;
}

- (void)loadPreview{
    if (!_preview) {
        _preview = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _preview.delegate = self;
        _preview.backgroundColor = [UIColor clearColor];
        _preview.opaque = NO;
        _preview.scalesPageToFit = YES;
        
        //webview加载指示
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        [_preview addSubview:_activityIndicator];
        [self.view addSubview:_preview];
        
        [_preview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_preview);
        }];
    }
    _preview.hidden = NO;
    _editView.hidden = YES;
    [_editView endEditing:YES];
    [self previewLoadMDData];
}

- (void)previewLoadMDData{
    NSString *mdStr = [NSString stringWithFormat:@"# %@\n%@", _inputTitleView.text, _inputContentView.text];
    [_activityIndicator startAnimating];
    
    @weakify(self);
    [[Coding_NetAPIManager sharedManager] request_MDHtmlStr_WithMDStr:mdStr andBlock:^(id data, NSError *error) {
        @strongify(self);
        NSString *htmlStr = data? data : error.description;
        NSString *contentStr = [WebContentManager markdownPatternedWithContent:htmlStr];
        [self.preview loadHTMLString:contentStr baseURL:nil];
    }];
}

#pragma mark nav_btn 

- (void)saveBtnClicked{
    self.curProTopic.mdTitle = _inputTitleView.text;
    self.curProTopic.mdContent = _inputContentView.text;
    if (self.type == TopicEditTypeModify) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        @weakify(self);
        [[Coding_NetAPIManager sharedManager] request_ModifyProjectTpoic:self.curProTopic andBlock:^(id data, NSError *error) {
            @strongify(self);
            self.navigationItem.rightBarButtonItem.enabled = YES;
            if (data) {
                if (self.topicChangedBlock) {
                    self.topicChangedBlock(data, self.type);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
        @weakify(self);
        [[Coding_NetAPIManager sharedManager] request_AddProjectTpoic:self.curProTopic andBlock:^(id data, NSError *error) {
            @strongify(self);
            self.navigationItem.rightBarButtonItem.enabled = YES;
            if (data) {
                if (self.topicChangedBlock) {
                    self.topicChangedBlock(data, self.type);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }

}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"strLink=[%@]",request.URL.absoluteString);
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
    else{
        DebugLog(@"%@", error.description);
        [self showError:error];
    }
}

@end
