//
//  PRMRSearchCell.m
//  Coding_iOS
//
//  Created by jwill on 15/11/24.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kBaseCellHeight 110
#define kMRPRListCell_UserWidth 40.0
#define kDetialContentMaxHeight 36.0
#define kDetialContentWidth (kScreen_Width - 2*kPaddingLeftWidth - 12 - kMRPRListCell_UserWidth)


#import "PRMRSearchCell.h"
#import "NSString+Attribute.h"

@interface PRMRSearchCell ()
@property (strong, nonatomic) UIImageView *imgView,*arrowIcon,*timeClockIconView;
@property (strong, nonatomic) UILabel *titleLabel, *subTitleLabel,*fromL,*toL,*describeLab,*timeLabel,*statusLab;
@end


@implementation PRMRSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryNone;
        if (!_imgView) {
            _imgView = [UIImageView new];
            _imgView.layer.masksToBounds = YES;
            _imgView.layer.cornerRadius = kMRPRListCell_UserWidth/2;
            _imgView.layer.borderWidth = 0.5;
            _imgView.layer.borderColor = kColorDDD.CGColor;
            [self.contentView addSubview:_imgView];
            [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kMRPRListCell_UserWidth, kMRPRListCell_UserWidth));
                make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                make.top.equalTo(self.contentView).offset(18);
            }];
        }
        
        if (!_titleLabel) {
            _titleLabel = [UILabel new];
            _titleLabel.textColor=kColor222;
            _titleLabel.font=[UIFont boldSystemFontOfSize:16];
            [self.contentView addSubview:_titleLabel];
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imgView.mas_right).offset(12);
                make.right.equalTo(self.contentView);
                make.top.equalTo(self.contentView).offset(13);
                make.height.mas_equalTo(20);
            }];
        }
        
        if (!_describeLab) {
            _describeLab = [UILabel new];
            _describeLab.textColor = kColor666;
            _describeLab.font = [UIFont systemFontOfSize:15];
            _describeLab.numberOfLines=2;
            [self.contentView addSubview:_describeLab];
        }

        
        if (!_subTitleLabel) {
            _subTitleLabel = [UILabel new];
            _subTitleLabel.font=[UIFont boldSystemFontOfSize:12];
            _subTitleLabel.textColor=kColor999;
            [self.contentView addSubview:_subTitleLabel];
//            [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.right.height.equalTo(_titleLabel);
//                make.bottom.equalTo(self.contentView.mas_bottom).offset(-13);
//            }];
        }
        
        if (!self.timeClockIconView) {
            self.timeClockIconView = [UIImageView new];
            self.timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:self.timeClockIconView];
            [self.timeClockIconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_subTitleLabel);
                make.size.mas_equalTo(CGSizeMake(12, 12));
                make.left.equalTo(_subTitleLabel.mas_right).offset(6);
            }];
        }
        
        if (!self.timeLabel) {
            self.timeLabel = [UILabel new];
            self.timeLabel.font = [UIFont boldSystemFontOfSize:12];
            self.timeLabel.textAlignment = NSTextAlignmentLeft;
            self.timeLabel.textColor = kColor999;
            [self.contentView addSubview:self.timeLabel];
        }
        
        if (!self.statusLab) {
            self.statusLab = [UILabel new];
            self.statusLab.font = [UIFont boldSystemFontOfSize:12];
            self.statusLab.textAlignment = NSTextAlignmentLeft;
            self.statusLab.textColor = [UIColor colorWithHexString:@"0xFB3B30"];
            [self.contentView addSubview:self.statusLab];
            [self.statusLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_subTitleLabel);
                make.height.equalTo(@(15));
                make.left.equalTo(_timeLabel.mas_right).offset(6);
                make.right.lessThanOrEqualTo(self.contentView).offset(-4);
            }];
        }

        if (!_fromL) {
            _fromL = [UILabel new];
            _fromL.backgroundColor = [UIColor colorWithHexString:@"0xF2F4F6"];
            _fromL.cornerRadius = 2;
            _fromL.masksToBounds = YES;
            _fromL.font = [UIFont systemFontOfSize:12];
            _fromL.textColor = [UIColor colorWithHexString:@"0x76808E"];
            [self.contentView addSubview:_fromL];
        }
        
        if (!_arrowIcon) {
            _arrowIcon = [UIImageView new];
            _arrowIcon.image = [UIImage imageNamed:@"mrpr_icon_arrow"];
            [self.contentView addSubview:_arrowIcon];
        }
        
        if (!_toL) {
            _toL = [UILabel new];
            _toL.backgroundColor = [UIColor colorWithHexString:@"0xD8DDE4"];
            _toL.cornerRadius = 2;
            _toL.masksToBounds = YES;
            _toL.font = [UIFont systemFontOfSize:12];
            _toL.textColor = [UIColor colorWithHexString:@"0x76808E"];
            [self.contentView addSubview:_toL];
        }
        
        [_fromL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel);
            make.top.equalTo(_titleLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(20);
        }];
        
        [_arrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_fromL.mas_right).offset(10);
            make.centerY.equalTo(_fromL);
            make.size.mas_equalTo(CGSizeMake(15, 15));
            make.right.lessThanOrEqualTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
    }
    return self;
}

- (void)setCurMRPR:(MRPR *)curMRPR{
    _curMRPR = curMRPR;
    if (!_curMRPR) {
        return;
    }
    [_imgView sd_setImageWithURL:[_curMRPR.author.avatar urlImageWithCodePathResize:2*kMRPRListCell_UserWidth] placeholderImage:kPlaceholderMonkeyRoundWidth(2*kMRPRListCell_UserWidth)];
    _titleLabel.attributedText = [NSString getAttributeFromText:[_curMRPR.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
//    _subTitleLabel.attributedText = [self attributeTail];
    _subTitleLabel.text=[NSString stringWithFormat:@"#%@ %@", [_curMRPR.iid stringValue], _curMRPR.author.name? _curMRPR.author.name: @""];
    [_subTitleLabel setLongString:_subTitleLabel.text withVariableWidth:kScreen_Width / 2];
    [_subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-13);
    }];
    
    _timeLabel.text=_curMRPR.created_at? [_curMRPR.created_at stringDisplay_HHmm]: @"";
    [_timeLabel setLongString:_timeLabel.text withVariableWidth:kScreen_Width / 2];
    [_timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_timeClockIconView.mas_right).offset(3);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-13);
    }];

    _statusLab.text= _curMRPR.statusDisplay;
    
    NSString *fromStr, *toStr;
    if (_curMRPR.isMR) {
        fromStr = [NSString stringWithFormat:@"  %@  ", _curMRPR.source_branch];
        toStr = [NSString stringWithFormat:@"  %@  ", _curMRPR.target_branch];
    }else{
        fromStr = [NSString stringWithFormat:@"  %@ : %@  ", _curMRPR.author.name, _curMRPR.source_branch];
        toStr = [NSString stringWithFormat:@"  %@ : %@  ", _curMRPR.des_owner_name, _curMRPR.target_branch];
    }
    
    NSString *totalStr = [NSString stringWithFormat:@"%@%@", fromStr, toStr];
    if ([totalStr getWidthWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)] + 40 > kScreen_Width - 2*kPaddingLeftWidth) {
        [_toL mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel);
            make.top.equalTo(_fromL.mas_bottom).offset(15);
            make.height.equalTo(_fromL);
            make.right.lessThanOrEqualTo(self.contentView).offset(-5);
        }];
    }else{
        [_toL mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_arrowIcon.mas_right).offset(10);
            make.top.equalTo(_fromL);
            make.height.top.equalTo(_fromL);
            make.right.lessThanOrEqualTo(self.contentView).offset(-5);
        }];
    }
    
    [_describeLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.top.equalTo(_toL.mas_bottom).offset(8);
        make.height.equalTo(@([PRMRSearchCell contentLabelHeightWithPRMR:_curMRPR]+2));
        make.width.equalTo(@(kDetialContentWidth));
    }];
    
//    _fromL.attributedText = [NSString getAttributeFromText:[fromStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
//    _toL.attributedText =  [NSString getAttributeFromText:[toStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
    _fromL.text = [NSString getStr:fromStr removeEmphasize:@"em"];
    _toL.text = [NSString getStr:toStr removeEmphasize:@"em"];
    _describeLab.attributedText=[NSString getAttributeFromText:[[_curMRPR.body firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
}


- (NSAttributedString *)attributeTail{
    NSString *numStr = [_curMRPR.iid stringValue];
    NSString *nameStr = _curMRPR.author.name? _curMRPR.author.name: @"";
    NSString *timeStr = _curMRPR.created_at? [_curMRPR.created_at stringDisplay_HHmm]: @"";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"#%@ %@ %@",numStr, nameStr, timeStr]];
//    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
//                                NSForegroundColorAttributeName : kColor222}
//                        range:NSMakeRange(0, nameStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                NSForegroundColorAttributeName : kColor999}
                        range:NSMakeRange(0,numStr.length+timeStr.length+nameStr.length+3)];
    return attrString;
}


+ (CGFloat)cellHeightWithObj:(id)obj {
    MRPR *mrpr = (MRPR *)obj;
    NSString *fromStr, *toStr;
    if (mrpr.isMR) {
        fromStr = [NSString stringWithFormat:@"  %@  ", mrpr.source_branch];
        toStr = [NSString stringWithFormat:@"  %@  ", mrpr.target_branch];
    }else{
        fromStr = [NSString stringWithFormat:@"  %@ : %@  ", mrpr.author.name, mrpr.source_branch];
        toStr = [NSString stringWithFormat:@"  %@ : %@  ", mrpr.des_owner_name, mrpr.target_branch];
    }
    
    NSString *totalStr = [NSString stringWithFormat:@"%@%@", fromStr, toStr];
    
    float offset= ([totalStr getWidthWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)] + 40 > kScreen_Width - 2*kPaddingLeftWidth)?(15+20):0;
    
    return kBaseCellHeight+[PRMRSearchCell contentLabelHeightWithPRMR:mrpr]+offset;
}

+ (CGFloat)contentLabelHeightWithPRMR:(MRPR *)curMRPR{
    NSString *content = [curMRPR.body firstObject];
    NSString *realContent=[NSString getStr:content removeEmphasize:@"em"];
    CGFloat realheight = [realContent getHeightWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(kDetialContentWidth, 1000)];
    return MIN(realheight, kDetialContentMaxHeight);
}
@end
