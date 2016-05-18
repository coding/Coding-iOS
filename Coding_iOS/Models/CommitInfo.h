//
//  CommitInfo.h
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectLineNote.h"
#import "CommitDetail.h"

@interface CommitInfo : NSObject
@property (strong, nonatomic) CommitDetail *commitDetail;
@property (strong, nonatomic) NSMutableArray *commitComments;
@property (strong, nonatomic) NSDictionary *propertyArrayMap;
@end
