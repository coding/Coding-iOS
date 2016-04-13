//
//  DemoCell.m
//  UISearchController&UISearchDisplayController
//
//  Created by zml on 15/12/2.
//  Copyright © 2015年 zml@lanmaq.com. All rights reserved.
//

#import "ReviewCell.h"

@implementation ReviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userState.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)initCellWithReviewer:(User*)reviewer
                   likeValue:(NSNumber*)likeValue;{
    self.user = reviewer;
    [self.headIcon sd_setImageWithURL:[reviewer.avatar urlImageWithCodePathResizeToView:self.headIcon] placeholderImage:kPlaceholderMonkeyRoundView(self.headIcon)];
    [self.headIcon doCircleFrame];
    self.userName.text = reviewer.name;
    if([likeValue isEqual:@100]) {
        self.userState.text = @"+1";
        [self.reviewIcon setHidden:NO];
        self.reviewIcon.image = [UIImage imageNamed:@"PointLikeHead"];
        self.userState.textColor = [UIColor colorWithHexString:@"0x3BBD79"];
    } else {
        [self.reviewIcon setHidden:YES];
        self.userState.text = @"未评审";
        self.userState.textColor = [UIColor colorWithHexString:@"0x999999"];
    }
    
}

- (void)initCellWithVolunteerReviewers:(User*)reviewer
                           likeValue:(NSNumber*)likeValue;{
    self.user = reviewer;
    [self.headIcon sd_setImageWithURL:[reviewer.avatar urlImageWithCodePathResizeToView:self.headIcon] placeholderImage:kPlaceholderMonkeyRoundView(self.headIcon)];
    [self.headIcon doCircleFrame];
    [self.reviewIcon setHidden:YES];
    self.userName.text = reviewer.name;
    if([likeValue isEqual:@100]) {
        self.userState.text = @"+1";
        self.userState.textColor = [UIColor colorWithHexString:@"0x3BBD79"];
    }
    
}

- (void)initCellWithUsers:(User*)user{
    self.user = user;
    [self.headIcon sd_setImageWithURL:[user.avatar urlImageWithCodePathResizeToView:self.headIcon] placeholderImage:kPlaceholderMonkeyRoundView(self.headIcon)];
    [self.headIcon doCircleFrame];
    [self.reviewIcon setHidden:YES];
    self.userName.text = user.name;
    self.userState.hidden = YES;
    
}

+ (CGFloat)cellHeight{
    return 44.0;
}

@end
