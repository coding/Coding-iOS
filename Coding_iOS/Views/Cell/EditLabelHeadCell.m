//
//  EditLabelHeadCell.m
//  Coding_iOS
//
//  Created by zwm on 15/4/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "EditLabelHeadCell.h"

@interface EditLabelHeadCell ()
@end

@implementation EditLabelHeadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kColorTableBG;
        // Initialization code
        if (!_colorBtn) {
            _colorBtn = [[UIButton alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, 30, 30)];
            _colorBtn.layer.masksToBounds = YES;
            _colorBtn.layer.cornerRadius = 4;
            [_colorBtn setImage:[UIImage imageNamed:@"tag_button_editColor"] forState:UIControlStateNormal];
            [self.contentView addSubview:_colorBtn];
        }
        if (!_addBtn) {
            _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 50, 7, 50, 30)];
            [_addBtn doBorderWidth:0.5 color:kColorCCC cornerRadius:4];
            [_addBtn setImage:[UIImage imageNamed:@"tag_button_add"] forState:UIControlStateNormal];
            _addBtn.enabled = FALSE;
            [self.contentView addSubview:_addBtn];
        }
        if (!_labelField) {
            _labelField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_colorBtn.frame) + 10, 0, (CGRectGetMinX(_addBtn.frame) - CGRectGetMaxX(_colorBtn.frame) - 20), 44)];
            _labelField.textColor = kColor222;
            _labelField.font = [UIFont systemFontOfSize:16];
            _labelField.placeholder = @"输入新标签的名称";
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
