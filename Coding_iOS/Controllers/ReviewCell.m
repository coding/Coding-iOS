//
//  DemoCell.m
//  UISearchController&UISearchDisplayController
//
//  Created by zml on 15/12/2.
//  Copyright © 2015年 zml@lanmaq.com. All rights reserved.
//

#import "ReviewCell.h"

@implementation ReviewCell

- (void)awakeFromNib{
    [super awakeFromNib];
//    self.userIcon.frame = CGRectMake(12, 5, 33, 33);
}

- (void)initCellWithReviewer:(User*)reviewer
                   likeValue:(NSNumber*)likeValue;{
    self.user = reviewer;
    [self.userIcon sd_setImageWithURL:[reviewer.avatar urlImageWithCodePathResizeToView:self.userIcon] placeholderImage:kPlaceholderMonkeyRoundView(self.userIcon)];
    [self.userIcon doCircleFrame];
    self.userName.text = reviewer.name;
    if([likeValue isEqual:@100]) {
        self.userState.text = @"+1";
        [self.reviewIcon setHidden:NO];
        self.reviewIcon.image = [UIImage imageNamed:@"PointLikeHead"];
        self.userState.textColor = kColorBrandGreen;
    } else {
        [self.reviewIcon setHidden:YES];
        self.userState.text = @"未评审";
        self.userState.textColor = kColorDark7;
    }
    
}

- (void)initCellWithVolunteerReviewers:(User*)reviewer
                           likeValue:(NSNumber*)likeValue;{
    self.user = reviewer;
    [self.userIcon sd_setImageWithURL:[reviewer.avatar urlImageWithCodePathResizeToView:self.userIcon] placeholderImage:kPlaceholderMonkeyRoundView(self.userIcon)];
    [self.userIcon doCircleFrame];
    [self.reviewIcon setHidden:YES];
    self.userName.text = reviewer.name;
    if([likeValue isEqual:@100]) {
        self.userState.text = @"+1";
        self.userState.textColor = kColorBrandGreen;
    }
    
}

- (void)initCellWithUsers:(User*)user{
    self.user = user;
    [self.userIcon sd_setImageWithURL:[user.avatar urlImageWithCodePathResizeToView:self.userIcon] placeholderImage:kPlaceholderMonkeyRoundView(self.userIcon)];
    [self.userIcon doCircleFrame];
    [self.reviewIcon setHidden:YES];
    self.userName.text = user.name;
    self.userState.hidden = YES;
}

+ (CGFloat)cellHeight{
    return 60.0;
}

@end
