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

+ (CGFloat)cellHeight;

@end

