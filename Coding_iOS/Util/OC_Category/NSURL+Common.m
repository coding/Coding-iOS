//
//  NSURL+Common.m
//  Coding_iOS
//
//  Created by Ease on 15/2/3.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define SYSTEM_VERSION_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "NSURL+Common.h"
#import <sys/xattr.h>


@implementation NSURL (Common)
+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if ([[NSFileManager defaultManager] fileExistsAtPath: [URL path]])
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1")) {
            NSError *error = nil;
            BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
            if(error){
                DebugLog(@"addSkipBackupAttributeToItemAtURL: %@, error: %@", [URL lastPathComponent], error);
            }
            return success;
        }
        
        if (SYSTEM_VERSION_GREATER_THAN(@"5.0")) {
            const char* filePath = [[URL path] fileSystemRepresentation];
            const char* attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
            int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
            return result == 0;
        }
    }
    return NO;
}
- (NSDictionary *)queryParams{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in [[self query] componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:elts[1] forKey:elts[0]];
    }
    return params;
}

- (BOOL)isTextData{
    NSDictionary *attributes = [self resourceValuesForKeys:@[NSURLTypeIdentifierKey] error:nil];
    NSString *itemType = attributes[NSURLTypeIdentifierKey];
    NSString *fileSuffix = [self.lastPathComponent componentsSeparatedByString:@"."].lastObject;
    return ((itemType.length > 0 && [[self.class ea_textUTIList] containsObject:itemType]) ||
            (fileSuffix.length > 0 && [[self.class p_sufToLangDict].allKeys containsObject:fileSuffix]));
}

- (NSString *)ea_lang{
    NSString *fileSuffix = [self.lastPathComponent componentsSeparatedByString:@"."].lastObject;
    return [[self.class p_sufToLangDict][fileSuffix] firstObject] ?: @"";
}

+ (NSDictionary *)p_sufToLangDict{
    static NSDictionary *sufToLangDict = nil;
    if (!sufToLangDict) {
        sufToLangDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"code_lang" ofType:@"plist"]];
    }
    return sufToLangDict;
}

+ (NSArray *)ea_textUTIList{
    return @[
             @"public.data",//其实这个是根，就是看不出来是啥东西的东西
             @"public.text",
             @"public.plain-text ",
             @"public.utf8-plain-text ",
             @"public.utf16-external-plain-​text",
             @"public.utf16-plain-text",
             @"com.apple.traditional-mac-​plain-text",
             @"com.apple.ink.inktext",
             @"com.apple.applescript.text",
             @"com.apple.txn.text-​multimedia-data",
             @"public.unix-executable",//私加的
             ];
}
+ (NSArray *)ea_imageUTIList{
    return @[
             @"public.image",
             @"public.fax",
             @"public.jpeg",
             @"public.jpeg-2000",
             @"public.camera-raw-image",
             @"public.png",
             @"public.xbitmap-image",
             @"com.apple.pict",
             @"com.apple.macpaint-image",
             @"com.apple.quicktime-image",
             @"com.apple.icns",
             @"com.adobe.photoshop-​image",
             @"com.adobe.illustrator.ai-​image",
             @"com.compuserve.gif",
             @"com.microsoft.bmp",
             @"com.microsoft.ico",
             @"com.truevision.tga-image",
             @"com.sgi.sgi-image",
             @"com.ilm.openexr-image",
             @"com.kodak.flashpix.image",
             ];
}
+ (NSArray *)ea_audioUTIList{
    return @[
             @"public.audio",
             @"public.mp3",
             @"public.mpeg-4-audio",
             @"com.apple.protected-​mpeg-4-audio",
             @"public.ulaw-audio",
             @"public.aifc-audio",
             @"public.aiff-audio",
             @"com.apple.coreaudio-​format",
             @"com.microsoft.waveform-​audio",
             @"com.microsoft.windows-​media-wma",
             @"com.microsoft.advanced-​stream-redirector",
             @"com.microsoft.windows-​media-wmx",
             @"com.microsoft.windows-​media-wvx",
             @"com.microsoft.windows-​media-wax",
             @"com.digidesign.sd2-audio",
             @"com.real.realaudio",
             ];
}
+ (NSArray *)ea_movieUTIList{
    return @[
             @"public.movie",
             @"public.video",
             @"public.avi",
             @"public.mpeg",
             @"public.mpeg-4",
             @"public.3gpp",
             @"public.3gpp2",
             @"com.apple.quicktime-movie",
             @"com.microsoft.windows-​media-wmp",
             @"com.microsoft.windows-​media-wmv",
             @"com.microsoft.windows-​media-wm",
             @"com.real.realmedia",
             ];
}

@end
