//
//  WXPayManager.m
//  RNArenaPay
//
//  Created by 丁乐 on 2019/1/17.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "WXPayManager.h"
#import "WXApi.h"

@interface WXPayManager()<WXApiDelegate>

@property (nonatomic,strong)NSDictionary *data;

@property (nonatomic,copy)NSString *authState;

//  成功的回调
@property (nonatomic,copy)RCTPromiseResolveBlock success;

//  失败的回调
@property (nonatomic,copy)RCTPromiseRejectBlock faild;

@end


@implementation WXPayManager

static WXPayManager *instance = nil;

+(instancetype)shareInstance{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[WXPayManager alloc]init];
        }
    }
    return instance;
}

+(void)setWXAppKey:(NSString *)key{
    [WXApi registerApp:key];
}

+(BOOL)applicationOpenUrl:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:[self shareInstance]];
}


// 发起支付
-(void)wxpay:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild{
    
    self.success = success;
    self.faild = faild;
    self.data = data;
    
//    if ([WXApi isWXAppInstalled] == NO){
//        self.faild(@"未安装微信", @"未安装微信", nil);
//        return;
//    }
    
    //调起微信支付
    PayReq* req   = [[PayReq alloc] init];
    req.partnerId = [data objectForKey:@"partnerid"];
    req.prepayId  = [data objectForKey:@"prepayid"];
    req.nonceStr  = [data objectForKey:@"noncestr"];
    req.timeStamp = [[data objectForKey:@"timestamp"] intValue];
    req.package   = [data objectForKey:@"package"];
    req.sign      = [data objectForKey:@"sign"];
    
//    if (req.partnerId == nil || req.prepayId == nil || req.nonceStr == nil || req.package == nil || req.sign == nil) {
//
//        self.faild(@"参数错误", @"参数错误", nil);
//        return;
//    }
    
    //日志输出
//    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[data objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
    
    if([WXApi sendReq:req] == NO){
        self.faild(@"调起微信支付失败", @"调起微信支付失败", nil);
    }
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        
        switch (resp.errCode) {
            case WXSuccess:
                self.success(@"支付成功");
                break;
                
            case WXErrCodeUserCancel:
                self.faild(@"用户取消！", @"用户取消！", nil);
                break;
                
            default:
                self.faild(@"支付失败！", @"支付失败！", nil);
                break;
        }
        
    }else if ([resp isKindOfClass:[SendAuthResp class]]){
        //        微信登录
        SendAuthResp* authResp = (SendAuthResp*)resp;
        
        if (![authResp.state isEqualToString:self.authState]) {
            self.faild(@"登录失败！", @"登录失败！", nil);
            return;
        }
        
        switch (resp.errCode) {
            case WXSuccess:
                self.success(@{@"code":authResp.code,@"state":authResp.state});

                NSLog(@"RESP:code:%@,state:%@\n", authResp.code, authResp.state);
                
                break;
            case WXErrCodeAuthDeny:
                self.faild(@"授权失败！", @"授权失败！", nil);

                break;
            case WXErrCodeUserCancel:
                self.faild(@"用户取消！", @"用户取消！", nil);

            default:
                break;
        }
        
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]){
        //        分享结果回调
        switch (resp.errCode) {
            case WXSuccess:
                self.success(@"分享成功");
                break;
                
            default:
                self.faild(@"分享失败！", @"分享失败！", nil);
                break;
        }
    }
    
}

//  =============   SSO   =============
-(void)sendAuthRequestSuccess:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild{
    
    self.success = success;
    self.faild = faild;
    
    NSString *state = [self randomKey];
    self.authState = state;
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc ] init ];
    req.scope = @"snsapi_userinfo" ;
    req.state = state ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    if([WXApi sendReq:req] == NO){
        faild(@"请先安装微信",@"请先安装微信",NULL);
    }
}

- (NSString *)randomKey {
    /* Get Random UUID */
    NSString *UUIDString;
    CFUUIDRef UUIDRef = CFUUIDCreate(NULL);
    CFStringRef UUIDStringRef = CFUUIDCreateString(NULL, UUIDRef);
    UUIDString = (NSString *)CFBridgingRelease(UUIDStringRef);
    CFRelease(UUIDRef);
    /* Get Time */
    double time = CFAbsoluteTimeGetCurrent();
    /* MD5 With Sale */
    return [NSString stringWithFormat:@"%@%f", UUIDString, time];
}


///   ==============   分享   =================

// 分享文字
-(void)wxShareText:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild{
    
    self.success = success;
    self.faild = faild;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = [data objectForKey:@"text"];
    req.scene = [[data objectForKey:@"scene"] intValue];
    [WXApi sendReq:req];
}

// 分享图片
-(void)wxShareImage:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild{
    
    self.success = success;
    self.faild = faild;
    
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = [NSData dataWithContentsOfFile:[data objectForKey:@"imageFile"]];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.mediaObject = imageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [[data objectForKey:@"scene"] intValue];
    [WXApi sendReq:req];
}

// 分享网页
-(void)wxShareUrl:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild{
    
    self.success = success;
    self.faild = faild;
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = [data objectForKey:@"webpageUrl"];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [data objectForKey:@"title"];
    message.description = [data objectForKey:@"description"];
    
    NSData *imageData = [self getUrlData:data[@"thumbImageUrl"]];
    [message setThumbImage:[UIImage imageWithData:imageData]];
    message.mediaObject = webpageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [[data objectForKey:@"scene"] intValue];
    [WXApi sendReq:req];
}



// 分享小程序
-(void)wxShareMiniProgram:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild{
    
    self.success = success;
    self.faild = faild;
    
    WXMiniProgramObject *object = [WXMiniProgramObject object];
    object.webpageUrl = [data objectForKey:@"webpageUrl"];
    object.userName = [data objectForKey:@"userName"];
    object.path = [data objectForKey:@"path"];
    //    小程序新版本的预览图
    object.hdImageData = [self getUrlData:data[@"thumbImageUrl"]];
    object.withShareTicket = YES;
//    正式版: WXMiniProgramTypeRelease;
//    测试版: WXMiniProgramTypeTest;
//    体验版: WXMiniProgramTypePreview;
    object.miniProgramType = [[data objectForKey:@"miniProgramType"] integerValue];
       
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [data objectForKey:@"title"];
    message.description = [data objectForKey:@"description"];
    
    //兼容旧版本节点的图片，小于32KB，新版本优先
    //使用WXMiniProgramObject的hdImageData属性
    message.thumbData = nil;
    message.mediaObject = object;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession; //目前只支持会话
    [WXApi sendReq:req];
}



/**
 获得对应图片url的数据
 */
-(NSData *)getUrlData:(NSString *)urlStr{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}

@end
