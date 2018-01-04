//
//  Tweet.h
//  Coding_iOS
//
//  Created by Ease on 15/3/9.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"
#import "User.h"
#import "HtmlMedia.h"
#import "TweetSendLocation.h"
#import "Project.h"

@class TweetImage;

@interface Tweet : NSObject
@property (readwrite, nonatomic, strong) NSString *content, *device, *location, *coord, *address;
@property (readwrite, nonatomic, strong) NSNumber *liked, *rewarded, *activity_id, *id, *comments, *likes, *rewards;
@property (readwrite, nonatomic, strong) NSDate *created_at, *sort_time;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) NSMutableArray *comment_list, *like_users, *reward_users;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (nonatomic,strong) TweetSendLocationResponse *locationData;

@property (readwrite, nonatomic, strong) NSMutableArray *tweetImages;//对 selectedAssetURLs 操作即可，最好不要直接赋值。。应用跳转带的图片会直接对 tweetImages赋值
@property (readwrite, nonatomic, strong) NSMutableArray *selectedAssetLocalIdentifiers;
@property (readwrite, nonatomic, strong) NSString *tweetContent;
@property (readwrite, nonatomic, strong) NSString *nextCommentStr;
@property (strong, nonatomic) NSString *callback;
@property (assign, nonatomic) CGFloat contentHeight;

@property (strong, nonatomic) NSString *user_global_key;
@property (strong, nonatomic) Project *project;
@property (strong, nonatomic) NSNumber *project_id;

- (BOOL)isProjectTweet;

- (void)addSelectedAssetLocalIdentifier:(NSString *)localIdentifier;
- (void)deleteSelectedAssetLocalIdentifier:(NSString *)localIdentifier;
- (void)deleteTweetImage:(TweetImage *)tweetImage;

- (NSInteger)numOfComments;
- (BOOL)hasMoreComments;

- (NSArray *)like_reward_users;
- (BOOL)hasLikesOrRewards;
- (BOOL)hasMoreLikesOrRewards;
- (BOOL)rewardedBy:(User *)user;

- (NSString *)toDoLikePath;
- (void)changeToLiked:(NSNumber *)liked;

- (NSString *)toDoCommentPath;
- (NSDictionary *)toDoCommentParams;

- (NSString *)toLikesAndRewardsPath;
- (NSDictionary *)toLikesAndRewardsParams;

- (NSString *)toLikersPath;
- (NSDictionary *)toLikersParams;

- (NSString *)toCommentsPath;
- (NSDictionary *)toCommentsParams;

- (NSString *)toDeletePath;
- (NSString *)toDetailPath;

+(Tweet *)tweetForSend;

- (void)saveSendData;
- (void)loadSendData;
+ (void)deleteSendData;

+(Tweet *)tweetWithGlobalKey:(NSString *)user_global_key andPPID:(NSString *)pp_id;
+(Tweet *)tweetInProject:(Project *)project andPPID:(NSString *)pp_id;

- (NSDictionary *)toDoTweetParams;
- (BOOL)isAllImagesDoneSucess;
- (void)addNewComment:(Comment *)comment;
- (void)deleteComment:(Comment *)comment;

- (NSString *)toShareLinkStr;
@end


typedef NS_ENUM(NSInteger, TweetImageUploadState)
{
    TweetImageUploadStateInit = 0,
    TweetImageUploadStateIng,
    TweetImageUploadStateSuccess,
    TweetImageUploadStateFail
};

typedef NS_ENUM(NSInteger, TweetImageDownloadState)
{
    TweetImageDownloadStateInit = 0,
    TweetImageDownloadStateIng,
    TweetImageDownloadStateSuccess,
    TweetImageDownloadStateFail
};

@interface TweetImage : NSObject
@property (readwrite, nonatomic, strong) UIImage *image, *thumbnailImage;
@property (strong, nonatomic) NSString *assetLocalIdentifier;
@property (assign, nonatomic) TweetImageUploadState uploadState;
@property (assign, nonatomic) TweetImageDownloadState downloadState;
@property (readwrite, nonatomic, strong) NSString *imageStr;
+ (instancetype)tweetImageWithAssetLocalIdentifier:(NSString *)localIdentifier;
+ (instancetype)tweetImageWithAssetLocalIdentifier:(NSString *)localIdentifier andImage:(UIImage *)image;
@end
