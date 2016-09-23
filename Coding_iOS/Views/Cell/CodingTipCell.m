//
//  CodingTipCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCodingTipCell_WidthContent (kScreen_Width - padding_left - kPaddingLeftWidth)
#define kCodingTipCell_FontContent [UIFont systemFontOfSize:15]

#import "CodingTipCell.h"
@interface CodingTipCell ()
@property (strong, nonatomic) UITapImageView *ownerImgView;
@property (strong, nonatomic) UILabel *ownerL;
@property (strong, nonatomic) UIButton *ownerNameBtn;
@property (strong, nonatomic) UILabel *timeLabel;


@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;

@property (strong, nonatomic) UIButton *targetBgBtn;
@property (strong, nonatomic) UIImageView *targetIconView;
@property (strong, nonatomic) UILabel *targetLabel;
@end

@implementation CodingTipCell

//static CGFloat user_icon_width = 35.0;
static CGFloat padding_height = 45;
static CGFloat padding_left = 30.0;
static CGFloat padding_between_content = 15.0;
static CGFloat target_height = 45.0;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        if (!self.ownerImgView) {
//            self.ownerImgView = [[UITapImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 15, user_icon_width, user_icon_width)];
//            [self.ownerImgView doCircleFrame];
//            
//            _ownerL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, user_icon_width, user_icon_width)];
//            _ownerL.backgroundColor = [UIColor clearColor];
//            _ownerL.font = [UIFont fontWithName:@"Chalkduster" size:20];
////            _ownerL.font = [UIFont fontWithName:@"PartyLetPlain" size:20];
////            _ownerL.font = [UIFont systemFontOfSize:20];
////            PartyLetPlain
////            Chalkduster
//            _ownerL.textColor = kColor999;
//            _ownerL.textAlignment = NSTextAlignmentCenter;
//            [self.ownerImgView addSubview:_ownerL];
//
//            @weakify(self);
//            [_ownerImgView addTapBlock:^(id obj) {
//                @strongify(self);
//                [self userBtnClicked];
//            }];
//            [self.contentView addSubview:self.ownerImgView];
//        }
        if (!self.ownerNameBtn) {
            self.ownerNameBtn = [UIButton buttonWithUserStyle];
            self.ownerNameBtn.frame = CGRectMake(padding_left, 15, 50, 20);
            [self.ownerNameBtn addTarget:self action:@selector(userBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.ownerNameBtn];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 100, 15, 100, 15)];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.textColor = kColor999;
            _timeLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_timeLabel];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(padding_left, padding_height, kCodingTipCell_WidthContent, 20)];
            _contentLabel.font = kCodingTipCell_FontContent;
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.textColor = kColor222;
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            _contentLabel.delegate = self;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_targetBgBtn) {
            _targetBgBtn = [[UIButton alloc] initWithFrame:CGRectMake(padding_left, 0, kCodingTipCell_WidthContent, target_height)];
            [_targetBgBtn setBackgroundColor:kColorTableSectionBg];
            //target_icon
            _targetIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, target_height, target_height)];
            _targetIconView.contentMode = UIViewContentModeCenter;
            [_targetBgBtn addSubview:_targetIconView];
            //target_content
            _targetLabel = [[UILabel alloc] initWithFrame:CGRectMake(target_height + 10, 0, kCodingTipCell_WidthContent - target_height - 10, target_height)];
            _targetLabel.textColor = kColor222;
            _targetLabel.font = [UIFont systemFontOfSize:14];
            _targetLabel.numberOfLines = 0;
//            _targetLabel.userInteractionEnabled = NO;
            [_targetBgBtn addSubview:_targetLabel];
            
            [self.targetBgBtn addTarget:self action:@selector(targetBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_targetBgBtn];
        }

    }
    return self;
}

- (void)setCurTip:(CodingTip *)curTip{
    _curTip = curTip;
    if (!_curTip) {
        return;
    }
    //owner头像
//    [self.ownerImgView sd_setImageWithURL:[@"" urlImageWithCodePathResizeToView:_ownerImgView] placeholderImage:kPlaceholderMonkeyRoundWidth(40.0)];
    NSString *userName = curTip.user_item.displayStr;
    
//    NSString *pinyin = [userName transformToPinyin];
////    NSString *pinyin = userName;
//    NSString *username_first = pinyin.length > 0? [[pinyin substringToIndex:1] uppercaseString]: @"C";
//    _ownerL.text = username_first;
    //owner姓名
    [self.ownerNameBtn setTitleColor:[UIColor colorWithHexString:curTip.user_item.type != HtmlMediaItemType_CustomLink? @"0x3bbd79": @"0x222222"] forState:UIControlStateNormal];
    [self.ownerNameBtn setUserTitle:userName font:[UIFont systemFontOfSize:17] maxWidth:(kCodingTipCell_WidthContent -80)];
    //时间
//    _timeLabel.text = _curTip.target_type;
    _timeLabel.text = [_curTip.created_at stringDisplay_HHmm];

    //content
    [_contentLabel setLongString:_curTip.content withFitWidth:kCodingTipCell_WidthContent];
    for (HtmlMediaItem *item in _curTip.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && item.href.length > 0) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    //target
    if (_curTip.target_item) {
        _targetBgBtn.hidden = NO;
        CGFloat curBottomY = padding_height;
        curBottomY += _curTip.content.length > 0? [_curTip.content getHeightWithFont:kCodingTipCell_FontContent constrainedToSize:CGSizeMake(kCodingTipCell_WidthContent, CGFLOAT_MAX)] + padding_between_content: 0;;
        
        [_targetIconView setBackgroundColor:[UIColor colorWithHexString:_curTip.target_type_ColorName]];
        [_targetIconView setImage:[UIImage imageNamed:_curTip.target_type_imageName]];
        _targetLabel.text = _curTip.target_item.displayStr;
        [_targetBgBtn setY:curBottomY];
    }else{
        _targetBgBtn.hidden = YES;
    }
    //unread
    [self.contentView addBadgeTip:_curTip.status.boolValue? @"": kBadgeTipStr withCenterPosition:CGPointMake(kPaddingLeftWidth + 4.0, _ownerNameBtn.center.y)];
}

- (void)targetBtnClicked{
    if (self.curTip.target_item && self.linkClickedBlock) {
        self.linkClickedBlock(self.curTip.target_item, self.curTip);
    }
}
- (void)userBtnClicked{
    if (self.curTip.user_item && self.linkClickedBlock) {
        self.linkClickedBlock(self.curTip.user_item, self.curTip);
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[CodingTip class]]) {
        CodingTip *curTip = (CodingTip *)obj;
        cellHeight = padding_height;
        cellHeight += curTip.content.length > 0? [curTip.content getHeightWithFont:kCodingTipCell_FontContent constrainedToSize:CGSizeMake(kCodingTipCell_WidthContent, CGFLOAT_MAX)] + padding_between_content: 0;
        if (curTip.target_item) {
            cellHeight += target_height + padding_between_content;
        }
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
