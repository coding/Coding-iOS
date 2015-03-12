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

@end

@implementation TweetSendSearchingNotFoundCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.backgroundColor = [UIColor clearColor];
        
        CGRect frame = CGRectZero;
        frame.size.width = kScreen_Width;
        frame.origin.y = 5;
        frame.origin.x = 15;
        frame.size.height = 20;
        UIFont *font = [UIFont systemFontOfSize:14];
        
        if (!_descriptionLabel) {
            _descriptionLabel = [[UILabel alloc]initWithFrame:frame];
            _descriptionLabel.font = font;
            _descriptionLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _descriptionLabel.text = @"没有找到你的位置？";
            _descriptionLabel.textAlignment = NSTextAlignmentLeft;
            
            [self.contentView addSubview:_descriptionLabel];
        }
        if (!_locationLabel) {
            frame.origin.y = 25;
            _locationLabel = [[UILabel alloc]initWithFrame:frame];
            _locationLabel.font = font;
            _locationLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _locationLabel.text = @"创建新的位置";
            _locationLabel.textAlignment = NSTextAlignmentLeft;

            [self.contentView addSubview:_locationLabel];
        }
        
        CGRect lineFrame = CGRectZero;
        lineFrame.size.width = kScreen_Width;
        lineFrame.size.height = 0.5;
        lineFrame.origin.y = 50 - 0.5;
        UIView *bottomLine = [[UIView alloc]initWithFrame:lineFrame];
        bottomLine.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        
        [self addSubview:bottomLine];
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

+ (CGFloat)cellHeight
{
    return 50;
}

@end
