//
//  PointShopCell.m
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "PointShopCell.h"

@interface PointShopCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleL;
@end

@implementation PointShopCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_iconView) {
            _iconView = [UIImageView new];
            [self.contentView addSubview:_iconView];
        }
        if (!_titleL) {
            _titleL = [UILabel new];
            _titleL.textAlignment = NSTextAlignmentLeft;
            _titleL.font = [UIFont systemFontOfSize:15];
            _titleL.textColor = kColor222;
            [self.contentView addSubview:_titleL];
        }
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconView.mas_right).offset(15);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(20);
        }];
        _iconView.image = [UIImage imageNamed:@"store_icon"];
        _titleL.text = @"商城";
    }
    return self;
}
+ (CGFloat)cellHeight{
    return 50.0;
}
@end
