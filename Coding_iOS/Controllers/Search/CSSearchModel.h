//
//  CSSearchModel.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CSSNewFeatureType) {
    
    CSSNewFeatureTypeTopic = 0,
    CSSNewFeatureTypeSearch,
    CSSNewFeatureTypeHotTopic
};

@interface CSSearchModel : NSObject

+ (BOOL)hasClickedNewFeatureWithType:(CSSNewFeatureType)type;
+ (void)clickNewFeatureWithType:(CSSNewFeatureType)type;

+ (BOOL)hasSearchBadgeShown;
+ (void)invalidSearchBadge;

+ (NSArray *)getSearchHistory;
+ (void)addSearchHistory:(NSString *)searchString;
+ (void)cleanAllSearchHistory;

@end
