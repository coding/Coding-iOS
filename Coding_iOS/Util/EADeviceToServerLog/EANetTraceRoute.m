//
//  EANetTraceRoute.m
//  CodingMart
//
//  Created by Ease on 2016/11/29.
//  Copyright © 2016年 net.coding. All rights reserved.
//

#import "EANetTraceRoute.h"
#import "LDNetTraceRoute.h"

@interface EANetTraceRoute ()<LDNetTraceRouteDelegate>
@property (strong, nonatomic) LDNetTraceRoute *ldNTR;
@property (strong, nonatomic) NSString *hostStr;
@property (strong, nonatomic) NSMutableArray *traceRouteList;
@property (copy, nonatomic) void(^finishBlock)(NSArray *traceRouteList);

@end

@implementation EANetTraceRoute

+ (instancetype)shareManager{
    static EANetTraceRoute *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

+ (void)getTraceRouteOfHost:(NSString *)hostStr block:(void(^)(NSArray *traceRouteList))block{
    EANetTraceRoute *eaNTR = [self shareManager];
    if ([eaNTR.ldNTR isRunning]) {//中断上一个
        [eaNTR.ldNTR stopTrace];
        [eaNTR traceRouteDidEnd];
    }
    eaNTR.finishBlock = block;
    [eaNTR doTraceRouteOfHost:hostStr];
}

- (void)doTraceRouteOfHost:(NSString *)hostStr{
    if (hostStr.length > 0) {
        _hostStr = hostStr;
        _traceRouteList = @[].mutableCopy;
        if (!_ldNTR) {
            _ldNTR = [[LDNetTraceRoute alloc] initWithMaxTTL:TRACEROUTE_MAX_TTL timeout:TRACEROUTE_TIMEOUT maxAttempts:5 port:TRACEROUTE_PORT];
            _ldNTR.delegate = self;
        }
        [NSThread detachNewThreadSelector:@selector(doTraceRoute:)
                                 toTarget:_ldNTR
                               withObject:hostStr];
    }else{
        [self traceRouteDidEnd];
    }
}

#pragma LDNetTraceRouteDelegate
- (void)appendRouteLog:(NSString *)routeLog{
    [_traceRouteList addObject:routeLog];
}

- (void)traceRouteDidEnd{
    if (_finishBlock) {
        _finishBlock(_traceRouteList);
    }
}
@end
