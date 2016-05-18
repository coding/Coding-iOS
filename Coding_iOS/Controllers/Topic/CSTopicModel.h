//
//  CSTopicModel.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSTopicModel : NSObject

+ (NSArray*)latestUseTopiclist;
+ (void)addAnotherUseTopic:(NSString*)topicName;

@end
