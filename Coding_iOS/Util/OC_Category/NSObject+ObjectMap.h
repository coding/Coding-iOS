//
//  NSObject+ObjectMap.h
///  CSBase
//
//  Created by Mr Right on 13-11-13.
//  Copyright (c) 2013年 csair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define OMDateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSS"
#define OMTimeZone @"UTC"

@interface NSObject (ObjectMap)

// Universal Method
-(NSDictionary *)propertyDictionary;
-(NSString *)nameOfClass;

// id -> Object
+(id)objectOfClass:(NSString *)object fromJSON:(NSDictionary *)dict;
+(NSMutableArray *)arrayFromJSON:(NSArray *)jsonArray ofObjects:(NSString *)obj;

//Object -> Data
-(NSDictionary *)objectDictionary;
-(NSData *)JSONData;
-(NSString *)JSONString;

// XML-SOAP
-(NSData *)XMLData;
-(NSString *)XMLString;
-(NSData *)SOAPData;
-(NSString *)SOAPString;
+(id)objectOfClass:(NSString *)object fromXML:(NSString *)xml;


// For mapping an array to properties
-(NSMutableDictionary *)getpropertyArrayMap;


// Copying an NSObject to new memory ref
// (basically initWithObject)
//-(id)initWithObject:(NSObject *)oldObject error:(NSError **)error;

// Base64 Encode/Decode
+(NSString *)encodeBase64WithData:(NSData *)objData;
+(NSData *)base64DataFromString:(NSString *)string;

@end

@interface SOAPObject : NSObject
@property (nonatomic, retain) id Header;
@property (nonatomic, retain) id Body;
@end