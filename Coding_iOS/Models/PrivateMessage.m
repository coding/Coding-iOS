//
//  PrivateMessage.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "PrivateMessage.h"
#import "Login.h"

@implementation PrivateMessage
- (instancetype)init
{
    self = [super init];
    if (self) {
        _sendStatus = PrivateMessageStatusSendSucess;
        _id = @(-1);
    }
    return self;
}

- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeCode];
        if (_htmlMedia.contentDisplay.length <= 0 && _htmlMedia.imageItems.count <= 0 && !_nextImg) {
            _content = @"    ";//占位
        }else{
            _content = _htmlMedia.contentDisplay;
        }
    }
}
- (BOOL)hasMedia{
    return self.nextImg || (self.htmlMedia && self.htmlMedia.imageItems.count> 0);
}
- (BOOL)isSingleBigMonkey{
    BOOL isSingleBigMonkey = NO;
    if (self.content.length == 0) {
        if (_htmlMedia.imageItems.count == 1) {
            HtmlMediaItem *item = [_htmlMedia.imageItems firstObject];
            if (item.type == HtmlMediaItemType_EmotionMonkey) {
                isSingleBigMonkey = YES;
            }
        }
    }
    return isSingleBigMonkey;
}
- (BOOL)isVoice{
    return (_type.integerValue == 1 || _voiceMedia);
}
+ (instancetype)privateMessageWithObj:(id)obj andFriend:(User *)curFriend{
    PrivateMessage *nextMsg = [[PrivateMessage alloc] init];
    nextMsg.sender = [Login curLoginUser];
    nextMsg.friend = curFriend;
    nextMsg.sendStatus = PrivateMessageStatusSending;
    nextMsg.created_at = [NSDate date];
    
    if ([obj isKindOfClass:[NSString class]]) {
        nextMsg.content = obj;
        nextMsg.extra = @"";
    }else if ([obj isKindOfClass:[UIImage class]]){
        nextMsg.nextImg = obj;
        nextMsg.content = @"";
        nextMsg.extra = @"";
    }else if ([obj isKindOfClass:[VoiceMedia class]]){
        nextMsg.voiceMedia = obj;
        nextMsg.extra = @"";
    }else if ([obj isKindOfClass:[PrivateMessage class]]){
        PrivateMessage *originalMsg = (PrivateMessage *)obj;
        NSMutableString *content = [[NSMutableString alloc] initWithString:originalMsg.content];
        NSMutableString *extra = [[NSMutableString alloc] init];
        if (originalMsg.htmlMedia.mediaItems && originalMsg.htmlMedia.mediaItems.count > 0) {
            for (HtmlMediaItem *item in originalMsg.htmlMedia.mediaItems) {
                if (item.type == HtmlMediaItemType_Image) {
                    if (extra.length > 0) {
                        [extra appendFormat:@",%@", item.src];
                    }else{
                        [extra appendString:item.src];
                    }
                }else if (item.type == HtmlMediaItemType_EmotionMonkey){
                    [content appendFormat:@" :%@: ", item.title];
                }
            }
        }
        nextMsg.content = content;
        nextMsg.extra = extra;
    }

    return nextMsg;
};

- (NSString *)toSendPath{
    return @"api/message/send";
}
- (NSDictionary *)toSendParams{
    return @{@"content" : _content? [_content aliasedString]: @"",
             @"extra" : _extra? _extra: @"",
             @"receiver_global_key" : _friend.global_key};
}


- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/message/%ld", _id.longValue];
}

@end
