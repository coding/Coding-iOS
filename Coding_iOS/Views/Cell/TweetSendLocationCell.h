//
//  TweetSendLocationCell.h
//  Coding_iOS
//
//  Created by Kevin on 3/10/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#define kCellIdentifier_TweetSendLocation @"TweetSendLocationCell"

#import <UIKit/UIKit.h>

@interface TweetSendLocationCell : UITableViewCell

- (void)setLocation:(NSString *)locationStr;

+ (CGFloat)cellHeight;
@end


@interface TweetSendSearchingNotFoundCell : UITableViewCell

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@end