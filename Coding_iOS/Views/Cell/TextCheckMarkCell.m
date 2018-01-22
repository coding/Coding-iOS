//
//  TextCheckMarkCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "TextCheckMarkCell.h"

@interface TextCheckMarkCell ()
@property (strong, nonatomic) UILabel *contentL;

@end

@implementation TextCheckMarkCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.tintColor = kColorBrandGreen;
        self.backgroundColor = kColorTableBG;

        if (!_contentL) {
            _contentL = [UILabel new];
            _contentL.font = [UIFont systemFontOfSize:15];
            _contentL.textColor = kColorDark3;
            [self.contentView addSubview:_contentL];
            [_contentL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, kPaddingLeftWidth, 10, kPaddingLeftWidth));
            }];
        }
    }
    return self;
}

- (void)setTextStr:(NSString *)textStr{
    _textStr = textStr;
    _contentL.text = _textStr;
}

- (void)setChecked:(BOOL)checked{
    _checked = checked;
    self.accessoryType = _checked? UITableViewCellAccessoryCheckmark: UITableViewCellAccessoryNone;
}



+ (CGFloat)cellHeight{
    return 44.0;
}
@end
