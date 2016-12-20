//
//  EADeviceToServerLog.h
//  CodingMart
//
//  Created by Ease on 2016/11/28.
//  Copyright © 2016年 net.coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EADeviceToServerLog : NSObject
@property (strong, nonatomic) NSString *userAgentStr, *globalKey;
@property (assign, nonatomic) NSTimeInterval minDutation;
+ (instancetype)shareManager;
- (void)tryToStart;
@end
