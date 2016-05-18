//
//  LocationCell.m
//  CodingMart
//
//  Created by Ease on 15/11/3.
//  Copyright © 2015年 net.coding. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (!_leftL) {
            _leftL = [UILabel new];
            _leftL.textColor = [UIColor colorWithHexString:@"0x000000"];
            _leftL.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_leftL];
        }
        if (!_rightL) {
            _rightL = [UILabel new];
            _rightL.textColor = [UIColor colorWithHexString:@"0x8e8e8e"];
            _rightL.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_rightL];
        }
        [_leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
        }];
        [_rightL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView);
            make.centerY.equalTo(@[self.contentView, self.leftL]);
        }];
    }
    return self;
}
@end
