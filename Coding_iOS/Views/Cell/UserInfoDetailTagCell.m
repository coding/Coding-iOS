//
//  UserInfoDetailTagCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "UserInfoDetailTagCell.h"

@interface UserInfoDetailTagCell ()
@property (strong, nonatomic) UILabel *titleL, *valueL;
@end

@implementation UserInfoDetailTagCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = kColorTableBG;
        if (!_titleL) {
            _titleL = [[UILabel alloc] init];
            [self.contentView addSubview:_titleL];
            _titleL.font = [UIFont systemFontOfSize:16];
            _titleL.textColor = [UIColor blackColor];
        }
        if (!_valueL) {
            _valueL = [[UILabel alloc] init];
            _valueL.numberOfLines = 0;
            [self.contentView addSubview:_valueL];
            _valueL.font = [UIFont systemFontOfSize:15];
            _valueL.textColor = kColor999;
        }
        
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(20);
            make.top.equalTo(self.contentView).offset(12);
            make.width.mas_equalTo(kScreen_Width - 2*kPaddingLeftWidth);
        }];
        [_valueL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleL.mas_bottom).offset(12);
            make.left.right.equalTo(_titleL);
        }];
    }
    return self;
}

- (void)setTagStr:(NSString *)tagStr{
    _titleL.text = @"个性标签";
    _valueL.text = tagStr;
    [_valueL sizeToFit];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            CGPoint accessoryViewCenter = view.center;
            accessoryViewCenter.y = 22;
            [view setCenter:accessoryViewCenter];
        }
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[NSString class]]) {
        cellHeight = 44;

        NSString *objStr = (NSString *)obj;
        cellHeight += [objStr getHeightWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(kScreen_Width - 2*kPaddingLeftWidth, CGFLOAT_MAX)];
        cellHeight += 12;
    }
    return cellHeight;
}
@end
