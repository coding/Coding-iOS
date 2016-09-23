//
//  TagColorDisplayCell.m
//  Coding_iOS
//
//  Created by Ease on 16/2/19.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TagColorDisplayCell.h"

@implementation TagColorDisplayCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.tintColor = kColorBrandGreen;
        if (!_colorView) {
            _colorView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 12, 20, 20)];
            _colorView.layer.masksToBounds = YES;
            _colorView.layer.cornerRadius = 10;
            [self.contentView addSubview:_colorView];
        }
        if (!_colorL) {
            _colorL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_colorView.frame) + 10, 0, 100, 44)];
            _colorL.textColor = kColor222;
            _colorL.font = [UIFont systemFontOfSize:16];
            [self.contentView addSubview:_colorL];
        }
    }
    return self;
}

@end
