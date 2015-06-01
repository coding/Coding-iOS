//
//  MRPR.h
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRPRComment.h"

@interface MRPR : NSObject
@property (strong, nonatomic) NSNumber *id, *iid;
@property (strong, nonatomic) NSString *title, *path;
@property (strong, nonatomic) User *author;
@property (strong, nonatomic) NSDate *created_at;
@property (strong, nonatomic) NSAttributedString *attributeTitle, *attributeTail;
@property (strong, nonatomic) NSMutableArray *comments;

- (NSString *)toCommentsPath;

@end
