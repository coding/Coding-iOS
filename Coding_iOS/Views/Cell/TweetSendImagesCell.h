//
//  TweetSendImagesCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TweetSendImages @"TweetSendImagesCell"

#import <UIKit/UIKit.h>
#import "Tweets.h"

@interface TweetSendImagesCell : UITableViewCell<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) Tweet *curTweet;
@property (copy, nonatomic) void(^addPicturesBlock)();
@property (copy, nonatomic) void (^deleteTweetImageBlock)(TweetImage *toDelete);

+ (CGFloat)cellHeightWithObj:(id)obj;
@end

