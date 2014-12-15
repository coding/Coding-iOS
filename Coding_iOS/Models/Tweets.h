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

@class TweetImage, Tweet;

typedef NS_ENUM(NSInteger, TweetType)
{
    TweetTypePublicTime = 0,
    TweetTypeUserFriends,
    TweetTypePublicHot,
    TweetTypeUserSingle
};


@interface Tweets : NSObject
@property (readwrite, nonatomic, strong) NSNumber *last_id;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (assign, nonatomic) TweetType tweetType;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (readwrite, nonatomic, strong) User *curUser;
@property (readwrite, nonatomic, strong) Tweet *nextTweet;

+ (Tweets *)tweetsWithType:(TweetType)tweetType;
+ (Tweets *)tweetsWithUser:(User *)curUser;
- (NSString *)localResponsePath;
- (void)configWithTweets:(NSArray *)responseA;

- (NSString *)toPath;
- (NSDictionary *)toParams;

@end



@interface Tweet : NSObject
@property (readwrite, nonatomic, strong) NSString *content, *device;
@property (readwrite, nonatomic, strong) NSNumber *liked, *activity_id, *id, *comments, *likes;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) NSMutableArray *comment_list, *like_users;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;

@property (readwrite, nonatomic, strong) NSMutableArray *tweetImages;
@property (readwrite, nonatomic, strong) NSString *tweetContent;
@property (readwrite, nonatomic, strong) NSString *nextCommentStr;
@property (assign, nonatomic) CGFloat contentHeight;

@property (strong, nonatomic) NSString *user_global_key, *pp_id;

- (NSInteger)numOfComments;
- (BOOL)hasMoreComments;

- (NSInteger)numOfLikers;
- (BOOL)hasMoreLikers;



- (NSString *)toDoLikePath;
- (void)changeToLiked:(NSNumber *)liked;

- (NSString *)toDoCommentPath;
- (NSDictionary *)toDoCommentParams;

- (NSString *)toLikersPath;
- (NSDictionary *)toLikersParams;

- (NSString *)toCommentsPath;
- (NSDictionary *)toCommentsParams;

- (NSString *)toDeletePath;
- (NSString *)toDetailPath;

+(Tweet *)tweetForSend;
+(Tweet *)tweetWithGlobalKey:(NSString *)user_global_key andPPID:(NSString *)pp_id;
- (NSDictionary *)toDoTweetParams;
- (BOOL)isAllImagesHaveDone;
- (void)addNewComment:(Comment *)comment;
- (void)deleteComment:(Comment *)comment;

@end


typedef NS_ENUM(NSInteger, TweetImageUploadState)
{
    TweetImageUploadStateInit = 0,
    TweetImageUploadStateIng,
    TweetImageUploadStateSuccess,
    TweetImageUploadStateFail
};

@interface TweetImage : NSObject
@property (readwrite, nonatomic, strong) UIImage *image;
@property (assign, nonatomic) TweetImageUploadState uploadState;
@property (readwrite, nonatomic, strong) NSString *imageStr;
+ (instancetype)tweetImageWithImage:(UIImage *)image;
@end


