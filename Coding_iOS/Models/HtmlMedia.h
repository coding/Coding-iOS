//
//  HtmlMedia.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"
#import "User.h"

typedef NS_ENUM(NSInteger, HtmlMediaItemType) {
    HtmlMediaItemType_Image = 0,
    HtmlMediaItemType_Code,
    HtmlMediaItemType_EmotionEmoji,
    HtmlMediaItemType_EmotionMonkey,
    HtmlMediaItemType_ATUser,
    HtmlMediaItemType_AutoLink,
    HtmlMediaItemType_CustomLink
};

@class HtmlMediaItem;

@interface HtmlMedia : NSObject
@property (readwrite, nonatomic, copy) NSString *contentOrigional;
@property (readwrite, nonatomic, strong) NSMutableString *contentDisplay;
@property (readwrite, nonatomic, strong) NSMutableArray *mediaItems;
@property (strong, nonatomic) NSArray *imageItems;

+ (instancetype)htmlMediaWithString:(NSString *)htmlString;
+ (instancetype)htmlMediaWithString:(NSString *)htmlString trimWhitespaceAndNewline:(BOOL)isTrim;
- (instancetype)initWithString:(NSString *)htmlString trimWhitespaceAndNewline:(BOOL)isTrim;

+ (void)addMediaItem:(HtmlMediaItem *)curItem toString:(NSMutableString *)curString andMediaItems:(NSMutableArray *)itemList;
+ (void)addLinkStr:(NSString *)linkStr type:(HtmlMediaItemType)type toString:(NSMutableString *)curString andMediaItems:(NSMutableArray *)itemList;
+ (void)addMediaItemUser:(User *)curUser toString:(NSMutableString *)curString andMediaItems:(NSMutableArray *)itemList;

@end



@interface HtmlMediaItem : NSObject
@property (assign, nonatomic) HtmlMediaItemType type;
@property (readwrite, nonatomic, strong) NSString *src, *title, *href, *name, *code, *linkStr;
@property (assign, nonatomic) NSRange range;

+ (instancetype)htmlMediaItemWithType:(HtmlMediaItemType)type;
+ (instancetype)htmlMediaItemWithTypeATUser:(User *)curUser mediaRange:(NSRange)curRange;

- (NSString *)displayStr;

@end