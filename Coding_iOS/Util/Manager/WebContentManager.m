//
//  WebContentManager.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-25.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "WebContentManager.h"

@interface WebContentManager ()
@property (strong, nonatomic) NSString *bubble_pattern_htmlStr;
@property (strong, nonatomic) NSString *topic_pattern_htmlStr;
@property (strong, nonatomic) NSString *code_pattern_htmlStr;
@property (strong, nonatomic) NSString *markdown_pattern_htmlStr;
@property (strong, nonatomic) NSString *diff_pattern_htmlStr;

@end

@implementation WebContentManager

+ (instancetype)sharedManager {
    static WebContentManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"bubble" ofType:@"html"];
        NSError *error = nil;
        shared_manager.bubble_pattern_htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DebugLog(@"bubble_pattern_htmlStr fail: %@", error.description);
        }
        path = [[NSBundle mainBundle] pathForResource:@"topic-ios" ofType:@"html"];
        shared_manager.topic_pattern_htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DebugLog(@"topic_pattern_htmlStr fail: %@", error.description);
        }
        path = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"html"];
        shared_manager.code_pattern_htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DebugLog(@"code_pattern_htmlStr fail: %@", error.description);
        }
        path = [[NSBundle mainBundle] pathForResource:@"markdown" ofType:@"html"];
        shared_manager.markdown_pattern_htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DebugLog(@"markdown_pattern_htmlStr fail: %@", error.description);
        }
        path = [[NSBundle mainBundle] pathForResource:@"diff-ios" ofType:@"html"];
        shared_manager.diff_pattern_htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DebugLog(@"diff_pattern_htmlStr fail: %@", error.description);
        }
    });
    return shared_manager;
}
- (NSString *)bubblePatternedWithContent:(NSString *)content{
    if (!content) {
        return @"";
    }
    NSString *patternedStr = [self.bubble_pattern_htmlStr stringByReplacingOccurrencesOfString:@"${webview_content}" withString:content];
    return patternedStr;
}
- (NSString *)topicPatternedWithContent:(NSString *)content{
    if (!content) {
        return @"";
    }
    NSString *patternedStr = [self.topic_pattern_htmlStr stringByReplacingOccurrencesOfString:@"${webview_content}" withString:content];
    return patternedStr;
}

- (NSString *)codePatternedWithContent:(CodeFile *)codeFile isEdit:(BOOL)isEdit{
    if (!codeFile || !codeFile.file) {
        return @"";
    }
    NSString *dataStr = [codeFile.file.lang isEqualToString:@"markdown"]? codeFile.file.preview: isEdit? codeFile.editData: codeFile.file.data;
    if (dataStr.length <= 0) {
        return @"";
    }
    NSString *patternedStr;
    if ([codeFile.file.lang isEqualToString:@"markdown"]) {
        patternedStr = [self.markdown_pattern_htmlStr stringByReplacingOccurrencesOfString:@"${webview_content}" withString:dataStr];
    }else{
        patternedStr = [dataStr stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        patternedStr = [patternedStr stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
        patternedStr = [patternedStr stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
        patternedStr = [self.code_pattern_htmlStr stringByReplacingOccurrencesOfString:@"${file_code}" withString:patternedStr];
        patternedStr = [patternedStr stringByReplacingOccurrencesOfString:@"${file_lang}" withString:codeFile.file.lang];
    }
    return patternedStr;
}
- (NSString *)markdownPatternedWithContent:(NSString *)content{
    if (!content) {
        return @"";
    }
    NSString *patternedStr = [self.markdown_pattern_htmlStr stringByReplacingOccurrencesOfString:@"${webview_content}" withString:content];
    return patternedStr;
}

- (NSString *)diffPatternedWithContent:(NSString *)content andComments:(NSString *)comments{
    if (!content) {
        return @"";
    }
    NSString *patternedStr = [self.diff_pattern_htmlStr stringByReplacingOccurrencesOfString:@"${diff-content}" withString:content];
    patternedStr = [patternedStr stringByReplacingOccurrencesOfString:@"${comments}" withString:comments];
    return patternedStr;
}

+ (NSString *)codePatternedWithContent:(CodeFile *)codeFile isEdit:(BOOL)isEdit{
    return [[self sharedManager] codePatternedWithContent:codeFile isEdit:(BOOL)isEdit];
}
+ (NSString *)bubblePatternedWithContent:(NSString *)content{
    return [[self sharedManager] bubblePatternedWithContent:content];
}
+ (NSString *)topicPatternedWithContent:(NSString *)content{
    return [[self sharedManager] topicPatternedWithContent:content];
}
+ (NSString *)markdownPatternedWithContent:(NSString *)content{
    return [[self sharedManager] markdownPatternedWithContent:content];
}
+ (NSString *)diffPatternedWithContent:(NSString *)content andComments:(NSString *)comments{
    return [[self sharedManager] diffPatternedWithContent:content andComments:comments];
}
@end
