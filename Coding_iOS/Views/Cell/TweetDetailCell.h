//
//  TweetDetailCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TweetDetail @"TweetDetailCell"

#import <UIKit/UIKit.h>
#import "Tweets.h"
@class TweetSendLocationResponse;

@interface TweetDetailCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIWebViewDelegate>
@property (strong, nonatomic) Tweet *tweet;
@property (nonatomic, copy) void (^commentClickedBlock) (id sender);
@property (nonatomic, copy) void (^cellRefreshBlock) ();
@property (nonatomic, copy) void (^deleteClickedBlock) ();
@property (nonatomic, copy) void (^userBtnClickedBlock) (User *curUser);
@property (nonatomic, copy) void (^moreLikersBtnClickedBlock) ();
@property (nonatomic, copy) void (^cellHeightChangedBlock) ();
@property (nonatomic, copy) void (^loadRequestBlock)(NSURLRequest *curRequest);

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
