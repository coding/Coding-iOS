//
//  TitleValueMoreCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-3.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TitleValueMoreCell.h"

@interface TitleValueMoreCell ()
@property (strong, nonatomic) UILabel *titleLabel, *valueLabel;
@end

@implementation TitleValueMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = kColorTableBG;

        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, 100, 30)];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.font = [UIFont systemFontOfSize:16];
            _titleLabel.textColor = [UIColor blackColor];
            [self.contentView addSubview:_titleLabel];
        }
        if (!_valueLabel) {
            _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 7, kScreen_Width-(110+kPaddingLeftWidth) - 30, 30)];
            _valueLabel.backgroundColor = [UIColor clearColor];
            _valueLabel.font = [UIFont systemFontOfSize:15];
            _valueLabel.textColor = kColor999;
            _valueLabel.textAlignment = NSTextAlignmentRight;
            _valueLabel.adjustsFontSizeToFitWidth = YES;
            _valueLabel.minimumScaleFactor = 0.6;
            [self.contentView addSubview:_valueLabel];
        }
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setTitleStr:(NSString *)title valueStr:(NSString *)value{
    _titleLabel.text = title;
    _valueLabel.text = value;
}

+ (CGFloat)cellHeight{
    return 44.0;
}

@end
