//
//  ResetLabelCell.m
//  Coding_iOS
//
//  Created by zwm on 15/4/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ResetLabelCell.h"

@implementation ResetLabelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        // Initialization code
        if (!_colorBtn) {
            _colorBtn = [[UIButton alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, 30, 30)];
            _colorBtn.layer.masksToBounds = YES;
            _colorBtn.layer.cornerRadius = 4;
            [_colorBtn setImage:[UIImage imageNamed:@"tag_button_editColor"] forState:UIControlStateNormal];
            [self.contentView addSubview:_colorBtn];
        }
        if (!_labelField) {
            _labelField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_colorBtn.frame) + 10, 0, (kScreen_Width - kPaddingLeftWidth - CGRectGetMaxX(_colorBtn.frame) - 10), 44)];
            _labelField.textColor = kColor222;
            _labelField.font = [UIFont systemFontOfSize:16];
            _labelField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _labelField.placeholder = @"输入标签名称";
            [self.contentView addSubview:_labelField];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

+ (CGFloat)cellHeight
{
    return 44.0;
}

@end
