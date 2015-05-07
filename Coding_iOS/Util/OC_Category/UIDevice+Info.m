//
//  UIDevice+Info.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIDevice+Info.h"
#import "sys/utsname.h"



@implementation UIDevice (Info)

+ (NSDictionary *)systemInfoDict{
    static NSMutableDictionary *systemInfoDict;
    if (!systemInfoDict) {
        systemInfoDict = [[NSMutableDictionary alloc] init];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        UIDevice *currentDevice = [UIDevice currentDevice];
        
        systemInfoDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"device" : currentDevice.deviceName,
                                                                           @"systemName" : currentDevice.systemName,
                                                                           @"systemVersion" : currentDevice.systemVersion,
                                                                           @"appName" : [infoDict objectForKey:@"CFBundleDisplayName"],
                                                                           @"appVersion" : [infoDict objectForKey:@"CFBundleShortVersionString"],
                                                                           @"appBuildVersion" : [infoDict objectForKey:@"CFBundleVersion"]
                                                                           }];
    }
    return systemInfoDict;
}

- (NSString *)deviceName{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSArray *modelArray = @[
                            
                            @"i386", @"x86_64",
                            
                            @"iPhone1,1",
                            @"iPhone1,2",
                            @"iPhone2,1",
                            @"iPhone3,1",
                            @"iPhone3,2",
                            @"iPhone3,3",
                            @"iPhone4,1",
                            @"iPhone5,1",
                            @"iPhone5,2",
                            @"iPhone5,3",
                            @"iPhone5,4",
                            @"iPhone6,1",
                            @"iPhone6,2",
                            @"iPhone7,1",
                            @"iPhone7,2",
                            
                            @"iPod1,1",
                            @"iPod2,1",
                            @"iPod3,1",
                            @"iPod4,1",
                            @"iPod5,1",
                            
                            @"iPad1,1",
                            @"iPad2,1",
                            @"iPad2,2",
                            @"iPad2,3",
                            @"iPad2,4",
                            @"iPad3,1",
                            @"iPad3,2",
                            @"iPad3,3",
                            @"iPad3,4",
                            @"iPad3,5",
                            @"iPad3,6",
                            @"iPad4,1",
                            @"iPad4,2",
                            @"iPad4,3",
                            
                            @"iPad2,5",
                            @"iPad2,6",
                            @"iPad2,7",
                            @"iPad4,4",
                            @"iPad4,5",
                            @"iPad4,6",
                            ];
    NSArray *modelNameArray = @[
                                
                                @"iPhone", @"iPhone",
                                
                                @"iPhone 2G",
                                @"iPhone 3G",
                                @"iPhone 3GS",
                                @"iPhone 4",
                                @"iPhone 4",
                                @"iPhone 4",
                                @"iPhone 4S",
                                @"iPhone 5",
                                @"iPhone 5",
                                @"iPhone 5c",
                                @"iPhone 5c",
                                @"iPhone 5s",
                                @"iPhone 5s",
                                @"iPhone 6 Plus",
                                @"iPhone 6",
                                
                                @"iPod Touch 1G",
                                @"iPod Touch 2G",
                                @"iPod Touch 3G",
                                @"iPod Touch 4G",
                                @"iPod Touch 5G",
                                
                                @"iPad",
                                @"iPad 2",
                                @"iPad 2",
                                @"iPad 2",
                                @"iPad 2",
                                @"iPad 3",
                                @"iPad 3",
                                @"iPad 3",
                                @"iPad 4",
                                @"iPad 4",
                                @"iPad 4",
                                @"iPad Air",
                                @"iPad Air",
                                @"iPad Air",
                                
                                @"iPad mini",
                                @"iPad mini",
                                @"iPad mini",
                                @"iPad mini 2G",
                                @"iPad mini 2G",
                                @"iPad mini 2G"
                                ];
    
//    NSArray *modelNameArray = @[
//                                
//                                @"iPhone Simulator", @"iPhone Simulator",
//                                
//                                @"iPhone 2G",
//                                @"iPhone 3G",
//                                @"iPhone 3GS",
//                                @"iPhone 4(GSM)",
//                                @"iPhone 4(GSM Rev A)",
//                                @"iPhone 4(CDMA)",
//                                @"iPhone 4S",
//                                @"iPhone 5(GSM)",
//                                @"iPhone 5(GSM+CDMA)",
//                                @"iPhone 5c(GSM)",
//                                @"iPhone 5c(Global)",
//                                @"iPhone 5s(GSM)",
//                                @"iPhone 5s(Global)",
//                                @"iPhone 6 Plus",
//                                @"iPhone 6",
//                                
//                                @"iPod Touch 1G",
//                                @"iPod Touch 2G",
//                                @"iPod Touch 3G",
//                                @"iPod Touch 4G",
//                                @"iPod Touch 5G",
//                                
//                                @"iPad",
//                                @"iPad 2(WiFi)",
//                                @"iPad 2(GSM)",
//                                @"iPad 2(CDMA)",
//                                @"iPad 2(WiFi + New Chip)",
//                                @"iPad 3(WiFi)",
//                                @"iPad 3(GSM+CDMA)",
//                                @"iPad 3(GSM)",
//                                @"iPad 4(WiFi)",
//                                @"iPad 4(GSM)",
//                                @"iPad 4(GSM+CDMA)",
//                                @"iPad Air",
//                                @"iPad Air",
//                                @"iPad Air",
//                                
//                                @"iPad mini (WiFi)",
//                                @"iPad mini (GSM)",
//                                @"iPad mini (GSM+CDMA)",
//                                @"iPad mini 2G",
//                                @"iPad mini 2G",
//                                @"iPad mini 2G"
//                                ];
    NSInteger modelIndex = - 1;
    NSString *modelNameString = @"";
    modelIndex = [modelArray indexOfObject:deviceString];
    if (modelIndex >= 0 && modelIndex < [modelNameArray count]) {
        modelNameString = [modelNameArray objectAtIndex:modelIndex];
    }
    
    
    DebugLog(@"----设备类型---%@",modelNameString);
    return modelNameString;
}
@end
