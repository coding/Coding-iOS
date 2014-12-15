//
//  Comment.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef NS_ENUM(NSInteger, CommentSendType) {
    CommentSendTypeSuccess = 0,
    CommentSendTypeIng,
    CommentSendTypeFail
};

@interface Comment : NSObject
@property (readwrite, nonatomic, strong) NSString *content;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *tweet_id;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;


@end
