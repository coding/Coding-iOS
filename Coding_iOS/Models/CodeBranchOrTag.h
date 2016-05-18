//
//  CodeBranchOrTag.h
//  Coding_iOS
//
//  Created by Ease on 15/1/30.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeBranchOrTag : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *is_default_branch, *is_protected;
@end
