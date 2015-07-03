//
//  HOTPGenerator.m
//
//  Copyright 2011 Google Inc.
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

#import "HOTPGenerator.h"

@interface HOTPGenerator ()

@property (readwrite) uint64_t counter;

@end

@implementation HOTPGenerator

+ (NSInteger)defaultInitialCounter {
  return 1;
}

- (id)initWithSecret:(NSData *)secret algorithm:(NSString *)algorithm digits:(uint32_t)digits counter:(NSInteger)counter {
	self = [super initWithSecret:secret algorithm:algorithm digits:digits];
	if (self) {
		_counter = counter;
	}
	return self;
}

- (NSString *)generateOTP {
	self.counter++;
	NSString *otp = [super generateOTPForCounter:_counter];
	return otp;
}

@end
