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

- (NSString *)address{
    if (!_address || _address.length == 0) {
        return @"未填写";
    }else{
        return _address;
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
                   [self maxLikerNum]));
}

- (NSInteger)maxLikerNum{
    NSInteger maxNum = 9;
    if (kDevice_Is_iPhone6) {
        maxNum = 11;
    }else if (kDevice_Is_iPhone6Plus){
        maxNum = 12;
    }
    return maxNum;
}

- (BOOL)hasMoreLikers{
    return (_likes.intValue > _like_users.count || _likes.intValue > [self maxLikerNum] - 1);
}

- (NSString *)toDoLikePath{
    NSString *doLikePath;
    doLikePath = [NSString stringWithFormat:@"api/tweet/%d/%@", self.id.intValue, (!_liked.boolValue? @"unlike":@"like")];
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
    NSMutableDictionary *tweetImagesDict = [NSMutableDictionary new];
    for (int i = 0; i < [self.tweetImages count]; i++) {
        TweetImage *tImg = [self.tweetImages objectAtIndex:i];
        if (tImg.image) {
            NSString *imgNameStr = [NSString stringWithFormat:@"%@_%d.jpg", dataPath, i];
            [tweetImagesDict setObject:tImg.assetURL.absoluteString forKey:imgNameStr];
            [NSObject saveImage:tImg.image imageName:imgNameStr inFolder:dataPath];
        }
    }
    [NSObject saveResponseData:@{@"content" : _tweetContent? _tweetContent: @"",
                                 @"locationData" : _locationData? [_locationData objectDictionary] : @"",
                                 @"tweetImagesDict" : tweetImagesDict,
                                 } toPath:dataPath];
}

- (void)loadSendData{
    NSString *dataPath = [NSString stringWithFormat:@"%@_tweetForSend", [Login curLoginUser].global_key];

    self.tweetContent = @"";
    NSDictionary *contentDict = [NSObject loadResponseWithPath:dataPath];
    NSDictionary *tweetImagesDict = [contentDict objectForKey:@"tweetImagesDict"];
    if (contentDict) {
        self.tweetContent = [contentDict objectForKey:@"content"];
        self.locationData = [NSObject objectOfClass:@"TweetSendLocationResponse" fromJSON:[contentDict objectForKey:@"locationData"]];
    }
    _tweetImages = [NSMutableArray new];
    _selectedAssetURLs = [NSMutableArray new];
    [tweetImagesDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSURL *assetURL = [NSURL URLWithString:obj];
        NSData *imageData = [NSObject loadImageDataWithName:key inFolder:dataPath];
        if (imageData) {
            TweetImage *tImg = [TweetImage tweetImageWithAssetURL:assetURL andImage:[UIImage imageWithData:imageData]];
            [self.tweetImages addObject:tImg];
            [self.selectedAssetURLs addObject:assetURL];
        }
    }];
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
                   @"address": _locationData.address? _locationData.address: @""};
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

- (NSString *)toShareLinkStr{
    return [NSString stringWithFormat:@"%@u/%@/pp/%@", kBaseUrlStr_Phone, _owner.global_key, _id];
}

#pragma mark ALAsset
- (void)setSelectedAssetURLs:(NSMutableArray *)selectedAssetURLs{
    NSMutableArray *needToAdd = [NSMutableArray new];
    NSMutableArray *needToDelete = [NSMutableArray new];
    [self.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![selectedAssetURLs containsObject:obj]) {
            [needToDelete addObject:obj];
        }
    }];
    [needToDelete enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteASelectedAssetURL:obj];
    }];
    [selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![self.selectedAssetURLs containsObject:obj]) {
            [needToAdd addObject:obj];
        }
    }];
    [needToAdd enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addASelectedAssetURL:obj];
    }];
}

- (void)addASelectedAssetURL:(NSURL *)assetURL{
    if (!_selectedAssetURLs) {
        _selectedAssetURLs = [NSMutableArray new];
    }
    if (!_tweetImages) {
        _tweetImages = [NSMutableArray new];
    }
    
    [_selectedAssetURLs addObject:assetURL];

    NSMutableArray *tweetImages = [self mutableArrayValueForKey:@"tweetImages"];//为了kvo
    TweetImage *tweetImg = [TweetImage tweetImageWithAssetURL:assetURL];
    [tweetImages addObject:tweetImg];
}

- (void)deleteASelectedAssetURL:(NSURL *)assetURL{
    [self.selectedAssetURLs removeObject:assetURL];
    NSMutableArray *tweetImages = [self mutableArrayValueForKey:@"tweetImages"];//为了kvo
    [tweetImages enumerateObjectsUsingBlock:^(TweetImage *obj, NSUInteger idx, BOOL *stop) {
        if (obj.assetURL == assetURL) {
            [tweetImages removeObject:obj];
            *stop = YES;
        }
    }];
}

- (void)deleteATweetImage:(TweetImage *)tweetImage{
    NSMutableArray *tweetImages = [self mutableArrayValueForKey:@"tweetImages"];//为了kvo
    [tweetImages removeObject:tweetImage];
    if (tweetImage.assetURL) {
        [self.selectedAssetURLs removeObject:tweetImage.assetURL];
    }
}

@end

@implementation TweetImage
+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL{
    TweetImage *tweetImg = [[TweetImage alloc] init];
    tweetImg.uploadState = TweetImageUploadStateInit;
    tweetImg.assetURL = assetURL;
    
    void (^selectAsset)(ALAsset *) = ^(ALAsset *asset){
        if (asset) {
            UIImage *highQualityImage = [UIImage fullScreenImageALAsset:asset];
            UIImage *thumbnailImage = [UIImage imageWithCGImage:[asset thumbnail]];
            dispatch_async(dispatch_get_main_queue(), ^{
                tweetImg.image = highQualityImage;
                tweetImg.thumbnailImage = thumbnailImage;
            });
        }
    };
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    @weakify(assetsLibrary);
    [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            selectAsset(asset);
        }else{
            @strongify(assetsLibrary);
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stopG) {
                    if([result.defaultRepresentation.url isEqual:assetURL]) {
                        selectAsset(result);
                        *stop = YES;
                        *stopG = YES;
                    }
                }];
            } failureBlock:^(NSError *error) {
                [NSObject showHudTipStr:@"读取图片失败"];
            }];
        }
    }failureBlock:^(NSError *error) {
        [NSObject showHudTipStr:@"读取图片失败"];
    }];
    return tweetImg;

}

+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL andImage:(UIImage *)image{
    TweetImage *tweetImg = [[TweetImage alloc] init];
    tweetImg.uploadState = TweetImageUploadStateInit;
    tweetImg.assetURL = assetURL;
    tweetImg.image = image;
    tweetImg.thumbnailImage = [image scaledToSize:CGSizeMake(kScaleFrom_iPhone5_Desgin(70), kScaleFrom_iPhone5_Desgin(70)) highQuality:YES];
    return tweetImg;
}

@end