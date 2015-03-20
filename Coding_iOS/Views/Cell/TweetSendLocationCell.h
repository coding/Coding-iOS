//
//  TweetSendLocationCell.h
//  Coding_iOS
//
//  Created by Kevin on 3/10/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetSendLocationCell : UITableViewCell

@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIButton *locationButton;

@property (copy, nonatomic) void(^locationClickBlock)();
- (void)setButtonText:(NSString *)str button:(UIButton *)btn;


+ (CGFloat)cellHeight;

@end


@interface TweetSendSearchingNotFoundCell : UITableViewCell

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@end