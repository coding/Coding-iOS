//
//  CommitDetail.m
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CommitDetail.h"

@interface CommitDetail ()
@property (strong, nonatomic) Committer *committer;//运行时不能取到父类（未重复声明）的属性
@end

@implementation CommitDetail
@synthesize committer = _committer;
@end
