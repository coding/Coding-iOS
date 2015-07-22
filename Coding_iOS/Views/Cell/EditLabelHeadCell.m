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
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = kColorTableBG;
        // Initialization code
        if (!_labelField) {
            _labelField = [[UITextField alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, (kScreen_Width - kPaddingLeftWidth * 2 - 50), 44)];
            _labelField.textColor = [UIColor colorWithHexString:@"0x222222"];
            _labelField.font = [UIFont systemFontOfSize:16];
            _labelField.placeholder = @"输入新标签的名称";
            //_labelField.
            [self.contentView addSubview:_labelField];
        }
        if (!_addBtn) {
            _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 50, 7, 50, 30)];
            _addBtn.layer.cornerRadius = 4;
            _addBtn.layer.borderWidth = 0.6;
            _addBtn.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
            [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
            [_addBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
            [_addBtn setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
            [_addBtn setTitleColor:[UIColor colorWithHexString:@"0xdddddd"] forState:UIControlStateDisabled];
            _addBtn.enabled = FALSE;
            [self.contentView addSubview:_addBtn];
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
