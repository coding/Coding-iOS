//
//  EditLabelCell.m
//  Coding_iOS
//
//  Created by zwm on 15/4/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "EditLabelCell.h"

@interface EditLabelCell ()
@end

@implementation EditLabelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
        if (!_nameLbl) {
            _nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, (kScreen_Width - kPaddingLeftWidth * 2 - 30), 44)];
            _nameLbl.textColor = [UIColor colorWithHexString:@"0x222222"];
            _nameLbl.font = [UIFont systemFontOfSize:16];
            [self.contentView addSubview:_nameLbl];
        }
        if (!_selectBtn) {
            _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 24, 10, 24, 24)];
            [_selectBtn setImage:[UIImage imageNamed:@"tag_select_no"] forState:UIControlStateNormal];
            [_selectBtn setImage:[UIImage imageNamed:@"tag_select"] forState:UIControlStateSelected];
            _selectBtn.userInteractionEnabled = NO;
            [self.contentView addSubview:_selectBtn];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)showRightBtn:(BOOL)show
{
    if (show) {
        _selectBtn.hidden = show;
        [UIView animateWithDuration:0.3 animations:^{
            _nameLbl.frame = CGRectMake(kPaddingLeftWidth + 88, 0, (kScreen_Width - kPaddingLeftWidth * 2 - 30 - 88), 44);
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            _nameLbl.frame = CGRectMake(kPaddingLeftWidth, 0, (kScreen_Width - kPaddingLeftWidth * 2 - 30), 44);
        } completion:^(BOOL finished) {
            _selectBtn.hidden = show;
        }];
    }
}

+ (CGFloat)cellHeight
{
    return 44.0;
}

@end
