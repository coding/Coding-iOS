//
//  OTPAuthURL.h
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

#import <Foundation/Foundation.h>
static NSString *const kOTPService = @"com.google.otp.authentication";

@class OTPGenerator;

// This class encapsulates the parsing of otpauth:// urls, the creation of
// either HOTPGenerator or TOTPGenerator objects, and the persistence of the
// objects state to the iPhone keychain in a secure fashion.
//
// The secret key is stored as the "password" in the keychain item, and the
// re-constructed URL is stored in an attribute.
@interface OTPAuthURL : NSObject

// |name| is an arbitrary UTF8 text string extracted from the url path.
@property (nonatomic, copy) NSString *name, *issuer;
@property (nonatomic, copy, readonly) NSString *otpCode;
@property (nonatomic, copy, readonly) NSString *checkCode;

+ (OTPAuthURL *)authURLWithURL:(NSURL *)url
                        secret:(NSData *)secret;

+ (OTPAuthURL *)ease_authURLWithKeychainDictionary:(NSDictionary *)dict;//

// Returns a reconstructed NSURL object representing the current state of the
// |generator|.
- (NSURL *)url;

// Saves the current object state to the keychain.
- (BOOL)saveToKeychain;

// Removes the current object state from the keychain.
- (BOOL)removeFromKeychain;

- (NSString*)checkCode;

@end

@interface TOTPAuthURL : OTPAuthURL  {
 @private
  NSTimeInterval generationAdvanceWarning_;
  NSTimeInterval lastProgress_;
  BOOL warningSent_;
}

@property(readwrite, assign, nonatomic) NSTimeInterval generationAdvanceWarning;

- (id)initWithSecret:(NSData *)secret name:(NSString *)name issuer:(NSString *)issuer;

@end

@interface HOTPAuthURL : OTPAuthURL {
 @private
  NSString *otpCode_;
}
- (id)initWithSecret:(NSData *)secret name:(NSString *)name issuer:(NSString *)issuer;
- (void)generateNextOTPCode;
@end

// Notification sent out |otpGenerationAdvanceWarning_| before a new OTP is
// generated. Only applies to TOTP Generators. Has a
// |OTPAuthURLSecondsBeforeNewOTPKey| key which is a NSNumber with the
// number of seconds remaining before the new OTP is generated.
extern NSString *const OTPAuthURLWillGenerateNewOTPWarningNotification;
extern NSString *const OTPAuthURLSecondsBeforeNewOTPKey;
extern NSString *const OTPAuthURLDidGenerateNewOTPNotification;
