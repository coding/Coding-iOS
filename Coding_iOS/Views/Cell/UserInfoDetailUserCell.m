//
//  UserInfoDetailUserCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "UserInfoDetailUserCell.h"

@interface UserInfoDetailUserCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *textL;
@end

@implementation UserInfoDetailUserCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([UserInfoDetailUserCell cellHeight] - 50)/2, 50, 50)];
            [_iconView doCircleFrame];
            [self.contentView addSubview:_iconView];
        }
        if (!_textL) {
            _textL = [[UILabel alloc] init];
            _textL.textAlignment = NSTextAlignmentLeft;
            _textL.font = [UIFont systemFontOfSize:16];
            _textL.textColor = [UIColor blackColor];
            [self.contentView addSubview:_textL];
            [_textL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_iconView.mas_right).offset(kPaddingLeftWidth);
                make.right.equalTo(self).offset(kPaddingLeftWidth);
                make.height.mas_equalTo(25);
                make.centerY.equalTo(self.contentView);
            }];
        }
    }
    return self;
}

- (void)setName:(NSString *)name icon:(NSString *)iconUrl{
    [_iconView sd_setImageWithURL:[iconUrl urlImageWithCodePathResizeToView:_iconView] placeholderImage:kPlaceholderMonkeyRoundView(_iconView)];
    _textL.text = name;
}

+ (CGFloat)cellHeight{
    return 70.0;
}
@end