//
//  UMessage.h
//  UMessage
//
//  Created by luyiyuan on 10/8/13.
//  Copyright (c) 2013 umeng.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



/** String type for alias
 */
//新浪微博
UIKIT_EXTERN NSString *const kUMessageAliasTypeSina;
//腾讯微博
UIKIT_EXTERN NSString *const kUMessageAliasTypeTencent;
//QQ
UIKIT_EXTERN NSString *const kUMessageAliasTypeQQ;
//微信
UIKIT_EXTERN NSString *const kUMessageAliasTypeWeiXin;
//百度
UIKIT_EXTERN NSString *const kUMessageAliasTypeBaidu;
//人人网
UIKIT_EXTERN NSString *const kUMessageAliasTypeRenRen;
//开心网
UIKIT_EXTERN NSString *const kUMessageAliasTypeKaixin;
//豆瓣
UIKIT_EXTERN NSString *const kUMessageAliasTypeDouban;
//facebook
UIKIT_EXTERN NSString *const kUMessageAliasTypeFacebook;
//twitter
UIKIT_EXTERN NSString *const kUMessageAliasTypeTwitter;


//error for handle
extern NSString * const kUMessageErrorDomain;

typedef NS_ENUM(NSInteger, kUMessageError) {
    /**未知错误*/
    kUMessageErrorUnknown = 0,
    /**响应出错*/
    kUMessageErrorResponseErr = 1,
    /**操作失败*/
    kUMessageErrorOperateErr = 2,
    /**参数非法*/
    kUMessageErrorParamErr = 3,
    /**条件不足(如:还未获取device_token，添加tag是不成功的)*/
    kUMessageErrorDependsErr = 4,
    /**服务器限定操作*/
    kUMessageErrorServerSetErr = 5,
};


@class CLLocation;

/** UMessage：开发者使用主类（API）
 */
@interface UMessage : NSObject


///---------------------------------------------------------------------------------------
/// @name settings（most required）
///---------------------------------------------------------------------------------------

//--required

/** 绑定App的appKey和启动参数，启动消息参数用于处理用户通过消息打开应用相关信息
 @param appKey      主站生成appKey
 @param launchOptions 启动参数
 */
+ (void)startWithAppkey:(NSString *)appKey launchOptions:(NSDictionary *)launchOptions;

/** 注册RemoteNotification的类型
 @brief 开启消息推送，实际调用：[[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
 @warning 此接口只针对 iOS 7及其以下的版本，iOS 8 请使用 `registerRemoteNotificationAndUserNotificationSettings`
 @param types 消息类型，参见`UIRemoteNotificationType`
 */
+ (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types NS_DEPRECATED_IOS(3_0, 8_0, "Please use registerRemoteNotificationAndUserNotificationSettings instead");

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
/** 注册RemoteNotification的类型
 @brief 开启消息推送，实际调用：[[UIApplication sharedApplication] registerForRemoteNotifications]和registerUserNotificationSettings;
 @warning 此接口只针对 iOS 8及其以上的版本，iOS 7 请使用 `registerForRemoteNotificationTypes`
 @param types 消息类型，参见`UIRemoteNotificationType`
 */
+ (void)registerRemoteNotificationAndUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings NS_AVAILABLE_IOS(8_0);
#endif

/** 解除RemoteNotification的注册（关闭消息推送，实际调用：[[UIApplication sharedApplication] unregisterForRemoteNotifications]）
 @param types 消息类型，参见`UIRemoteNotificationType`
 */
+ (void)unregisterForRemoteNotifications;

/** 向友盟注册该设备的deviceToken，便于发送Push消息
 @param deviceToken APNs返回的deviceToken
 */
+ (void)registerDeviceToken:(NSData *)deviceToken;

/** 应用处于运行时（前台、后台）的消息处理
 @param userInfo 消息参数
 */
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

//--optional

/** 开发者自行传入location
 @param location 当前location信息
 */
+ (void)setLocation:(CLLocation *)location;

/** 设置应用的日志输出的开关（默认关闭）
 @param value 是否开启标志，注意App发布时请关闭日志输出
 */
+ (void)setLogEnabled:(BOOL)value;

/** 设置是否允许SDK自动清空角标（默认开启）
 @param value 是否开启角标清空
 */
+ (void)setBadgeClear:(BOOL)value;

/** 设置是否允许SDK当应用在前台运行收到Push时弹出Alert框（默认开启）
 @warning 建议不要关闭，否则会丢失程序在前台收到的Push的点击统计,如果定制了 Alert，可以使用`sendClickReportForRemoteNotification`补发 log
 @param value 是否开启弹出框
 */
+ (void)setAutoAlert:(BOOL)value;

/** 设置App的发布渠道（默认为:"App Store"）
 @param channel 渠道名称
 */
+ (void)setChannel:(NSString *)channel;

/** 为某个消息发送点击事件
 @warning 请注意不要对同一个消息重复调用此方法，可能导致你的消息打开率飚升，此方法只在需要定制 Alert 框时调用
 @param userInfo 消息体的NSDictionary，此Dictionary是
        (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo中的userInfo
 */
+ (void)sendClickReportForRemoteNotification:(NSDictionary *)userInfo;


///---------------------------------------------------------------------------------------
/// @name tag (optional)
///---------------------------------------------------------------------------------------


/** 获取当前绑定设备上的所有tag(每台设备最多绑定64个tag)
 @warning 获取列表的先决条件是已经成功获取到device_token，否则失败(kUMessageErrorDependsErr)
 @param handle responseTags为绑定的tag
 集合,remain剩余可用的tag数,为-1时表示异常,error为获取失败时的信息(ErrCode:kUMessageError)
 */
+ (void)getTags:(void (^)(NSSet *responseTags,NSInteger remain,NSError *error))handle;

/** 绑定一个或多个tag至设备，每台设备最多绑定64个tag，超过64个，绑定tag不再成功，可`removeTag`或者`removeAllTags`来精简空间
 @warning 添加tag的先决条件是已经成功获取到device_token，否则直接添加失败(kUMessageErrorDependsErr)
 @param tag tag标记,可以为单个tag（NSString）也可以为tag集合（NSArray、NSSet），单个tag最大允许长度50字节，编码UTF-8，超过长度自动截取
 @param handle responseTags为绑定的tag集合,remain剩余可用的tag数,为-1时表示异常,error为获取失败时的信息(ErrCode:kUMessageError)
 */
+ (void)addTag:(id)tag response:(void (^)(id responseObject,NSInteger remain,NSError *error))handle;

/** 删除设备中绑定的一个或多个tag
 @warning 添加tag的先决条件是已经成功获取到device_token，否则失败(kUMessageErrorDependsErr)
 @param tag tag标记,可以为单个tag（NSString）也可以为tag集合（NSArray、NSSet），单个tag最大允许长度50字节，编码UTF-8，超过长度自动截取
 @param handle responseTags为绑定的tag集合,remain剩余可用的tag数,为-1时表示异常,error为获取失败时的信息(ErrCode:kUMessageError)
 */
+ (void)removeTag:(id)tag response:(void (^)(id responseObject,NSInteger remain,NSError *error))handle;

/** 删除设备中所有绑定的tag,handle responseObject
 @warning 删除tag的先决条件是已经成功获取到device_token，否则失败(kUMessageErrorDependsErr)
 @param handle responseTags为绑定的tag集合,remain剩余可用的tag数,为-1时表示异常,error为获取失败时的信息(ErrCode:kUMessageError)
 */
+ (void)removeAllTags:(void (^)(id responseObject,NSInteger remain,NSError *error))handle;


///---------------------------------------------------------------------------------------
/// @name alias (optional)
///---------------------------------------------------------------------------------------


/** 绑定一个别名至设备（含账户，和平台类型）
 @warning 添加Alias的先决条件是已经成功获取到device_token，否则失败(kUMessageErrorDependsErr)
 @param name 账户，例如email
 @param type 平台类型，参见本文件头部的`kUMessageAliasType...`，例如：kUMessageAliasTypeSina
 @param handle block返回数据，error为获取失败时的信息，responseObject为成功返回的数据
 */
+ (void)addAlias:(NSString *)name type:(NSString *)type response:(void (^)(id responseObject,NSError *error))handle;

/** 删除一个设备的别名绑定
 @warning 删除Alias的先决条件是已经成功获取到device_token，否则失败(kUMessageErrorDependsErr)
 @param name 账户，例如email
 @param type 平台类型，参见本文件头部的`kUMessageAliasType...`，例如：kUMessageAliasTypeSina
 @param handle block返回数据，error为获取失败时的信息，responseObject为成功返回的数据
 */
+ (void)removeAlias:(NSString *)name type:(NSString *)type response:(void (^)(id responseObject,NSError *error))handle;

@end
