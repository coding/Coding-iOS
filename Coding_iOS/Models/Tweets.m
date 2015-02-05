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

@implementation Tweet
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Comment", @"comment_list",
                             @"User", @"like_users", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _contentHeight = 1;
    }
    return self;
}

- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeNone];
        _content = _htmlMedia.contentDisplay;
    }
}

- (void)changeToLiked:(NSNumber *)liked{
    if (!liked) {
        return;
    }
    if (!_liked || ![_liked isEqualToNumber:liked]) {
        _liked = liked;
        User *cur_user = [Login curLoginUser];
        NSPredicate *finalPredicate = [NSPredicate predicateWithFormat:@"global_key == %@", cur_user.global_key];
        if (_liked.boolValue) {//喜欢
            if (!_like_users) {
                _like_users = [NSMutableArray arrayWithObject:cur_user];
                _likes = [NSNumber numberWithInteger:_likes.integerValue +1];
            }else{
                NSArray *fliterArray = [_like_users filteredArrayUsingPredicate:finalPredicate];
                if (!fliterArray || [fliterArray count] <= 0) {
                    [_like_users insertObject:cur_user atIndex:0];
                    _likes = [NSNumber numberWithInteger:_likes.integerValue +1];
                }
            }
        }else{//不喜欢
            if (_like_users) {
                NSArray *fliterArray = [_like_users filteredArrayUsingPredicate:finalPredicate];
                if (fliterArray && [fliterArray count] > 0) {
                    [_like_users removeObjectsInArray:fliterArray];
                    _likes = [NSNumber numberWithInteger:_likes.integerValue -1];
                }
            }
        }
    }
}

- (NSInteger)numOfComments{
    return MIN(_comment_list.count +1,
               MIN(_comments.intValue,
                   6));
}
- (BOOL)hasMoreComments{
    return (_comments.intValue > _comment_list.count || _comments.intValue > 5);
}

- (NSInteger)numOfLikers{
    return MIN(_like_users.count +1,
               MIN(_likes.intValue,
                   8));
}
- (BOOL)hasMoreLikers{
    return (_likes.intValue > _like_users.count || _likes.intValue > 7);
}

- (NSString *)toDoLikePath{
    NSString *doLikePath;
    doLikePath = [NSString stringWithFormat:@"api/tweet/%d/%@", self.id.intValue, (_liked.boolValue? @"unlike":@"like")];
    return doLikePath;
}

- (NSString *)toDoCommentPath{
    NSString *doCommentPath;
    doCommentPath = [NSString stringWithFormat:@"api/tweet/%d/comment", self.id.intValue];
    return doCommentPath;
}
- (NSDictionary *)toDoCommentParams{
    return @{@"content" : [self.nextCommentStr aliasedString]};
}
- (NSString *)toLikersPath{
    return [NSString stringWithFormat:@"api/tweet/%d/likes", _id.intValue];
}
- (NSDictionary *)toLikersParams{
    return @{@"page" : [NSNumber numberWithInteger:1],
             @"pageSize" : [NSNumber numberWithInteger:500]};
}
- (NSString *)toCommentsPath{
    return [NSString stringWithFormat:@"api/tweet/%d/comments", _id.intValue];
}
- (NSDictionary *)toCommentsParams{
    return @{@"page" : [NSNumber numberWithInteger:1],
             @"pageSize" : [NSNumber numberWithInteger:500]};
}
- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/tweet/%d", self.id.intValue];
}
- (NSString *)toDetailPath{
    return [NSString stringWithFormat:@"api/tweet/%@/%@", self.user_global_key, self.pp_id];
}
+(Tweet *)tweetForSend{
    Tweet *tweet = [[Tweet alloc] init];
    tweet.tweetImages = [[NSMutableArray alloc] init];
    tweet.tweetContent = @"";
    return tweet;
}
+(Tweet *)tweetWithGlobalKey:(NSString *)user_global_key andPPID:(NSString *)pp_id{
    Tweet *tweet = [[Tweet alloc] init];
    tweet.user_global_key = user_global_key;
    tweet.pp_id = pp_id;
    return tweet;
}

- (NSDictionary *)toDoTweetParams{
    NSMutableString *contentStr = [[NSMutableString alloc] initWithString:_tweetContent];
    for (TweetImage *imageItem in _tweetImages) {
        if (imageItem.imageStr && imageItem.imageStr.length > 0) {
            [contentStr appendString:imageItem.imageStr];
        }
    }
    return @{@"content" : contentStr};
}
- (BOOL)isAllImagesHaveDone{
    for (TweetImage *imageItem in _tweetImages) {
        if (imageItem.uploadState != TweetImageUploadStateSuccess) {
            return NO;
        }
    }
    return YES;
}
- (void)addNewComment:(Comment *)comment{
    if (!comment) {
        return;
    }
    if (_comment_list) {
        [_comment_list insertObject:comment atIndex:0];
    }else{
        _comment_list = [NSMutableArray arrayWithObject:comment];
    }
    _comments = [NSNumber numberWithInteger:_comments.integerValue +1];
}
- (void)deleteComment:(Comment *)comment{
    if (_comment_list) {
        NSUInteger index = [_comment_list indexOfObject:comment];
        if (index != NSNotFound) {
            [_comment_list removeObjectAtIndex:index];
            _comments = [NSNumber numberWithInteger:_comments.integerValue -1];
        }
    }
}
@end

@implementation TweetImage
+ (instancetype)tweetImageWithImage:(UIImage *)image{
    TweetImage *tweetImg = [[TweetImage alloc] init];
    tweetImg.image = image;
    tweetImg.uploadState = TweetImageUploadStateInit;
    return tweetImg;
}

@end
