//
//  AliPayManager.m
//  RNArenaPay
//
//  Created by 丁乐 on 2019/1/16.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "AliPayManager.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AliPayManager ()

@property (nonatomic,strong)NSDictionary *data;

//  成功的回调
@property (nonatomic,copy)RCTPromiseResolveBlock success;

//  失败的回调
@property (nonatomic,copy)RCTPromiseRejectBlock faild;

@end

@implementation AliPayManager

static AliPayManager *instance = nil;

+(instancetype)shareInstance{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[AliPayManager alloc]init];
        }
    }
    return instance;
}



+(BOOL)applicationOpenUrl:(NSURL *)url{
    
    if ([url.host isEqualToString:@"safepay"]) {
        
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            [AliPayManager shareInstance].success(resultDic);
        }];
    }
    return YES;
}


-(void)alipay:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild{
    
    self.data = data;
    self.success = success;
    self.faild = faild;
    
    // 将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = [data objectForKey:@"payInfo"];
    
    NSString *appScheme = @"arenaAlipay";
    
    if (orderString == nil || appScheme == nil) {
        self.faild(@"缺少参数", @"缺少参数", nil);

        return;
    }
    
    //日志输出
    
    [[AlipaySDK defaultService] payOrder:orderString
                              fromScheme:appScheme
                                callback:^(NSDictionary *resultDict) {
                                    
                                    NSString *resultStr = [(NSString *)resultDict[@"resultStatus"]  isEqual: @"9000"] ? @"success" : @"failed";
                                    
                                    self.success(resultStr);
                                }
     ];
}


@end
