//
//  TeamPurchaseOrderCell.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "TeamPurchaseOrderCell.h"

@interface TeamPurchaseOrderCell ()
@property (strong, nonatomic) UILabel *priceL, *statusL;
@property (strong, nonatomic) UILabel *numT, *numV, *creatorT, *creatorV, *timeT, *timeV;
@end

@implementation TeamPurchaseOrderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _priceL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorDark3];
        _statusL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDarkA];
        _numT = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
        _numV = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark3];
        _creatorT = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
        _creatorV = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark3];
        _timeT = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
        _timeV = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark3];
        [self.contentView addSubview:_priceL];
        [self.contentView addSubview:_statusL];
        [self.contentView addSubview:_numT];
        [self.contentView addSubview:_numV];
        [self.contentView addSubview:_creatorT];
        [self.contentView addSubview:_creatorV];
        [self.contentView addSubview:_timeT];
        [self.contentView addSubview:_timeV];
        UIView *lineV = ({
            UIView *view = [UIView new];
            view.backgroundColor = kColorDarkD;
            [self.contentView addSubview:view];
            view;
        });
        UIView *bottomV = ({
            UIView *view = [UIView new];
            view.backgroundColor = kColorDarkF;
            [self.contentView addSubview:view];
            view;
        });
        CGFloat labelW = 200;
        CGFloat pointX = kScreen_Width - kPaddingLeftWidth - labelW;
        _priceL.frame = CGRectMake(kPaddingLeftWidth, 10, labelW, 20);
        _statusL.frame = CGRectMake(pointX, 10, labelW, 20);
        _numT.frame = CGRectMake(kPaddingLeftWidth, 50, labelW, 20);
        _numV.frame = CGRectMake(pointX, 50, labelW, 20);
        _creatorT.frame = CGRectMake(kPaddingLeftWidth, 80, labelW, 20);
        _creatorV.frame = CGRectMake(pointX, 80, labelW, 20);
        _timeT.frame = CGRectMake(kPaddingLeftWidth, 110, labelW, 20);
        _timeV.frame = CGRectMake(pointX, 110, labelW, 20);
        lineV.frame = CGRectMake(kPaddingLeftWidth, 40, kScreen_Width, 1.0/[UIScreen mainScreen].scale);
        bottomV.frame = CGRectMake(0, 140, kScreen_Width, 10);
        
        [bottomV addLineUp:YES andDown:NO];
        _statusL.textAlignment = NSTextAlignmentRight;
        _numV.textAlignment = NSTextAlignmentRight;
        _creatorV.textAlignment = NSTextAlignmentRight;
        _timeV.textAlignment = NSTextAlignmentRight;
        
        _numT.text = @"订单编号";
        _creatorT.text = @"创建者";
        _timeT.text = @"创建时间";
    }
    return self;
}

- (void)setCurOrder:(TeamPurchaseOrder *)curOrder{
    NSDictionary *statusDisplayDict = @{@"pending": @"等待支付",
                                        @"success": @"成功",
                                        @"closed": @"关闭",
                                        };
    NSDictionary *statusColorDict = @{@"pending": @"0xF78636",
                                        @"success": @"0x5BA2FF",
                                        @"closed": @"0xA9B3BE",
                                        };
    _curOrder = curOrder;
    _priceL.text = [NSString stringWithFormat:@"充值 %@ 元", _curOrder.price];
    _statusL.textColor = [UIColor colorWithHexString:statusColorDict[_curOrder.status]];
    _statusL.text = statusDisplayDict[_curOrder.status];
    _numV.text = _curOrder.number;
    _creatorV.text = _curOrder.creator_name;
    _timeV.text = [_curOrder.created_at stringWithFormat:@"yyyy.MM.dd HH:mm"];
}

+ (CGFloat)cellHeight{
    return 150;
}
@end
