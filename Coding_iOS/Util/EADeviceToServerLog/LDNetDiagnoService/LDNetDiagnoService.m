//
//  LDNetDiagnoService.m
//  LDNetDiagnoServieDemo
//
//  Created by 庞辉 on 14-10-29.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "LDNetDiagnoService.h"
#import "LDNetPing.h"
#import "LDNetTraceRoute.h"
#import "LDNetGetAddress.h"
#import "LDNetTimer.h"
#import "LDNetConnect.h"

static NSString *const kPingOpenServerIP = @"";
static NSString *const kCheckOutIPURL = @"";

@interface LDNetDiagnoService () <LDNetPingDelegate, LDNetTraceRouteDelegate,
                                  LDNetConnectDelegate> {
    NSString *_appCode;  //客户端标记
    NSString *_appName;
    NSString *_appVersion;
    NSString *_UID;       //用户ID
    NSString *_deviceID;  //客户端机器ID，如果不传入会默认取API提供的机器ID
    NSString *_carrierName;
    NSString *_ISOCountryCode;
    NSString *_MobileCountryCode;
    NSString *_MobileNetCode;

    NETWORK_TYPE _curNetType;
    NSString *_localIp;
    NSString *_gatewayIp;
    NSArray *_dnsServers;
    NSArray *_hostAddress;

    NSMutableString *_logInfo;  //记录网络诊断log日志
    BOOL _isRunning;
    BOOL _connectSuccess;  //记录连接是否成功
    LDNetPing *_netPinger;
    LDNetTraceRoute *_traceRouter;
    LDNetConnect *_netConnect;
}

@end

@implementation LDNetDiagnoService
#pragma mark - public method
/**
 * 初始化网络诊断服务
 */
- (id)initWithAppCode:(NSString *)theAppCode
              appName:(NSString *)theAppName
           appVersion:(NSString *)theAppVersion
               userID:(NSString *)theUID
             deviceID:(NSString *)theDeviceID
              dormain:(NSString *)theDormain
          carrierName:(NSString *)theCarrierName
       ISOCountryCode:(NSString *)theISOCountryCode
    MobileCountryCode:(NSString *)theMobileCountryCode
        MobileNetCode:(NSString *)theMobileNetCode
{
    self = [super init];
    if (self) {
        _appCode = theAppCode;
        _appName = theAppName;
        _appVersion = theAppVersion;
        _UID = theUID;
        _deviceID = theDeviceID;
        _dormain = theDormain;
        _carrierName = theCarrierName;
        _ISOCountryCode = theISOCountryCode;
        _MobileCountryCode = theMobileCountryCode;
        _MobileNetCode = theMobileNetCode;

        _logInfo = [[NSMutableString alloc] initWithCapacity:20];
        _isRunning = NO;
    }

    return self;
}


/**
 * 开始诊断网络
 */
- (void)startNetDiagnosis
{
    if (!_dormain || [_dormain isEqualToString:@""]) return;

    _isRunning = YES;
    [_logInfo setString:@""];
    [self recordStepInfo:@"开始诊断..."];
    [self recordCurrentAppVersion];
    [self recordLocalNetEnvironment];

    //未联网不进行任何检测
    if (_curNetType == 0) {
        _isRunning = NO;
        [self recordStepInfo:@"\n当前主机未联网，请检查网络！"];
        [self recordStepInfo:@"\n网络诊断结束\n"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(netDiagnosisDidEnd:)]) {
            [self.delegate netDiagnosisDidEnd:_logInfo];
        }
        return;
    }

    if (_isRunning) {
//        [self recordOutIPInfo];
    }

    if (_isRunning) {
        // connect诊断，同步过程, 如果TCP无法连接，检查本地网络环境
        _connectSuccess = NO;
        [self recordStepInfo:@"\n开始TCP连接测试..."];
        if ([_hostAddress count] > 0) {
            _netConnect = [[LDNetConnect alloc] init];
            _netConnect.delegate = self;
            for (int i = 0; i < [_hostAddress count]; i++) {
                [_netConnect runWithHostAddress:[_hostAddress objectAtIndex:i] port:80];
            }
        } else {
            [self recordStepInfo:@"DNS解析失败，主机地址不可达"];
        }
        if (_isRunning) {
            [self pingDialogsis:!_connectSuccess];
        }
    }


    if (_isRunning) {
        //开始诊断traceRoute
        [self recordStepInfo:@"\n开始traceroute..."];
        _traceRouter = [[LDNetTraceRoute alloc] initWithMaxTTL:TRACEROUTE_MAX_TTL
                                                       timeout:TRACEROUTE_TIMEOUT
                                                   maxAttempts:TRACEROUTE_ATTEMPTS
                                                          port:TRACEROUTE_PORT];
        _traceRouter.delegate = self;
        if (_traceRouter) {
            [NSThread detachNewThreadSelector:@selector(doTraceRoute:)
                                     toTarget:_traceRouter
                                   withObject:_dormain];
        }
    }
}


/**
 * 停止诊断网络, 清空诊断状态
 */
- (void)stopNetDialogsis
{
    if (_isRunning) {
        if (_netConnect != nil) {
            [_netConnect stopConnect];
            _netConnect = nil;
        }

        if (_netPinger != nil) {
            [_netPinger stopPing];
            _netPinger = nil;
        }

        if (_traceRouter != nil) {
            [_traceRouter stopTrace];
            _traceRouter = nil;
        }

        _isRunning = NO;
    }
}


/**
 * 打印整体loginInfo；
 */
- (void)printLogInfo
{
    NSLog(@"\n%@\n", _logInfo);
}


#pragma mark -
#pragma mark - private method

/*!
 *  @brief  获取App相关信息
 */
- (void)recordCurrentAppVersion
{
    //输出应用版本信息和用户ID
    [self recordStepInfo:[NSString stringWithFormat:@"应用code: %@", _appCode]];
    NSDictionary *dicBundle = [[NSBundle mainBundle] infoDictionary];

    if (!_appName || [_appName isEqualToString:@""]) {
        _appName = [dicBundle objectForKey:@"CFBundleDisplayName"];
    }
    [self recordStepInfo:[NSString stringWithFormat:@"应用名称: %@", _appName]];

    if (!_appVersion || [_appVersion isEqualToString:@""]) {
        _appVersion = [dicBundle objectForKey:@"CFBundleShortVersionString"];
    }
    [self recordStepInfo:[NSString stringWithFormat:@"应用版本: %@", _appVersion]];
    [self recordStepInfo:[NSString stringWithFormat:@"用户id: %@", _UID]];

    //输出机器信息
    UIDevice *device = [UIDevice currentDevice];
    [self recordStepInfo:[NSString stringWithFormat:@"机器类型: %@", [device systemName]]];
    [self recordStepInfo:[NSString stringWithFormat:@"系统版本: %@", [device systemVersion]]];
    if (!_deviceID || [_deviceID isEqualToString:@""]) {
        _deviceID = [self uniqueAppInstanceIdentifier];
    }
    [self recordStepInfo:[NSString stringWithFormat:@"机器ID: %@", _deviceID]];


    //运营商信息
    if (!_carrierName || [_carrierName isEqualToString:@""]) {
        CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        if (carrier != NULL) {
            _carrierName = [carrier carrierName];
            _ISOCountryCode = [carrier isoCountryCode];
            _MobileCountryCode = [carrier mobileCountryCode];
            _MobileNetCode = [carrier mobileNetworkCode];
        } else {
            _carrierName = @"";
            _ISOCountryCode = @"";
            _MobileCountryCode = @"";
            _MobileNetCode = @"";
        }
    }

    [self recordStepInfo:[NSString stringWithFormat:@"运营商: %@", _carrierName]];
    [self recordStepInfo:[NSString stringWithFormat:@"ISOCountryCode: %@", _ISOCountryCode]];
    [self recordStepInfo:[NSString stringWithFormat:@"MobileCountryCode: %@", _MobileCountryCode]];
    [self recordStepInfo:[NSString stringWithFormat:@"MobileNetworkCode: %@", _MobileNetCode]];
}


/*!
 *  @brief  获取本地网络环境信息
 */
- (void)recordLocalNetEnvironment
{
    [self recordStepInfo:[NSString stringWithFormat:@"\n\n诊断域名 %@...\n", _dormain]];
    //判断是否联网以及获取网络类型
    NSArray *typeArr = [NSArray arrayWithObjects:@"2G", @"3G", @"4G", @"5G", @"wifi", nil];
    _curNetType = [LDNetGetAddress getNetworkTypeFromStatusBar];
    if (_curNetType == 0) {
        [self recordStepInfo:[NSString stringWithFormat:@"当前是否联网: 未联网"]];
    } else {
        [self recordStepInfo:[NSString stringWithFormat:@"当前是否联网: 已联网"]];
        if (_curNetType > 0 && _curNetType < 6) {
            [self
                recordStepInfo:[NSString stringWithFormat:@"当前联网类型: %@",
                                                          [typeArr objectAtIndex:_curNetType - 1]]];
        }
    }

    //本地ip信息
    _localIp = [LDNetGetAddress deviceIPAdress];
    [self recordStepInfo:[NSString stringWithFormat:@"当前本机IP: %@", _localIp]];

    if (_curNetType == NETWORK_TYPE_WIFI) {
        _gatewayIp = [LDNetGetAddress getGatewayIPAddress];
        [self recordStepInfo:[NSString stringWithFormat:@"本地网关: %@", _gatewayIp]];
    } else {
        _gatewayIp = @"";
    }


    _dnsServers = [NSArray arrayWithArray:[LDNetGetAddress outPutDNSServers]];
    [self recordStepInfo:[NSString stringWithFormat:@"本地DNS: %@",
                                                    [_dnsServers componentsJoinedByString:@", "]]];

    [self recordStepInfo:[NSString stringWithFormat:@"远端域名: %@", _dormain]];

    // host地址IP列表
    long time_start = [LDNetTimer getMicroSeconds];
    _hostAddress = [NSArray arrayWithArray:[LDNetGetAddress getDNSsWithDormain:_dormain]];
    long time_duration = [LDNetTimer computeDurationSince:time_start] / 1000;
    if ([_hostAddress count] == 0) {
        [self recordStepInfo:[NSString stringWithFormat:@"DNS解析结果: 解析失败"]];
    } else {
        [self
            recordStepInfo:[NSString stringWithFormat:@"DNS解析结果: %@ (%ldms)",
                                                      [_hostAddress componentsJoinedByString:@", "],
                                                      time_duration]];
    }
}

/**
 * 使用接口获取用户的出口IP和DNS信息
 */
- (void)recordOutIPInfo
{
    [self recordStepInfo:@"\n开始获取运营商信息..."];
    // 初始化请求, 这里是变长的, 方便扩展
    NSMutableURLRequest *request =
        [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kCheckOutIPURL]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 timeoutInterval:10];

    // 发送同步请求, data就是返回的数据
    NSError *error = nil;
    NSData *data =
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error != nil) {
        NSLog(@"error = %@", error);
        [self recordStepInfo:@"\n获取超时"];
        return;
    }
    NSString *response = [[NSString alloc] initWithData:data encoding:0x80000632];
    NSLog(@"response: %@", response);
    [self recordStepInfo:response];
}


/**
 * 构建ping列表并进行ping诊断
 */
- (void)pingDialogsis:(BOOL)pingLocal
{
    //诊断ping信息, 同步过程
    NSMutableArray *pingAdd = [[NSMutableArray alloc] init];
    NSMutableArray *pingInfo = [[NSMutableArray alloc] init];
    if (pingLocal) {
        [pingAdd addObject:@"127.0.0.1"];
        [pingInfo addObject:@"本机"];
        [pingAdd addObject:_localIp];
        [pingInfo addObject:@"本机IP"];
        if (_gatewayIp && ![_gatewayIp isEqualToString:@""]) {
            [pingAdd addObject:_gatewayIp];
            [pingInfo addObject:@"本地网关"];
        }
        if ([_dnsServers count] > 0) {
            [pingAdd addObject:[_dnsServers objectAtIndex:0]];
            [pingInfo addObject:@"DNS服务器"];
        }
    }

    //不管服务器解析DNS是否可达，均需要ping指定ip地址
    if([_localIp rangeOfString:@":"].location == NSNotFound){
        [pingAdd addObject:kPingOpenServerIP];
        [pingInfo addObject:@"开放服务器"];
    }

    [self recordStepInfo:@"\n开始ping..."];
    _netPinger = [[LDNetPing alloc] init];
    _netPinger.delegate = self;
    for (int i = 0; i < [pingAdd count]; i++) {
        [self recordStepInfo:[NSString stringWithFormat:@"ping: %@ %@ ...",
                                                        [pingInfo objectAtIndex:i],
                                                        [pingAdd objectAtIndex:i]]];
        if ([[pingAdd objectAtIndex:i] isEqualToString:kPingOpenServerIP]) {
            [_netPinger runWithHostName:[pingAdd objectAtIndex:i] normalPing:YES];
        } else {
            [_netPinger runWithHostName:[pingAdd objectAtIndex:i] normalPing:YES];
        }
    }
}


#pragma mark -
#pragma mark - netPingDelegate

- (void)appendPingLog:(NSString *)pingLog
{
    [self recordStepInfo:pingLog];
}

- (void)netPingDidEnd
{
    // net
}

#pragma mark - traceRouteDelegate
- (void)appendRouteLog:(NSString *)routeLog
{
    [self recordStepInfo:routeLog];
}

- (void)traceRouteDidEnd
{
    _isRunning = NO;
    [self recordStepInfo:@"\n网络诊断结束\n"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(netDiagnosisDidEnd:)]) {
        [self.delegate netDiagnosisDidEnd:_logInfo];
    }
}

#pragma mark - connectDelegate
- (void)appendSocketLog:(NSString *)socketLog
{
    [self recordStepInfo:socketLog];
}

- (void)connectDidEnd:(BOOL)success
{
    if (success) {
        _connectSuccess = YES;
    }
}


#pragma mark - common method
/**
 * 如果调用者实现了stepInfo接口，输出信息
 */
- (void)recordStepInfo:(NSString *)stepInfo
{
    if (stepInfo == nil) stepInfo = @"";
    [_logInfo appendString:stepInfo];
    [_logInfo appendString:@"\n"];

    if (self.delegate && [self.delegate respondsToSelector:@selector(netDiagnosisStepInfo:)]) {
        [self.delegate netDiagnosisStepInfo:[NSString stringWithFormat:@"%@\n", stepInfo]];
    }
}


/**
 * 获取deviceID
 */
- (NSString *)uniqueAppInstanceIdentifier
{
    NSString *app_uuid = @"";
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    app_uuid = [NSString stringWithString:(__bridge NSString *)uuidString];
    CFRelease(uuidString);
    CFRelease(uuidRef);
    return app_uuid;
}


@end
