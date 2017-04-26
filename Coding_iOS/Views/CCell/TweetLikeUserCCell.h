//
//  TweetLikeUserCCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-8.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCCellIdentifier_TweetLikeUser @"TweetLikeUserCCell"

#import <UIKit/UIKit.h>
#import "User.h"

@interface TweetLikeUserCCell : UICollectionViewCell

- (void)configWithUser:(User *)user rewarded:(BOOL)rewarded;

+(CGSize)ccellSize;
@end
