//
//  MRPRS.h
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRPR.h"

typedef NS_ENUM(NSInteger, MRPRSType) {
    MRPRSTypeMRDefault = 0,
    MRPRSTypeMRCanMerge,
    MRPRSTypeMRCannotMerge,
    MRPRSTypeMRRefused,
    MRPRSTypeMRAccepted,
    MRPRSTypePROpen,
    MRPRSTypePRClosed,
    MRPRSTypePRAll,
};

@interface MRPRS : NSObject
@property (strong, nonatomic) NSString *user_gk, *project_name;
@property (nonatomic, assign, readonly) MRPRSType type;

@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;

- (NSDictionary *)toParams;
- (NSString *)toPath;
- (void)configWithMRPRS:(MRPRS *)resultA;

-(instancetype)initWithType:(MRPRSType)type userGK:(NSString *)user_gk projectName:(NSString *)project_name;

@end
