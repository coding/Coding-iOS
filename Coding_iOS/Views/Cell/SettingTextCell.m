//
//  SettingTextCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "SettingTextCell.h"

@interface SettingTextCell ()
@end

@implementation SettingTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_textField) {
            _textField = [[UITextField alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7,kScreen_Width- 2*kPaddingLeftWidth, 30)];
            _textField.backgroundColor = [UIColor clearColor];
            _textField.font = [UIFont systemFontOfSize:16];
            _textField.textColor = [UIColor blackColor];
            _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _textField.placeholder = @"未填写";
            [_textField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
            [self.contentView addSubview:_textField];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setTextValue:(NSString *)textValue andTextChangeBlock:(void(^)(NSString *textValue))block{
    [_textField becomeFirstResponder];
    if ([textValue isEqualToString:@"未填写"]) {
        _textValue = nil;
    }else{
        _textValue = textValue;
    }
    _textChangeBlock = block;
}



- (void)layoutSubviews{
    [super layoutSubviews];
    _textField.text = _textValue;
}

- (void)textValueChanged:(UITextField *)sender{
    _textValue = sender.text;
    if (_textChangeBlock) {
        _textChangeBlock(_textValue);
    }
}
@end
