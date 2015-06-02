//
//  MRPR.h
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRPRComment.h"
#import "Depot.h"

@interface MRPR : NSObject
@property (strong, nonatomic) NSNumber *id, *iid, *srcExist;
@property (strong, nonatomic) NSString *title, *path, *srcBranch, *desBranch, *merge_status;
@property (strong, nonatomic) User *author, *action_author;
@property (strong, nonatomic) NSDate *created_at;
@property (strong, nonatomic) Depot *source_depot;
@property (strong, nonatomic) NSAttributedString *attributeTitle, *attributeTail;
@property (strong, nonatomic) NSMutableArray *comments;

- (BOOL)isMR;
- (BOOL)isPR;
- (NSString *)toBasePath;
- (NSString *)toCommitsPath;
- (NSString *)toFileChangesPath;
- (NSString *)toFileLineChangesPath;

@end
