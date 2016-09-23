//
//  InputOnlyTextPlainCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "InputOnlyTextPlainCell.h"
@interface InputOnlyTextPlainCell ()
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) NSString *phStr, *valueStr;
@property (assign,nonatomic) BOOL isSecure;
@end

@implementation InputOnlyTextPlainCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_textField) {
            _textField = [[UITextField alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7.0, kScreen_Width-kPaddingLeftWidth*2, 30)];
            _textField.backgroundColor = [UIColor clearColor];
            _textField.borderStyle = UITextBorderStyleNone;
            _textField.font = [UIFont systemFontOfSize:16];
            [_textField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
            _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [self.contentView addSubview:_textField];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_phStr? _phStr: @"" attributes:@{NSForegroundColorAttributeName: kColor999}];
    _textField.text = _valueStr;
    _textField.secureTextEntry = _isSecure;
}

- (void)configWithPlaceholder:(NSString *)phStr valueStr:(NSString *)valueStr secureTextEntry:(BOOL)isSecure{
    self.phStr = phStr;
    self.valueStr = valueStr;
    self.isSecure = isSecure;
}
- (void)textValueChanged:(id)sender {
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(self.textField.text);
    }
}
@end
