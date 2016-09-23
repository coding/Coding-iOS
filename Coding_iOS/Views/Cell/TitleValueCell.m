//
//  TitleValueCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-25.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TitleValueCell.h"
@interface TitleValueCell ()
@property (strong, nonatomic) UILabel *titleLabel, *valueLabel;
@property (strong, nonatomic) NSString *title, *value;
@end


@implementation TitleValueCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = kColorTableBG;
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, 100, 30)];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.font = [UIFont systemFontOfSize:16];
            _titleLabel.textColor = [UIColor blackColor];
            [self.contentView addSubview:_titleLabel];
        }
        if (!_valueLabel) {
            _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 7, kScreen_Width-(120+kPaddingLeftWidth), 30)];
            _valueLabel.backgroundColor = [UIColor clearColor];
            _valueLabel.font = [UIFont systemFontOfSize:15];
            _valueLabel.textColor = kColor999;
            _valueLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_valueLabel];
        }
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];

    _titleLabel.text = _title;
    _valueLabel.text = _value;
}

- (void)setTitleStr:(NSString *)title valueStr:(NSString *)value{
    self.title = title;
    self.value = value;
}

@end
