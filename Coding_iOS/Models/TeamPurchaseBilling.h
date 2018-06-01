//
//  TeamPurchaseBilling.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TeamPurchaseBillingDetail.h"

@interface TeamPurchaseBilling : NSObject
@property (strong, nonatomic) NSNumber *id, *price, *balance;
@property (strong, nonatomic) NSDate *created_at, *billing_date;
@property (strong, nonatomic) NSArray *details;
@property (strong, nonatomic, readonly) NSArray *details_display;
@property (strong, nonatomic, readonly) NSDictionary *propertyArrayMap;

@property (assign, nonatomic) BOOL isExpanded;//UI 页面是都展开了
@end
