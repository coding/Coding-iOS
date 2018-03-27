//
//  CodeBranchOrTag.h
//  Coding_iOS
//
//  Created by Ease on 15/1/30.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CodeBranchOrTagCommit, CodeBranchOrTagMetric;

@interface CodeBranchOrTag : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *is_default_branch, *is_protected;

@property (strong, nonatomic) CodeBranchOrTagCommit *last_commit;//不一定有
@property (strong, nonatomic) CodeBranchOrTagMetric *branch_metric;//这是需要另外请求的
@end


@interface CodeBranchOrTagCommit : NSObject
@property (strong, nonatomic) NSString *commitId, *shortMessage;
@property (strong, nonatomic) NSDate *commitTime;
@end

@interface CodeBranchOrTagMetric : NSObject

@property (strong, nonatomic) NSString *base;
@property (strong, nonatomic) NSNumber *ahead, *behind;

@end
