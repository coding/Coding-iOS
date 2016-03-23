//
//  NSObject+PRReviewerListCell.m
//  Coding_iOS
//
//  Created by hardac on 16/3/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "PRReviewerListCell.h"
#define kDefaultImageSize 30
@interface PRReviewerListCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation PRReviewerListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = kColorTableBG;
        if (!_imgView) {
            if (!_imgView) {
                _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 20, 20)];
                [_imgView doCircleFrame];
                [self.contentView addSubview:_imgView];
            }
        }
        
    }
    return self;
}

- (void)prepareForReuse{
    [self removeTip];
}

- (void)addTip:(NSString *)countStr{
    self.accessoryType = UITableViewCellAccessoryNone;
    CGFloat pointX = kScreen_Width - 25;
    CGFloat pointY = [[self class] cellHeight]/2;
    [self.contentView addBadgeTip:countStr withCenterPosition:CGPointMake(pointX, pointY)];
}

- (void)addTipIcon{
    CGFloat pointX = kScreen_Width - 40;
    CGFloat pointY = [[self class] cellHeight]/2;
    [self.contentView addBadgeTip:kBadgeTipStr withCenterPosition:CGPointMake(pointX, pointY)];
}

- (void)addTipHeadIcon:(NSString *)IconString {
    CGFloat pointX = kScreen_Width - 40;
    CGFloat pointY = [[self class] cellHeight]/2;
    [self.contentView addBadgeTip:IconString withCenterPosition:CGPointMake(pointX, pointY)];
}

- (void)removeTip{
    [self.contentView removeBadgeTips];
}

- (void)setImageStr:(NSString *)imgStr andTitle:(NSString *)title{
    self.imgView.image = [UIImage imageNamed:imgStr];
    self.titleLabel.text = title;
}

+ (CGFloat)cellHeight{
    return 44.0;
}


@end
