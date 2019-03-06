//
//  AliPayManager.h
//  RNArenaPay
//
//  Created by 丁乐 on 2019/1/16.
//  Copyright © 2019 Facebook. All rights reserved.
//

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface AliPayManager : NSObject

+(instancetype)shareInstance;


+(BOOL)applicationOpenUrl:(NSURL *)url;

-(void)alipay:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild;

@end

NS_ASSUME_NONNULL_END
