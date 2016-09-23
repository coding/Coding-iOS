//
//  TopicPreviewCell.m
//  Coding_iOS
//
//  Created by 周文敏 on 15/4/20.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kTopicContentCell_FontTitle [UIFont boldSystemFontOfSize:18]
#define kTopicContentCell_FontContent [UIFont systemFontOfSize:15]

#import "TopicPreviewCell.h"
#import "WebContentManager.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTag.h"
#import "ProjectTagsView.h"

@interface TopicPreviewCell () <UIWebViewDelegate>

@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *titleLabel, *timeLabel;
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) ProjectTagsView *tagsView;
//@property (strong, nonatomic) UIView *lineView;

@end

@implementation TopicPreviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 20, 20)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        CGFloat curWidth = kScreen_Width - 2 * kPaddingLeftWidth;
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 15,  curWidth, 30)];
            _titleLabel.textColor = kColor222;
            _titleLabel.font = kTopicContentCell_FontTitle;
            [self.contentView addSubview:_titleLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +25, 0, curWidth, 20)];
            _timeLabel.textColor = kColor999;
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
        if (!_tagsView) {
            _tagsView = [ProjectTagsView viewWithTags:nil];
            @weakify(self);
            _tagsView.addTagBlock = ^(){
                @strongify(self);
                [self addtitleBtnClick];
            };
            _tagsView.deleteTagBlock = ^(ProjectTag *curTag){
                @strongify(self);
                [self deleteTag:curTag];
            };
            [self.contentView addSubview:_tagsView];
        }
//        if (!_lineView) {
//            _lineView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, 1)];
//            _lineView.backgroundColor = kColorTableSectionBg;
//            [self.contentView addSubview:_lineView];
//        }
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

- (void)setCurTopic:(ProjectTopic *)curTopic
{
    if (curTopic) {
        _curTopic = curTopic;
    }
    
    CGFloat curBottomY = 0;
    CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
    [_titleLabel setLongString:_curTopic.mdTitle withFitWidth:curWidth];
    
    curBottomY += CGRectGetMaxY(_titleLabel.frame) + 15;
    
    if (!_isLabel) {
        _userIconView.hidden = TRUE;
        _timeLabel.hidden = TRUE;
        _tagsView.hidden = YES;
        
        // 讨论的内容
        [self.webContentView setY:curBottomY];
        [self.activityIndicator setCenter:CGPointMake(self.webContentView.center.x, curBottomY + 10)];
        [self.webContentView setHeight:_curTopic.contentHeight];
        
        if (!_webContentView.isLoading) {
            [_activityIndicator startAnimating];
            @weakify(self);
            [[Coding_NetAPIManager sharedManager] request_MDHtmlStr_WithMDStr:_curTopic.mdContent inProject:_curTopic.project andBlock:^(id data, NSError *error) {
                @strongify(self);
                NSString *htmlStr = data ? data : error.description;
                //NSString *contentStr = [WebContentManager markdownPatternedWithContent:htmlStr];
                NSString *contentStr = [WebContentManager topicPatternedWithContent:htmlStr];
                [self.webContentView loadHTMLString:contentStr baseURL:nil];
            }];
        }
        return;
    }else{
        [_userIconView sd_setImageWithURL:[_curTopic.owner.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
        [_userIconView setY:curBottomY];
        [_timeLabel setY:curBottomY];
        _timeLabel.attributedText = [self getStringWithName:_curTopic.owner.name andTime:[_curTopic.created_at stringDisplay_HHmm]];
        curBottomY += 16 + 20;
        _tagsView.tags = _curTopic.mdLabels;
        [_tagsView setY:curBottomY];

    }

    //[_lineView setY:curBottomY];
 
    // 讨论的内容
    curBottomY += CGRectGetHeight(_tagsView.frame);
    [self.webContentView setY:curBottomY];
    [self.activityIndicator setCenter:CGPointMake(self.webContentView.center.x, curBottomY + 10)];
    [self.webContentView setHeight:_curTopic.contentHeight];
    
    if (!_webContentView.isLoading) {
        [_activityIndicator startAnimating];
        @weakify(self);
        [[Coding_NetAPIManager sharedManager] request_MDHtmlStr_WithMDStr:_curTopic.mdContent inProject:_curTopic.project andBlock:^(id data, NSError *error) {
            @strongify(self);
            NSString *htmlStr = data ? data : error.description;
            //NSString *contentStr = [WebContentManager markdownPatternedWithContent:htmlStr];
            NSString *contentStr = [WebContentManager topicPatternedWithContent:htmlStr];
            [self.webContentView loadHTMLString:contentStr baseURL:nil];
        }];
    }
}

- (void)deleteTag:(ProjectTag *)curTag
{
    curTag = [ProjectTag tags:_curTopic.mdLabels hasTag:curTag];
    if (curTag) {
        [_curTopic.mdLabels removeObject:curTag];
        [self setCurTopic:_curTopic];
        if (_delLabelBlock) {
            _delLabelBlock();
        }
    }
}

- (NSMutableAttributedString*)getStringWithName:(NSString *)nameStr andTime:(NSString *)timeStr
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ 发布于 %@", nameStr, timeStr]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                 NSForegroundColorAttributeName : kColor222}
                         range:NSMakeRange(0, nameStr.length)];
    
    [attrString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                 NSForegroundColorAttributeName : kColor999}
                         range:NSMakeRange(nameStr.length, attrString.length - nameStr.length)];
    return  attrString;
}

+ (CGFloat)cellHeightWithObj:(id)obj
{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[ProjectTopic class]]) {
        ProjectTopic *topic = (ProjectTopic *)obj;
        CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
        cellHeight += 8 + [topic.title getHeightWithFont:kTopicContentCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 16 + 20;
        cellHeight += topic.contentHeight + 5;
    }
    return cellHeight;
}

+ (CGFloat)cellHeightWithObjWithLabel:(id)obj
{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[ProjectTopic class]]) {
        ProjectTopic *topic = (ProjectTopic *)obj;
        CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
        cellHeight += 8 + [topic.title getHeightWithFont:kTopicContentCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 16 + 20;

        cellHeight += [ProjectTagsView getHeightForTags:topic.mdLabels];
        cellHeight += topic.contentHeight + 50;
    }
    return cellHeight;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *strLink = request.URL.absoluteString;
    DebugLog(@"strLink=[%@]", strLink);
    if ([strLink rangeOfString:@"about:blank"].location != NSNotFound) {
        return YES;
    } else {
        if (_clickedLinkStrBlock) {
            _clickedLinkStrBlock(strLink);
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
    CGFloat scrollHeight = webView.scrollView.contentSize.height;
    if (ABS(scrollHeight - _curTopic.contentHeight) > 5) {
        webView.scalesPageToFit = YES;
        _curTopic.contentHeight = scrollHeight;
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
        //        NSString *js = @"window.onload = function(){ document.body.style.backgroundColor = '#333333';}";
        //        [_webContentView stringByEvaluatingJavaScriptFromString:js];
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webContentView.frame)];
        [_webContentView stringByEvaluatingJavaScriptFromString:meta];
    }
}

#pragma mark - click
- (void)addtitleBtnClick
{
    if (_addLabelBlock) {
        _addLabelBlock();
    }
}

@end
