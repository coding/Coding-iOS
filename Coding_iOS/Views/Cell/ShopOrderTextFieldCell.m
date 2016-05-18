//
//  ShopOrderTextFieldCell.m
//  Coding_iOS
//
//  Created by liaoyp on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ShopOrderTextFieldCell.h"

@interface ShopOrderTextFieldCell ()
@end

@implementation ShopOrderTextFieldCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_nameLabel) {
            _nameLabel = [UILabel new];
            _nameLabel.textColor = [UIColor colorWithHexString:@"0x000000"];
            _nameLabel.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_nameLabel];
        }
        
        if (!_textField) {
            _textField = [UITextField new];
            _textField.textColor = [UIColor colorWithHexString:@"0x000000"];
            _textField.font = [UIFont systemFontOfSize:14];
            [self.contentView addSubview:_textField];
        }
        
      
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(12);
            make.top.equalTo(self.contentView.mas_top).offset(15);
        }];
        
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameLabel.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(-12);
            make.top.equalTo(_nameLabel.mas_bottom).offset(18);
        }];
        
    }
    return self;
}

+ (CGFloat)cellHeight{
    return 596/4.0/2.0;
}

@end


