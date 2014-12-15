//
//  XGPush.h
//  XG-SDK
//
//  Created by xiangchen on 13-10-18.
//  Copyright (c) 2013年 mta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define XG_SDK_VERSION @"2.2.0"

@interface XGPush : NSObject

/**
 * 初始化信鸽
 * @param appId - 通过前台申请的应用ID
 * @param appKey - 通过前台申请的appKey
 * @return none
 */
+(void)startApp:(uint32_t)appId appKey:(NSString *)appKey;

/**
 * 如果注销过信鸽，需要再次注册push服务前的准备
 * @param successCallback 初始化之后的回调，如果需要即刻恢复push服务，registerPush在此回调中调用
 * @return none
 */
+(void)initForReregister:(void (^)(void)) successCallback;

/**
 * 判断当前是否是已注销状态
 * @param none
 * @return none
 */
+(BOOL)isUnRegisterStatus;

/**
 * 设置设备的帐号 (在初始化信鸽后，注册设备之前调用。account本质上是registerDevice的一个参数)
 * @param account - 帐号名（长度为2个字节以上，不要使用"test","123456"这种过于简单的字符串）
 * @return none
 */
+(void)setAccount:(NSString *)account;

/**
 * 注册设备
 * @param deviceToken - 通过app delegate的didRegisterForRemoteNotificationsWithDeviceToken回调的获取
 * @return 获取的deviceToken字符串
 */
+(NSString *)registerDevice:(NSData *)deviceToken;

//注册设备，支持回调函数版本
+(NSString *)registerDevice:(NSData *)deviceToken successCallback:(void (^)(void)) successCallback errorCallback:(void (^)(void)) errorCallback;

//注册设备，支持字符串deviceToken版本
+(NSString *)registerDeviceStr:(NSString *)deviceToken;

/**
 * 注销设备，设备不再进行推送
 * @param none
 * @return none
 */
+(void)unRegisterDevice;

//注销设备，支持回调版本
+(void)unRegisterDevice:(void (^)(void)) successCallback errorCallback:(void (^)(void)) errorCallback;

/**
 * 设置tag
 * @param tag - 需要设置的tag
 * @return none
 */
+(void)setTag:(NSString *)tag;

//设置tag，支持回调版本
+(void)setTag:(NSString *)tag successCallback:(void (^)(void)) successCallback errorCallback:(void (^)(void)) errorCallback;

/**
 * 删除tag
 * @param tag - 需要删除的tag
 * @return none
 */
+(void)delTag:(NSString *)tag;

//删除tag，支持回调版本
+(void)delTag:(NSString *)tag successCallback:(void (^)(void)) successCallback errorCallback:(void (^)(void)) errorCallback;

/**
 * 在didReceiveRemoteNotification中调用，用于推送反馈。(app在运行时)
 * @param userInfo 苹果apns的推送信息
 * @return none
 */
+(void)handleReceiveNotification:(NSDictionary *)userInfo;

//信鸽Pro专用接口
+(void)handleReceiveNotification:(NSDictionary *)userInfo completion:(void (^)(void)) completion;

//推送反馈(app在运行时),支持回调版本
+(void)handleReceiveNotification:(NSDictionary *)userInfo successCallback:(void (^)(void)) successCallback errorCallback:(void (^)(void)) errorCallback completion:(void (^)(void)) completion;

/**
 * 在didFinishLaunchingWithOptions中调用，用于推送反馈.(app没有运行时，点击推送启动时)
 * @param userInfo
 * @return none
 */
+(void)handleLaunching:(NSDictionary *)launchOptions;

//推送反馈.(app没有运行时，点击推送启动时),支持回调版本
+(void)handleLaunching:(NSDictionary *)launchOptions successCallback:(void (^)(void)) successCallback errorCallback:(void (^)(void)) errorCallback;

/**
 * 获取userInfo里的bid信息(bid:信鸽的推送消息id)
 * @param userInfo 苹果apns的推送信息
 * @return none
 */
+(NSString *)getBid:(NSDictionary *)userInfo;

/**
 * deviceToken类型转换
 * @param deviceToken NSData格式的deviceToken
 * @return none
 */
+(NSString *)getDeviceToken:(NSData *)deviceToken;

/**
 * 获取本地缓存的deviceToken
 * @param none
 * @return 信鸽启动时填入的的accessID
 */
+(uint32_t)getAccessID;

/**************************
 以下是本地推送相关
**************************/

/**
 * 本地推送，最多支持64个
 * @param fireDate 本地推送触发的时间
 * @param alertBody 推送的内容
 * @param badge 角标的数字。如果不改变，则传递 -1
 * @param alertAction 替换弹框的按钮文字内容（默认为"启动"）
 * @param userInfo 自定义参数，可以用来标识推送和增加附加信息
 * @return none
 */
+(void)localNotification:(NSDate *)fireDate alertBody:(NSString *)alertBody badge:(int)badge alertAction:(NSString *)alertAction userInfo:(NSDictionary *)userInfo;

/**
 * 本地推送在前台推送。默认App在前台运行时不会进行弹窗，通过此接口可实现指定的推送弹窗。
 * @param notification 本地推送对象
 * @param userInfoKey 本地推送的标识Key
 * @param userInfoValue 本地推送的标识Key对应的值
 * @return none
 */
+(void)localNotificationAtFrontEnd:(UILocalNotification *)notification userInfoKey:(NSString *)userInfoKey userInfoValue:(NSString *)userInfoValue;

/**
 * 删除本地推送，方法1
 * @param userInfoKey 本地推送的标识Key
 * @param userInfoValue 本地推送的标识Key对应的值
 * @return none
 */
+(void)delLocalNotification:(NSString *)userInfoKey userInfoValue:(NSString *)userInfoValue;

/**
 * 删除本地推送，方法2
 * @param myUILocalNotification 本地推送对象
 * @return none
 */
+(void)delLocalNotification:(UILocalNotification *)myUILocalNotification;

/**
 * 清除所有本地推送对象
 * @param none
 * @return none
 */
+(void)clearLocalNotifications;

@end