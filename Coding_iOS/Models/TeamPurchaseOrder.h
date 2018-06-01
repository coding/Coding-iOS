//
//  TeamPurchaseOrder.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamPurchaseOrder : NSObject
@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSString *number, *status, *action, *creator_name, *creator_gk;
@property (strong, nonatomic) NSDate *created_at;
@end
