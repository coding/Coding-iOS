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
#define kDetialContentWidth (kScreen_Width - 2*kPaddingLeftWidth - 12)


#import "PRMRSearchCell.h"
#import "NSString+Attribute.h"

@interface PRMRSearchCell ()
@property (strong, nonatomic) UIImageView *imgView,*arrowIcon;
@property (strong, nonatomic) UILabel *titleLabel, *subTitleLabel,*fromL,*toL,*describeLab;
@end


@implementation PRMRSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = kColorTableBG;
        if (!_imgView) {
            _imgView = [UIImageView new];
            _imgView.layer.masksToBounds = YES;
            _imgView.layer.cornerRadius = kMRPRListCell_UserWidth/2;
            _imgView.layer.borderWidth = 0.5;
            _imgView.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
            [self.contentView addSubview:_imgView];
            [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kMRPRListCell_UserWidth, kMRPRListCell_UserWidth));
                make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                make.top.equalTo(self.contentView).offset(18);
            }];
        }
        
        if (!_titleLabel) {
            _titleLabel = [UILabel new];
            _titleLabel.textColor=[UIColor colorWithHexString:@"0x222222"];
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
            _describeLab.textColor = [UIColor colorWithHexString:@"0x666666"];
            _describeLab.font = [UIFont systemFontOfSize:15];
            _describeLab.numberOfLines=2;
            [self.contentView addSubview:_describeLab];
        }

        
        if (!_subTitleLabel) {
            _subTitleLabel = [UILabel new];
            [self.contentView addSubview:_subTitleLabel];
            [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.height.equalTo(_titleLabel);
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-13);
            }];
        }
        
        if (!_fromL) {
            _fromL = [UILabel new];
            [_fromL doBorderWidth:0.5 color:[UIColor colorWithHexString:@"0x4E90BF"] cornerRadius:2.0];
            _fromL.font = [UIFont systemFontOfSize:12];
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
            _toL.font = [UIFont systemFontOfSize:12];
            _toL.textColor = [UIColor colorWithHexString:@"0x4E90BF"];
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
    _subTitleLabel.attributedText = [self attributeTail];
    
    
    NSString *fromStr, *toStr;
    if (_curMRPR.isMR) {
        fromStr = [NSString stringWithFormat:@"  %@  ", _curMRPR.source_branch];
        toStr = [NSString stringWithFormat:@"  %@  ", _curMRPR.target_branch];
    }else{
        fromStr = [NSString stringWithFormat:@"  %@ : %@  ", _curMRPR.src_owner_name, _curMRPR.source_branch];
        toStr = [NSString stringWithFormat:@"  %@ : %@  ", _curMRPR.des_owner_name, _curMRPR.target_branch];
    }
    NSString *totalStr = [NSString stringWithFormat:@"%@%@", fromStr, toStr];
    if ([totalStr getWidthWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)] + 40 > kScreen_Width - 2*kPaddingLeftWidth) {
        [_toL mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel);
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
    
    [_describeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.top.equalTo(_toL.mas_bottom).offset(8);
        make.height.equalTo(@([PRMRSearchCell contentLabelHeightWithPRMR:_curMRPR]+3));
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
//                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x222222"]}
//                        range:NSMakeRange(0, nameStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x999999"]}
                        range:NSMakeRange(0,numStr.length+timeStr.length+nameStr.length+3)];
    return attrString;
}


+ (CGFloat)cellHeightWithObj:(id)obj {
    MRPR *mrpr = (MRPR *)obj;
    return kBaseCellHeight+[PRMRSearchCell contentLabelHeightWithPRMR:mrpr];
}

+ (CGFloat)contentLabelHeightWithPRMR:(MRPR *)curMRPR{
    NSString *content = [curMRPR.body firstObject];
    CGFloat realheight = [content getHeightWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(kDetialContentWidth, 1000)];
    return MIN(realheight, kDetialContentMaxHeight);
}
@end
