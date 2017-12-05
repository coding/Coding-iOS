//
//  AlipaySDK.h
//  AlipaySDK
//
//  Created by alipay on 16-12-12.
//  Copyright (c) 2016年 Alipay. All rights reserved.
//


////////////////////////////////////////////////////////
///////////////// 支付宝标准版本支付SDK ///////////////////
/////////// version:15.3.3  motify:2017.03.07 ///////////
////////////////////////////////////////////////////////


#import "APayAuthInfo.h"
typedef enum {
    ALIPAY_TIDFACTOR_IMEI,
    ALIPAY_TIDFACTOR_IMSI,
    ALIPAY_TIDFACTOR_TID,
    ALIPAY_TIDFACTOR_CLIENTKEY,
    ALIPAY_TIDFACTOR_VIMEI,
    ALIPAY_TIDFACTOR_VIMSI,
    ALIPAY_TIDFACTOR_CLIENTID,
    ALIPAY_TIDFACTOR_APDID,
    ALIPAY_TIDFACTOR_MAX
} AlipayTidFactor;

typedef void(^CompletionBlock)(NSDictionary *resultDic);

@interface AlipaySDK : NSObject

/**
 *  创建支付单例服务
 *
 *  @return 返回单例对象
 */
+ (AlipaySDK *)defaultService;

/**
 *  用于设置SDK使用的window，如果没有自行创建window无需设置此接口
 */
@property (nonatomic, weak) UIWindow *targetWindow;

/**
 *  支付接口
 *
 *  @param orderStr       订单信息
 *  @param schemeStr      调用支付的app注册在info.plist中的scheme
 *  @param compltionBlock 支付结果回调Block，用于wap支付结果回调（非跳转钱包支付）
 */
- (void)payOrder:(NSString *)orderStr
      fromScheme:(NSString *)schemeStr
        callback:(CompletionBlock)completionBlock;

/**
 *  处理钱包或者独立快捷app支付跳回商户app携带的支付结果Url
 *
 *  @param resultUrl        支付结果url
 *  @param completionBlock  支付结果回调
 */
- (void)processOrderWithPaymentResult:(NSURL *)resultUrl
                      standbyCallback:(CompletionBlock)completionBlock;



/**
 *  获取交易token。
 *
 *  @return 交易token，若无则为空。
 */
- (NSString *)fetchTradeToken;

/**
 *  是否已经使用过
 *
 *  @return YES为已经使用过，NO反之
 */
- (BOOL)isLogined;

/**
 *  获取当前版本号
 *
 *  @return 当前版本字符串
 */
- (NSString *)currentVersion;

/**
 *  获取当前tid相关信息
 *
 *  @return tid相关信息
 */
- (NSString*)queryTidFactor:(AlipayTidFactor)factor;

/**
 *  測試所用，realse包无效
 *
 *  @param url  测试环境
 */
- (void)setUrl:(NSString *)url;


//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////h5 拦截支付入口///////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  从h5链接中获取订单串接口
 *
 *  @param urlStr     拦截的 url string
 *
 *  @return 获取到的url order info
 */
- (NSString*)fetchOrderInfoFromH5PayUrl:(NSString*)urlStr;


/**
 *  h5链接获取到的订单串支付接口
 *
 *  @param orderStr       订单信息
 *  @param schemeStr      调用支付的app注册在info.plist中的scheme
 *  @param compltionBlock 支付结果回调Block
 */
- (void)payUrlOrder:(NSString *)orderStr
         fromScheme:(NSString *)schemeStr
           callback:(CompletionBlock)completionBlock;


//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////授权1.0//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  快登授权
 *  @param authInfo         需授权信息
 *  @param completionBlock  授权结果回调，若在授权过程中，调用方应用被系统终止，则此block无效，
                            需要调用方在appDelegate中调用processAuthResult:standbyCallback:方法获取授权结果
 */
- (void)authWithInfo:(APayAuthInfo *)authInfo
             callback:(CompletionBlock)completionBlock;


/**
 *  处理授权信息Url
 *
 *  @param resultUrl        钱包返回的授权结果url
 *  @param completionBlock  授权结果回调
 */
- (void)processAuthResult:(NSURL *)resultUrl
          standbyCallback:(CompletionBlock)completionBlock;


//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////授权2.0//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  快登授权2.0
 *
 *  @param infoStr          授权请求信息字符串
 *  @param schemeStr        调用授权的app注册在info.plist中的scheme
 *  @param completionBlock  授权结果回调，若在授权过程中，调用方应用被系统终止，则此block无效，
                            需要调用方在appDelegate中调用processAuth_V2Result:standbyCallback:方法获取授权结果
 */
- (void)auth_V2WithInfo:(NSString *)infoStr
             fromScheme:(NSString *)schemeStr
               callback:(CompletionBlock)completionBlock;

/**
 *  处理授权信息Url
 *
 *  @param resultUrl        钱包返回的授权结果url
 *  @param completionBlock  授权结果回调
 */
- (void)processAuth_V2Result:(NSURL *)resultUrl
             standbyCallback:(CompletionBlock)completionBlock;

@end
