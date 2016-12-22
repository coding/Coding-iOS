//
//  EANetTraceRoute.h
//  CodingMart
//
//  Created by Ease on 2016/11/29.
//  Copyright © 2016年 net.coding. All rights reserved.
//

//libresolv.9.tbd
//CoreTelephony.framework

#import <Foundation/Foundation.h>

@interface EANetTraceRoute : NSObject
+ (void)getTraceRouteOfHost:(NSString *)hostStr block:(void(^)(NSArray *traceRouteList))block;
@end
