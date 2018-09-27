//
//  TeamSupportCell.m
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2018/3/15.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "TeamSupportCell.h"

@implementation TeamSupportCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _leftL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorDark2];
        [self.contentView addSubview:_leftL];
        _rightL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorLightBlue];
        [self.contentView addSubview:_rightL];
        [_leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
        }];
        [_rightL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

@end
