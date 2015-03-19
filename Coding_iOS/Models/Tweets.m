//
//  Tweets.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#import "Tweets.h"
#import "Login.h"

@implementation Tweets

+ (Tweets *)tweetsWithType:(TweetType)tweetType{
    Tweets *tweets = [[Tweets alloc] init];
    tweets.tweetType = tweetType;
    tweets.last_id = kDefaultLastId;
    tweets.canLoadMore = NO;
    tweets.isLoading = NO;
    tweets.willLoadMore = NO;
    return tweets;
}
+ (Tweets *)tweetsWithUser:(User *)curUser{
    Tweets *tweets = [Tweets tweetsWithType:TweetTypeUserSingle];
    tweets.curUser = curUser;
    return tweets;
}

- (NSString *)toPath{
    NSString *requstPath;
    switch (_tweetType) {
        case TweetTypePublicHot:
        case TweetTypePublicTime:
            requstPath = @"api/tweet/public_tweets";
            break;
        case TweetTypeUserFriends:
            requstPath = @"api/activities/user_tweet";
            break;
        case TweetTypeUserSingle:
            requstPath = @"api/tweet/user_public";
            break;
        default:
            break;
    }
    return requstPath;
}

- (NSDictionary *)toParams{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    switch (_tweetType) {
        case TweetTypePublicHot:
            [params setObject:@"hot" forKey:@"sort"];
            break;
        case TweetTypePublicTime:
            [params setObject:@"time" forKey:@"sort"];
            break;
        case TweetTypeUserFriends:
            break;
        case TweetTypeUserSingle:
            if (_curUser && _curUser.id) {
                [params setObject:_curUser.id forKey:@"user_id"];
            }else if ([Login curLoginUser].id) {
                [params setObject:[Login curLoginUser].id forKey:@"user_id"];
            }
            break;
        default:
            break;
    }
    [params setObject:(_willLoadMore? _last_id:kDefaultLastId) forKey:@"last_id"];
    return params;
}

- (NSString *)localResponsePath{
    if ([_last_id isEqualToNumber:kDefaultLastId]) {
        return [NSString stringWithFormat:@"ActivieiesWithType_%d", (int)_tweetType];
    }else{
        return nil;
    }
}
- (void)configWithTweets:(NSArray *)responseA{
    if (responseA && [responseA count] > 0) {
        self.canLoadMore = (_tweetType != TweetTypePublicHot);
        Tweet *lastTweet = [responseA lastObject];
        self.last_id = lastTweet.id;
        if (_willLoadMore) {
            [_list addObjectsFromArray:responseA];
        }else{
            self.list = [NSMutableArray arrayWithArray:responseA];
        }
    }else{
        self.canLoadMore = NO;
        if (!_willLoadMore) {
            self.list = [NSMutableArray array];
        }
    }
}

@end
