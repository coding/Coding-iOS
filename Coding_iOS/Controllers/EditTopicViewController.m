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
#import "EditLabelViewController.h"

@interface EditTopicViewController ()<UIWebViewDelegate>
{
    CGFloat _labelH;
}

@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (assign, nonatomic) NSInteger curIndex;

@property (strong, nonatomic) UIView *preView;
@property (strong, nonatomic) UILabel *titleLbl;
@property (strong, nonatomic) UIWebView *contentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UIView *editView;
@property (strong, nonatomic) UITextField *inputTitleView;
@property (strong, nonatomic) EaseMarkdownTextView *inputContentView;

@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) UIView *labelView;
@property (strong, nonatomic) UIButton *labelAddBtn;

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
            self.inputContentView.scrollIndicatorInsets = self.inputContentView.contentInset;
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
- (void)segmentedControlSelected:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.curIndex = segmentedControl.selectedSegmentIndex;
}

#pragma mark index_view
- (void)setCurIndex:(NSInteger)curIndex
{
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

- (void)loadLabelView
{
    _labelH = 15;
    _labelView = [[UIView alloc] initWithFrame:CGRectZero];
    if (_curProTopic.mdLabels.count > 0) {
        CGFloat x = 0.0f;
        CGFloat y = 0.0f;
        CGFloat limitW = kScreen_Width - kPaddingLeftWidth * 2 - 40;
        
        for (NSString *str in _curProTopic.mdLabels) {
            UILabel *tLbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 0, 0)];
            
            tLbl.font = [UIFont systemFontOfSize:12];
            tLbl.text = str;
            tLbl.textColor = [UIColor colorWithHexString:@"0x3bbd79"];
            tLbl.textAlignment = NSTextAlignmentCenter;
            tLbl.backgroundColor = [UIColor redColor];
            tLbl.layer.cornerRadius = 5;
            
            [tLbl sizeToFit];
            
            CGFloat width = tLbl.frame.size.width + 10;
            if (x + width > limitW) {
                y += 20.0f;
                x = 0.0f;
            }
            [tLbl setFrame:CGRectMake(x, y, width - 4, 20 - 4)];
            x += width;
            
            [_labelView addSubview:tLbl];
        }
        _labelH = y + 20;
        
    } else {
        UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        [iconImg setImage:[UIImage imageNamed:@"tag_icon"]];
        
        UILabel *tLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 30, 15)];
        
        tLbl.font = [UIFont systemFontOfSize:14];
        tLbl.text = @"标签";
        tLbl.textColor = [UIColor colorWithHexString:@"0x3bbd79"];
        
        [_labelView addSubview:iconImg];
        [_labelView addSubview:tLbl];
    }
    
    _labelAddBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [_labelAddBtn setImage:[UIImage imageNamed:@"tag_add"] forState:UIControlStateNormal];
    [_labelAddBtn setImageEdgeInsets:UIEdgeInsetsMake(14, 12, 14, 12)];
    [_labelAddBtn addTarget:self action:@selector(addtitleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectZero];
    _lineView.backgroundColor = kColorTableSectionBg;
}

- (void)loadEditView
{
    if (!_editView) {
        //控件
        _editView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        _inputTitleView = [[UITextField alloc] initWithFrame:CGRectZero];
        _inputTitleView.textColor = [UIColor colorWithHexString:@"0x222222"];
        _inputTitleView.font = [UIFont systemFontOfSize:18];
        [_editView addSubview:_inputTitleView];
        
        _inputContentView = [[EaseMarkdownTextView alloc] initWithFrame:CGRectZero];
        _inputContentView.curProject = self.curProTopic.project;
        _inputContentView.textColor = [UIColor colorWithHexString:@"0x666666"];
        
        _inputContentView.backgroundColor = [UIColor clearColor];
        _inputContentView.font = [UIFont systemFontOfSize:15];
        [_editView addSubview:_inputContentView];
        
        [self.view addSubview:_editView];
    }
    
    if (_labelView) {
        [_labelView removeFromSuperview];
        [_labelAddBtn removeFromSuperview];
        [_lineView removeFromSuperview];
    } else {
        [self loadLabelView];
    }
    [_editView addSubview:_labelView];
    [_editView addSubview:_labelAddBtn];
    [_editView addSubview:_lineView];
    
    // 布局
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
    
    // 标签
    [_labelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_inputTitleView.mas_bottom).offset(22.0);
        make.height.mas_equalTo(_labelH);
        
        make.left.equalTo(_editView).offset(kPaddingLeftWidth);
        make.right.equalTo(_editView).offset(-kPaddingLeftWidth);
    }];
    
    [_labelAddBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_labelView.mas_top).offset(-14.0);
        make.right.equalTo(_editView);
        
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(44);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_labelView.mas_bottom).offset(12.0);
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
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[self.inputTitleView.rac_textSignal, self.inputContentView.rac_textSignal] reduce:^id (NSString *title, NSString *content) {
        //刚开始编辑content的时候，title传过来的总是nil
        @strongify(self);
        title = self.inputTitleView.text;
        content = self.inputContentView.text;
        BOOL enabled = ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0
                        && [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0
                        && (![title isEqualToString:self.curProTopic.mdTitle] || ![content isEqualToString:self.curProTopic.mdContent]));
        return @(enabled);
    }];
    _inputTitleView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:(self.type == TopicEditTypeFeedBack? @"反馈标题": @"讨论标题") attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    _inputTitleView.text = _curProTopic.mdTitle;
    _inputContentView.text = _curProTopic.mdContent;

    _editView.hidden = NO;
    _preView.hidden = YES;
}

- (void)loadPreview
{
    if (!_preView) {
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLbl.textColor = [UIColor colorWithHexString:@"0x222222"];
        _titleLbl.font = [UIFont systemFontOfSize:18];
        _titleLbl.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLbl.numberOfLines = 0;
        [_preView addSubview:_titleLbl];
        
        _contentView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _contentView.delegate = self;
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.opaque = NO;
        _contentView.scalesPageToFit = YES;
        
        //webview加载指示
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        [_contentView addSubview:_activityIndicator];
        [_preView addSubview:_contentView];
        
        [self.view addSubview:_preView];
    }
    
    if (_labelView) {
        [_labelView removeFromSuperview];
        [_labelAddBtn removeFromSuperview];
        [_lineView removeFromSuperview];
    } else {
        [self loadLabelView];
    }
    [_preView addSubview:_labelView];
    [_preView addSubview:_labelAddBtn];
    [_preView addSubview:_lineView];
    
    // 布局
    [_preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
//    _titleLbl.text = _inputTitleView.text;
//    if (_titleLbl.text.length <= 0) {
//        _titleLbl.text = @" "; 
//    }
//    [_titleLbl sizeThatFits:CGSizeMake(kScreen_Width - kPaddingLeftWidth * 2, self.view.frame.size.height)];
//    CGFloat h = _titleLbl.frame.size.height;
//    if (h < 30) {
//        h = 30;
//    }
    [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(10.0);
        
        make.left.equalTo(_preView).offset(kPaddingLeftWidth);
        make.right.equalTo(_preView).offset(-kPaddingLeftWidth);
    }];
    _titleLbl.text = _inputTitleView.text;
   
    // 标签
    [_labelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLbl.mas_bottom).offset(22.0);
        make.height.mas_equalTo(_labelH);
        
        make.left.equalTo(_preView).offset(kPaddingLeftWidth);
        make.right.equalTo(_preView).offset(-kPaddingLeftWidth);
    }];
    
    [_labelAddBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_labelView.mas_top).offset(-14.0);
        make.right.equalTo(_preView);
        
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(44);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_labelView.mas_bottom).offset(12.0);
        make.left.equalTo(_preView).offset(kPaddingLeftWidth);
        make.height.mas_equalTo(1.0);
        make.right.equalTo(_preView);
    }];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lineView.mas_bottom).offset(5.0);
        make.left.right.bottom.equalTo(_preView);
    }];
    
    [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_contentView);
    }];

    
    _preView.hidden = NO;
    _editView.hidden = YES;
    [_editView endEditing:YES];
    [self previewLoadMDData];
}

- (void)previewLoadMDData
{
    NSString *mdStr = [NSString stringWithFormat:@"%@", _inputContentView.text];
    [_activityIndicator startAnimating];
    
    @weakify(self);
    [[Coding_NetAPIManager sharedManager] request_MDHtmlStr_WithMDStr:mdStr andBlock:^(id data, NSError *error) {
        @strongify(self);
        NSString *htmlStr = data? data : error.description;
        NSString *contentStr = [WebContentManager markdownPatternedWithContent:htmlStr];
        [self.contentView loadHTMLString:contentStr baseURL:nil];
    }];
}

#pragma mark - click
- (void)addtitleBtnClick:(UIButton *)sender
{
    EditLabelViewController *vc = [[EditLabelViewController alloc] init];
    vc.curProTopic = _curProTopic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)saveBtnClicked
{
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
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        if (self.type == TopicEditTypeFeedBack) {
            self.curProTopic.mdContent = [NSString stringWithFormat:@"%@\n%@", self.curProTopic.mdContent, [NSString userAgentStr]];
        }
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
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"strLink=[%@]", request.URL.absoluteString);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if([error code] == NSURLErrorCancelled)
        return;
    else {
        DebugLog(@"%@", error.description);
        [self showError:error];
    }
}

@end
