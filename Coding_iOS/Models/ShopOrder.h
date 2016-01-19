//
//  ShopOder.h
//  Coding_iOS
//
//  Created by liaoyp on 15/11/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "BaseModel.h"

@interface ShopOrder : BaseModel

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSNumber *giftId;
@property (strong, nonatomic) NSNumber *pointsCost;
@property (strong, nonatomic) NSNumber *status;
@property (strong, nonatomic) NSNumber *createdAt;
@property (strong, nonatomic) NSString *receiverName;
@property (strong, nonatomic) NSString *receiverAddress;
@property (strong, nonatomic) NSString *receiverPhone;
@property (strong, nonatomic) NSString *orderNo;
@property (strong, nonatomic) NSString *expressNo;
@property (strong, nonatomic) NSString *giftName;
@property (strong, nonatomic) NSString *giftImage;
@property (strong, nonatomic) NSString *remark;
@property (strong, nonatomic) NSString *optionName;
@end
