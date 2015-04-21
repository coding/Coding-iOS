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
#import "ProjectTopicLabel.h"

@interface TopicPreviewCell () <UIWebViewDelegate>
{
    CGFloat _labelH;
}

@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *titleLabel, *timeLabel;
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UIView *labelView;
@property (strong, nonatomic) UIButton *labelAddBtn;

@end

@implementation TopicPreviewCell

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
        if (!_labelView) {
            _labelH = 15;
            _labelView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, _labelH)];
            [self.contentView addSubview:_labelView];
            
            _labelAddBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-44, 0, 44, 44)];
            [_labelAddBtn setImage:[UIImage imageNamed:@"tag_add"] forState:UIControlStateNormal];
            [_labelAddBtn setImageEdgeInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
            [_labelAddBtn addTarget:self action:@selector(addtitleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_labelAddBtn];
        }
        curWidth = kScreen_Width - 2*kPaddingLeftWidth;
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
        _labelAddBtn.hidden = TRUE;
        _labelView.hidden = TRUE;
        
        // 讨论的内容
        [self.webContentView setY:curBottomY];
        [self.activityIndicator setCenter:CGPointMake(self.webContentView.center.x, curBottomY + 10)];
        [self.webContentView setHeight:_curTopic.contentHeight];
        
        if (!_webContentView.isLoading) {
            [_activityIndicator startAnimating];
            @weakify(self);
            [[Coding_NetAPIManager sharedManager] request_MDHtmlStr_WithMDStr:_curTopic.mdContent andBlock:^(id data, NSError *error) {
                @strongify(self);
                NSString *htmlStr = data ? data : error.description;
                //NSString *contentStr = [WebContentManager markdownPatternedWithContent:htmlStr];
                NSString *contentStr = [WebContentManager topicPatternedWithContent:htmlStr];
                [self.webContentView loadHTMLString:contentStr baseURL:nil];
            }];
        }
        return;
    }
    
    [_userIconView sd_setImageWithURL:[_curTopic.owner.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    [_userIconView setY:curBottomY];
    [_timeLabel setY:curBottomY];
    _timeLabel.attributedText = [self getStringWithName:_curTopic.owner.name andTime:[_curTopic.created_at stringTimesAgo]];
    
    curBottomY += 20 + 20;
    
    _labelH = 15;
    if (_labelView) {
        [_labelView removeFromSuperview];
        _labelView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, _labelH)];
        [self.contentView insertSubview:_labelView belowSubview:_labelAddBtn];
    }
    [_labelAddBtn setY:curBottomY - 15];
    [_labelView setY:curBottomY];
    if (_curTopic.mdLabels.count > 0) {
        CGFloat x = 0.0f;
        CGFloat y = 0.0f;
        CGFloat limitW = kScreen_Width - kPaddingLeftWidth - 44;
        
        for (ProjectTopicLabel *label in _curTopic.mdLabels) {
            UILabel *tLbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 0, 0)];
            
            tLbl.font = [UIFont systemFontOfSize:12];
            tLbl.text = label.name;
            tLbl.textColor = kColorLabelText;
            tLbl.textAlignment = NSTextAlignmentCenter;
            tLbl.layer.cornerRadius = 10;
            tLbl.layer.backgroundColor = kColorLabelBgColor.CGColor;
            
            [tLbl sizeToFit];
            
            CGFloat width = tLbl.frame.size.width + 20;
            if (x + width > limitW) {
                y += 26.0f;
                x = 0.0f;
            }
            [tLbl setFrame:CGRectMake(x, y, width - 4, 20)];
            x += width;
            
            [_labelView addSubview:tLbl];
        }
        _labelH = y + 26;
    } else {
        UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        [iconImg setImage:[UIImage imageNamed:@"tag_icon"]];
        
        UILabel *tLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 30, 15)];
        
        tLbl.font = [UIFont systemFontOfSize:14];
        tLbl.text = @"标签";
        tLbl.textColor = kColorLabelText;
        
        [_labelView addSubview:iconImg];
        [_labelView addSubview:tLbl];
    }
    [_labelView setHeight:_labelH];
    
    curBottomY += _labelH + 3;
    
    // 讨论的内容
    [self.webContentView setY:curBottomY];
    [self.activityIndicator setCenter:CGPointMake(self.webContentView.center.x, curBottomY + 10)];
    [self.webContentView setHeight:_curTopic.contentHeight];
    
    if (!_webContentView.isLoading) {
        [_activityIndicator startAnimating];
        @weakify(self);
        [[Coding_NetAPIManager sharedManager] request_MDHtmlStr_WithMDStr:_curTopic.mdContent andBlock:^(id data, NSError *error) {
            @strongify(self);
            NSString *htmlStr = data ? data : error.description;
            //NSString *contentStr = [WebContentManager markdownPatternedWithContent:htmlStr];
            NSString *contentStr = [WebContentManager topicPatternedWithContent:htmlStr];
            [self.webContentView loadHTMLString:contentStr baseURL:nil];
        }];
    }
}

- (NSMutableAttributedString*)getStringWithName:(NSString *)nameStr andTime:(NSString *)timeStr
{
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ 发布于 %@", nameStr, timeStr]];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x222222"]}
                         range:NSMakeRange(0, nameStr.length)];
    
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x999999"]}
                         range:NSMakeRange(nameStr.length, attriString.length - nameStr.length)];
    return  attriString;
}

+ (CGFloat)cellHeightWithObj:(id)obj
{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[ProjectTopic class]]) {
        ProjectTopic *topic = (ProjectTopic *)obj;
        CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
        cellHeight += 8 + [topic.title getHeightWithFont:kTopicContentCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 20 + 20;
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
        cellHeight += 8 + [topic.title getHeightWithFont:kTopicContentCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 20 + 20;
        
        CGFloat labelH = 15;
        if (topic.mdLabels.count > 0) {
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            CGFloat limitW = kScreen_Width - kPaddingLeftWidth - 44;
            
            UILabel *tLbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 0, 0)];
            tLbl.font = [UIFont systemFontOfSize:12];
            tLbl.textAlignment = NSTextAlignmentCenter;
            
            for (ProjectTopicLabel *label in topic.mdLabels) {
                tLbl.text = label.name;
                [tLbl sizeToFit];
                
                CGFloat width = tLbl.frame.size.width + 20;
                if (x + width > limitW) {
                    y += 26.0f;
                    x = 0.0f;
                }
                x += width;
            }
            labelH = y + 26;
        }
        cellHeight += labelH + 3;
        cellHeight += topic.contentHeight + 5;
    }
    return cellHeight;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *strLink = request.URL.absoluteString;
    NSLog(@"strLink=[%@]", strLink);
    if ([strLink rangeOfString:@"about:blank"].location != NSNotFound) {
        return YES;
    } else {
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
- (void)addtitleBtnClick:(UIButton *)sender
{
    if (_addLabelBlock) {
        _addLabelBlock();
    }
}

@end
