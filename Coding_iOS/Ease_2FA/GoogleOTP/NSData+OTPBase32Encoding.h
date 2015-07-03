//
//  NSData+OTPBase32Encoding.h
//
//  Copyright 2012-2013 Dave Poirier.
//
//  Licensed under public domain.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, OTPDataBase32DecodingOptions) {
    OTPDataBase32DecodingCaseInsensitive = 1UL << 0,
    OTPDataBase32DecodingIgnoreSpaces = 2UL << 0,
};

typedef NS_OPTIONS(NSUInteger, OTPDataBase32EncodingOptions) {
    OTPDataBase32EncodingCaseInsensitive = 1UL << 0,
};


/** RFC-4648 compatible implementation of Base-32 encoding.
 
 See http://www.ietf.org/rfc/rfc4648.txt for more details
 */
@interface NSData (OTPBase32Encoding)

/* Create an NSData from a Base-32 encoded NSString. By default, returns nil when the input is not recognized as valid Base-32.
 */
- (id)otp_initWithBase32EncodedString:(NSString *)base32String options:(OTPDataBase32DecodingOptions)options __attribute__((objc_method_family(init)));

/* Create a Base-32 encoded NSString from the receiver's contents.
 */
- (NSString *)otp_base32EncodedStringWithOptions:(OTPDataBase32EncodingOptions)options;

/* Create an NSData from a Base-32, UTF-8 encoded NSData. By default, returns nil when the input is not recognized as valid Base-32.
 */
- (id)otp_initWithBase32EncodedData:(NSData *)base32Data options:(OTPDataBase32DecodingOptions)options  __attribute__((objc_method_family(init)));

/* Create a Base-32, UTF-8 encoded NSData from the receiver's contents;
 */
- (NSData *)otp_base32EncodedDataWithOptions:(OTPDataBase32EncodingOptions)options;

@end
