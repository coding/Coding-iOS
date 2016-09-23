//
//  TweetSendLocationCell.m
//  Coding_iOS
//
//  Created by Kevin on 3/10/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendLocationCell.h"

@interface TweetSendLocationCell ()
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *locationL;
@end

@implementation TweetSendLocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_iconImageView) {
            _iconImageView = [UIImageView new];
            [self.contentView addSubview:_iconImageView];
        }
        if (!_locationL) {
            _locationL = [UILabel new];
            _locationL.font = [UIFont systemFontOfSize:13.0];
            [self.contentView addSubview:_locationL];
        }
        
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        
        [_locationL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconImageView.mas_right).offset(10);
            make.right.equalTo(self.contentView).offset(-15);
            make.bottom.top.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setImage:(NSString *)imageStr andLocation:(NSString *)locationStr{

}

- (void)setLocation:(NSString *)locationStr{
    if (locationStr.length > 0) {
        [self.iconImageView setImage:[UIImage imageNamed:@"icon_locationed"]];
        self.locationL.text = locationStr;
        self.locationL.textColor = kColorBrandGreen;
    }else{
        [self.iconImageView setImage:[UIImage imageNamed:@"icon_not_locationed"]];
        self.locationL.text = @"所在位置";
        self.locationL.textColor = [UIColor lightGrayColor];
    }
}


+ (CGFloat)cellHeight
{
    return 30;
}

@end

@implementation TweetSendSearchingNotFoundCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        CGRect frame = CGRectZero;
        frame.size.width = kScreen_Width;
        frame.origin.y = 5;
        frame.origin.x = 15;
        frame.size.height = 20;
        UIFont *font = [UIFont systemFontOfSize:14];
        
        if (!_descriptionLabel) {
            _descriptionLabel = [[UILabel alloc]initWithFrame:frame];
            _descriptionLabel.font = font;
            _descriptionLabel.textColor = kColor999;
            _descriptionLabel.text = @"没有找到你的位置？";
            _descriptionLabel.textAlignment = NSTextAlignmentLeft;
            
            [self.contentView addSubview:_descriptionLabel];
        }
        if (!_locationLabel) {
            frame.origin.y = 25;
            _locationLabel = [[UILabel alloc]initWithFrame:frame];
            _locationLabel.font = font;
            _locationLabel.textColor = kColor999;
            _locationLabel.text = @"创建新的位置";
            _locationLabel.textAlignment = NSTextAlignmentLeft;

            [self.contentView addSubview:_locationLabel];
        }
        
        CGRect lineFrame = CGRectZero;
        lineFrame.size.width = kScreen_Width;
        lineFrame.size.height = 0.5;
        lineFrame.origin.y = 50 - 0.5;
        UIView *bottomLine = [[UIView alloc]initWithFrame:lineFrame];
        bottomLine.backgroundColor = kColorDDD;
        
        [self addSubview:bottomLine];
    }
    return self;
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
