//
//  MRPRTopCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kMRPRActionView_Height 25.0
#define kMRPRTopCell_FontTitle [UIFont boldSystemFontOfSize:18]
#define kMRPRTopCell_FontFromTo [UIFont boldSystemFontOfSize:12]

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
        self.backgroundColor = kColorTableBG;
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 20, 20)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        CGFloat curWidth = kScreen_Width - 2 * kPaddingLeftWidth;
        if (!_titleL) {
            _titleL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 15,  curWidth, 30)];
            _titleL.textColor = kColor222;
            _titleL.font = kMRPRTopCell_FontTitle;
            [self.contentView addSubview:_titleL];
        }
        if (!_timeL) {
            _timeL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +25, 0, curWidth, 20)];
            _timeL.textColor = kColor999;
            _timeL.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeL];
        }
        if (!_statusL) {
            _statusL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +25, 0, curWidth, 20)];
            _statusL.textColor = [UIColor colorWithHexString:@"0xFB3B30"];
            _statusL.font = [UIFont systemFontOfSize:12];
            _statusL.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_statusL];
        }

        if (!_lineView) {
            _lineView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, 0.5)];
            _lineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_line"]];
            [self.contentView addSubview:_lineView];
        }
        
        if (!_fromL) {
            _fromL = [UILabel new];
            [_fromL doBorderWidth:0.5 color:[UIColor colorWithHexString:@"0x4E90BF"] cornerRadius:2.0];
            _fromL.font = kMRPRTopCell_FontFromTo;
            _fromL.textColor = [UIColor colorWithHexString:@"0x4E90BF"];
            [self.contentView addSubview:_fromL];
        }
        if (!_arrowIcon) {
            _arrowIcon = [UIImageView new];
            _arrowIcon.image = [UIImage imageNamed:@"mrpr_icon_arrow"];
            [self.contentView addSubview:_arrowIcon];
        }
        if (!_toL) {
            _toL = [UILabel new];
            [_toL doBorderWidth:0.5 color:[UIColor colorWithHexString:@"0x4E90BF"] cornerRadius:2.0];
            _toL.font = kMRPRTopCell_FontFromTo;
            _toL.textColor = [UIColor colorWithHexString:@"0x4E90BF"];
            [self.contentView addSubview:_toL];
        }
        
        {
            [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_userIconView.mas_right).offset(5);
                make.centerY.equalTo(_userIconView);
                make.height.mas_equalTo(_userIconView.mas_height);
            }];
            
            [_statusL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_timeL.mas_right).offset(10);
                make.centerY.height.equalTo(_timeL);
                make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
                make.width.mas_equalTo(80);
            }];
            [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_userIconView);
                make.right.equalTo(_statusL);
                make.height.mas_equalTo(0.5);
                make.top.equalTo(_userIconView.mas_bottom).offset(15);
            }];
            [_fromL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_userIconView);
                make.top.equalTo(_lineView.mas_bottom).offset(15);
                make.height.mas_equalTo(20);
            }];
            [_arrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_fromL.mas_right).offset(10);
                make.centerY.equalTo(_fromL);
                make.size.mas_equalTo(CGSizeMake(15, 15));
                make.right.lessThanOrEqualTo(self.contentView).offset(-kPaddingLeftWidth);
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
    
    _timeL.attributedText = [self attributeTail];
    _statusL.text =  _curMRPRInfo.mrpr.statusDisplay;
    
    NSString *fromStr, *toStr;
    if (_curMRPRInfo.mrpr.isMR) {
        fromStr = [NSString stringWithFormat:@"  %@  ", _curMRPRInfo.mrpr.srcBranch];
        toStr = [NSString stringWithFormat:@"  %@  ", _curMRPRInfo.mrpr.desBranch];
    }else{
        fromStr = [NSString stringWithFormat:@"  %@ : %@  ", _curMRPRInfo.mrpr.src_owner_name, _curMRPRInfo.mrpr.srcBranch];
        toStr = [NSString stringWithFormat:@"  %@ : %@  ", _curMRPRInfo.mrpr.des_owner_name, _curMRPRInfo.mrpr.desBranch];
    }
    NSString *totalStr = [NSString stringWithFormat:@"%@%@", fromStr, toStr];
    if ([totalStr getWidthWithFont:kMRPRTopCell_FontFromTo constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)] + 40 > kScreen_Width - 2*kPaddingLeftWidth) {
        [_toL mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userIconView);
            make.top.equalTo(_fromL.mas_bottom).offset(15);
            make.height.equalTo(_fromL);
            make.right.lessThanOrEqualTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
    }else{
        [_toL mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_arrowIcon.mas_right).offset(10);
            make.top.equalTo(_fromL);
            make.height.top.equalTo(_fromL);
            make.right.lessThanOrEqualTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
    }
    _fromL.text = fromStr;
    _toL.text = toStr;
    
    if (_curMRPRInfo.mrpr.status == MRPRStatusAccepted || _curMRPRInfo.mrpr.status == MRPRStatusRefused) {
        if (!_actionView) {
            _actionView = [MRPRActionView new];
            [self.contentView addSubview:_actionView];
            
            [_actionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(_lineView);
                make.height.mas_equalTo(kMRPRActionView_Height);
                make.top.equalTo(_toL.mas_bottom).offset(15);
            }];
        }
        [_actionView setStatus:_curMRPRInfo.mrpr.status userName:_curMRPRInfo.mrpr.action_author.name actionDate:_curMRPRInfo.mrpr.action_at];
        _actionView.hidden = NO;
    }else{
        _actionView.hidden = YES;
    }
}

- (NSAttributedString *)attributeTail{
    NSString *nameStr = _curMRPRInfo.mrpr.author.name? _curMRPRInfo.mrpr.author.name: @"";
    NSString *timeStr = _curMRPRInfo.mrpr.created_at? [_curMRPRInfo.mrpr.created_at stringDisplay_HHmm]: @"";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", nameStr, timeStr]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                NSForegroundColorAttributeName : kColor222}
                        range:NSMakeRange(0, nameStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                NSForegroundColorAttributeName : kColor999}
                        range:NSMakeRange(nameStr.length + 1, timeStr.length)];
    return attrString;
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[MRPRBaseInfo class]]) {
        MRPRBaseInfo *curMRPRInfo = (MRPRBaseInfo *)obj;
        CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
        cellHeight += [curMRPRInfo.mrpr.title getHeightWithFont:kMRPRTopCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)];
        cellHeight += 15 + 15 + 15 + 15 + 15 + 20 + 15;
        if (curMRPRInfo.mrpr.status == MRPRStatusAccepted || curMRPRInfo.mrpr.status == MRPRStatusRefused) {
            cellHeight += kMRPRActionView_Height + 15;
        }
        
        
        NSString *fromStr, *toStr;
        if (curMRPRInfo.mrpr.isMR) {
            fromStr = [NSString stringWithFormat:@"  %@  ", curMRPRInfo.mrpr.srcBranch];
            toStr = [NSString stringWithFormat:@"  %@  ", curMRPRInfo.mrpr.desBranch];
        }else{
            fromStr = [NSString stringWithFormat:@"  %@ : %@  ", curMRPRInfo.mrpr.src_owner_name, curMRPRInfo.mrpr.srcBranch];
            toStr = [NSString stringWithFormat:@"  %@ : %@  ", curMRPRInfo.mrpr.des_owner_name, curMRPRInfo.mrpr.desBranch];
        }
        NSString *totalStr = [NSString stringWithFormat:@"%@%@", fromStr, toStr];
        if ([totalStr getWidthWithFont:kMRPRTopCell_FontFromTo constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)] + 40 > kScreen_Width - 2*kPaddingLeftWidth) {
            cellHeight += 20 + 15;
        }
        
    }
    return cellHeight;
}

@end


#pragma mark MRPRActionView
@interface MRPRActionView ()
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *contentL;
@property (strong, nonatomic) UIView *lineView;
@end

@implementation MRPRActionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = kColorNavBG;
        self.frame = CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - 2*kPaddingLeftWidth, kMRPRActionView_Height);
        if (!_icon) {
            _icon = [UIImageView new];
            [self addSubview:_icon];
        }
        if (!_contentL) {
            _contentL = [UILabel new];
            [self addSubview:_contentL];
        }
        if (!_lineView) {
            _lineView = [UIView new];
            [self addSubview:_lineView];
        }
        {
            [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(10);
                make.centerY.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(20, 20));
            }];
            [_contentL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_icon.mas_right).offset(10);
                make.right.equalTo(self).offset(10);
                make.centerY.equalTo(self);
                make.height.mas_equalTo(15);
            }];
            [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.bottom.equalTo(self);
                make.width.mas_equalTo(3);
            }];
        }
    }
    return self;
}

- (void)setStatus:(MRPRStatus)status userName:(NSString *)userName actionDate:(NSDate *)actionDate{
    NSString *imageStr, *contentStr, *lineColorStr;
    switch (status) {
        case MRPRStatusAccepted:
            imageStr = @"mrpr_icon_accepted";
            contentStr = @"合并";
            lineColorStr = @"0x3BBD79";
            break;
        case MRPRStatusRefused:
            imageStr = @"mrpr_icon_refaused";
            contentStr = @"拒绝";
            lineColorStr = @"0xFB3B30";
            break;
//        case MRPRStatusCancel:
//            imageStr = @"mrpr_icon_cancel";
//            contentStr = @"取消";
//            break;
        default:
            return;
            break;
    }
    _lineView.backgroundColor = [UIColor colorWithHexString:lineColorStr];
    [_icon setImage:[UIImage imageNamed:imageStr]];
    contentStr = [NSString stringWithFormat:@"%@ %@ %@了这个请求", userName, [actionDate stringDisplay_HHmm], contentStr];
    NSMutableAttributedString *attrContentStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
    [attrContentStr addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                    NSForegroundColorAttributeName : kColor222}
                            range:NSMakeRange(0, userName.length)];
    [attrContentStr addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                    NSForegroundColorAttributeName : kColor999}
                            range:NSMakeRange(userName.length, attrContentStr.length - userName.length)];
    _contentL.attributedText = attrContentStr;
}


@end
