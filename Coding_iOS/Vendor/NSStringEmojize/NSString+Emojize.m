//
//  NSString+Emojize.m
//  Field Recorder
//
//  Created by Jonathan Beilin on 11/5/12.
//  Copyright (c) 2014 DIY. All rights reserved.
//

#import "NSString+Emojize.h"
#import "emojis.h"

@implementation NSString (Emojize)

- (NSString *)emojizedString
{
    return [NSString emojizedStringWithString:self];
}

+ (NSString *)emojizedStringWithString:(NSString *)text
{
    static dispatch_once_t onceToken;
    static NSRegularExpression *regex = nil;
    dispatch_once(&onceToken, ^{
        regex = [[NSRegularExpression alloc] initWithPattern:@"(:[a-z0-9-+_]+:)" options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    
    __block NSString *resultText = text;
    NSRange matchingRange = NSMakeRange(0, [resultText length]);
    [regex enumerateMatchesInString:resultText options:NSMatchingReportCompletion range:matchingRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
         if (result && ([result resultType] == NSTextCheckingTypeRegularExpression) && !(flags & NSMatchingInternalError)) {
             NSRange range = result.range;
             if (range.location != NSNotFound) {
                 NSString *code = [text substringWithRange:range];
                 NSString *unicode = self.emojiForAliases[code];
                 if (unicode) {
                     resultText = [resultText stringByReplacingOccurrencesOfString:code withString:unicode];
                 }
             }
         }
     }];
    
    return resultText;
}

- (NSString *)aliasedString{
    return [NSString aliasedStringWithString:self];
}

+ (NSString *)aliasedStringWithString:(NSString *)text{
    if (!text || text.length <= 0) {
        return text;
    }
    __block NSString *resultText = text;
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (self.aliaseForEmojis[substring]) {
            NSString *aliase = self.aliaseForEmojis[substring];
            resultText = [resultText stringByReplacingOccurrencesOfString:substring withString:aliase];
        }
    }];
    return resultText;
}

+ (NSDictionary *)emojiForAliases {
    static NSDictionary *_emojiForAliases;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emojiForAliases = EMOJI_HASH;
    });
    return _emojiForAliases;
}

+ (NSDictionary *)aliaseForEmojis {
    static NSMutableDictionary *_aliaseForEmojis;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _aliaseForEmojis = [[NSMutableDictionary alloc] init];
        [[self emojiForAliases] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [_aliaseForEmojis setObject:key forKey:obj];
        }];
    });
    return _aliaseForEmojis;
}

- (NSString *)toAliase{
    return self.class.aliaseForEmojis[self];
}
- (NSString *)toEmoji{
    return self.class.emojiForAliases[self];
}


@end
