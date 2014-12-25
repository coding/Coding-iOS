//
//  HtmlMedia.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "HtmlMedia.h"
@implementation HtmlMedia
- (instancetype)initWithString:(NSString *)htmlString trimWhitespaceAndNewline:(BOOL)isTrim{
    self = [super init];
    if (self) {
        _contentOrigional = htmlString;

        if (![htmlString hasPrefix:@"<body>"]) {
            htmlString = [NSString stringWithFormat:@"<body>%@</body>", htmlString];
        }
        
        if (isTrim) {
            //        过滤掉html元素之间的"空格+换行+空格"
            htmlString = [htmlString stringByReplacingOccurrencesOfString:@">(\\s*\\n*\\r*\\s*)<" withString:@"><" options:NSRegularExpressionSearch range:NSMakeRange(0, htmlString.length)];
            htmlString = [htmlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        _contentDisplay = [[NSMutableString alloc] init];
        _mediaItems = [[NSMutableArray alloc] init];
        
        NSData *data=[htmlString dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *doc = [TFHpple hppleWithHTMLData:data];
        TFHppleElement *rootElement = [doc peekAtSearchWithXPathQuery:@"//body"];
        [self analyzeHtmlElement:rootElement];
        _contentDisplay = [NSMutableString stringWithString:[_contentDisplay stringByTrimmingRightCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        _imageItems = [_mediaItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d OR type == %d", HtmlMediaItemType_Image, HtmlMediaItemType_EmotionMonkey]];
    }
    return self;
}

- (void)analyzeHtmlElement:(TFHppleElement* )element{
    HtmlMediaItem *item = nil;
    if (element.isTextNode) {
        [_contentDisplay appendString:element.content];
    }else if ([element.tagName isEqualToString:@"code"]) {
        item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_Code];
        item.code = element.text;
    }else if ([element.tagName isEqualToString:@"a"]) {
        NSDictionary *attributes = element.attributes;
        NSString *element_Class = [attributes objectForKey:@"class"];
        if (!element_Class || [element_Class isEqualToString:@"auto-link"]) {
            //网址
            NSString *linkStr = element.text;
            if (linkStr) {
                item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_AutoLink];
                item.href = [attributes objectForKey:@"href"];
                item.linkStr = [element.text stringByTrimmingRightCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
        }else if ([element_Class isEqualToString:@"at-someone"]) {
            //@了某个人
            item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_ATUser];
            item.href = [attributes objectForKey:@"href"];
            item.name = element.text? element.text: @"";
        }else if ([element_Class hasPrefix:@"bubble-markdown-image-link"]){
            //图片
            item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_Image];
            item.src = [attributes objectForKey:@"href"];
        }
    }else if ([element.tagName isEqualToString:@"img"]){
        NSDictionary *attributes = element.attributes;
        NSString *element_Class = [attributes objectForKey:@"class"];
        if ([element_Class isEqualToString:@"emotion emoji"]){
            //Emoji
            NSString *emojiAliase = [NSString stringWithFormat:@":%@:", [attributes objectForKey:@"title"]];
            NSString *emojiCode = [emojiAliase toEmoji];
            if (emojiCode) {
                [_contentDisplay appendString:emojiCode];
            }else{
                item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_EmotionEmoji];
                item.src = [attributes objectForKey:@"src"];
                NSString *emotionStr;
                if ([attributes objectForKey:@"title"]) {
                    emotionStr = [NSString stringWithFormat:@"%@", [attributes objectForKey:@"title"]];
                }else if (item.src){
                    emotionStr = [NSString stringWithFormat:@"%@", [[item.src componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject];
                }
                item.title = emotionStr;
            }
        }else if ([element_Class isEqualToString:@"emotion monkey"]){
            //Monkey
            item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_EmotionMonkey];
            item.src = [attributes objectForKey:@"src"];
            NSString *emotionStr;
            if ([attributes objectForKey:@"title"]) {
                emotionStr = [NSString stringWithFormat:@"%@", [attributes objectForKey:@"title"]];
            }else if (item.src){
                emotionStr = [NSString stringWithFormat:@"%@", [[item.src componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject];
            }
            item.title = emotionStr;
        }else if ([element_Class isEqualToString:@"bubble-markdown-image"] || [element_Class isEqualToString:@"message-image"]){
            //图片
            item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_Image];
            item.src = [attributes objectForKey:@"src"];
        }
    }
    if (item) {
        item.range = NSMakeRange(_contentDisplay.length, item.displayStr.length);
        [_mediaItems addObject:item];
        [_contentDisplay appendString:item.displayStr];
        return;
    }
    
    if (element.hasChildren) {
        for (TFHppleElement *child in [element children]) {
            [self analyzeHtmlElement:child];
        }
    }
}

+ (instancetype)htmlMediaWithString:(NSString *)htmlString trimWhitespaceAndNewline:(BOOL)isTrim{
     return [[[self class] alloc] initWithString:htmlString trimWhitespaceAndNewline:isTrim];
}

+ (instancetype)htmlMediaWithString:(NSString *)htmlString{
    return [[[self class] alloc] initWithString:htmlString trimWhitespaceAndNewline:NO];
}

+ (void)addMediaItem:(HtmlMediaItem *)curItem toString:(NSMutableString *)curString andMediaItems:(NSMutableArray *)itemList{
    [itemList addObject:curItem];
    [curString appendString:curItem.displayStr];
}
+ (void)addLinkStr:(NSString *)linkStr type:(HtmlMediaItemType)type toString:(NSMutableString *)curString andMediaItems:(NSMutableArray *)itemList{
    if (!linkStr || !curString) {
        return;
    }
    HtmlMediaItem *curItem = [HtmlMediaItem htmlMediaItemWithType:type];
    curItem.linkStr = linkStr;
    curItem.range = NSMakeRange(curString.length, linkStr.length);
    [itemList addObject:curItem];
    [curString appendString:linkStr];
}
+ (void)addMediaItemUser:(User *)curUser toString:(NSMutableString *)curString andMediaItems:(NSMutableArray *)itemList{
    HtmlMediaItem *userItem = [HtmlMediaItem htmlMediaItemWithTypeATUser:curUser mediaRange:NSMakeRange(curString.length, curUser.name.length)];
    [self addMediaItem:userItem toString:curString andMediaItems:itemList];
}
@end

@implementation HtmlMediaItem

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)htmlMediaItemWithType:(HtmlMediaItemType)type{
    HtmlMediaItem *item = [[HtmlMediaItem alloc] init];
    item.type = type;
    return item;
}
+ (instancetype)htmlMediaItemWithTypeATUser:(User *)curUser mediaRange:(NSRange)curRange{
    HtmlMediaItem *item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_ATUser];
    item.name = curUser.name;
    item.href = [NSString stringWithFormat:@"/u/%@", curUser.global_key];
    item.range = curRange;
    return item;
}
- (NSString *)displayStr{
    NSString *displayStr;
    switch (_type) {
        case HtmlMediaItemType_Image:
            displayStr = @"";
            break;
        case HtmlMediaItemType_Code:
            displayStr = @"[code]";
            break;
        case HtmlMediaItemType_EmotionEmoji:
            displayStr = [NSString stringWithFormat:@"[%@]", _title];
            break;
        case HtmlMediaItemType_EmotionMonkey:
            displayStr = @"";
            break;
        case HtmlMediaItemType_ATUser:
            displayStr = _name;
            break;
        case HtmlMediaItemType_AutoLink:
        case HtmlMediaItemType_CustomLink:
            displayStr = _linkStr;
            break;
        default:
            displayStr = @"";
            break;
    }
    return displayStr;
}
@end