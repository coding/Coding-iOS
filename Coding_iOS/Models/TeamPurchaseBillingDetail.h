//
//  TeamPurchaseBillingDetail.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamPurchaseBillingDetail : NSObject
@property (strong, nonatomic) NSString *user_name, *user_gk;
@property (strong, nonatomic) NSNumber *days;
@property (strong, nonatomic) NSDate *start_date, *end_date;
@end
