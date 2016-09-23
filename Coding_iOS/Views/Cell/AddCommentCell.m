//
//  AddCommentCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/3.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "AddCommentCell.h"

@interface AddCommentCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *contentL;
@end

@implementation AddCommentCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = kColorTableBG;
        if (!_iconView) {
            _iconView = [UIImageView new];
            _iconView.image = [UIImage imageNamed:@"icon_add_comment"];
            [self.contentView addSubview:_iconView];
        }
        if (!_contentL) {
            _contentL = [UILabel new];
            _contentL.font = [UIFont systemFontOfSize:15];
            _contentL.textColor = kColor222;
            _contentL.text = @"添加评论";
            [self.contentView addSubview:_contentL];
        }
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerY.equalTo(self.contentView);
            make.centerX.equalTo(self.contentView).offset(-50);
        }];
        [_contentL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconView.mas_right).offset(15);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

+ (CGFloat)cellHeight{
    return 44.0;
}
@end
