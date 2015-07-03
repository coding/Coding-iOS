//
//  NSURL+OTPURLArguments.h
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

#import <Foundation/Foundation.h>

@interface NSURL (OTPURLArguments)

/** Returns a dictionary of decoded key-values pairs for the URL query string
 of the form key1=value1&key2=value2&...&keyN=valueN for the recieving URL.
 
 Keys and values will be unescaped automatically.
 
 Only the first value for a repeated key is used.
 */
- (NSDictionary *)otp_dictionaryWithQueryArguments;

/** Returns a string representation of the given dictionary in the form
 key1=value1&key2=value2&...&keyN=valueN, suitable for use as a URL query string
 or a POST body.
 
 Dictionary keys and values will be escaped automatically.
 */
+ (NSString *)otp_queryArgumentsForDictionary:(NSDictionary *)dict;

@end
