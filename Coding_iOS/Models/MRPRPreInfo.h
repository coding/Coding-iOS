//
//  NSObject+MRPRPreInfo.h
//  Coding_iOS
//
//  Created by hardac on 16/4/2.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRPR.h"
#import "ProjectLineNote.h"

@interface MRPRPreInfo : NSObject
@property (strong, nonatomic) MRPR *pull_request;
@property (strong, nonatomic) MRPR *merge_request;
@property (strong, nonatomic) MRPR *mrpr;
@property (strong, nonatomic) NSNumber *can_edit_src_branch;
@property (strong, nonatomic) NSNumber *can_edit;
@property (strong, nonatomic) NSNumber *author_can_edit;

@end
