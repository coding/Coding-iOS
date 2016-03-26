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

- (void)initCellWithReviewer:(Reviewer*)reviewer {
    [self.headIcon sd_setImageWithURL:[reviewer.reviewer.avatar urlImageWithCodePathResizeToView:self.headIcon] placeholderImage:kPlaceholderMonkeyRoundView(self.headIcon)];
    [self.headIcon doCircleFrame];
    self.userName.text = reviewer.reviewer.name;
    if([reviewer.value isEqual:@100]) {
       self.reviewIcon.image = [UIImage imageNamed:@"PointLikeHead"];
        self.userState.text = @"+1";
    } else {
        [self.reviewIcon setHidden:YES];
        self.userState.text = @"未评审";
    }
    
}

+ (CGFloat)cellHeight{
    return 44.0;
}

@end
