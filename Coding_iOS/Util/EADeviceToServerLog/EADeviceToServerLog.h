//
//  EADeviceToServerLog.h
//  CodingMart
//
//  Created by Ease on 2016/11/28.
//  Copyright © 2016年 net.coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EADeviceToServerLog : NSObject
+ (instancetype)shareManager;
- (void)tryToStart;
@end
