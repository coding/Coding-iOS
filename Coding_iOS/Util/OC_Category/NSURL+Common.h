//
//  NSURL+Common.h
//  Coding_iOS
//
//  Created by Ease on 15/2/3.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Common)
+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
- (NSDictionary *)queryParams;

- (BOOL)isTextData;
- (NSString *)ea_lang;

//https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
+ (NSArray *)ea_textUTIList;
+ (NSArray *)ea_imageUTIList;
+ (NSArray *)ea_audioUTIList;
+ (NSArray *)ea_movieUTIList;

@end
