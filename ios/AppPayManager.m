//
//  AppPayManager.m
//  RNArenaPay
//
//  Created by 丁乐 on 2019/1/15.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "AppPayManager.h"
#import <StoreKit/StoreKit.h>

@interface AppPayManager ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property(nonatomic,copy)NSString * productId;

@property(nonatomic,copy)NSString * gatewayNo;

//  支付数据
@property (nonatomic,strong)NSDictionary *payData;

//  成功的回调
@property (nonatomic,copy)RCTPromiseResolveBlock success;

//  失败的回调
@property (nonatomic,copy)RCTPromiseRejectBlock faild;

@end

@implementation AppPayManager

static AppPayManager *instance;

+(instancetype)shareInstance
{
    if (instance == nil) {
        instance = [AppPayManager new];
    }
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

//  购买
-(void)buy:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild{
    
    self.success = success;
    self.faild = faild;
    self.payData = data;
    
    NSString *_pid = data[@"productId"];
    NSString *_gatewayNo = data[@"gatewayNo"];
    
    if (_pid != nil && _gatewayNo != nil) {
        self.productId = _pid;
        self.gatewayNo = _gatewayNo;
        
        if ([SKPaymentQueue canMakePayments]) {
            // 去苹果后台请求商品信息 ，需要商品的id（我们自己在苹果后台定义的那个id）
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:_pid]];
            
            request.delegate = self;
            
            [request start];
            
        }else {
            faild(@"不允许applePay",@"不允许applePay",nil);
        }
        
    } else {
        faild(@"缺少参数",@"缺少参数",nil);
    }
}


#pragma -mark 查询商品代理方法
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (response.products.count > 0) {
        self.faild(@"无此商品", @"无此商品", nil);
    }
    
    for (SKProduct *pro in response.products) {
        if ([pro.productIdentifier isEqualToString:self.productId]) {
            
            // 1.创建票据
            SKPayment *payment = [SKPayment paymentWithProduct:pro];
            // 2.将票据加入到交易队列中
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            return;
        }
    }
}

-(void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"获取应用内支付商品信息结束");
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    self.faild(@"获取商品信息失败", @"获取商品信息失败", error);
}

#pragma -mark 支付结果代理方法
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            //                支付成功
            case SKPaymentTransactionStatePurchased:
                // 去验证
                [self completeTransaction:tran];
                
                //验证成功与否,咱们都注销交易,否则会出现虚假凭证信息一直验证不通过..每次进程序都得输入苹果账号的情况
                [[SKPaymentQueue  defaultQueue] finishTransaction:tran];
                break;
                
            case SKPaymentTransactionStateFailed:
                
                self.faild(@"购买失败", @"购买失败", nil);
                
                //验证成功与否,咱们都注销交易,否则会出现虚假凭证信息一直验证不通过..每次进程序都得输入苹果账号的情况
                [[SKPaymentQueue  defaultQueue] finishTransaction:tran];
                break;
                
            case SKPaymentTransactionStateRestored:
                // 去验证
                self.faild(@"已经购买过，不能重复购买！", @"已经购买过，不能重复购买！", nil);
                
                //验证成功与否,咱们都注销交易,否则会出现虚假凭证信息一直验证不通过..每次进程序都得输入苹果账号的情况
                [[SKPaymentQueue  defaultQueue] finishTransaction:tran];
                break;
                
            case SKPaymentTransactionStatePurchasing:
                // 购买中...
                NSLog(@"购买中...");
                break;
                
            case SKPaymentTransactionStateDeferred:
                // 购买中...
                NSLog(@"等待操作,最终状态未定");
                break;
                
            default:
                break;
        }
    }
}

-(void)completeTransaction:(SKPaymentTransaction *)tran{
    
    NSURL *url = [NSBundle mainBundle].appStoreReceiptURL;
    
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:url.path];
    if (exist) {
        NSData *storeData = [[NSData alloc]initWithContentsOfURL:url];
        
        NSString *storeStr = [storeData base64EncodedStringWithOptions:0];
        
        self.success(storeStr);
        
    }else{
        self.faild(@"支付成功，但交易无法验证，请联系管理员", @"支付成功，但交易无法验证，请联系管理员", nil);
    }
}



@end
