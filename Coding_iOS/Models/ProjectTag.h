//
//  ProjectTag.h
//  Coding_iOS
//
//  Created by Ease on 15/7/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ProjectTagType){
    ProjectTagTypeTopic = 0,
    ProjectTagTypeTask,
};

@interface ProjectTag : NSObject

@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *count;
@property (readwrite, nonatomic, strong) NSString *name, *color;

+ (instancetype)tagWithName:(NSString *)name;
+ (BOOL)tags:(NSArray *)aTags isEqualTo:(NSArray *)bTags;
+ (instancetype)tags:(NSArray *)aTags hasTag:(ProjectTag *)curTag;

@end
