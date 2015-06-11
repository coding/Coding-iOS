//
//  UserInfoTextCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "UserInfoTextCell.h"

@interface UserInfoTextCell ()
@property (strong, nonatomic) UILabel *titleL, *valueL;
@end

@implementation UserInfoTextCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_titleL) {
            _titleL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 12, 80, 20)];
            _titleL.textAlignment = NSTextAlignmentLeft;
            _titleL.font = [UIFont systemFontOfSize:15];
            _titleL.textColor = [UIColor colorWithHexString:@"0x888888"];
            [self.contentView addSubview:_titleL];
        }
        if (!_valueL) {
            _valueL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_titleL.frame), 12, kScreen_Width - CGRectGetMaxX(_titleL.frame) - kPaddingLeftWidth, 20)];
            _valueL.textAlignment = NSTextAlignmentLeft;
            _valueL.font = [UIFont systemFontOfSize:15];
            _valueL.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_valueL];
        }
        
    }
    return self;
}

- (void)setTitle:(NSString *)title value:(NSString *)value{
    _titleL.text = title;
    _valueL.text = value;
}

+ (CGFloat)cellHeight{
    return 44;
}
@end
