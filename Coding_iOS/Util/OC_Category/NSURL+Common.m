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
@end
