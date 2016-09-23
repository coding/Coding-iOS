//
//  PointTopCell.m
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "PointTopCell.h"

@interface PointTopCell ()
@property (strong, nonatomic) UILabel *valueL, *titleL;
@end

@implementation PointTopCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_valueL) {
            _valueL = [UILabel new];
            _valueL.textColor = kColorBrandGreen;
            _valueL.font = [UIFont systemFontOfSize:50];
            _valueL.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_valueL];
        }
        if (!_titleL) {
            _titleL = [UILabel new];
            _titleL.textColor = kColor999;
            _titleL.font = [UIFont systemFontOfSize:12];
            _titleL.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_titleL];
            _titleL.text = @"码币余额";
        }
        [_valueL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
//            make.top.equalTo(self.contentView).offset(20);
            make.centerY.equalTo(self.contentView).offset(-10);
            make.height.mas_equalTo(50);
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_valueL.mas_bottom).offset(5);
            make.centerX.equalTo(_valueL);
            make.height.mas_equalTo(15);
        }];
    }
    return self;
}

- (void)setPointLeftStr:(NSString *)pointLeftStr{
    _pointLeftStr = pointLeftStr;
    _valueL.text = _pointLeftStr;
}

+ (CGFloat)cellHeight{
    return 150.0;
}

@end
