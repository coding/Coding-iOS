//
//  Tweet.m
//  Coding_iOS
//
//  Created by Ease on 15/3/9.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "Tweet.h"
#import "Login.h"


static Tweet *_tweetForSend = nil;

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
    if (self.user_global_key && self.pp_id) {
        return [NSString stringWithFormat:@"api/tweet/%@/%@", self.user_global_key, self.pp_id];
    }else{
        return [NSString stringWithFormat:@"api/tweet/%@/%@", self.owner.global_key, self.id.stringValue];
    }
}

+(Tweet *)tweetForSend{
    if (!_tweetForSend) {
        _tweetForSend = [[Tweet alloc] init];
        [_tweetForSend loadSendData];
    }
    return _tweetForSend;
}

- (void)saveSendData{
    NSString *dataPath = [NSString stringWithFormat:@"%@_tweetForSend", [Login curLoginUser].global_key];
    for (int i = 0; i < [self.tweetImages count]; i++) {
        TweetImage *tImg = [self.tweetImages objectAtIndex:i];
        NSString *imgNameStr = [NSString stringWithFormat:@"%@_%d.jpg", dataPath, i];
        [NSObject saveImage:tImg.image imageName:imgNameStr inFolder:dataPath];
    }
    if (self.tweetContent.length > 0) {
        [NSObject saveResponseData:@{
                                     @"content" : _tweetContent? _tweetContent: @"",
                                     @"locationData" : _locationData? [_locationData objectDictionary] : @""
                                     } toPath:dataPath];
    }
}

- (void)loadSendData{
    self.tweetImages = [[NSMutableArray alloc] init];
    NSInteger maxIndexOfImage = 6;
    NSString *dataPath = [NSString stringWithFormat:@"%@_tweetForSend", [Login curLoginUser].global_key];
    for (int i = 0; i < maxIndexOfImage; i++) {
        NSString *imgNameStr = [NSString stringWithFormat:@"%@_%d.jpg", dataPath, i];
        NSData *imageData = [NSObject loadImageDataWithName:imgNameStr inFolder:dataPath];
        if (!imageData) {
            break;
        }
        TweetImage *tImg= [TweetImage tweetImageWithImage:[UIImage imageWithData:imageData]];
        [self.tweetImages addObject:tImg];
    }
    
    self.tweetContent = @"";
    NSDictionary *contentDict = [NSObject loadResponseWithPath:dataPath];
    if (contentDict) {
        self.tweetContent = [contentDict objectForKey:@"content"];
        self.locationData = [NSObject objectOfClass:@"TweetSendLocationResponse" fromJSON:[contentDict objectForKey:@"locationData"]] ;
    }
}

+ (void)deleteSendData{
    _tweetForSend = nil;
    NSString *dataPath = [NSString stringWithFormat:@"%@_tweetForSend", [Login curLoginUser].global_key];
    [NSObject deleteImageCacheInFolder:dataPath];
    [NSObject deleteResponseCacheForPath:dataPath];
}

+(Tweet *)tweetWithGlobalKey:(NSString *)user_global_key andPPID:(NSString *)pp_id{
    Tweet *tweet = [[Tweet alloc] init];
    tweet.user_global_key = user_global_key;
    tweet.pp_id = pp_id;
    return tweet;
}

- (NSDictionary *)toDoTweetParams{
    NSMutableString *contentStr = [[NSMutableString alloc] initWithString:_tweetContent? _tweetContent: @""];
    for (TweetImage *imageItem in _tweetImages) {
        if (imageItem.imageStr && imageItem.imageStr.length > 0) {
            [contentStr appendString:imageItem.imageStr];
        }
    }
    NSDictionary *params;
    if (_locationData) {
        params = @{@"content" : contentStr,
                   @"location": _locationData.displayLocaiton,
                   @"coord": [NSString stringWithFormat:@"%@,%@,%i", _locationData.lat, _locationData.lng, _locationData.isCustomLocaiton],
                   @"address": _locationData.address};
    }else{
        params = @{@"content" : contentStr};
    }
    return params;
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