//
//  MRPR.h
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Depot.h"

typedef NS_ENUM(NSInteger, MRPRStatus) {
    MRPRStatusCanMerge = 0,
    MRPRStatusCannotMerge,
    MRPRStatusAccepted,
    MRPRStatusRefused,
    MRPRStatusCancel
};

@interface MRPR : NSObject
@property (strong, nonatomic) NSNumber *id, *iid, *srcExist, *comment_count, *granted;
@property (strong, nonatomic) NSString *title, *path, *srcBranch, *desBranch, *merge_status, *src_owner_name,*source_branch,*target_branch;
@property (strong, nonatomic) NSString *des_owner_name, *des_project_name;
@property (strong, nonatomic) User *author, *action_author;
@property (strong, nonatomic) NSDate *created_at, *action_at;
@property (strong, nonatomic) Depot *source_depot;
@property (assign, nonatomic) MRPRStatus status;
@property (assign, nonatomic) BOOL isLoading;

//Post
@property (assign, nonatomic) BOOL del_source_branch, can_edit_src_branch;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSArray *body;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;

+ (MRPR *)mrprWithPath:(NSString *)path;

- (NSString *)statusDisplay;

- (BOOL)isMR;
- (BOOL)isPR;
- (NSString *)toPrePath;
- (NSString *)toBasePath;
- (NSString *)toReviewersPath;
- (NSString *)toCommitsPath;
- (NSString *)toFileChangesPath;
- (NSString *)toFileLineChangesPath;
- (NSString *)toAcceptPath;
- (NSDictionary *)toAcceptParams;
- (NSString *)toRefusePath;
- (NSString *)toCancelPath;
- (NSString *)toCancelMRPath;
- (NSString *)toAuthorizationPath;

@end
