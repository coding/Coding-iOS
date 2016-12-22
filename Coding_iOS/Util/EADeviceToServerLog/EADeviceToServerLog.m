//
//  EADeviceToServerLog.m
//  CodingMart
//
//  Created by Ease on 2016/11/28.
//  Copyright © 2016年 net.coding. All rights reserved.
//

//MinIntervalDutation 单位（秒）
#define kEALogKey_PostServerPath @"https://tracker.coding.net/v1"
#define kEALogKey_MinIntervalDutation (60 * 30)
#define kEALogKey_LogFileName @"deviceLog"
#define kEALogKey_LastTimeLogDate @"ealastTimeLogDate"
#define kEALogKey_StartTime @"startTime"
#define kEALogKey_FinishTime @"finishTime"
#define kEALogKey_LogInfo @"log"

#import <netdb.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <ObjectiveGit/ObjectiveGit.h>//https://github.com/libgit2/objective-git
#import "EADeviceToServerLog.h"
#import "EANetTraceRoute.h"
#import "LDNetGetAddress.h"
#import "Login.h"
#import "AFNetworkReachabilityManager.h"
#import "NSData+gzip.h"

@interface EADeviceToServerLog ()
@property (strong, nonatomic) NSMutableDictionary *logDict;
@property (strong, nonatomic) NSArray *hostStrList, *portList;
@property (assign, nonatomic) BOOL isRunning;
@end

@implementation EADeviceToServerLog

+ (instancetype)shareManager{
    static EADeviceToServerLog *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hostStrList = @[@"coding.net",
                         @"git.coding.net",
                         @"mart.coding.net"];
        _portList = @[@(80),
                      @(443)];
    }
    return self;
}

- (void)p_resetLog{
    if (!_logDict) {
        _logDict = @{}.mutableCopy;
    }else{
        [_logDict removeAllObjects];
    }
    _logDict[kEALogKey_StartTime] = [self p_curTime];
//    添加 App 信息
    _logDict[@"userAgent"] = [NSString userAgentStr];
    _logDict[@"globalKey"] = [Login curLoginUser].global_key;
}

- (void)p_addLog:(NSDictionary *)dict{
    for (NSString *key in dict) {
        _logDict[key] = dict[key];
    }
}

- (NSNumber *)p_curTime{
    return @((long)(1000 *[[NSDate date] timeIntervalSince1970]));
}

- (NSString*)p_dictionaryToJson:(NSDictionary *)dict{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)p_updateLogDate{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:kEALogKey_LastTimeLogDate];
    [defaults synchronize];
}

- (NSDate *)p_lastTimeLogDate{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kEALogKey_LastTimeLogDate];
}

- (BOOL)p_canStartLog{
    if (_isRunning) {
        return NO;
    }
    NSDate *lastTimeLogDate = [self p_lastTimeLogDate];
    if (!lastTimeLogDate) {
        return YES;
    }else{
        return [[NSDate date] timeIntervalSinceDate:lastTimeLogDate] > kEALogKey_MinIntervalDutation;
    }
}

- (void)tryToStart{
    if ([self p_canStartLog]) {
        [self startLog];
    }else{
        [self tryToPostToServer];
    }
}

- (void)tryToPostToServer{
    if (![AFNetworkReachabilityManager sharedManager].isReachableViaWiFi) {
        return;
    }
    if (_isRunning) {
        return;
    }
    _isRunning = YES;
    NSString *logStr = [self p_readLog];
    if (logStr.length > 0) {
        NSURL *url = [NSURL URLWithString:kEALogKey_PostServerPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        request.HTTPBody = [self p_gzipStr:logStr];
        [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        __weak typeof(self) weakSelf = self;
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [weakSelf handlePostToServerSuccess:!error];
        }];
        [task resume];
    }else{
        _isRunning = NO;
    }
}

- (NSData *)p_gzipStr:(NSString *)string{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    data = [NSData gzipData:data];
    return data;
}

- (void)handlePostToServerSuccess:(BOOL)isSuccess{
    _isRunning = NO;
    if (isSuccess) {
        NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingFormat:@"/%@", kEALogKey_LogFileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:logFilePath]) {
            [fileManager removeItemAtPath:logFilePath error:nil];
        }
    }
}

- (void)startLog{
    if (_isRunning) {
        return;
    }
    _isRunning = YES;
    [self p_resetLog];
    __weak typeof(self) weakSelf = self;
    [self getLocalIPBlock:^(NSDictionary *dictLocalIP) {
        if (!dictLocalIP) {//第一步获取 ip 不能完成的话，默认原因为连不上外网，取消截下来的监控步骤
            [weakSelf handleCancel];
        }else{
            [weakSelf p_addLog:dictLocalIP];
            [weakSelf getHostIPsBlock:^(NSDictionary *dictHostIPs) {
                [weakSelf p_addLog:dictHostIPs];
                [weakSelf getHostPortsBlock:^(NSDictionary *dictHostPorts) {
                    [weakSelf p_addLog:dictHostPorts];
                    [weakSelf getHostMtrsBlock:^(NSDictionary *dictHostMtrs) {
                        [weakSelf p_addLog:dictHostMtrs];
                        [weakSelf getGitsBlock:^(NSDictionary *dictGits) {
                            [weakSelf p_addLog:dictGits];
                            [weakSelf handleFinish];
                        }];
                    }];
                }];
            }];
        }
    }];
}

- (void)handleFinish{
    _isRunning = NO;
    _logDict[kEALogKey_FinishTime] = [self p_curTime];
    _logDict[@"logDuration"] = [NSString stringWithFormat:@"%ldms", ([_logDict[kEALogKey_FinishTime] longValue] - [_logDict[kEALogKey_StartTime] longValue])] ;
    //写文件
    [self p_writeLog];
    [self p_resetLog];
    [self tryToPostToServer];
}


- (void)handleCancel{
    _isRunning = NO;
    [self p_resetLog];
}

- (void)p_writeLog{
    if (!_logDict) {
        return;
    }
    NSData *logData = [NSJSONSerialization dataWithJSONObject:_logDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *logStr = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
    if (logStr.length <= 0) {
        return;
    }
    NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingFormat:@"/%@", kEALogKey_LogFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:logFilePath]) {
        logStr = [NSString stringWithFormat:@"\n--------------------------------------------------\n%@", logStr];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:logFilePath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[logStr dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }else{
        [logStr writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    [self p_updateLogDate];
}

- (NSString *)p_readLog{
    NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingFormat:@"/%@", kEALogKey_LogFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:logFilePath]) {
        NSString *logStr = [[NSString alloc] initWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
        return logStr;
    }else{
        return nil;
    }
}

- (void)getLocalIPBlock:(void(^)(NSDictionary *dictLocalIP))block{
    NSURL *url = [NSURL URLWithString:@"http://ip.cn"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:@"curl/7.41.0" forHTTPHeaderField:@"User-Agent"];
    NSMutableDictionary *dictLocalIP = @{kEALogKey_StartTime: [self p_curTime]}.mutableCopy;
    __weak typeof(self) weakSelf = self;
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dictLocalIP[@"log"] = dataStr;
        dictLocalIP[@"dns"] = [LDNetGetAddress outPutDNSServers];
        dictLocalIP[kEALogKey_FinishTime] = [weakSelf p_curTime];
        if (error) {
            block(nil);//需要中断监控
        }else{
            block(@{@"localIp": dictLocalIP});
        }
    }];
    [task resume];
}

- (void)getHostIPsBlock:(void(^)(NSDictionary *dictHostIPs))block{
    static NSMutableArray *dictHostIPList;
    if (dictHostIPList.count == _hostStrList.count){
        block(@{@"hostIp": dictHostIPList});
        dictHostIPList = nil;
    }else{
        if (!dictHostIPList) {
            dictHostIPList = @[].mutableCopy;
        }
        __weak typeof(self) weakSelf = self;
        [self getHost:_hostStrList[dictHostIPList.count] ipBlock:^(NSDictionary *dictHostIP) {
            [dictHostIPList addObject:dictHostIP];
            [weakSelf getHostIPsBlock:block];
        }];
    }
}

- (void)getHost:(NSString *)hostStr ipBlock:(void(^)(NSDictionary *dictHostIP))block{
    NSMutableDictionary *dictHostIP = @{kEALogKey_StartTime: [self p_curTime]}.mutableCopy;
    dictHostIP[@"host"] = hostStr;
    dictHostIP[@"ip"] = [self p_getIPWithHostName:hostStr];
    dictHostIP[kEALogKey_FinishTime] = [self p_curTime];
    block(dictHostIP);
}

- (NSString *)p_getIPWithHostName:(NSString *)hostName{
    struct hostent *hs;
    struct sockaddr_in server;
    if ((hs = gethostbyname([hostName UTF8String])) != NULL) {
        server.sin_addr = *((struct in_addr*)hs->h_addr_list[0]);
        return [NSString stringWithUTF8String:inet_ntoa(server.sin_addr)];
    }
    return nil;
}

- (void)getHostPortsBlock:(void(^)(NSDictionary *dictHostPorts))block{
    static NSMutableArray *dictHostPortList;
    if (dictHostPortList.count == _hostStrList.count * _portList.count){
        block(@{@"portScan": dictHostPortList});
        dictHostPortList = nil;
    }else{
        if (!dictHostPortList) {
            dictHostPortList = @[].mutableCopy;
        }
        __weak typeof(self) weakSelf = self;
        [self getHost:_hostStrList[dictHostPortList.count / _portList.count] port:_portList[dictHostPortList.count % _portList.count] block:^(NSDictionary *dictHostPort) {
            [dictHostPortList addObject:dictHostPort];
            [weakSelf getHostPortsBlock:block];
        }];
    }
}

- (void)getHost:(NSString *)hostStr port:(NSNumber *)port block:(void(^)(NSDictionary *dictHostPort))block{
    NSMutableDictionary *dictHostPort = @{kEALogKey_StartTime: [self p_curTime]}.mutableCopy;
    dictHostPort[@"host"] = hostStr;
    dictHostPort[@"port"] = port;
    NSString *errorStr = nil;
    dictHostPort[@"result"] = @([self p_canLinkToHost:hostStr port:port errorStr:&errorStr]);
    dictHostPort[kEALogKey_FinishTime] = [self p_curTime];
    block(dictHostPort);
}

- (BOOL)p_canLinkToHost:(NSString *)hostStr port:(NSNumber *)port errorStr:(NSString **)errorStr{
    int socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
    struct hostent *hs;
    if (socketFileDescriptor == -1) {
        *errorStr = @"创建 socket 失败";
        return NO;
    }else if ((hs = gethostbyname([hostStr UTF8String])) == NULL){
        *errorStr = @"IP 地址解析失败";
        return NO;
    }else{
        struct sockaddr_in socketParameters;
        socketParameters.sin_family = AF_INET;
        socketParameters.sin_addr = *((struct in_addr*)hs->h_addr_list[0]);
        socketParameters.sin_port = htons(port.intValue);
        int ret = connect(socketFileDescriptor, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
        close(socketFileDescriptor);
        if (ret == -1) {
            *errorStr = @"socket 连接失败";
            return NO;
        }else{//链接成功
            return YES;
        }
    }
}

- (void)getHostMtrsBlock:(void(^)(NSDictionary *dictHostMtrs))block{
    NSString *dnsStr = [self.logDict[@"localIp"][@"dns"] firstObject];
    if (dnsStr.length > 0 && [dnsStr componentsSeparatedByString:@"."].count != 4) {//不是 ipv4 的暂时不处理
        block(nil);
        return;
    }
    static NSMutableArray *dictHostMtrList;
    if (!dictHostMtrList) {
        dictHostMtrList = @[].mutableCopy;
    }
    if (dictHostMtrList.count == _hostStrList.count){
        block(@{@"mtr": dictHostMtrList});
        dictHostMtrList = nil;
    }else{
        __weak typeof(self) weakSelf = self;
        [self getHost:_hostStrList[dictHostMtrList.count] mtrBlock:^(NSDictionary *dictHostMtr) {
            [dictHostMtrList addObject:dictHostMtr];
            [weakSelf getHostMtrsBlock:block];
        }];
    }
}

- (void)getHost:(NSString *)hostStr mtrBlock:(void(^)(NSDictionary *dictHostMtr))block{
    NSMutableDictionary *dictHostMtr = @{kEALogKey_StartTime: [self p_curTime]}.mutableCopy;
    dictHostMtr[@"host"] = hostStr;
    [EANetTraceRoute getTraceRouteOfHost:hostStr block:^(NSArray *traceRouteList) {
        dictHostMtr[@"pings"] = traceRouteList;
        dictHostMtr[kEALogKey_FinishTime] = [self p_curTime];
        block(dictHostMtr);
    }];
}

- (void)getGitsBlock:(void(^)(NSDictionary *dictGits))block{
    NSURL *repoURL = [NSURL URLWithString:@"https://git.coding.net/coding/test-point.git"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL *appDocsDir = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].lastObject;
    NSURL *localURL = [NSURL URLWithString:repoURL.lastPathComponent relativeToURL:appDocsDir];
    if ([fileManager fileExistsAtPath:localURL.path isDirectory:nil]) {//已经存在的话，就先删掉
        [fileManager removeItemAtURL:localURL error:nil];
    }
    
    NSMutableDictionary *dictGits = @{kEALogKey_StartTime: [self p_curTime]}.mutableCopy;
    dictGits[@"url"] = repoURL.absoluteString;
    NSError* error = nil;
    GTRepository *repo = [GTRepository cloneFromURL:repoURL toWorkingDirectory:localURL options:@{GTRepositoryCloneOptionsCheckout: @NO} error:&error transferProgressBlock:^(const git_transfer_progress *progress, BOOL *stop) {
        DebugLog(@"received_objects_count: %d", progress->received_objects);
    } checkoutProgressBlock:^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {//{Checkout: @NO}，所以这里不会执行
        DebugLog(@"checkout_progress:%.2f", (float)completedSteps/totalSteps);
    }];
    
    dictGits[kEALogKey_FinishTime] = [self p_curTime];
    dictGits[@"result"] = repo? @YES: @NO;
    dictGits[kEALogKey_LogInfo] = error.description ?: @"";
    block(@{@"git": dictGits});
}

@end
