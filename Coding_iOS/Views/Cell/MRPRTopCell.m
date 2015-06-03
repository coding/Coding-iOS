//
//  MRPRTopCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kMRPRActionView_Height 35.0
#define kMRPRTopCell_FontTitle [UIFont boldSystemFontOfSize:18]

#import "MRPRTopCell.h"

@interface MRPRTopCell ()
@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *titleL, *timeL, *statusL;

@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UILabel *fromL, *toL;
@property (strong, nonatomic) UIImageView *arrowIcon;
@property (strong, nonatomic) MRPRActionView *actionView;
@end

@implementation MRPRTopCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
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
        if (!_titleL) {
            _titleL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 15,  curWidth, 30)];
            _titleL.textColor = [UIColor colorWithHexString:@"0x222222"];
            _titleL.font = kMRPRTopCell_FontTitle;
            [self.contentView addSubview:_titleL];
        }
        if (!_timeL) {
            _timeL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +25, 0, curWidth, 20)];
            _timeL.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeL.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeL];
            [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_userIconView.mas_right).offset(5);
                make.centerY.equalTo(_userIconView);
                make.height.mas_equalTo(20);
            }];
        }
        if (!_statusL) {
            _statusL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +25, 0, curWidth, 20)];
            _statusL.textColor = [UIColor colorWithHexString:@"0xFB3B30"];
            _statusL.font = [UIFont systemFontOfSize:12];
            _statusL.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_statusL];
            [_statusL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_timeL.mas_right).offset(10);
                make.centerY.height.equalTo(_timeL);
                make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
                make.width.mas_equalTo(80);
            }];
        }

        if (!_lineView) {
            _lineView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, 0.5)];
            _lineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_line"]];
            [self.contentView addSubview:_lineView];
            [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_userIconView);
                make.right.equalTo(_statusL);
                make.height.mas_equalTo(0.5);
                make.top.equalTo(_userIconView.mas_bottom).offset(15);
            }];
        }
        
        if (!_fromL) {
            _fromL = [UILabel new];
            [_fromL doBorderWidth:0.5 color:[UIColor colorWithHexString:@"0x4E90BF"] cornerRadius:2.0];
            [self.contentView addSubview:_fromL];
            [_fromL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_userIconView);
                make.top.equalTo(_lineView.mas_bottom).offset(15);
                make.height.mas_equalTo(20);
            }];
        }
        if (!_arrowIcon) {
            _arrowIcon = [UIImageView new];
            _arrowIcon.image = [UIImage imageNamed:@"mrpr_icon_arrow"];
            [_arrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_fromL.mas_right);
                make.centerY.equalTo(_fromL);
            }];
        }
        if (!_toL) {
            _toL = [UILabel new];
            [_toL doBorderWidth:0.5 color:[UIColor colorWithHexString:@"0x4E90BF"] cornerRadius:2.0];
            [self.contentView addSubview:_toL];
            [_toL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_arrowIcon.mas_right);
                make.height.centerY.equalTo(_fromL);
            }];
        }
        
    }
    return self;
}

- (void)setCurMRPRInfo:(MRPRBaseInfo *)curMRPRInfo{
    _curMRPRInfo = curMRPRInfo;
    if (!_curMRPRInfo) {
        return;
    }
    CGFloat curBottomY = 0;
    CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
    [_titleL setLongString:_curMRPRInfo.mrpr.title withFitWidth:curWidth];
    
    curBottomY += CGRectGetMaxY(_titleL.frame) + 15;
    
    [_userIconView sd_setImageWithURL:[_curMRPRInfo.mrpr.author.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    [_userIconView setY:curBottomY];
    
    _timeL.attributedText = _curMRPRInfo.mrpr.attributeTail;
    _statusL.text =  _curMRPRInfo.mrpr.statusDisplay;
    
    NSString *fromStr, *toStr;
    if (_curMRPRInfo.mrpr.isMR) {
        fromStr = _curMRPRInfo.mrpr.srcBranch;
        toStr = _curMRPRInfo.mrpr.desBranch;
    }else{
        fromStr = [NSString stringWithFormat:@"%@ : %@", _curMRPRInfo.mrpr.src_owner_name, _curMRPRInfo.mrpr.srcBranch];
        toStr = [NSString stringWithFormat:@"%@ : %@", _curMRPRInfo.mrpr.des_owner_name, _curMRPRInfo.mrpr.desBranch];
    }
    _fromL.attributedText = [self p_styleStr:fromStr];
    _toL.attributedText = [self p_styleStr:toStr];
    
    if (_curMRPRInfo.mrpr.status >= MRPRStatusAccept ) {
        if (!_actionView) {
            _actionView = [MRPRActionView new];
            [_actionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(_lineView);
                make.height.mas_equalTo(kMRPRActionView_Height);
                make.top.equalTo(_fromL.mas_bottom).offset(15);
            }];
        }
        [_actionView setStatus:_curMRPRInfo.mrpr.status userName:_curMRPRInfo.mrpr.action_author.name actionDate:_curMRPRInfo.mrpr.action_at];
        _actionView.hidden = NO;
    }else{
        _actionView.hidden = YES;
    }
}

- (NSAttributedString *)p_styleStr:(NSString *)str{
    if (str.length <= 0) {
        return nil;
    }
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.headIndent = 10;
    style.tailIndent = 10;
    style.alignment = NSTextAlignmentCenter;
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x4E90BF"],NSParagraphStyleAttributeName : style}
                         range:NSMakeRange(0, attrString.length)];

    return attrString;
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[MRPRBaseInfo class]]) {
        MRPRBaseInfo *curMRPRInfo = (MRPRBaseInfo *)obj;
        CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
        cellHeight += 8 + [curMRPRInfo.mrpr.title getHeightWithFont:kMRPRTopCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)];
        cellHeight += 15 + 15 + 20 + 15 + 15 + 20 + 15;
        if (curMRPRInfo.mrpr.status >= MRPRStatusAccept ) {
            cellHeight += kMRPRActionView_Height + 15;
        }
    }
    return cellHeight;
}

@end


#pragma mark MRPRActionView
@interface MRPRActionView ()
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *contentL;
@end

@implementation MRPRActionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xfafafa"];
        self.frame = CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - 2*kPaddingLeftWidth, kMRPRActionView_Height);
        if (!_icon) {
            _icon = [UIImageView new];
            [self addSubview:_icon];
            [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(30);
                make.centerY.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(20, 20));
            }];
        }
        if (!_contentL) {
            _contentL = [UILabel new];
            [self addSubview:_contentL];
            [_contentL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_icon.mas_right).offset(10);
                make.top.bottom.right.equalTo(self).offset(10);
            }];
        }
    }
    return self;
}

- (void)setStatus:(MRPRStatus)status userName:(NSString *)userName actionDate:(NSDate *)actionDate{
    NSString *imageStr, *contentStr;
    switch (status) {
        case MRPRStatusAccept:
            imageStr = @"mrpr_icon_open";
            contentStr = @"合并";
            break;
        case MRPRStatusRefuse:
            imageStr = @"mrpr_icon_refause";
            contentStr = @"拒绝";
            break;
        case MRPRStatusCancel:
            imageStr = @"mrpr_icon_cancel";
            contentStr = @"取消";
            break;
        default:
            return;
            break;
    }
    [_icon setImage:[UIImage imageNamed:imageStr]];
    contentStr = [NSString stringWithFormat:@"%@ %@ %@了这个请求", userName, [actionDate stringTimesAgo], contentStr];
    NSMutableAttributedString *attrContentStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
    [attrContentStr addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                    NSForegroundColorAttributeName : [UIColor colorWithHexString:@"ox222222"]}
                            range:NSMakeRange(0, userName.length)];
    [attrContentStr addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                    NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x999999"]}
                            range:NSMakeRange(userName.length, attrContentStr.length - userName.length)];
    _contentL.attributedText = attrContentStr;
}


@end