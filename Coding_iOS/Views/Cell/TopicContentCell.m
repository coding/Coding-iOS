//
//  TopicContentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTopicContentCell_FontTitle [UIFont boldSystemFontOfSize:18]
#define kTopicContentCell_FontContent [UIFont systemFontOfSize:15]


#import "TopicContentCell.h"
#import "WebContentManager.h"

@interface TopicContentCell ()
@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *titleLabel, *timeLabel, *commentCountLabel;
@property (strong, nonatomic) UIButton *commentBtn, *deleteBtn;
@property (strong, nonatomic) UIWebView *topicContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end
@implementation TopicContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 20, 20)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 15,  curWidth, 30)];
            _titleLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _titleLabel.font = kTopicContentCell_FontTitle;
            [self.contentView addSubview:_titleLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +25, 0, curWidth, 20)];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
        curWidth = kScreen_Width - 2*kPaddingLeftWidth;
        if (!self.topicContentView) {
            self.topicContentView = [[UIWebView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, 1)];
            self.topicContentView.delegate = self;
            self.topicContentView.scrollView.scrollEnabled = NO;
            self.topicContentView.scrollView.scrollsToTop = NO;
            self.topicContentView.scrollView.bounces = NO;
            self.topicContentView.backgroundColor = [UIColor clearColor];
            self.topicContentView.opaque = NO;
            [self.contentView addSubview:self.topicContentView];
        }
        if (!_activityIndicator) {
            _activityIndicator = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
            _activityIndicator.hidesWhenStopped = YES;
            [self.contentView addSubview:_activityIndicator];
        }
        
        if (!_commentCountLabel) {
            _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 120, 20)];
            _commentCountLabel.textColor = [UIColor colorWithHexString:@"0x99999999"];
            _commentCountLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_commentCountLabel];
        }
        if (!_commentBtn) {
            _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _commentBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth - 50, 0, 50, 25);
            [_commentBtn setImage:[UIImage imageNamed:@"tweet_comment_btn"] forState:UIControlStateNormal];
            [self.commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_commentBtn];
        }
        
        if (!self.deleteBtn) {
            self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.deleteBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth - 50 - 50, 0, 50, 25);
            [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            self.deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.deleteBtn];
        }
        
    }
    return self;
}

- (void)setCurTopic:(ProjectTopic *)curTopic{
    if (curTopic) {
        _curTopic = curTopic;
    }
    
    CGFloat curBottomY = 10;
    CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth - 50;
    [_userIconView sd_setImageWithURL:[_curTopic.owner.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    [_titleLabel setLongString:_curTopic.title withFitWidth:curWidth];
    curBottomY += 15+ [_curTopic.title getHeightWithFont:kTopicContentCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)];
    
    [_userIconView setY:curBottomY];
    [_timeLabel setY:curBottomY];
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", _curTopic.owner.name, [_curTopic.created_at stringTimesAgo]];
    curBottomY += 10+ 20;
    
    //    讨论的内容
    [self.topicContentView setY:curBottomY];
    [self.topicContentView setHeight:_curTopic.contentHeight];
    if (!self.topicContentView.isLoading) {
        [_activityIndicator startAnimating];
        [self.topicContentView loadHTMLString:[WebContentManager topicPatternedWithContent:_curTopic.htmlMedia.contentOrigional] baseURL:nil];
    }
    [_activityIndicator setCenter:CGPointMake(kScreen_Width/2, curBottomY+5)];
    
    curBottomY += _curTopic.contentHeight+5;
    [_commentCountLabel setY:curBottomY+2];
    _commentCountLabel.text = [NSString stringWithFormat:@"%d条评论", _curTopic.child_count.intValue];
    [_commentBtn setY:curBottomY];
    if ([_curTopic canEdit]) {
        _deleteBtn.hidden = NO;
        [_deleteBtn setY:curBottomY];
    }else{
        _deleteBtn.hidden = YES;
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[ProjectTopic class]]) {
        ProjectTopic *topic = (ProjectTopic *)obj;
        CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth - 50;
        cellHeight += 10 + [topic.title getHeightWithFont:kTopicContentCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] +5 +20 +10;
        cellHeight += topic.contentHeight;
        cellHeight += 20+10;
        cellHeight += 15;
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
    [self refreshtopicContentView];
    [_activityIndicator stopAnimating];
    CGFloat scrollHeight = webView.scrollView.contentSize.height;
    if (ABS(scrollHeight - _curTopic.contentHeight) > 1) {
        NSLog(@"ABS(scrollHeight - _tweet.contentHeight)=========\n scrollHeight: %.2f", ABS(scrollHeight - _curTopic.contentHeight));
        webView.scalesPageToFit = YES;
        _curTopic.contentHeight = scrollHeight;
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

- (void)refreshtopicContentView{
    if (_topicContentView) {
        //        NSString *js = @"window.onload = function(){ document.body.style.backgroundColor = '#333333';}";
        //        [_topicContentView stringByEvaluatingJavaScriptFromString:js];
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_topicContentView.bounds)];
        [_topicContentView stringByEvaluatingJavaScriptFromString:meta];
    }
}
#pragma mark Btn M
- (void)commentBtnClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    if (_commentTopicBlock) {
        _commentTopicBlock(_curTopic, weakSelf);
    }
}

- (void)deleteBtnClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    if (_deleteTopicBlock) {
        _deleteTopicBlock(weakSelf.curTopic);
    }
}

@end
