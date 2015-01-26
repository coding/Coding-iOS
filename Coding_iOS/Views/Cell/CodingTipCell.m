//
//  CodingTipCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCodingTipCell_WidthContent (kScreen_Width - 2*kPaddingLeftWidth - 35)
#define kCodingTipCell_FontContent [UIFont systemFontOfSize:15]

#import "CodingTipCell.h"
@interface CodingTipCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation CodingTipCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, 25, 25)];
            [self.contentView addSubview:_iconView];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +35, 10, kCodingTipCell_WidthContent, 20)];
            _contentLabel.font = kCodingTipCell_FontContent;
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            _contentLabel.delegate = self;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_timeLabel];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_curTip) {
        return;
    }
    _contentLabel.textColor = [UIColor colorWithHexString:_curTip.status.boolValue? @"0x999999" :@"0x222222"];

    CGFloat curBottomY = 10;
    _iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"tipIcon_%@", _curTip.target_type]];
    [_contentLabel setLongString:_curTip.content withFitWidth:kCodingTipCell_WidthContent];
    curBottomY += [_curTip.content getHeightWithFont:kCodingTipCell_FontContent constrainedToSize:CGSizeMake(kCodingTipCell_WidthContent, CGFLOAT_MAX)]+10;
    NSString *timeStr = [_curTip.created_at stringTimeDisplay];
    [_timeLabel setLongString:timeStr withVariableWidth:200];
    [_timeLabel setCenter:CGPointMake(kScreen_Width -(CGRectGetWidth(_timeLabel.frame)/2 +kPaddingLeftWidth), curBottomY+ CGRectGetHeight(_timeLabel.frame)/2)];
    for (HtmlMediaItem *item in _curTip.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[CodingTip class]]) {
        CodingTip *curTip = (CodingTip *)obj;
        cellHeight += 10 + [curTip.content getHeightWithFont:kCodingTipCell_FontContent constrainedToSize:CGSizeMake(kCodingTipCell_WidthContent, CGFLOAT_MAX)] +10+20;
    }
    return cellHeight;
}

#pragma mark TTTAttributedLabelDelegate M
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *item = [components objectForKey:@"value"];
    if (item && self.linkClickedBlock) {
        self.linkClickedBlock(item, _curTip);
    }
}


@end
