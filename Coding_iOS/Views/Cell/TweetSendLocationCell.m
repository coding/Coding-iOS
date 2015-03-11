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
            _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 20, 20)];
            _iconImageView.backgroundColor = [UIColor blueColor];
            [self.contentView addSubview:_iconImageView];
        }
        if (!_locationButton) {
            _locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
            _locationButton.backgroundColor = [UIColor clearColor];
            [_locationButton setTitle:@"所在位置" forState:UIControlStateNormal];
            [_locationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            CGRect btnFrame = _locationButton.frame;
            btnFrame.origin.x = 15 + 20 + 10;
            btnFrame.origin.y = 5;
            btnFrame.size.height = 30;
            btnFrame.size.width = 100;
            [_locationButton setFrame:btnFrame];
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

- (void)locationClick:(id)sender
{
    if (self.locationClickBlock) {
        self.locationClickBlock();
    }
}


+ (CGFloat)cellHeight
{
    return 40;
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
