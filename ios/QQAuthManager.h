//
//  QQAuthManager.h
//  RNArenaPay
//
//  Created by 丁乐 on 2020/3/1.
//  Copyright © 2020 Facebook. All rights reserved.
//

//#if __has_include("RCTBridgeModule.h")
//#import "RCTBridgeModule.h"
//#else
//#import <React/RCTBridgeModule.h>
//#endif

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif


#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>

NS_ASSUME_NONNULL_BEGIN

@interface QQAuthManager : NSObject



+(instancetype)shareInstance;

//  设置QQ的appId
-(void)setQQAppId:(NSString *)key;

//  QQ 登录
-(void)QQLogin:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild;

@end

NS_ASSUME_NONNULL_END
