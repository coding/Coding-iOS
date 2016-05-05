//
//  TweetCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_Tweet @"TweetCell"

#import <UIKit/UIKit.h>
#import "Tweets.h"
#import "UITapImageView.h"
#import "UITTTAttributedLabel.h"
typedef void (^CommentClickedBlock) (Tweet *curTweet, NSInteger index, id sender);
typedef void (^DeleteClickedBlock) (Tweet *curTweet, NSInteger outTweetsIndex);
typedef void (^UserBtnClickedBlock) (User *curUser);
typedef void (^MoreLikersBtnClickedBlock) (Tweet *curTweet);
typedef void (^LocationClickedBlock) (Tweet *curTweet);

@interface TweetCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (nonatomic, assign) NSInteger outTweetsIndex;

- (void)setTweet:(Tweet *)tweet needTopView:(BOOL)needTopView;

@property (nonatomic, copy) CommentClickedBlock commentClickedBlock;
@property (nonatomic, copy) UserBtnClickedBlock userBtnClickedBlock;
@property (nonatomic, copy) MoreLikersBtnClickedBlock moreLikersBtnClickedBlock;
@property (nonatomic, copy) DeleteClickedBlock deleteClickedBlock;
@property (nonatomic, copy) void(^goToDetailTweetBlock) (Tweet *curTweet);
@property (copy, nonatomic) void (^cellRefreshBlock)();
@property (copy, nonatomic) void (^mediaItemClickedBlock)(HtmlMediaItem *curItem);


typedef void (^MoreLikersBtnClickedBlock) (Tweet *curTweet);

+ (CGFloat)cellHeightWithObj:(id)obj needTopView:(BOOL)needTopView;
@end
