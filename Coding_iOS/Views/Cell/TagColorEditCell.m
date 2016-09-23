//
//  TagColorEditCell.m
//  Coding_iOS
//
//  Created by Ease on 16/2/19.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TagColorEditCell.h"

@implementation TagColorEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_colorView) {
            _colorView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, 30, 30)];
            _colorView.layer.masksToBounds = YES;
            _colorView.layer.cornerRadius = 4;
            [self.contentView addSubview:_colorView];
        }
        if (!_randomBtn) {
            _randomBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 50, 7, 50, 30)];
            [_randomBtn doBorderWidth:0.5 color:kColorCCC cornerRadius:4];
            [_randomBtn setImage:[UIImage imageNamed:@"tag_button_randomColor"] forState:UIControlStateNormal];
            [self.contentView addSubview:_randomBtn];
        }
        if (!_colorF) {
            _colorF = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_colorView.frame) + 10, 0, (CGRectGetMinX(_randomBtn.frame) - CGRectGetMaxX(_colorView.frame) - 20), 44)];
            _colorF.textColor = kColor222;
            _colorF.font = [UIFont systemFontOfSize:16];
            _colorF.placeholder = @"#00A7F4";
            [self.contentView addSubview:_colorF];
        }
    }
    return self;
}

@end
