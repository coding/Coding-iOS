//
//  CSSearchModel.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CSSearchModel : NSObject

+ (NSArray *)getSearchHistory;
+ (void)addSearchHistory:(NSString *)searchString;
+ (void)cleanAllSearchHistory;

@end
