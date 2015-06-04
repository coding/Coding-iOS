//
//  CommitComment.m
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CommitComment.h"

@interface CommitComment ()
@property (strong, nonatomic) User *author;//运行时不能取到父类（未重复声明）的属性
@end

@implementation CommitComment
@synthesize author = _author;
@end
