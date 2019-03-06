//
//  WXPayManager.h
//  RNArenaPay
//
//  Created by 丁乐 on 2019/1/17.
//  Copyright © 2019 Facebook. All rights reserved.
//
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif


#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface WXPayManager : NSObject

+(instancetype)shareInstance;

//  设置微信appKey
+(void)setWXAppKey:(NSString *)key;

//  应用间跳转调用
+(BOOL)applicationOpenUrl:(NSURL *)url;

// 微信支付
-(void)wxpay:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild;

//  微信登录
-(void)sendAuthRequestSuccess:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild;

// 分享文字
-(void)wxShareText:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild;

// 分享图片
-(void)wxShareImage:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild;

// 分享网页
-(void)wxShareUrl:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild;


// 分享小程序
-(void)wxShareMiniProgram:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild;

@end

NS_ASSUME_NONNULL_END
