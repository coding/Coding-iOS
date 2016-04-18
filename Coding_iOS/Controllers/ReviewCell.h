//
//  DemoCell.h
//  UISearchController&UISearchDisplayController
//
//  Created by zml on 15/12/2.
//  Copyright © 2015年 zml@lanmaq.com. All rights reserved.
//  https://github.com/Lanmaq/iOS_HelpOther_WorkSpace


#import <UIKit/UIKit.h>
#import "User.h"

#define kCellIdentifier_ReviewCell @"ReviewCell"

@interface ReviewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *headIcon;
@property (strong, nonatomic) IBOutlet UIImageView *reviewIcon;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *userState;
@property (strong, nonatomic) User * user;

- (void)initCellWithReviewer:(User*)reviewer
                 likeValue:(NSNumber*)likeValue;
- (void)initCellWithVolunteerReviewers:(User*)reviewer
                             likeValue:(NSNumber*)likeValue;
- (void)initCellWithUsers:(User*)user;

+ (CGFloat)cellHeight;
@end
