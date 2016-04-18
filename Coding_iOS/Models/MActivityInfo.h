//
//  NSObject+MActivityInfo.h
//  Coding_iOS
//
//  Created by hardac on 16/3/26.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"


@interface MActivityInfo:NSObject
@property (strong, nonatomic) User *author;
@property (strong, nonatomic) NSString* action;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (strong, nonatomic) NSNumber* id;
@property (strong, nonatomic) NSString* content;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@end
