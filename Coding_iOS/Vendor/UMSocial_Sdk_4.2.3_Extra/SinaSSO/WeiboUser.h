//
//  WeiboUser.h
//  WeiboSDK
//
//  Created by DannionQiu on 14-9-23.
//  Copyright (c) 2014年 SINA iOS Team. All rights reserved.
//

#import <Foundation/Foundation.h>

/*@
    You can get the latest WeiboUser field description on http://open.weibo.com/wiki/2/friendships/friends/en .
*/
@interface WeiboUser : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)paraDict;
+ (instancetype)userWithDictionary:(NSDictionary*)paraDict;

// Validate the dictionary to be converted.
+ (BOOL)isValidForDictionary:(NSDictionary *)dict;

- (BOOL)updateWithDictionary:(NSDictionary*)paraDict;


@property(readwrite, retain, nonatomic) NSString* userID;
@property(readwrite, retain, nonatomic) NSString* userClass;
@property(readwrite, retain, nonatomic) NSString* screenName;
@property(readwrite, retain, nonatomic) NSString* name;
@property(readwrite, retain, nonatomic) NSString* province;
@property(readwrite, retain, nonatomic) NSString* city;
@property(readwrite, retain, nonatomic) NSString* location;
@property(readwrite, retain, nonatomic) NSString* userDescription;
@property(readwrite, retain, nonatomic) NSString* url;
@property(readwrite, retain, nonatomic) NSString* profileImageUrl;
@property(readwrite, retain, nonatomic) NSString* coverImageUrl;
@property(readwrite, retain, nonatomic) NSString* coverImageForPhoneUrl;
@property(readwrite, retain, nonatomic) NSString* profileUrl;
@property(readwrite, retain, nonatomic) NSString* userDomain;
@property(readwrite, retain, nonatomic) NSString* weihao;
@property(readwrite, retain, nonatomic) NSString* gender;
@property(readwrite, retain, nonatomic) NSString* followersCount;
@property(readwrite, retain, nonatomic) NSString* friendsCount;
@property(readwrite, retain, nonatomic) NSString* pageFriendsCount;
@property(readwrite, retain, nonatomic) NSString* statusesCount;
@property(readwrite, retain, nonatomic) NSString* favouritesCount;
@property(readwrite, retain, nonatomic) NSString* createdTime;
@property(readwrite, assign, nonatomic) BOOL isFollowingMe;
@property(readwrite, assign, nonatomic) BOOL isFollowingByMe;
@property(readwrite, assign, nonatomic) BOOL isAllowAllActMsg;
@property(readwrite, assign, nonatomic) BOOL isAllowAllComment;
@property(readwrite, assign, nonatomic) BOOL isGeoEnabled;
@property(readwrite, assign, nonatomic) BOOL isVerified;
@property(readwrite, retain, nonatomic) NSString* verifiedType;
@property(readwrite, retain, nonatomic) NSString* remark;
@property(readwrite, retain, nonatomic) NSString* statusID;
@property(readwrite, retain, nonatomic) NSString* ptype;
@property(readwrite, retain, nonatomic) NSString* avatarLargeUrl;
@property(readwrite, retain, nonatomic) NSString* avatarHDUrl;
@property(readwrite, retain, nonatomic) NSString* verifiedReason;
@property(readwrite, retain, nonatomic) NSString* verifiedTrade;
@property(readwrite, retain, nonatomic) NSString* verifiedReasonUrl;
@property(readwrite, retain, nonatomic) NSString* verifiedSource;
@property(readwrite, retain, nonatomic) NSString* verifiedSourceUrl;
@property(readwrite, retain, nonatomic) NSString* verifiedState;
@property(readwrite, retain, nonatomic) NSString* verifiedLevel;
@property(readwrite, retain, nonatomic) NSString* onlineStatus;
@property(readwrite, retain, nonatomic) NSString* biFollowersCount;
@property(readwrite, retain, nonatomic) NSString* language;
@property(readwrite, retain, nonatomic) NSString* star;
@property(readwrite, retain, nonatomic) NSString* mbtype;
@property(readwrite, retain, nonatomic) NSString* mbrank;
@property(readwrite, retain, nonatomic) NSString* block_word;
@property(readwrite, retain, nonatomic) NSString* block_app;
@property(readwrite, retain, nonatomic) NSString* credit_score;
@property(readwrite, retain, nonatomic) NSDictionary* originParaDict;

@end
