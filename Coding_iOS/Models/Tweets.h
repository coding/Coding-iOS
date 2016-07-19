//
//  Tweets.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"
#import "User.h"
#import "HtmlMedia.h"
#import "Tweet.h"
#import "Project.h"

@class TweetImage, Tweet,TweetSendLocationResponse;


typedef NS_ENUM(NSInteger, TweetType)
{
    TweetTypePublicTime = 0,
    TweetTypeUserFriends,
    TweetTypePublicHot,
    TweetTypeUserSingle,
    TweetTypeProject
};


@interface Tweets : NSObject
@property (strong, nonatomic, readonly) NSDate *last_time;
@property (readonly, nonatomic, strong) NSNumber *last_id;

@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (assign, nonatomic) TweetType tweetType;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (readwrite, nonatomic, strong) User *curUser;
@property (strong, nonatomic) Project *curPro;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSNumber *totalPage, *totalRow;
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize;

+ (Tweets *)tweetsWithType:(TweetType)tweetType;
+ (Tweets *)tweetsWithUser:(User *)curUser;
+ (Tweets *)tweetsWithProject:(Project *)curPro;
- (void)configWithTweets:(NSArray *)responseA;

- (NSString *)toPath;
- (NSDictionary *)toParams;

@end



