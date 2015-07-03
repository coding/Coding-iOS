//
//  NSURL+OTPURLArguments.m
//
//  Copyright 2006-2011 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "NSURL+OTPURLArguments.h"
#import "NSString+OTPURLArguments.h"

@implementation NSURL (OTPURLArguments)

- (NSDictionary *)otp_dictionaryWithQueryArguments
{
    if (!self.query.length)
        return @{};
    
    NSArray *components = [self.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:components.count];
    
    [components enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
        if (!component.length) {
            return;
        }
        
        NSString *key = nil;
        NSString *val = nil;
        
        NSRange pos = [component rangeOfString:@"="];
        if (pos.location == NSNotFound) {
            key = [component otp_stringByUnescapingFromURLArgument];
            val = @"";
        } else {
            key = [[component substringToIndex:pos.location] otp_stringByUnescapingFromURLArgument];
            val = [[component substringFromIndex:NSMaxRange(pos)] otp_stringByUnescapingFromURLArgument];
        }

        if (!key) key = @"";
        if (!val) val = @"";
        
        parameters[key] = val;
    }];
    
    return [parameters copy];
}

+ (NSString *)otp_queryArgumentsForDictionary:(NSDictionary *)dict
{
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:dict.count];
    [dict enumerateKeysAndObjectsUsingBlock:^(id <NSObject> key, id <NSObject> obj, BOOL *stop) {
        [arguments addObject:[NSString stringWithFormat:@"%@=%@",
                              [[key description] otp_stringByEscapingForURLArgument],
                              [[obj description] otp_stringByEscapingForURLArgument]]];
    }];
    return [arguments componentsJoinedByString:@"&"];
}

@end
