//
//  TweetSendLocationCell.m
//  Coding_iOS
//
//  Created by Kevin on 3/10/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendLocationCell.h"

@implementation TweetSendLocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!_iconImageView) {
            _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 23, 22, 22)];
            _iconImageView.backgroundColor = [UIColor clearColor];
            [_iconImageView setImage:[UIImage imageNamed:@"icon_not_locationed"]];
            [self.contentView addSubview:_iconImageView];
        }
        if (!_locationButton) {
            _locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
            _locationButton.backgroundColor = [UIColor clearColor];
            [_locationButton setTitleColor:[UIColor colorWithHexString:@"0x222222"] forState:UIControlStateNormal];
            _locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            _locationButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
            CGRect btnFrame = _locationButton.frame;
            btnFrame.origin.x = 15 + 22 + 9;
            btnFrame.origin.y = 23;
            btnFrame.size.height = 22;
            btnFrame.size.width = 100;
            [_locationButton setFrame:btnFrame];
            [self setButtonText:@"所在位置" button:_locationButton];
            [_locationButton addTarget:self action:@selector(locationClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView addSubview:_locationButton];
        }
    }
    return self;
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setButtonText:(NSString *)str button:(UIButton *)btn
{
    UIFont *font = btn.titleLabel.font;
    CGSize size = CGSizeMake(CGFLOAT_MAX, 22.0);
    CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:font.fontName size:font.pointSize]} context:nil];
    CGRect buttonFrame = btn.frame;
    buttonFrame.size.width = CGRectGetWidth(rect);
    [btn setTitle:str forState:UIControlStateNormal];
    [btn setFrame:buttonFrame];
}

- (void)locationClick:(id)sender
{
    if (self.locationClickBlock) {
        self.locationClickBlock();
    }
}


+ (CGFloat)cellHeight
{
    return 45;
}

//- (UIImageView *)iconImageView
//{
//    if (!_iconImageView) {
//        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 20, 20)];
//        _iconImageView.backgroundColor = [UIColor blueColor];
//        [self.contentView addSubview:_iconImageView];
//    }
//    return _iconImageView;
//}
//
//- (UIButton *)locationButton
//{
//    if (!_locationButton) {
//        _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _locationButton.backgroundColor = [UIColor clearColor];
//        [_locationButton setTitle:@"所在位置" forState:UIControlStateNormal];
//        CGRect btnFrame = _locationButton.frame;
//        btnFrame.origin.x = 40;
//        btnFrame.origin.y = 5;
//        [_locationButton setFrame:btnFrame];
//        
//        [self.contentView addSubview:_locationButton];
//    }
//    return _locationButton;
//}

@end
