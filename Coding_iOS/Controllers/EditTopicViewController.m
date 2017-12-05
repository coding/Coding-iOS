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
#import "TopicPreviewCell.h"
#import "ProjectTag.h"
#import "ProjectTagsView.h"
#import "WebViewController.h"

@interface EditTopicViewController ()<UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (assign, nonatomic) NSInteger curIndex;

@property (strong, nonatomic) UITableView *preView;

@property (strong, nonatomic) UIView *editView;
@property (strong, nonatomic) UITextField *inputTitleView;
@property (strong, nonatomic) EaseMarkdownTextView *inputContentView;

@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) ProjectTagsView *tagsView;

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
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:
                                                self.type == TopicEditTypeFeedBack ? @"发送" :
                                                self.type == TopicEditTypeModify? @"保存": @"完成"
                                                                          target:self action:@selector(saveBtnClicked)] animated:YES];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_curIndex == 0) {
        [self loadEditView];
    } else {
        [self loadPreview];
    }
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
    if (!_tagsView) {
        _tagsView = [ProjectTagsView viewWithTags:_curProTopic.mdLabels];
        [self.editView addSubview:_tagsView];
    }else{
        _tagsView.tags = _curProTopic.mdLabels;
    }
    __weak typeof(self) weakSelf = self;
    _tagsView.deleteTagBlock = ^(ProjectTag *curTag){
        curTag = [ProjectTag tags:weakSelf.curProTopic.mdLabels hasTag:curTag];
        if (curTag) {
            [weakSelf.curProTopic.mdLabels removeObject:curTag];
        }
        [weakSelf loadEditView];
        weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    };
    _tagsView.addTagBlock = ^(){
        [weakSelf addtitleBtnClick];
    };
}

- (void)loadEditView
{
    if (!_editView) {
        //控件
        _editView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        _inputTitleView = [[UITextField alloc] initWithFrame:CGRectZero];
        _inputTitleView.textColor = kColor222;
        _inputTitleView.font = [UIFont systemFontOfSize:18];
        _inputTitleView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:(self.type == TopicEditTypeFeedBack ? @"反馈标题" : @"讨论标题") attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        [_editView addSubview:_inputTitleView];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = kColorTableSectionBg;
        [_editView addSubview:_lineView];
        
        _inputContentView = [[EaseMarkdownTextView alloc] initWithFrame:CGRectZero];
        _inputContentView.curProject = self.curProTopic.project;
        _inputContentView.textColor = kColor222;
        _inputContentView.placeholder = self.type == TopicEditTypeFeedBack ? @"反馈内容" : @"讨论内容";
        
        _inputContentView.backgroundColor = [UIColor clearColor];
        _inputContentView.font = [UIFont systemFontOfSize:15];
        [_editView addSubview:_inputContentView];
        
        [self.view addSubview:_editView];
        
        // 内容
        @weakify(self);
        RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[self.inputTitleView.rac_textSignal, self.inputContentView.rac_textSignal, RACObserve(self.curProTopic, mdLabels)] reduce:^id (NSString *title, NSString *content, NSArray *mdLabels) {
            // 刚开始编辑content的时候，title传过来的总是nil
            @strongify(self);
            title = self.inputTitleView.text;
            content = self.inputContentView.text;
            BOOL enabled = ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0
                            && [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0
                            && (![title isEqualToString:self.curProTopic.mdTitle]
                                || ![content isEqualToString:self.curProTopic.mdContent]
                                || ![ProjectTag tags:mdLabels isEqualTo:self.curProTopic.labels]));
            return @(enabled);
        }];
        _inputTitleView.text = _curProTopic.mdTitle;
        _inputContentView.text = _curProTopic.mdContent;
    }
    
    if (self.type != TopicEditTypeFeedBack) {
        [self loadLabelView];
    }
    
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
    
    if (self.type != TopicEditTypeFeedBack) {
        // 标签
        CGFloat tagsViewHeight = [ProjectTagsView getHeightForTags:_curProTopic.mdLabels];
        [_tagsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_inputTitleView.mas_bottom).offset(16.0);
            make.height.mas_equalTo(tagsViewHeight);
            
            make.left.right.equalTo(_editView);
        }];
        
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_tagsView.mas_bottom).offset(9.0);
            make.left.equalTo(_editView).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(1.0);
            make.right.equalTo(_editView);
        }];
    } else {
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_inputTitleView.mas_bottom).offset(12.0);
            make.left.equalTo(_editView).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(1.0);
            make.right.equalTo(_editView);
        }];
    }
    
    [_inputContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lineView.mas_bottom).offset(5.0);
        make.left.right.bottom.equalTo(_editView);
    }];

    _editView.hidden = NO;
    _preView.hidden = YES;
}

- (void)loadPreview
{
    if (!_preView) {
        _preView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[TopicPreviewCell class] forCellReuseIdentifier:kCellIdentifier_TopicPreviewCell];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView;
        });
        
        [self.view addSubview:_preView];
    }
    
    // 布局
    [_preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _preView.hidden = NO;
    [_preView reloadData];
    _editView.hidden = YES;
    [_editView endEditing:YES];
}

#pragma mark - click
- (void)addtitleBtnClick
{
    EditLabelViewController *vc = [[EditLabelViewController alloc] init];
    vc.curProject = _curProTopic.project;
    vc.orignalTags = _curProTopic.mdLabels;
    @weakify(self);
    vc.tagsSelectedBlock = ^(EditLabelViewController *vc, NSMutableArray *selectedTags){
        @strongify(self);
        self.curProTopic.mdLabels = selectedTags;
    };
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

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopicPreviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicPreviewCell forIndexPath:indexPath];
    _curProTopic.created_at = [NSDate date];
    cell.isLabel = (self.type == TopicEditTypeFeedBack ? FALSE : TRUE);
    self.curProTopic.mdTitle = _inputTitleView.text;
    self.curProTopic.mdContent = _inputContentView.text;
    cell.curTopic = self.curProTopic;
    __weak typeof(self) weakSelf = self;
    cell.cellHeightChangedBlock = ^(){
        [weakSelf.preView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    };
    cell.addLabelBlock = ^(){
        [weakSelf addtitleBtnClick];
    };
    cell.delLabelBlock = ^(){
         weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    };
    cell.clickedLinkStrBlock = ^(NSString *linkStr){
        [weakSelf analyseLinkStr:linkStr];
    };
    //[tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.type == TopicEditTypeFeedBack ? [TopicPreviewCell cellHeightWithObj:self.curProTopic] : [TopicPreviewCell cellHeightWithObjWithLabel:self.curProTopic]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark analyseLinkStr
- (void)analyseLinkStr:(NSString *)linkStr
{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        // 跳转去网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }
}

@end
