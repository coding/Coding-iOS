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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Tweet", @"list", nil];
    }
    return self;
}


+ (Tweets *)tweetsWithType:(TweetType)tweetType{
    Tweets *tweets = [[Tweets alloc] init];
    tweets.tweetType = tweetType;
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
+ (Tweets *)tweetsWithProject:(Project *)curPro{
    Tweets *tweets = [Tweets tweetsWithType:TweetTypeProject];
    tweets.curPro = curPro;
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
            case TweetTypeProject:
            requstPath = [NSString stringWithFormat:@"api/project/%@/tweet", _curPro.id.stringValue];
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
            if (_curUser && _curUser.global_key) {
                [params setObject:_curUser.global_key forKey:@"global_key"];
            }else if ([Login curLoginUser].id) {
                [params setObject:[Login curLoginUser].global_key forKey:@"global_key"];
            }
            break;
        default:
            break;
    }
    params[@"last_time"] = _willLoadMore? @((long long)([_last_time timeIntervalSince1970] * 1000)): nil;//冒泡广场、朋友圈、个人，都已经改成用 time 了
    params[@"last_id"] = _willLoadMore? _last_id: nil;//项目内冒泡还在用 id
    return params;
}

- (void)configWithTweets:(NSArray *)responseA{
    if (responseA && [responseA count] > 0) {
        self.canLoadMore = (_tweetType != TweetTypePublicHot);
        Tweet *lastTweet = [responseA lastObject];
        _last_time = lastTweet.sort_time;
        _last_id = lastTweet.id;
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
