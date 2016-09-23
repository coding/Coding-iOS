//
//  ProjectActivityListCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kProjectActivityListCell_IconHeight 33.0
#define kProjectActivityListCell_TimeIconWidth 13.0
#define kProjectActivityListCell_TimeLineWidth 2.0
#define kProjectActivityListCell_LeftPading 85
#define kProjectActivityListCell_RightPading kPaddingLeftWidth
#define kProjectActivityListCell_UpDownPading kScaleFrom_iPhone5_Desgin(10)
#define kProjectActivityListCell_TextPading 5.0
//#define kProjectActivityListCell_MaxActionHeight (40.0+kNotHigher_iOS_6_1_DIS(0))
//#define kProjectActivityListCell_MaxContentHeight (32.0+kNotHigher_iOS_6_1_DIS(0))
#define kProjectActivityListCell_MaxActionHeight 80.0
#define kProjectActivityListCell_MaxContentHeight 64.0

#define kProjectActivityListCell_TimeHeight 12.0
#define kProjectActivityListCell_ContentWidth (kScreen_Width - kProjectActivityListCell_LeftPading - kProjectActivityListCell_RightPading)

#define kProjectActivityListCell_ActionFont [UIFont systemFontOfSize:15]
#define kProjectActivityListCell_ContentFont [UIFont systemFontOfSize:13]
#define kProjectActivityListCell_TimeFont [UIFont systemFontOfSize:11]

#import "ProjectActivityListCell.h"

@interface ProjectActivityListCell ()<TTTAttributedLabelDelegate>
@property (nonatomic, strong) ProjectActivity *proAct;
@property (nonatomic, assign) BOOL haveRead, top, bottom;

@property (nonatomic, strong) UIImageView *timeIconView, *timeLineView;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation ProjectActivityListCell
- (void)configWithProAct:(ProjectActivity *)proAct haveRead:(BOOL)haveRead isTop:(BOOL)top isBottom:(BOOL)bottom{
    self.proAct = proAct;
    _haveRead = haveRead;
    _top = top;
    _bottom = bottom;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_userIconView) {
            _userIconView = [[UITapImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kProjectActivityListCell_UpDownPading, kProjectActivityListCell_IconHeight, kProjectActivityListCell_IconHeight)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        CGFloat imgRightX = CGRectGetMaxX(_userIconView.frame);
        CGFloat timeLineCenterX = imgRightX + (kProjectActivityListCell_LeftPading-imgRightX)/2;
        
        ;
                                         
        if (!_timeLineView) {
            _timeLineView = [[UIImageView alloc] initWithFrame:CGRectMake(timeLineCenterX - kProjectActivityListCell_TimeLineWidth/2, 0, kProjectActivityListCell_TimeLineWidth, 1)];
            //        _timeLineView.contentMode = UIViewContentModeScaleToFill;
            [self.contentView addSubview:_timeLineView];
        }
        if (!_timeIconView) {
            _timeIconView = [[UIImageView alloc] initWithFrame:CGRectMake(timeLineCenterX - kProjectActivityListCell_TimeIconWidth/2, 10+(kProjectActivityListCell_IconHeight- kProjectActivityListCell_TimeIconWidth)/2 , kProjectActivityListCell_TimeIconWidth, kProjectActivityListCell_TimeIconWidth)];
            [self.contentView addSubview:_timeIconView];
        }
        if (!_actionLabel) {
            _actionLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kProjectActivityListCell_LeftPading, kProjectActivityListCell_UpDownPading, kProjectActivityListCell_ContentWidth, 20)];
            _actionLabel.backgroundColor = [UIColor clearColor];
            _actionLabel.textColor = kColor222;
            _actionLabel.font = kProjectActivityListCell_ActionFont;
            _actionLabel.linkAttributes = kLinkAttributes;
            _actionLabel.activeLinkAttributes = kLinkAttributesActive;
            _actionLabel.delegate = self;
            [self.contentView addSubview:_actionLabel];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kProjectActivityListCell_LeftPading, 0, kProjectActivityListCell_ContentWidth, 20)];
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x555555"];
            _contentLabel.font = kProjectActivityListCell_ContentFont;
//            _contentLabel.linkAttributes = kLinkAttributes;
//            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            _contentLabel.delegate = self;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kProjectActivityListCell_LeftPading, 0, kProjectActivityListCell_ContentWidth, kProjectActivityListCell_TimeHeight)];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.font = kProjectActivityListCell_TimeFont;
            _timeLabel.textColor = kColor999;
            [self.contentView addSubview:_timeLabel];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_proAct) {
        return;
    }
//    头像
    CGFloat cellHeight = [ProjectActivityListCell cellHeightWithObj:_proAct];
    [_userIconView sd_setImageWithURL:[_proAct.user.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    
//    时间轴Line
    CGRect frame = _timeLineView.frame;
    if (_top) {
        frame.origin.y = 10+kProjectActivityListCell_IconHeight/2;
        if (_bottom) {
            frame.size.height = 0;
        }else{
            frame.size.height = cellHeight -frame.origin.y;
        }
    }else{
        frame.origin.y = 0;
        if (_bottom) {
            frame.size.height = 10+kProjectActivityListCell_IconHeight/2;
        }else{
            frame.size.height = cellHeight;
        }
    }
    _timeLineView.frame = frame;
//    [_timeLineView setHeight:cellHeight];
    [_timeLineView setImage:[UIImage imageNamed:(_haveRead? @"timeline_line_read" : @"timeline_line_unread")]];
//    时间轴Icon
    [_timeIconView setImage:[UIImage imageNamed:(_haveRead? @"timeline_icon_read" : @"timeline_icon_unread")]];
    
//    行为
    CGFloat curBottomY = kProjectActivityListCell_UpDownPading;

    [_actionLabel setLongString:_proAct.actionStr withFitWidth:kProjectActivityListCell_ContentWidth maxHeight:kProjectActivityListCell_MaxActionHeight];
    for (HtmlMediaItem *item in _proAct.actionMediaItems) {
        if (item.displayStr.length > 0 && item.href.length > 0) {
            [self.actionLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }

    curBottomY += [_proAct.actionStr getHeightWithFont:kProjectActivityListCell_ActionFont constrainedToSize:CGSizeMake(kProjectActivityListCell_ContentWidth, kProjectActivityListCell_MaxActionHeight)];
    curBottomY += kProjectActivityListCell_TextPading;
//    内容
    [_contentLabel setLongString:_proAct.contentStr withFitWidth:kProjectActivityListCell_ContentWidth maxHeight:kProjectActivityListCell_MaxContentHeight];
    [_contentLabel setY:curBottomY];
    curBottomY += [_proAct.contentStr getHeightWithFont:kProjectActivityListCell_ContentFont constrainedToSize:CGSizeMake(kProjectActivityListCell_ContentWidth, kProjectActivityListCell_MaxContentHeight)];
    curBottomY += kProjectActivityListCell_TextPading;
//    时间
    curBottomY +=5;
    if (_proAct.created_at) {
        _timeLabel.text = [_proAct.created_at stringWithFormat:@"HH:mm"];
    }else{
        _timeLabel.text = @"";
    }
    [_timeLabel setY:curBottomY];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    ProjectActivity *proAct = (ProjectActivity *)obj;
    CGFloat cellHeight = 0;
    cellHeight += kProjectActivityListCell_UpDownPading *2;
    cellHeight += MIN(kProjectActivityListCell_MaxActionHeight, [proAct.actionStr getHeightWithFont:kProjectActivityListCell_ActionFont constrainedToSize:CGSizeMake(kProjectActivityListCell_ContentWidth, kProjectActivityListCell_MaxActionHeight)]);
    cellHeight += kProjectActivityListCell_TextPading*2;
    cellHeight += MIN(kProjectActivityListCell_MaxContentHeight, [proAct.contentStr getHeightWithFont:kProjectActivityListCell_ContentFont constrainedToSize:CGSizeMake(kProjectActivityListCell_ContentWidth, kProjectActivityListCell_MaxContentHeight)]);
    cellHeight += 5+ kProjectActivityListCell_TimeHeight;
    
    return cellHeight;
}
#pragma mark TTTAttributedLabelDelegate M
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *item = [components objectForKey:@"value"];
    if (item) {
        if (_htmlItemClickedBlock) {
            _htmlItemClickedBlock(item, _proAct, (_contentLabel == label));
        }
    }
}
@end
