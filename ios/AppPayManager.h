//
//  AppPayManager.h
//  RNArenaPay
//
//  Created by 丁乐 on 2019/1/15.
//  Copyright © 2019 Facebook. All rights reserved.
//


#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppPayManager : NSObject

+(instancetype)shareInstance;

-(void)buy:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild;

@end

NS_ASSUME_NONNULL_END
