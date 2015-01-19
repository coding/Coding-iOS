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
    }
    return self;
}

- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeCode];
        _content = _htmlMedia.contentDisplay;
    }
}
- (BOOL)hasMedia{
    return self.nextImg || (self.htmlMedia && self.htmlMedia.imageItems.count> 0);
}

+ (instancetype)privateMessageWithObj:(id)obj andFriend:(User *)curFriend{
    PrivateMessage *nextMsg = [[PrivateMessage alloc] init];
    nextMsg.sender = [Login curLoginUser];
    nextMsg.friend = curFriend;
    nextMsg.sendStatus = PrivateMessageStatusSending;
    nextMsg.created_at = [NSDate date];
    nextMsg.content = @"";
    nextMsg.extra = @"";
    if ([obj isKindOfClass:[NSString class]]) {
        nextMsg.content = obj;
    }else if ([obj isKindOfClass:[UIImage class]]){
        nextMsg.nextImg = obj;
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
