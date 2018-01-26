//
//  Login2FATipCell.m
//  Coding_iOS
//
//  Created by Ease on 15/7/8.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "Login2FATipCell.h"

@implementation Login2FATipCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        if (!_tipLabel) {
            _tipLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark2];
            _tipLabel.minimumScaleFactor = 0.5;
            _tipLabel.adjustsFontSizeToFitWidth = YES;
            _tipLabel.text = @"您的账户开启了两步验证，请输入动态验证码登录";
            [self.contentView addSubview:_tipLabel];
            [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(kLoginPaddingLeftWidth);
                make.right.offset(-kPaddingLeftWidth);
                make.top.offset(10);
                make.height.mas_equalTo(20);
            }];
        }
    }
    return self;
}

@end
