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
@end
