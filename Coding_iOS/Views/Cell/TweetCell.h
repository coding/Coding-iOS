//
//  TweetCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweets.h"
#import "UITapImageView.h"
#import "UITTTAttributedLabel.h"
typedef void (^CommentClickedBlock) (Tweet *curTweet, NSInteger index, id sender);
typedef void (^DeleteClickedBlock) (Tweet *curTweet, NSInteger outTweetsIndex);
typedef void (^LikeBtnClickedBlock) (Tweet *curTweet);
typedef void (^UserBtnClickedBlock) (User *curUser);
typedef void (^MoreLikersBtnClickedBlock) (Tweet *curTweet);

@interface TweetCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (strong, nonatomic) Tweet *tweet;
@property (nonatomic, assign) NSInteger outTweetsIndex;

@property (nonatomic, copy) CommentClickedBlock commentClickedBlock;
@property (nonatomic, copy) LikeBtnClickedBlock likeBtnClickedBlock;
@property (nonatomic, copy) UserBtnClickedBlock userBtnClickedBlock;
@property (nonatomic, copy) MoreLikersBtnClickedBlock moreLikersBtnClickedBlock;
@property (nonatomic, copy) DeleteClickedBlock deleteClickedBlock;
@property (nonatomic, copy) void(^goToDetailTweetBlock) (Tweet *curTweet);
@property (copy, nonatomic) void (^refreshSingleCCellBlock)();
@property (copy, nonatomic) void (^mediaItemClickedBlock)(HtmlMediaItem *curItem);


typedef void (^MoreLikersBtnClickedBlock) (Tweet *curTweet);

+ (CGFloat)cellHeightWithObj:(id)obj;;
@end
