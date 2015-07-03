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

#import "OTPGenerator.h"

#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

#import "OTPDefines.h"

static NSUInteger kPinModTable[] = {
    0,
    10,
    100,
    1000,
    10000,
    100000,
    1000000,
    10000000,
    100000000,
};

NSString *const kOTPGeneratorSHA1Algorithm = @"SHA1";
NSString *const kOTPGeneratorSHA256Algorithm = @"SHA256";
NSString *const kOTPGeneratorSHA512Algorithm = @"SHA512";
NSString *const kOTPGeneratorSHAMD5Algorithm = @"MD5";

@interface OTPGenerator ()
@property (copy, nonatomic, readwrite) NSString *algorithm;
@property (copy, nonatomic, readwrite) NSData *secret;
@property (nonatomic, readwrite) uint32_t digits;
@end

@implementation OTPGenerator

+ (NSString *)defaultAlgorithm {
    return kOTPGeneratorSHA1Algorithm;
}

+ (uint32_t)defaultDigits {
    return 6;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithSecret:(NSData *)secret
           algorithm:(NSString *)algorithm
              digits:(uint32_t)digits {
    BOOL goodAlgorithm = ([algorithm isEqualToString:kOTPGeneratorSHA1Algorithm] || [algorithm isEqualToString:kOTPGeneratorSHA256Algorithm] || [algorithm isEqualToString:kOTPGeneratorSHA512Algorithm] || [algorithm isEqualToString:kOTPGeneratorSHAMD5Algorithm]);
    if (!goodAlgorithm || digits > 8 || digits < 6 || !secret) {
        OTPDevLog(@"Bad args digits(min 6, max 8): %lu secret: %@ algorithm: %@", (unsigned long)digits, secret, algorithm);
        return (self = nil);
    }
    
    self = [super init];
    if (self) {
        self.algorithm = algorithm;
        self.secret = [secret copy];
        self.digits = digits;
    }
    return self;
}


// Must be overriden by subclass.
- (NSString *)generateOTP {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)generateOTPForCounter:(uint64_t)counter {
    CCHmacAlgorithm alg;
    NSUInteger hashLength = 0;
    if ([self.algorithm isEqualToString:kOTPGeneratorSHA1Algorithm]) {
        alg = kCCHmacAlgSHA1;
        hashLength = CC_SHA1_DIGEST_LENGTH;
    } else if ([self.algorithm isEqualToString:kOTPGeneratorSHA256Algorithm]) {
        alg = kCCHmacAlgSHA256;
        hashLength = CC_SHA256_DIGEST_LENGTH;
    } else if ([self.algorithm isEqualToString:kOTPGeneratorSHA512Algorithm]) {
        alg = kCCHmacAlgSHA512;
        hashLength = CC_SHA512_DIGEST_LENGTH;
    } else if ([self.algorithm isEqualToString:kOTPGeneratorSHAMD5Algorithm]) {
        alg = kCCHmacAlgMD5;
        hashLength = CC_MD5_DIGEST_LENGTH;
    } else {
        NSAssert(NO, @"Unknown algorithm");
        return nil;
    }
    
    NSMutableData *hash = [NSMutableData dataWithLength:hashLength];
    
    counter = NSSwapHostLongLongToBig(counter);
    NSData *counterData = [NSData dataWithBytes:&counter
                                         length:sizeof(counter)];
    CCHmacContext ctx;
    CCHmacInit(&ctx, alg, [self.secret bytes], [self.secret length]);
    CCHmacUpdate(&ctx, [counterData bytes], [counterData length]);
    CCHmacFinal(&ctx, [hash mutableBytes]);
    
    const char *ptr = [hash bytes];
    unsigned char offset = ptr[hashLength-1] & 0x0f;
    
    
//    unsigned long truncatedHash =
//    NSSwapBigLongToHost(*((unsigned long *)&ptr[offset])) & 0x7fffffff;
//    unsigned long pinValue = truncatedHash % kPinModTable[self.digits];
    uint32_t truncatedHash =
    NSSwapBigIntToHost(*((uint32_t *)&ptr[offset])) & 0x7fffffff;
    uint32_t pinValue = truncatedHash % kPinModTable[self.digits];

    
    OTPDevLog(@"secret: %@", self.secret);
    OTPDevLog(@"counter: %llu", counter);
    OTPDevLog(@"hash: %@", hash);
    OTPDevLog(@"offset: %d", offset);
//    OTPDevLog(@"truncatedHash: %lu", truncatedHash);
//    OTPDevLog(@"pinValue: %lu", pinValue);
    OTPDevLog(@"truncatedHash: %u", truncatedHash);
    OTPDevLog(@"pinValue: %u", pinValue);
    
//    return [NSString stringWithFormat:@"%0*lu", self.digits, pinValue];
    return [NSString stringWithFormat:@"%0*u", (int)self.digits, pinValue];
}

@end
