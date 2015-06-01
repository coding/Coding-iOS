//
//  MRPRCommentItem.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface MRPRCommentItem : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSDate *created_at;
@property (strong, nonatomic) User *author;
@property (strong, nonatomic) NSString *content, *noteable_type;

@end
