//
//  HtmlMedia.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "HtmlMedia.h"
@implementation HtmlMedia
- (instancetype)initWithString:(NSString *)htmlString showType:(MediaShowType)showType{
    self = [super init];
    if (self) {
        _contentOrigional = htmlString;

        if (![htmlString hasPrefix:@"<body>"]) {
            htmlString = [NSString stringWithFormat:@"<body>%@</body>", htmlString];
        }

        _contentDisplay = [NSMutableString stringWithString:@""];
        _mediaItems = [[NSMutableArray alloc] init];
        
        NSData *data=[htmlString dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *doc = [TFHpple hppleWithHTMLData:data];
        TFHppleElement *rootElement = [doc peekAtSearchWithXPathQuery:@"//body"];
        [self analyseHtmlElement:rootElement withShowType:showType];
        _imageItems = [_mediaItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d OR type == %d", HtmlMediaItemType_Image, HtmlMediaItemType_EmotionMonkey]];
        
        //过滤末尾无用的空格&空行
        NSRange contentRange = [_contentDisplay rangeByTrimmingRightCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (_mediaItems.count > 0) {
            HtmlMediaItem *item;
            for (int i = (int)_mediaItems.count; i > 0; i--) {
                item = [_mediaItems objectAtIndex:i-1];
                if (item.displayStr.length > 0) {
                    contentRange.length = MAX(contentRange.length, item.range.location +item.range.length);
                    break;
                }
            }
        }
        if (contentRange.length < _contentDisplay.length) {
            [_contentDisplay deleteCharactersInRange:NSMakeRange(contentRange.length, _contentDisplay.length - contentRange.length)];
        }
    }
    return self;
}

- (void)analyseHtmlElement:(TFHppleElement* )element withShowType:(MediaShowType)showType{
    HtmlMediaItem *item = nil;
    if (element.isTextNode) {
        if ([element.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            [_contentDisplay appendString:element.content];
        }else if (![_contentDisplay hasSuffix:@"\n"] && _contentDisplay.length > 0){
            NSCharacterSet *lineSet = [NSCharacterSet newlineCharacterSet];
            if ([element.content rangeOfCharacterFromSet:lineSet].location != NSNotFound) {
                [_contentDisplay appendString:@"\n"];
            }else{
                [_contentDisplay appendString:element.content];
            }
        }
    }else if ([element.tagName isEqualToString:@"br"]){
        if (![_contentDisplay hasSuffix:@"\n"] && _contentDisplay.length > 0) {
            [_contentDisplay appendString:@"\n"];
        }
    }else if ([element.attributes[@"class"] isEqualToString:@"kdmath"]) {
        item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_Math];
        item.code = [element.text trimWhitespace];
    }else if ([element.tagName isEqualToString:@"code"]) {
        item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_Code];
        item.code = [element.text trimWhitespace];
    }else if ([element.tagName isEqualToString:@"a"]) {
        NSDictionary *attributes = element.attributes;
        NSString *element_Class = [attributes objectForKey:@"class"];
        if ([element_Class isEqualToString:@"at-someone"]) {
            //@了某个人
            item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_ATUser];
            item.href = [attributes objectForKey:@"href"];
            item.name = element.text? element.text: @"";
        }else if ([element_Class hasPrefix:@"bubble-markdown-image-link"]){
            //图片
            item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_Image];
            item.href = [attributes objectForKey:@"href"];
            
            TFHppleElement *child = [element.children firstObject];
            if (child && [child.attributes objectForKey:@"src"]) {
                item.src = [child.attributes objectForKey:@"src"];
            }else{
                item.src = [attributes objectForKey:@"href"];
            }
        }else{
            //网址
            if (element.text.length > 0) {
                item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_AutoLink];
                item.href = [attributes objectForKey:@"href"];
                item.linkStr = element.text;
            }
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
        }else {
            //图片
            item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_Image];
            item.src = [attributes objectForKey:@"src"];
        }
    }
    if (item) {
        item.showType = showType;
        item.range = NSMakeRange(_contentDisplay.length, item.displayStr.length);
        [_mediaItems addObject:item];
        [_contentDisplay appendString:item.displayStr];
        return;
    }
    
    if (element.hasChildren) {
        for (TFHppleElement *child in [element children]) {
            [self analyseHtmlElement:child withShowType:showType];
        }
    }
}

- (void)removeItem:(HtmlMediaItem *)delItem{
    NSInteger index = [_mediaItems indexOfObject:delItem];
    if (index != NSNotFound) {
        //处理链接左侧字符串尾部的空格
        if (delItem.range.location > 0) {
            NSString *lStr = [_contentDisplay substringToIndex:delItem.range.location];
            NSRange lRange = [lStr rangeByTrimmingRightCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSUInteger diffLength = lStr.length - lRange.length;
            if (diffLength > 0) {
                delItem.range = NSMakeRange(delItem.range.location - diffLength, delItem.range.length + diffLength);
            }
        }
        //处理链接右侧字符串头部的空格
        if (delItem.range.location + delItem.range.length < _contentDisplay.length) {
            NSString *rStr = [_contentDisplay substringFromIndex:delItem.range.location + delItem.range.length];
            NSRange rRange = [rStr rangeByTrimmingLeftCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSUInteger diffLength = rStr.length - rRange.length;
            if (diffLength > 0) {
                delItem.range = NSMakeRange(delItem.range.location, delItem.range.length + diffLength);
            }
        }
        //更新 _contentDisplay 和 delItem 后面 items 的 range
        if (delItem.range.length > 0) {
            [_mediaItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HtmlMediaItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx > index) {
                    obj.range = NSMakeRange(obj.range.location - delItem.range.length, obj.range.length);
                }else{
                    *stop = YES;
                }
            }];
            [_contentDisplay replaceCharactersInRange:delItem.range withString:@""];
        }
        //删除 delItem
        [_mediaItems removeObject:delItem];
    }
}
- (BOOL)needToShowDetail{
    for (HtmlMediaItem *item in _mediaItems) {
        if (item.type == HtmlMediaItemType_Code || item.type == HtmlMediaItemType_Math) {
            return YES;
        }
    }
    return NO;
}
+ (instancetype)htmlMediaWithString:(NSString *)htmlString showType:(MediaShowType)showType{
    return [[[self class] alloc] initWithString:htmlString showType:showType];
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
    curItem.range = NSMakeRange(curString.length, curItem.displayStr.length);
    [itemList addObject:curItem];
    [curString appendString:curItem.displayStr];
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
            displayStr = (_showType % MediaShowTypeImage == 0)? @"[图片]": @"";
            break;
        case HtmlMediaItemType_Code:
            displayStr = (_showType % MediaShowTypeCode == 0)? [NSString stringWithFormat:@"[%@]", _code]: @"[code]";
            break;
        case HtmlMediaItemType_EmotionEmoji:
            displayStr = [NSString stringWithFormat:@"[%@]", _title];
            break;
        case HtmlMediaItemType_EmotionMonkey:
            displayStr = (_showType % MediaShowTypeMonkey == 0)? @"[洋葱猴]": @"";
            break;
        case HtmlMediaItemType_ATUser:
            displayStr = _name;
            break;
        case HtmlMediaItemType_AutoLink:
        case HtmlMediaItemType_CustomLink:
            displayStr = [_linkStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            break;
        case HtmlMediaItemType_Math:
            displayStr = @"[math]";
            break;
        default:
            displayStr = @"";
            break;
    }
    return displayStr? displayStr : @"";
}
- (BOOL)isGif{
    return self.type == HtmlMediaItemType_Image && [self.src rangeOfString:@".gif"].location != NSNotFound;
}
@end
