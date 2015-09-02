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

@class TweetImage;

@interface Tweet : NSObject
@property (readwrite, nonatomic, strong) NSString *content, *device, *location, *coord, *address;
@property (readwrite, nonatomic, strong) NSNumber *liked, *activity_id, *id, *comments, *likes;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) NSMutableArray *comment_list, *like_users;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (nonatomic,strong) TweetSendLocationResponse *locationData;

@property (readonly, nonatomic, strong) NSMutableArray *tweetImages;
@property (readwrite, nonatomic, strong) NSMutableArray *selectedAssetURLs;
@property (readwrite, nonatomic, strong) NSString *tweetContent;
@property (readwrite, nonatomic, strong) NSString *nextCommentStr;
@property (assign, nonatomic) CGFloat contentHeight;

@property (strong, nonatomic) NSString *user_global_key, *pp_id;

- (void)addASelectedAssetURL:(NSURL *)assetURL;
- (void)deleteASelectedAssetURL:(NSURL *)assetURL;
- (void)deleteATweetImage:(TweetImage *)tweetImage;

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

- (void)saveSendData;
- (void)loadSendData;
+ (void)deleteSendData;

+(Tweet *)tweetWithGlobalKey:(NSString *)user_global_key andPPID:(NSString *)pp_id;
- (NSDictionary *)toDoTweetParams;
- (BOOL)isAllImagesHaveDone;
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

@interface TweetImage : NSObject
@property (readwrite, nonatomic, strong) UIImage *image, *thumbnailImage;
@property (strong, nonatomic) NSURL *assetURL;
@property (assign, nonatomic) TweetImageUploadState uploadState;
@property (readwrite, nonatomic, strong) NSString *imageStr;
+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL;
+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL andImage:(UIImage *)image;
@end
