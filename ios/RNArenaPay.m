
#import "RNArenaPay.h"

@implementation RNArenaPay

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

/**
 支付宝支付

 @param NSDictionary 支付数据
 @success 成功的回调
 @faild 失败的回调
 */
RCT_EXPORT_METHOD(aliPay:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild)
{
    [[AliPayManager shareInstance] alipay:data success:success faild:faild];
}



/**
 微信注册 appKey
 
 @param NSString appId
 */
RCT_EXPORT_METHOD(wechatRegister:(NSString *)appKey)
{
    [WXPayManager setWXAppKey:appKey];
}



/**
 微信支付
 
 @param NSDictionary 支付数据
 @success 成功的回调
 @faild 失败的回调
 */
RCT_EXPORT_METHOD(wechatPay:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild)
{
    [[WXPayManager shareInstance] wxpay:data success:success faild:faild];
}


/**
 微信登录
 
 @success 成功的回调
 @faild 失败的回调
 */
RCT_EXPORT_METHOD(wechatLogin:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild)
{
    [[WXPayManager shareInstance] sendAuthRequestSuccess:success faild:faild];
}


/**
 app内购
 
 @param NSDictionary 支付数据
 @success 成功的回调
 @faild 失败的回调
 */
RCT_EXPORT_METHOD(appPay:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild)
{
    [[AppPayManager shareInstance] buy:data success:success faild:faild];
}


/**
 分享文字
 
 @param NSDictionary 数据
 @success 成功的回调
 @faild 失败的回调
 */
RCT_EXPORT_METHOD(wxShareText:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild)
{
    [[WXPayManager shareInstance] wxShareText:data success:success faild:faild];
}

/**
 分享图片
 
 @param NSDictionary 数据
 @success 成功的回调
 @faild 失败的回调
 */
RCT_EXPORT_METHOD(wxShareImage:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild)
{
    [[WXPayManager shareInstance] wxShareImage:data success:success faild:faild];
}


/**
 分享网页
 
 @param NSDictionary 数据
 @success 成功的回调
 @faild 失败的回调
 */
RCT_EXPORT_METHOD(wxShareUrl:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild)
{
    [[WXPayManager shareInstance] wxShareUrl:data success:success faild:faild];
}


/**
 分享小程序
 
 @param NSDictionary 数据
 @success 成功的回调
 @faild 失败的回调
 */
RCT_EXPORT_METHOD(wxShareMiniProgram:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild)
{
    [[WXPayManager shareInstance] wxShareMiniProgram:data success:success faild:faild];
}



@end
  
