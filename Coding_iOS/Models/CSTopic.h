//
//  Topic.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"
#import "HtmlMedia.h"
#import "Tweet.h"

@interface CSTopic : NSObject

@property (readwrite, nonatomic, strong) NSNumber *id, *user_count;

@property (readwrite, nonatomic, strong) NSString *name, *device, *location, *coord, *address;

@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) NSArray *user_list;
@property (readwrite, nonatomic, strong) Tweet *hot_tweet;

@property (readwrite, nonatomic, assign) BOOL watched;

//@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
//@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;

@property (assign, nonatomic) CGFloat contentHeight;

//@property (strong, nonatomic) NSString *user_global_key, *pp_id;

@property (assign,nonatomic) CGFloat listCellHeight;


- (NSString *)toDoWatchPath;

@end
