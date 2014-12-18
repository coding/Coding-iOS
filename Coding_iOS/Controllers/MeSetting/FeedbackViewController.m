//
//  FeedbackViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-23.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Coding_NetAPIManager.h"
#import "UIPlaceHolderTextView.h"

@interface FeedbackViewController ()
@property (strong, nonatomic) UITextField *inputTitleView;
@property (strong, nonatomic) UIPlaceHolderTextView *inputContentView;
@property (strong, nonatomic) UIView *inputContentContainerView;
@property (strong, nonatomic) ProjectTopic *myProTopic;

@end

@implementation FeedbackViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView{
    [super loadView];
    CGRect frame = [UIView frameWithOutNav];
    
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    
    frame = CGRectMake(0, 30, kScreen_Width, 44);
    UIView *bgWhiteView = [[UIView alloc] initWithFrame:frame];
    bgWhiteView.backgroundColor = [UIColor whiteColor];
    [bgWhiteView addLineUp:YES andDown:YES];
    [self.view addSubview:bgWhiteView];
    
    CGRect frameTitle = CGRectInset(frame, 5, kPaddingLeftWidth);
    
    _inputTitleView = [[UITextField alloc] initWithFrame:frameTitle];
    _inputTitleView.font = [UIFont boldSystemFontOfSize:15];
    _inputTitleView.placeholder = @" 输入反馈标题";
    [_inputTitleView setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_inputTitleView setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
//    [_inputTitleView becomeFirstResponder];
    [self.view addSubview:_inputTitleView];
    
    
    
    frame.origin.y += 44+20;
    frame.size.height = kScreen_Height -64- 55-280-kHigher_iOS_6_1_DIS(20);
    _inputContentContainerView = [[UIView alloc] initWithFrame:frame];
    _inputContentContainerView.backgroundColor = [UIColor clearColor];
    _inputContentView = [[UIPlaceHolderTextView alloc] initWithFrame:_inputContentContainerView.bounds];
    _inputContentView.font = [UIFont systemFontOfSize:15];
    _inputContentView.placeholder = @"请输入反馈内容，我们将为您不断改进";

    [_inputContentContainerView addSubview:_inputContentView];
    [_inputContentContainerView addLineUp:YES andDown:YES];

    [self.view addSubview:_inputContentContainerView];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(feedbackBtnClicked:)];
    self.title = @"意见反馈";
    _myProTopic = [[ProjectTopic alloc] init];
    _myProTopic.project_id = [NSNumber numberWithInteger:182];
}

- (void)feedbackBtnClicked:(id)sender{
    self.myProTopic.title = _inputTitleView.text;
    self.myProTopic.content = _inputContentView.text;
    
    if (_myProTopic.title.length <= 0 || _myProTopic.content <= 0) {
        kTipAlert(@"至少写点什么吖");
        return;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[Coding_NetAPIManager sharedManager] request_AddProjectTpoic:self.myProTopic andBlock:^(id data, NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (data) {
            self.myProTopic = data;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
@end
