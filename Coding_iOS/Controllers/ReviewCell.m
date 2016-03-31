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
    }
    return self;
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithHeadIconURL:(NSString *)headIconURL
                       reviewIconURL:(NSString *)reviewIconURL
                            userName:(NSString *)uName
                           userState:(NSString *)uState {
    headIconURL = @"/static/fruit_avatar/Fruit-6.png";
    [self.headIcon sd_setImageWithURL:[headIconURL urlImageWithCodePathResizeToView:self.headIcon] placeholderImage:kPlaceholderMonkeyRoundView(self.headIcon)];
    [self.headIcon doCircleFrame];
    self.reviewIcon.image = [UIImage imageNamed:reviewIconURL];
    self.userName.text = uName;
    self.userState.text = uState;
    
    
}

- (void)initCellWithReviewer:(User*)reviewer
                   likeValue:(NSNumber*)likeValue;{
    [self.headIcon sd_setImageWithURL:[reviewer.avatar urlImageWithCodePathResizeToView:self.headIcon] placeholderImage:kPlaceholderMonkeyRoundView(self.headIcon)];
    [self.headIcon doCircleFrame];
    self.reviewIcon.image = [UIImage imageNamed:@"PointLikeHead"];
    self.userName.text = reviewer.name;
    if([likeValue isEqual:@100]) {
        self.userState.text = @"+1";
    } else {
        self.userState.text = @"未评审";
    }
    
}

- (void)initCellWithVolunteerReviewers:(User*)reviewer
                           likeValue:(NSNumber*)likeValue;{
    [self.headIcon sd_setImageWithURL:[reviewer.avatar urlImageWithCodePathResizeToView:self.headIcon] placeholderImage:kPlaceholderMonkeyRoundView(self.headIcon)];
    [self.headIcon doCircleFrame];
    [self.reviewIcon setHidden:YES];
    self.userName.text = reviewer.name;
    if([likeValue isEqual:@100]) {
        self.userState.text = @"+1";
    }
    
}

- (void)initCellWithUsers:(User*)user{
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
