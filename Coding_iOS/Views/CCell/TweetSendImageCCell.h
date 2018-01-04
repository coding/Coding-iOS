//
//  TweetSendImageCCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCCellIdentifier_TweetSendImage @"TweetSendImageCCell"

#import <UIKit/UIKit.h>
#import "Tweets.h"

@interface TweetSendImageCCell : UICollectionViewCell
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) TweetImage *curTweetImg;
@property (copy, nonatomic) void (^deleteTweetImageBlock)(TweetImage *toDelete);
+(CGSize)ccellSize;
@end
